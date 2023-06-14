from arcgis.gis import GIS
from arcgis.apps.storymap import Image, StoryMap
from arcgis.mapping import WebMap
from arcgis.apps.storymap.story_content import Text
import os
import pickle

path = r'T:\MPO\Bike&Ped\BikeCounting\StoryMap\copies'
gis = GIS("home")
exst_stry = StoryMap("4c8e01a034f5438eb17be5436baeb16d") #443277613d964e2d82f04d71c72d6aa7, 241cfe53fdc54602b313eeb299729031
all_nodes = exst_stry.nodes
list_text_obj = []

def get_text_from_Text_obj(Text_obj):
    node_dict = Text_obj.properties
    return node_dict['node_dict']['data']['text']

for node in all_nodes:
    for key, value in node.items():
        if isinstance(value, Text):
            list_text_obj.append(value)

text_list = []
for txt_obj in list_text_obj:
    text_list.append(get_text_from_Text_obj(txt_obj))

with open(os.path.join(path, "allyear_storymap_text_v2.pkl"), "wb") as f: #allyear_storymap_text_v1.pkl, storymap_text_2021.pkl
        pickle.dump(text_list, f)