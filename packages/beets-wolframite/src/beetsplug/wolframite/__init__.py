"""Wolframite beets plugin."""

from __future__ import annotations

from typing import Any, cast

from beets import plugins as beets_plugins
from beets.plugins import BeetsPlugin

from . import alternatives, fields, playlist, templates, translate


class WolframitePlugin(BeetsPlugin):
    """Personal beets plugin for Wolframite library conventions"""

    item_types = fields.ITEM_TYPES
    album_types = fields.ALBUM_TYPES

    def __init__(self) -> None:
        super().__init__()

        # Add our field translation functionality
        self.config.add(
            {
                "field_translations": [],
                "rating_owner": "wolframite",
            }
        )
        self.import_stages = [
            self._finish_field_translations,
            self._sync_imported_album_fields,
        ]
        self._library_revision = None
        self._updated_alternatives: set[str] = set()
        self._playlists_changed = False
        self.register_listener(
            cast(Any, "alternatives.item_updated"),
            self._record_alternatives_update,
        )
        self.register_listener(
            cast(Any, "wolframite.item_fields_read"),
            self._sync_read_item_fields,
        )
        self.register_listener("import_begin", self._validate_field_translations)
        self.register_listener("import_task_choice", self._prepare_field_translations)
        self.register_listener("import_task_apply", self._reapply_field_translations)
        self.register_listener("import_task_files", self._write_imported_media)
        self.register_listener("library_opened", self._record_library_revision)
        self.register_listener("cli_exit", self._finalize_library)

        # Custom fields registered as tags
        fields.install_item_store_compatibility()
        fields.install_strict_media_writes()
        fields.install_album_field_writes()
        fields.install_file_authority_listeners()
        fields.install_file_authoritative_deletions()
        fields.install_reimport_fresh_fields()
        fields.register_media_fields(self)

        # Template fields
        self.template_fields["tracknumber"] = templates.tracknumber
        self.template_fields["trackdate"] = templates.date
        self.template_fields["artistinitial"] = templates.initial
        self.template_fields["division"] = templates.division
        # Album template fields
        self.album_template_fields["albumdate"] = templates.date
        self.album_template_fields["artistinitial"] = templates.initial
        self.album_template_fields["albumdivision"] = templates.division

        # Template functions
        self.template_funcs["tdot"] = templates.tdot

    # Custom workflow
    def commands(self):
        return [
            *playlist.commands(self),
            *fields.commands(),
        ]

    # The translation method
    def _prepare_field_translations(self, session, task) -> None:
        translate.prepare_field_translations(self, task)

    def _reapply_field_translations(self, session, task) -> None:
        translate.reapply_field_translations(self, task)

    def _finish_field_translations(self, session, task) -> None:
        translate.finish_field_translations(session, task)

    def _write_imported_media(self, session, task) -> None:
        translate.write_deferred_import_fields(session, task)

    def _validate_field_translations(self, session) -> None:
        translate.validate_config(self)

    def _sync_imported_album_fields(self, _session, task) -> None:
        if task.is_album and hasattr(task, "album"):
            fields.sync_item_fields_to_album(task.album)

    def _record_library_revision(self, lib) -> None:
        self._library_revision = lib.revision
        self._wrap_smartplaylist_updates()

    def _record_alternatives_update(self, collection: str, **_kwargs) -> None:
        self._updated_alternatives.add(collection)

    def _sync_read_item_fields(self, lib, item) -> None:
        if item.album_id is None:
            return
        album = lib.get_album(item.album_id)
        if album is not None:
            fields.sync_read_item_fields_to_album(album, item)

    def _finalize_library(self, lib) -> None:
        if self._library_revision is None:
            return

        if lib.revision != self._library_revision:
            for album in lib.albums():
                fields.sync_item_fields_to_album(album)
            playlist.generate_all_playlists(lib)
            self._playlists_changed = True
            if not self._smartplaylist_pretend():
                self._refresh_smartplaylists(lib)

        if self._playlists_changed:
            alternatives.sync_all_collections(self, lib)
        else:
            alternatives.sync_updated_collections(
                self,
                lib,
                self._updated_alternatives,
            )

        self._updated_alternatives.clear()
        self._playlists_changed = False
        self._library_revision = lib.revision

    @staticmethod
    def _refresh_smartplaylists(lib) -> None:
        for plugin in beets_plugins.find_plugins():
            if plugin.name != "smartplaylist" or not plugin.config["auto"].get(bool):
                continue

            smartplaylist = cast(Any, plugin)
            smartplaylist.build_queries()
            definitions = set(smartplaylist._unmatched_playlists)
            smartplaylist._matched_playlists = definitions
            smartplaylist._unmatched_playlists.clear()
            smartplaylist.update_playlists(lib)

    def _wrap_smartplaylist_updates(self) -> None:
        for plugin in beets_plugins.find_plugins():
            if plugin.name != "smartplaylist":
                continue

            smartplaylist = cast(Any, plugin)
            update = smartplaylist.update_playlists
            if getattr(update, "_wolframite_reconcile", False):
                continue

            def wrapped(lib, _update=update, _plugin=smartplaylist) -> None:
                definitions = set(_plugin._matched_playlists)
                configured_count = len(_plugin.config["playlists"].get(list))
                playlist.validate_smartplaylist_outputs(
                    _plugin,
                    lib,
                    definitions,
                )
                _update(lib)
                playlist.reconcile_smartplaylists(
                    _plugin,
                    lib,
                    definitions,
                    full_update=len(definitions) == configured_count,
                )
                if not _plugin.config["pretend"].get(bool):
                    self._playlists_changed = True

            setattr(wrapped, "_wolframite_reconcile", True)
            smartplaylist.update_playlists = wrapped

    @staticmethod
    def _smartplaylist_pretend() -> bool:
        return any(
            plugin.name == "smartplaylist"
            and plugin.config["pretend"].get(bool)
            for plugin in beets_plugins.find_plugins()
        )
