# data/parse.py

import codecs
from bs4 import BeautifulSoup

def get_table(filename):
    with codecs.open("Wikipedia.html", "r", "UTF-8") as fin:
        html = fin.read()
        soup = BeautifulSoup(html, "html.parser")
    return soup.find("div", class_="mw-parser-output").find_all("table")[4]

def rgb_to_hex(string):
    if string.startswith('#'):
        return string
    else: # "rgb(1,2,3)" -> "#010203"
        return "#%02X%02X%02X" % tuple(map(int, string[4:-1].split(',')))

def find_parent(records, i, j):
    pj = j - 1
    pi = i
    while (pi, pj) not in records:
        pi -= 1
    return pi, pj

def clean_name(records, i, j):
    name = records[i, j]["name"]
    if name.startswith("Upper/Late"):
        name = "Late" + ' ' + records[find_parent(records, i, j)]["name"]
    elif name.startswith("Lower/Early"):
        name = "Early" + ' ' + records[find_parent(records, i, j)]["name"]
    elif name.startswith("Middle"):
        name = "Middle" + ' ' + records[find_parent(records, i, j)]["name"]
    name = name.split('[')[0] # ']'
    name = name.split('(')[0] # ')'
    records[i, j]["name"] = name

def resolve_table(table):
    rows = table.find_all("tr")[1:]
    start_times = []
    for row in rows:
        cells = row.find_all("td")
        start_times.append(float(cells[-1].text.strip("~ \n").split(' ')[0]))
    stack = [-1]
    records = {}
    for i in range(0, len(rows)):
        while stack[-1] == i:
            stack.pop()
        j = len(stack) - 1
        row = rows[i]
        cells = row.find_all("td")
        for cell in cells:
            j += 1
            if j > 5:
                break
            style = cell.get("style")
            if style:
                hex = rgb_to_hex(style[11:])
            else:
                break
            stack.append(i + int(cell.get("rowspan", "1")))
            name = cell.text.strip()
            records[i, j] = {"name": name, "hex": hex, 
                "start_time": start_times[stack[-1]-1]}
            clean_name(records, i, j)
    return records

def print_to_tsv(filename, records):
    with codecs.open(filename, "w", "UTF-8") as fout:
        for key in sorted(records.keys(), key = lambda k: k[1]):
            record = records[key]
            print(key[1], record["name"], record["hex"], record["start_time"], 
                sep='\t', file=fout)

if __name__ == "__main__":
    table = get_table("wikipedia.html")
        # https://en.wikipedia.org/wiki/Geologic_time_scale, accessed 20230423
    records = resolve_table(table)
    print_to_tsv("timescale.tsv", records)
