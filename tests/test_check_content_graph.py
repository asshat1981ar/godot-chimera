"""Tests for scripts/check_content_graph.py: clean on real data, red on seeded breakage.

Run: python3 -I -m unittest discover -s tests -v   (from the repo root)
"""
import json
import os
import shutil
import subprocess
import sys
import tempfile
import unittest

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SCRIPT = os.path.join(ROOT, "scripts", "check_content_graph.py")
DATA = os.path.join(ROOT, "data")


def run(data_dir):
    p = subprocess.run([sys.executable, "-I", SCRIPT, data_dir],
                       capture_output=True, text=True, check=False)
    return p.returncode, p.stdout


class ContentGraphTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.mkdtemp()
        self.d = os.path.join(self.tmp, "data")
        shutil.copytree(DATA, self.d)
        self.addCleanup(shutil.rmtree, self.tmp, True)

    def edit(self, name, fn):
        path = os.path.join(self.d, name)
        with open(path, encoding="utf-8") as fh:
            doc = json.load(fh)
        fn(doc)
        with open(path, "w", encoding="utf-8") as fh:
            json.dump(doc, fh)

    def assert_fails(self, needle):
        rc, out = run(self.d)
        self.assertEqual(rc, 1, out)
        self.assertIn(needle, out)

    def first_choice(self, doc):
        tree = next(iter(doc["trees"].values()))
        return next(c for n in tree["nodes"].values() for c in n["choices"])

    def test_current_data_is_clean(self):
        rc, out = run(DATA)
        self.assertEqual(rc, 0, out)

    def test_missing_dir_is_error(self):
        rc, _ = run(os.path.join(self.tmp, "nope"))
        self.assertEqual(rc, 2)

    def test_duplicate_npc_id(self):
        self.edit("npcs.json", lambda d: d.append(dict(d[0])))
        self.assert_fails("duplicate npc id")

    def test_duplicate_scene_id(self):
        self.edit("act1_scenes.json", lambda d: d.append(dict(d[0])))
        self.assert_fails("duplicate scene id")

    def test_invalid_choice_type(self):
        self.edit("dialogue_trees.json",
                  lambda d: self.first_choice(d).update(choiceType="shout"))
        self.assert_fails("invalid choiceType 'shout'")

    def test_broken_next_node(self):
        self.edit("dialogue_trees.json",
                  lambda d: self.first_choice(d).update(nextNodeId="no_such_node"))
        self.assert_fails("unknown node 'no_such_node'")

    def test_scene_unknown_npc(self):
        self.edit("act1_scenes.json", lambda d: d[0].update(npcId="ghost"))
        self.assert_fails("unknown npc 'ghost'")

    def test_map_unknown_scene(self):
        self.edit("act1_map.json", lambda d: d[0].update(sceneId="ghost_scene"))
        self.assert_fails("unknown scene 'ghost_scene'")

    def test_map_unknown_connection(self):
        self.edit("act1_map.json", lambda d: d[0]["connectedTo"].append("nowhere"))
        self.assert_fails("unknown map node 'nowhere'")

    def test_unreachable_map_node(self):
        def f(d):
            d.append({"id": "island", "sceneId": "", "connectedTo": [], "isUnlocked": False})
        self.edit("act1_map.json", f)
        self.assert_fails("not reachable")

    def test_quest_unknown_item_reward(self):
        def f(d):
            q = next(q for q in d if q["rewards"]["items"])
            q["rewards"]["items"][0]["itemId"] = "ghost_item"
        self.edit("quests.json", f)
        self.assert_fails("unknown item 'ghost_item'")

    def test_quest_unknown_scene_objective(self):
        def f(d):
            o = next(o for q in d for o in q["objectives"] if o["type"] == "scene")
            o["targetId"] = "ghost_scene"
        self.edit("quests.json", f)
        self.assert_fails("unknown scene 'ghost_scene'")

    def test_recipe_unknown_ingredient(self):
        def f(d):
            d[0]["ingredientsJson"] = json.dumps([{"itemId": "ghost_item", "quantity": 1}])
        self.edit("crafting_recipes.json", f)
        self.assert_fails("unknown item 'ghost_item'")

    def test_lore_unknown_scene(self):
        self.edit("lore_entries.json", lambda d: d[0].update(unlockedBySceneId="ghost_scene"))
        self.assert_fails("unknown scene 'ghost_scene'")

    def test_persona_missing(self):
        self.edit("npc_personas.json", lambda d: d.pop("warden"))
        self.assert_fails("has no persona")

    def test_malformed_json(self):
        with open(os.path.join(self.d, "items.json"), "w") as fh:
            fh.write("[{")
        self.assert_fails("unreadable JSON")


if __name__ == "__main__":
    unittest.main()
