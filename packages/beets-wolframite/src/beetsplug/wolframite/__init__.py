"""Wolframite beets plugin."""

from __future__ import annotations

from typing import Any, cast

from beets.plugins import BeetsPlugin

from . import alternatives, fields, templates


class WolframitePlugin(BeetsPlugin):
    """Personal beets plugin for Wolframite library conventions."""

    item_types = fields.ITEM_TYPES
    album_types = fields.ALBUM_TYPES

    def __init__(self) -> None:
        super().__init__()

        self._library_revision = None
        self._updated_alternatives: set[str] = set()
        self.register_listener("album_imported", self._sync_imported_album_fields)
        self.register_listener("library_opened", self._record_library_revision)
        self.register_listener("cli_exit", self._sync_changed_album_fields)
        self.register_listener(
            cast(Any, "alternatives.collection_updated"),
            self._queue_alternative_playlists,
        )

        fields.install_store_compatibility()
        fields.register_media_fields(self)

        self.template_fields["tracknumber"] = templates.tracknumber
        self.template_fields["trackdate"] = templates.date
        self.template_fields["artistinitial"] = templates.initial
        self.template_fields["division"] = templates.division
        self.album_template_fields["albumdate"] = templates.date
        self.album_template_fields["artistinitial"] = templates.initial
        self.album_template_fields["albumdivision"] = templates.division
        self.template_funcs["tdot"] = templates.tdot

    def _sync_imported_album_fields(self, lib, album) -> None:
        fields.sync_item_fields_to_album(album)

    def _record_library_revision(self, lib) -> None:
        self._library_revision = lib.revision

    def _sync_changed_album_fields(self, lib) -> None:
        if self._library_revision is None or lib.revision == self._library_revision:
            return
        for album in lib.albums():
            fields.sync_item_fields_to_album(album)

    def _queue_alternative_playlists(self, collection: str, **_kwargs) -> None:
        self._updated_alternatives.add(collection)
        self.register_listener("cli_exit", self._sync_alternative_playlists)

    def _sync_alternative_playlists(self, lib) -> None:
        for collection in sorted(self._updated_alternatives):
            alternatives.sync_collection_playlists(self, lib, collection)
        self._updated_alternatives.clear()
