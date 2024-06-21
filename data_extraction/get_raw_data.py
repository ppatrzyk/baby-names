import fileinput
import glob
import os
import re
import sys
from urllib.request import urlretrieve
import zipfile

DIR = os.path.dirname(os.path.realpath(__file__))
DATA_URL = "https://api.dane.gov.pl/datasets/219,imiona-nadawane-dzieciom-w-polsce/resources/files/download"
ZIP_FILE = os.path.join(DIR, "baby_names_pl.zip")
DATA_PATH = os.path.join(DIR, "baby_names_pl")
COL_REPLACE = (
    ("(pierwsze|1)", "first_name"),
    ("(drugie|2)", "middle_name"),
    ("imię", "first_name"),
    ("liczba", "count"),
    ("(kod|^woj$)", "voivodeship_code"),
    ("woj", "voivodeship"),
    ("płeć", "gender"),
    ("rok", "year"),
)

if not os.path.exists(ZIP_FILE):
    urlretrieve(DATA_URL, ZIP_FILE)

if not os.path.exists(DATA_PATH):
    os.mkdir(DATA_PATH)
    with zipfile.ZipFile(ZIP_FILE, 'r') as zip_file:
        zip_file.extractall(DATA_PATH)

print("Data downloaded")

csv_files = glob.glob("baby_names_pl/*/*.csv")
for file_path in csv_files:
    # partial files
    if re.search("(połowie|poowie)", file_path, re.IGNORECASE):
        os.remove(file_path)
        continue
    for i, line in enumerate(fileinput.input(file_path, inplace=1), start=0):
        splitted = tuple(el.strip() for el in line.split(","))
        if not any(splitted):
            continue
        if i == 0:
            fixed_headers = []
            for header in splitted:
                fixed_header = header
                for pattern, col_name in COL_REPLACE:
                    if re.search(pattern, header, re.IGNORECASE):
                        fixed_header = col_name
                        break
                fixed_headers.append(fixed_header)
            line = ", ".join(fixed_headers) + "\n"
        sys.stdout.write(line)

print("CSV headers unified")
