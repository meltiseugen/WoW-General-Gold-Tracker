import csv
import importlib.util
from pathlib import Path
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location("map_preview_data", ROOT / "tools/map_preview_data.py")
DATA = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(DATA)


class MapPreviewDataTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name)
        def write(name, columns, rows):
            with (self.path / f"{name}.csv").open("w", newline="", encoding="utf-8") as handle:
                writer = csv.writer(handle)
                writer.writerow(columns.split(",")); writer.writerows(rows)
        write("UiMap", "ID,Name_lang,Type,ParentUiMapID", [
            (1, "Geographic", 2, 0), (2, "Zone", 3, 1), (3, "Diagram", 2, 1),
            (4, "Diagram zone", 3, 3), (6, "Mixed", 2, 0), (7, "Inset", 3, 6),
            (8, "Cycle A", 3, 9), (9, "Cycle B", 3, 8)])
        write("UiMapXMapArt", "UiMapID,UiMapArtID,PhaseID", [(i, 10, 0) for i in (1, 2, 3, 4, 6, 7, 8, 9)])
        write("UiMapArt", "ID,UiMapArtStyleID", [(10, 1)])
        write("UiMapArtStyleLayer", "UiMapArtStyleID,LayerIndex,LayerWidth,LayerHeight,TileWidth,TileHeight", [(1, 0, 1000, 650, 256, 256)])
        write("UiMapArtTile", "UiMapArtID,LayerIndex,RowIndex,ColIndex,FileDataID", [(10, 0, 0, 0, 123)])
        write("WorldMapOverlay", "ID,UiMapArtID", [])
        write("WorldMapOverlayTile", "WorldMapOverlayID,LayerIndex,FileDataID", [])
        write("UiMapAssignment", "UiMapID,OrderIndex,MapID,UiMin_0,UiMin_1,UiMax_0,UiMax_1,Region_0,Region_1,Region_3,Region_4", [
            (1, 0, 7, 0, 0, 1, 1, 0, 0, 1000, 2000),
            (2, 0, 7, 0, 0, 1, 1, 400, 800, 800, 1600),
            (4, 0, 9, 0, 0, 1, 1, 0, 0, 100, 100),
            (6, 0, 8, .5, 0, 1, .5, 0, 0, 1000, 2000),
            (7, 0, 8, 0, 0, 1, 1, 0, 0, 1000, 2000)])
        write("UiMapLink", "ChildUiMapID,ParentUiMapID,PlayerConditionID,UiMin_0,UiMin_1,UiMax_0,UiMax_1", [
            (3, 1, 0, .6, .2, .9, .5), (4, 3, 0, .1, .2, .7, .8), (7, 1, 123, 0, 0, 1, 1)])
        self.maps = DATA.ClientMaps(self.path)

    def test_geographic_zone_coordinates_match_the_parent(self):
        self.assertEqual([.2, .6, .2, .6], self.maps.rect(2, 1))

    def test_diagram_links_compose_through_nested_continents(self):
        for actual, expected in zip(self.maps.rect(4, 1), [.63, .81, .26, .44]):
            self.assertAlmostEqual(expected, actual)
        self.assertEqual([0, 1, 0, 1], self.maps.rect(3, 3))

    def test_partial_assignments_preserve_surface_and_underground_placement(self):
        self.assertEqual({"worldID": 8, "w0": 4000, "w1": 0, "n0": 1000, "n1": -1000}, self.maps.world(6))
        self.assertEqual([.5, 1, 0, .5], self.maps.rect(7, 6))

    def test_unavailable_conditions_and_cycles_do_not_fabricate_placements(self):
        self.assertIsNone(self.maps.rect(7, 1))
        self.assertIsNone(self.maps.rect(8, 1))
        self.assertNotIn(8, self.maps.descendants(1))

    def test_diagram_fixtures_have_art_without_inventing_a_physical_world(self):
        fixture = self.maps.fixture(3)
        self.assertEqual({3, 4}, set(fixture))
        self.assertNotIn("worldID", fixture[3])
        self.assertEqual(9, fixture[4]["worldID"])
        self.assertEqual({123}, self.maps.texture_ids(fixture))


if __name__ == "__main__":
    unittest.main()
