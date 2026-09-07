"""Shared bootstrap for the build-creature-model pipeline.

Run every script with Blender's bundled Python (3.10) so the compiled pywowlib extensions load:
  <blender>\\3.4\\python\\bin\\python.exe <script>
Configuration by environment variable (defaults are this fork's Windows dev box):
  WBS_ROOT    io_scene_wmo folder of WoW Blender Studio (provides pywowlib)
  WOW_CLIENT  3.3.5a client root (Data\\*.MPQ)
  CREATURE_OUT  output folder (default: ./out next to the scripts)
"""
import os
import sys

WBS_ROOT = os.environ.get("WBS_ROOT", r"C:\dev\tools\blender-wow-studio\io_scene_wmo")
if WBS_ROOT not in sys.path:
    sys.path.insert(0, WBS_ROOT)

CLIENT = os.environ.get("WOW_CLIENT", r"C:\dev\wow-335\scout")
WORK = os.path.dirname(os.path.abspath(__file__))
OUT = os.environ.get("CREATURE_OUT", os.path.join(WORK, "out"))
ASSETS = os.path.join(os.path.dirname(WORK), "assets")
os.makedirs(OUT, exist_ok=True)

# Blizzard load order (later overrides earlier). Locale archives last.
ARCHIVES = [
    "common.MPQ", "common-2.MPQ", "expansion.MPQ", "lichking.MPQ",
    "patch.MPQ", "patch-2.MPQ", "patch-3.MPQ",
    r"enUS\locale-enUS.MPQ", r"enUS\expansion-locale-enUS.MPQ", r"enUS\lichking-locale-enUS.MPQ",
    r"enUS\patch-enUS.MPQ", r"enUS\patch-enUS-2.MPQ", r"enUS\patch-enUS-3.MPQ",
]


def open_client():
    from pywowlib.archives.mpq import MPQFile
    mpq = MPQFile()
    for a in ARCHIVES:
        p = os.path.join(CLIENT, "Data", a)
        if os.path.exists(p):
            mpq.add_archive(p)
    return mpq


def read_latest(mpq, name):
    """Return bytes of `name` from the highest-priority archive that has it."""
    from pywowlib.archives.mpq.native import storm
    name = name.replace("/", "\\")
    found = None
    for arc in mpq._archives:
        if storm.SFileHasFile(arc, name):
            found = arc
    if found is None:
        raise KeyError(name)
    h = storm.SFileOpenFileEx(found, name, 0)
    size = storm.SFileGetFileSize(h)
    data = storm.SFileReadFile(h, size)
    storm.SFileCloseFile(h)
    return data
