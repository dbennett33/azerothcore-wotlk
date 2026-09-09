"""Extract the donor creature model (M2 + skins + BLPs) and the two creature DBCs."""
import os
import sys
from wowlib import open_client, read_latest, OUT

DONOR_DIR = r"Creature\Kobold"
DONOR = "Kobold"
FILES = [f"{DONOR_DIR}\\{DONOR}.m2"] + [f"{DONOR_DIR}\\{DONOR}0{i}.skin" for i in range(4)]
DBCS = [r"DBFilesClient\CreatureDisplayInfo.dbc", r"DBFilesClient\CreatureModelData.dbc",
        r"DBFilesClient\CreatureDisplayInfoExtra.dbc", r"DBFilesClient\AnimationData.dbc"]

mpq = open_client()
names = [n for n in mpq.namelist() if n.lower().startswith("creature/kobold/")]
print("kobold files in client:", *sorted(set(names)), sep="\n  ")

for n in FILES + DBCS + [x.replace("/", "\\") for x in set(names) if x.lower().endswith((".blp", ".anim"))]:
    dest = os.path.join(OUT, "donor", n.replace("\\", os.sep))
    os.makedirs(os.path.dirname(dest), exist_ok=True)
    try:
        data = read_latest(mpq, n)
    except KeyError:
        print("MISSING", n)
        continue
    with open(dest, "wb") as f:
        f.write(data)
    print(f"{len(data):>9}  {n}")
mpq.close()
