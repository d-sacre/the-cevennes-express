import re

INPUT_FILE_PATH : str = "../raw/pages/Tile Ideas.md"
EXPORT_FILE_PATH : str = "../doc/index.html"

REGEX = {
    "HEADING": { # REMARK: Needs to be refined!
    # REMARK: regex101 says that "- #{1} .*$" should work. However, the "$" (end of line/file) 
    # is not working properly (probably due to the import method). However, "\n" instead of "$" works
        "H1": "- #{1} .*\n", #"[^\n#]#{1}\ .*$",
        "H2": "- #{2} .*\n"
    },
    "IMAGE": 
    {
        "PLAIN": "- !\[(?:\d*\D*)\]\((?:\S*)\)",
        "SIZE": "\{(?:\:\w*\s\d*\,\s\:\w*\s\d*)\}", # needs to be refined
        "SRC": "\(\s*\S*\)",
        "TITLE": "\[\s*\S*\]"
    }
}

HTML = {
    "IMAGE": "<br><img src=\"{src}\" title=\"{title}\" width = \"50%\" style=\"max-width: 100%; height: auto;\"/><br>",
    "HEADING": {
        "H1": "<h1 id=\"{title}\">{title}</h1>",
        "H2": "<h2 id=\"{title}\">{title}</h2>"
    }
}

data = ""
replacementDatabase : list = []

# DESCRIPTION: Load md from file
with open(INPUT_FILE_PATH, "r") as logseqMd:
    _lines = logseqMd.readlines()
    for _line in _lines:
        data += _line 

# DESCRIPTION: Process headings
headings = []

for i in range(1,3):
    headings += re.findall(REGEX["HEADING"]["H"+str(i)], data)

for heading in headings:
    dbEntry = {"match": heading}

    if re.search(REGEX["HEADING"]["H1"], heading) != None:

        # DESCRIPTION: Extract heading title and format it to html
        heading = heading.replace("- # ", "").replace("\n", "")
        _tmp_heading : str = HTML["HEADING"]["H1"]
        _tmp_heading = _tmp_heading.format(title = heading)
        dbEntry["html"] = _tmp_heading + "\n"

    elif re.search(REGEX["HEADING"]["H2"], heading) != None:

        # DESCRIPTION: Extract heading title and format it to html
        heading = heading.replace("- ## ", "").replace("\n", "")
        _tmp_heading : str = HTML["HEADING"]["H2"]
        _tmp_heading = _tmp_heading.format(title = heading)  
        dbEntry["html"] = _tmp_heading + "\n"

    replacementDatabase.append(dbEntry)


# DESCRIPTION: Delete image width specification
# REMARK: Temporary!
data = re.sub(REGEX["IMAGE"]["SIZE"], "", data)

# DESCRIPTION: Find all images and extract source/title
images = re.findall(REGEX["IMAGE"]["PLAIN"], data)

for image in images:
    dbEntry = {"match": image, "title": ""}
    dbEntry["src"] = re.findall(REGEX["IMAGE"]["SRC"], image)[0].replace("(", "").replace(")", "")

    tmp_title = re.findall(REGEX["IMAGE"]["TITLE"], image)
    if len(tmp_title) != 0:
        dbEntry["title"] = tmp_title[0].replace("[", "").replace("]", "")

    tmp_html = HTML["IMAGE"]
    tmp_html = tmp_html.format(src = dbEntry["src"], title = dbEntry["title"])

    dbEntry["html"] = tmp_html

    replacementDatabase.append(dbEntry)

# DESCRIPTION: Replace all the selected objects with HTML code
for replacement in replacementDatabase:
    data = data.replace(replacement["match"], replacement["html"])

# DESCRIPTION: Final clean up
data = data.replace("public:: true\n\n", "")

# DEXRIPTION: Export data to html file
with open(EXPORT_FILE_PATH, "w") as htmlExport:
    htmlExport.write(data)
