import docx
from docx import Document
import pickle
import os

path = r'T:\MPO\Bike&Ped\BikeCounting\StoryMap\copies'

with open(os.path.join(path, "storymap_text_2021.pkl"), "rb") as f: #allyear_storymap_text_v1
    text_list = pickle.load(f)

document = Document()
# Write each string in the list to the document
for text in text_list:
    document.add_paragraph(text)

# Save the document
document.save(os.path.join(path,'storymap_text_2021.docx'))