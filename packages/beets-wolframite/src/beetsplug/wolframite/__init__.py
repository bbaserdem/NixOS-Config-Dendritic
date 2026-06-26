"""Wolframite beets plugin."""

from __future__ import annotations

from typing import Any, cast

from beets.library import Album
from beets.plugins import BeetsPlugin

from . import alternatives, fields, playlist, templates, translate


class WolframitePlugin(BeetsPlugin):
    """Personal beets plugin for Wolframite library conventions"""

    item_types = fields.ITEM_TYPES
    album_types = fields.ALBUM_TYPES

    def __init__(self) -> None:
        super().__init__()

        # Add our field translation functionality
        self.config.add({"field_translations": []})
        self.import_stages = [self._apply_field_translations]
        self._updated_alternatives: set[str] = set()
        self.register_listener(
            cast(Any, "alternatives.item_updated"),
            self._record_alternatives_update,
        )
        self.register_listener("cli_exit", self._sync_alternatives_playlists)
        self.register_listener("database_change", self._sync_album_fields_to_items)

        # Custom fields registered as tags
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
    def _apply_field_translations(self, session, task) -> None:
        translate.apply_field_translations(self, session, task)

    def _record_alternatives_update(self, collection: str, **_kwargs) -> None:
        self._updated_alternatives.add(collection)

    def _sync_alternatives_playlists(self, lib) -> None:
        alternatives.sync_updated_collections(self, lib, self._updated_alternatives)

    def _sync_album_fields_to_items(self, _lib, model) -> None:
        if not isinstance(model, Album):
            return
        fields.sync_album_fields_to_items(model, set(model._dirty))
