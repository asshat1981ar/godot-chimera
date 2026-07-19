#!/usr/bin/env python3
"""Generate procedural gothic/ink-wash placeholder sprites for the Godot Chimera port."""
import os, subprocess, sys, json

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OUT = os.path.join(ROOT, "assets", "images")
IM = "convert"

def run(*args):
    subprocess.run([IM, *args], check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

def ensure_dirs():
    for d in ["ui","map_tiles","map","items","combat",os.path.join("npcs","portraits"),os.path.join("npcs","tokens")]:
        os.makedirs(os.path.join(OUT, d), exist_ok=True)

def gen_app_icon():
    run("-size","256x256","radial-gradient:#3e3026-#0d0b09","-pointsize","48","-fill","#d4c4a8","-gravity","center","-annotate","+0+0","C","-stroke","#8a7357","-strokewidth","4","-fill","none","-draw","roundrectangle 12,12 244,244 24,24", os.path.join(OUT,"ui","app_icon.png"))

def gen_terrain_tiles():
    variants = {"tile_ash":("#3d322b","#2b231e"),"tile_stone":("#4a4038","#2f2822"),"tile_parchment":("#6e5f4f","#4e4337"),"tile_water":("#1c2a2e","#0f191c"),"tile_shore":("#5a4d3f","#363024")}
    for name,(light,dark) in variants.items():
        run("-size","128x128",f"gradient:{light}-{dark}","+noise","Random","-blur","0x3","-modulate","90,30","-stroke","#00000020","-strokewidth","2","-fill","none","-draw","rectangle 0,0 127,127", os.path.join(OUT,"map_tiles",f"{name}.png"))

def gen_map_nodes():
    states = {"active":("#d4c4a8","#e8c547"),"neutral":("#6e5f4f","#4a4038"),"hidden":("#2a211c","#1a1512"),"completed":("#7d9a76","#4a5c46"),"failed":("#8a3e3e","#4a1c1c"),"blocked":("#4a4a4a","#2a2a2a")}
    for state,(fill,glow) in states.items():
        run("-size","128x128","xc:transparent","-fill",f"{glow}80","-draw","circle 64,64 110,64","-fill",f"{fill}dd","-stroke","#1a1512","-strokewidth","4","-draw","circle 64,64 94,64","-fill","#00000060","-stroke","none","-draw","circle 64,64 82,64", os.path.join(OUT,"map",f"map_ruins_{state}.png"))

def gen_portrait(npc_id):
    hue = (hash(npc_id) % 360 + 360) % 360
    run("-size","256x256","xc:transparent","-fill",f"hsl({hue},30%,25%)","-stroke","#000000","-strokewidth","3","-draw","ellipse 128,100 60,80 0,360","-fill",f"hsl({hue},40%,50%)","-draw","ellipse 128,105 45,55 0,360","-fill","#0d0b09","-draw","ellipse 110,100 8,10 0,360","-draw","ellipse 146,100 8,10 0,360","-fill",f"hsl({hue},25%,20%)","-draw","path 'M 80,180 Q 128,260 176,180 L 176,256 L 80,256 Z'","-blur","0x1", os.path.join(OUT,"npcs","portraits",f"portrait_{npc_id}.png"))

def gen_token(npc_id):
    hue = (hash(npc_id) % 360 + 360) % 360
    run("-size","96x96","xc:transparent","-fill",f"hsl({hue},35%,30%)","-stroke","#d4c4a8","-strokewidth","3","-draw","circle 48,40 70,40","-fill",f"hsl({hue},45%,55%)","-draw","circle 48,42 58,42","-fill","#0d0b09","-draw","circle 42,40 5,5","-draw","circle 54,40 5,5", os.path.join(OUT,"npcs","tokens",f"token_{npc_id}.png"))

def gen_ui():
    for name in ["frame_gold","panel_parchment"]:
        run("-size","512x512","xc:transparent","-stroke","#8a7357","-strokewidth","8","-fill","#1a1512c0","-draw","roundrectangle 16,16 496,496 32,32","-stroke","#d4c4a8","-strokewidth","3","-fill","none","-draw","roundrectangle 28,28 484,484 24,24", os.path.join(OUT,"ui",f"{name}.png"))

def gen_items():
    items = ["herb_bundle","ash_urn","sealed_letter","rusty_key","iron_ration"]
    for i,name in enumerate(items):
        hue = (i*70)%360
        run("-size","128x128","xc:transparent","-fill",f"hsl({hue},35%,35%)","-stroke","#1a1512","-strokewidth","3","-draw","roundrectangle 24,24 104,104 16,16","-fill",f"hsl({hue},50%,55%)","-draw","circle 64,64 28,28", os.path.join(OUT,"items",f"item_{name}.png"))

def gen_combat():
    for stance in ["strike","ward","feint"]:
        for state in ["","_wounded"]:
            color = "#8a3e3e" if state else "#6e5f4f"
            run("-size","256x256","xc:transparent","-stroke",color,"-strokewidth","6","-fill","#2a211c","-draw","ellipse 128,180 60,90 0,360","-fill",color,"-draw","ellipse 128,90 50,60 0,360","-fill","#0d0b09","-draw","circle 115,85 7,7","-draw","circle 141,85 7,7", os.path.join(OUT,"combat",f"stance_{stance}{state}.png"))

def main():
    ensure_dirs()
    gen_app_icon(); gen_terrain_tiles(); gen_map_nodes(); gen_ui(); gen_items(); gen_combat()
    with open(os.path.join(ROOT,"data","npcs.json"),"r") as f:
        npcs = json.load(f)
    for npc in npcs:
        npc_id = npc["id"]
        gen_portrait(npc_id); gen_token(npc_id)
    print(f"Placeholder sprites generated in {OUT}")

if __name__ == "__main__":
    main()
