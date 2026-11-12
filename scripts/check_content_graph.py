#!/usr/bin/env python3
"""Deterministic content-graph checker for data/*.json (stdlib only).

Usage: python3 -I scripts/check_content_graph.py [DATA_DIR]   (default: data)

Checks: unique ids; every referenced id resolves (npc, map node, scene, quest,
dialogue tree/node, item, recipe, lore/reveal tag); choiceType in the CLAUDE.md
set; map reachability. Missing optional files are skipped. Exit 0 = clean,
1 = problems found, 2 = a file is unreadable or has an unexpected shape.
"""
import json
import os
import sys

CHOICE_TYPES = {"defer", "help", "threaten", "demand", "empathize", "vow",
                "lie", "conceal", "inquire"}
ACTS = (1, 2, 3)


class Graph:
    def __init__(self):
        self.errors = []

    def err(self, check, where, msg):
        self.errors.append(f"[{check}] {where}: {msg}")


def load(data_dir, name, g):
    path = os.path.join(data_dir, name)
    if not os.path.isfile(path):
        return None
    try:
        with open(path, encoding="utf-8") as fh:
            return json.load(fh)
    except (OSError, ValueError) as exc:
        g.err("parse", name, f"unreadable JSON ({exc})")
        return None


def as_list(v, name, g):
    if v is None:
        return []
    if not isinstance(v, list):
        g.err("shape", name, "expected a JSON array")
        return []
    return [x for x in v if isinstance(x, dict)]


def unique(g, kind, where, ids):
    seen = set()
    for i in ids:
        if not isinstance(i, str) or not i:
            g.err("id", where, f"missing or empty {kind} id")
        elif i in seen:
            g.err("unique-id", where, f"duplicate {kind} id '{i}'")
        seen.add(i)
    return seen


def check_ref(g, kind, where, value, valid, optional=True):
    if value in (None, ""):
        if not optional:
            g.err("ref", where, f"missing {kind} reference")
        return
    if value not in valid:
        g.err("ref", where, f"unknown {kind} '{value}'")


def check(data_dir):
    g = Graph()
    npcs = as_list(load(data_dir, "npcs.json", g), "npcs.json", g)
    personas = load(data_dir, "npc_personas.json", g)
    items = as_list(load(data_dir, "items.json", g), "items.json", g)
    lore = as_list(load(data_dir, "lore_entries.json", g), "lore_entries.json", g)
    recipes = as_list(load(data_dir, "crafting_recipes.json", g), "crafting_recipes.json", g)
    quests = as_list(load(data_dir, "quests.json", g), "quests.json", g)
    trees_doc = load(data_dir, "dialogue_trees.json", g)
    portraits = load(data_dir, "portrait_manifest.json", g)
    maps, scenes = [], []
    for a in ACTS:
        for n in as_list(load(data_dir, f"act{a}_map.json", g), f"act{a}_map.json", g):
            maps.append((a, n))
        for s in as_list(load(data_dir, f"act{a}_scenes.json", g), f"act{a}_scenes.json", g):
            scenes.append((a, s))

    npc_ids = unique(g, "npc", "npcs.json", [n.get("id") for n in npcs])
    item_ids = unique(g, "item", "items.json", [i.get("id") for i in items])
    unique(g, "lore", "lore_entries.json", [l.get("id") for l in lore])
    recipe_ids = unique(g, "recipe", "crafting_recipes.json", [r.get("id") for r in recipes])
    quest_ids = unique(g, "quest", "quests.json", [q.get("id") for q in quests])
    node_ids = unique(g, "map node", "act*_map.json", [n.get("id") for _, n in maps])
    scene_ids = unique(g, "scene", "act*_scenes.json", [s.get("sceneId") for _, s in scenes])

    # personas keyed by npc id
    persona_ids = set(personas) if isinstance(personas, dict) else set()
    if personas is not None and not isinstance(personas, dict):
        g.err("shape", "npc_personas.json", "expected a JSON object")
    if personas is not None:
        for nid in sorted(npc_ids - persona_ids):
            g.err("ref", "npc_personas.json", f"npc '{nid}' has no persona")
        for pid in sorted(persona_ids - npc_ids):
            g.err("ref", "npc_personas.json", f"persona '{pid}' has no npc in npcs.json")

    # lore / reveal tags
    reveal_tags = {l.get("revealTag") for l in lore if l.get("revealTag")}
    for l in lore:
        w = f"lore_entries.json:{l.get('id')}"
        check_ref(g, "scene", w + ".unlockedBySceneId", l.get("unlockedBySceneId"), scene_ids)
        check_ref(g, "npc", w + ".relatedNpcId", l.get("relatedNpcId"), npc_ids)

    # scenes
    for _, s in scenes:
        w = f"scene:{s.get('sceneId')}"
        check_ref(g, "npc", w + ".npcId", s.get("npcId"), npc_ids, optional=False)
        for r in s.get("allowedReveals") or []:
            reveal_tags.add(r)

    # map
    adj, unlocked = {}, set()
    for _, n in maps:
        w = f"map:{n.get('id')}"
        check_ref(g, "scene", w + ".sceneId", n.get("sceneId"), scene_ids)
        adj[n.get("id")] = list(n.get("connectedTo") or [])
        if n.get("isUnlocked"):
            unlocked.add(n.get("id"))
        for c in n.get("connectedTo") or []:
            check_ref(g, "map node", w + ".connectedTo", c, node_ids)
    # edges may be one-directional; treat as undirected for reachability
    und = {k: set(v) for k, v in adj.items()}
    for k, vs in adj.items():
        for v in vs:
            und.setdefault(v, set()).add(k)
    seen, stack = set(), list(unlocked)
    while stack:
        cur = stack.pop()
        if cur not in seen:
            seen.add(cur)
            stack.extend(und.get(cur, ()))
    for nid in sorted(x for x in node_ids if x not in seen):
        g.err("reachable", f"map:{nid}", "not reachable from any default-unlocked node")

    # dialogue trees
    trees = {}
    if trees_doc is not None:
        if isinstance(trees_doc, dict) and isinstance(trees_doc.get("trees"), dict):
            trees = trees_doc["trees"]
        else:
            g.err("shape", "dialogue_trees.json", "expected {version, trees: {}}")
    choice_ids = []
    for tkey, t in trees.items():
        if not isinstance(t, dict):
            g.err("shape", f"tree:{tkey}", "tree is not an object")
            continue
        w = f"tree:{tkey}"
        if t.get("id") != tkey:
            g.err("unique-id", w, f"tree id '{t.get('id')}' does not match key")
        check_ref(g, "npc", w + ".npcId", t.get("npcId"), npc_ids, optional=False)
        check_ref(g, "scene", w + ".sceneId", t.get("sceneId"), scene_ids)
        nodes = t.get("nodes") if isinstance(t.get("nodes"), dict) else {}
        if not nodes:
            g.err("shape", w, "tree has no nodes")
        check_ref(g, "node", w + ".startNodeId", t.get("startNodeId"), set(nodes), optional=False)
        for nkey, n in nodes.items():
            nw = f"{w}/{nkey}"
            if n.get("id") != nkey:
                g.err("unique-id", nw, f"node id '{n.get('id')}' does not match key")
            check_ref(g, "npc", nw + ".speaker", n.get("speaker"), npc_ids)
            for c in n.get("choices") or []:
                cw = f"{nw}/{c.get('id')}"
                choice_ids.append(c.get("id"))
                ct = c.get("choiceType")
                if ct not in CHOICE_TYPES:
                    g.err("choiceType", cw, f"invalid choiceType '{ct}'")
                check_ref(g, "node", cw + ".nextNodeId", c.get("nextNodeId"), set(nodes))
                eff = c.get("effects")
                if isinstance(eff, dict) and isinstance(eff.get("reveal"), str):
                    reveal_tags.add(eff["reveal"])
    unique(g, "choice", "dialogue_trees.json", choice_ids)

    # crafting
    for r in recipes:
        w = f"recipe:{r.get('id')}"
        check_ref(g, "item", w + ".resultItemId", r.get("resultItemId"), item_ids, optional=False)
        check_ref(g, "scene", w + ".requiredScene", r.get("requiredScene"), scene_ids)
        check_ref(g, "npc", w + ".requiredNpc", r.get("requiredNpc"), npc_ids)
        try:
            ings = json.loads(r.get("ingredientsJson") or "[]")
        except ValueError:
            g.err("shape", w, "ingredientsJson is not valid JSON")
            ings = []
        for ing in ings if isinstance(ings, list) else []:
            check_ref(g, "item", w + ".ingredients", ing.get("itemId") if isinstance(ing, dict) else None, item_ids, optional=False)

    # quests
    for q in quests:
        w = f"quest:{q.get('id')}"
        check_ref(g, "npc", w + ".giverNpcId", q.get("giverNpcId"), npc_ids)
        uc = q.get("unlockConditions") or {}
        for s in uc.get("completedScenes") or []:
            check_ref(g, "scene", w + ".unlockConditions.completedScenes", s, scene_ids)
        for k in uc.get("minDisposition") or {}:
            check_ref(g, "npc", w + ".unlockConditions.minDisposition", k, npc_ids)
        obj_ids = []
        for o in q.get("objectives") or []:
            ow = f"{w}/{o.get('id')}"
            obj_ids.append(o.get("id"))
            t, tid = o.get("type"), o.get("targetId")
            if t == "scene":
                check_ref(g, "scene", ow, tid, scene_ids, optional=False)
            elif t == "item":
                check_ref(g, "item", ow, tid, item_ids, optional=False)
            elif t == "visit_node":
                check_ref(g, "map node", ow, tid, node_ids, optional=False)
            elif t == "reveal":
                check_ref(g, "reveal tag", ow, tid, reveal_tags, optional=False)
            elif t == "duel":
                check_ref(g, "npc", ow, tid, npc_ids)
        unique(g, "objective", w, obj_ids)
        rw = q.get("rewards") or {}
        for k in rw.get("disposition") or {}:
            check_ref(g, "npc", w + ".rewards.disposition", k, npc_ids)
        for it in rw.get("items") or []:
            check_ref(g, "item", w + ".rewards.items", it.get("itemId") if isinstance(it, dict) else None, item_ids, optional=False)
        for r in rw.get("reveals") or []:
            check_ref(g, "reveal tag", w + ".rewards.reveals", r, reveal_tags, optional=False)
        for s in rw.get("unlockScenes") or []:
            check_ref(g, "scene", w + ".rewards.unlockScenes", s, scene_ids)
        for r in rw.get("recipes") or []:
            check_ref(g, "recipe", w + ".rewards.recipes", r, recipe_ids)
        for n in rw.get("recruit") or []:
            check_ref(g, "npc", w + ".rewards.recruit", n, npc_ids)
        end_ids = []
        for e in rw.get("endings") or []:
            end_ids.append(e.get("id"))
            req = e.get("requires") or {}
            ew = f"{w}.endings:{e.get('id')}"
            for i in req.get("items") or []:
                check_ref(g, "item", ew, i, item_ids)
            for s in req.get("completedScenes") or []:
                check_ref(g, "scene", ew, s, scene_ids)
            for r in req.get("reveals") or []:
                check_ref(g, "reveal tag", ew, r, reveal_tags)
            for k in req.get("minDisposition") or {}:
                check_ref(g, "npc", ew, k, npc_ids)
        unique(g, "ending", w, end_ids)

    # portrait manifest
    if portraits is not None:
        plist = portraits.get("portraits") if isinstance(portraits, dict) else None
        if not isinstance(plist, list):
            g.err("shape", "portrait_manifest.json", "expected {portraits: []}")
        else:
            for p in plist:
                check_ref(g, "npc", "portrait_manifest.json", p.get("characterId"), npc_ids, optional=False)
    return g.errors


def main(argv):
    data_dir = argv[1] if len(argv) > 1 else "data"
    if not os.path.isdir(data_dir):
        print(f"check_content_graph: no such directory: {data_dir}", file=sys.stderr)
        return 2
    errors = check(data_dir)
    for e in errors:
        print(e)
    print(f"check_content_graph: {len(errors)} problem(s) in {data_dir}")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
