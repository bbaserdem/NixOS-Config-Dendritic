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

        self.register_listener("album_imported", self._sync_imported_album_fields)
        self.register_listener(
            cast(Any, "alternatives.collection_updated"),
            self._sync_alternative_playlists,
        )

        fields.install_item_store_compatibility()
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

    def _sync_alternative_playlists(self, lib, collection: str, **_kwargs) -> None:
        alternatives.sync_collection_playlists(self, lib, collection)
