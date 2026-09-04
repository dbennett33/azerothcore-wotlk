# Windows vs Linux: tools and commands for client/server data work

Read [SKILL.md](SKILL.md) first. This file is lookup only.

**Linux is the process this fork maintains** (playable client `/home/dan/dev/wow-3.3.5/`, Proton;
do not use `~/Downloads/ChromieCraft_*`). A contributor also works on Windows: same versions
(Blender 3.4.1 + WBS, MPQ v2, extractors from this repo). They own Windows packer/GUI/scout
paths; do not block Linux work on those columns. Historical `C:/dev/tools/…` notes from
Waxworks may have moved.

## Tool matrix

| Task | Windows | Linux | Notes |
|---|---|---|---|
| Edit ADT terrain | Noggit3 GUI (`C:/dev/tools/noggit3/noggit.exe` *(this machine)*) | Noggit3 can be built (Qt); unsupported, Wine works | Windows-first tool. Writes ADT/WDT into its project dir. |
| Build/kitbash WMO, M2 | Blender **3.4.1** + WBS (Windows contributor) | `/home/dan/dev/tools/blender-3.4.1-linux-x64/blender` + WBS addon **WoW** | WMO **v17** only. Do not export M2. Procedure: `build-dungeon/reference-blender-wmo.md`. |
| Browse/dump Blizzard MPQs | wow.export "Open Legacy Installation", MPQEditor GUI | wow.export Linux portable (kruithne.net); `extract-wmo-family.py` dumps native WMO bytes from `common-2.MPQ` | wow.export CASC mode is for retail. OBJ from wow.export is **not** what WBS imports. |
| Pack MPQ | Ladik's MPQEditor (`/console` script or GUI) *(Windows: `C:/dev/tools/mpqeditor/x64/MPQEditor.exe`)* | `/home/dan/dev/tools/pack-mpq` (StormLib, v2, spec `disk=archivepath`). `smpq -M 2 -c` if installed (not on this box) | Must be MPQ v1/v2. Extractors (`deps/libmpq`) and the 3.3.5a client reject v3/v4. |
| Edit DBC | WDBX Editor (.NET) *(this machine: `C:/dev/tools/wdbxeditor/`)* | WDBX under Wine/Mono; or SQL: server `*_dbc` overlay + export to DBC with a Python writer | Column order must match `DBCfmt.h`. |
| Extract server data | `map_extractor.exe` etc. from a Windows build of this repo (`-DTOOLS_BUILD=all`) | Same tools built on Linux | Identical output format. Tools are **not** on the VPS. |
| Bundle | `client-patches/scripts/build-bundle.ps1` | `client-patches/scripts/build-bundle.sh` (needs `python3`, `jq`, `tar`) | Same manifest. World MPQs → `Data/<file>`; locale MPQs → `Data/<locale>/<file>`. |
| Extract helper | none (`extract-server-data.sh` is bash-only) | `extract-server-data.sh` (`AC_TOOLS_BIN`, `--map ID`) | Invokes tools with `-i`/`-o`/`-d`; does not `cd` into the WoW dir. |
| Publish to VPS | `publish-to-vps.ps1` (`ssh.exe`/`scp.exe` from OpenSSH Client optional feature) | `publish-to-vps.sh` (`ssh`, `rsync`) | Log in as `debian@`; the helper `sudo -u acore`s. Publish **before** the git push that deploys. |
| Player update | `update-client.ps1 -WowDir … -FromVps debian@… -Target test \| -PatchesUrl …` | `update-client.sh --wow-dir … --from-vps … --target test \| --patches-url …` | `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` if blocked. `-Target live` for Live. |
| Scout client / screenshots | `walk-instance` scripts (PowerShell + SendKeys, `C:\dev\wow-335\scout\`) | Playable Proton client at `/home/dan/dev/wow-3.3.5/`; scout scripts are Windows-only | Visual proof is a PNG with `.gps` in frame, not SOAP. |
| SOAP GM commands | `scout-soap.ps1` → `http://127.0.0.1:7878/` | `curl` with the same XML body | SOAP is localhost-only on the VPS; tunnel with `ssh -L 7878:127.0.0.1:7878`. |

## Packing an MPQ

Stage loose files in `client-patches/sources/client/loose/` with exact internal paths, e.g.
`World/Maps/Waxworks/Waxworks.wdt`, `DBFilesClient/Map.dbc`. Then:

**Linux** (from a complete `sources/client/loose/` tree — every custom world file, not just the
new WMO). This machine's packer is `/home/dan/dev/tools/pack-mpq` (StormLib, MPQ v2, spec
`disk=archivepath` with `=` — not `:`):

```bash
# Rebuild the WHOLE patch-4; omitting Waxworks/Belfry files drops those maps.
REPO=/home/dan/dev/azerothcore-wotlk
PACK=/home/dan/dev/tools/pack-mpq
LOOSE=$REPO/client-patches/sources/client/loose
OUT=$REPO/client-patches/sources/client/mpq/patch-4.MPQ
specs=()
while IFS= read -r -d '' f; do
  rel=${f#"$LOOSE/"}
  specs+=("$f=${rel//\//\\}")
done < <(find "$LOOSE/World" -type f -print0)
"$PACK" "$OUT" "${specs[@]}"
# Locale DBC archive: same loop over $LOOSE/DBFilesClient → patch-enUS-4.MPQ
```

`smpq -M 2 -c` is the distro alternative (`-M 2` is mandatory; default v4 is unreadable). Not
installed here. If `pack-mpq` is missing, rebuild `/home/dan/dev/tools/pack-mpq.cpp` against
`/home/dan/dev/tools/stormlib-prefix/`.

**Windows** (MPQEditor console; save the script as **ASCII**, no BOM — PowerShell 5.1
`Set-Content` defaults to UTF-8-BOM and MPQEditor then ignores `new`):

```
new "C:\work\out\patch-4.MPQ" 0x1000
add "C:\work\out\patch-4.MPQ" "C:\work\loose\World\*" "World\" /c /r
flush "C:\work\out\patch-4.MPQ"
close
```

```powershell
Set-Content -Path C:\work\pack.txt -Value $script -Encoding ascii
& 'C:\dev\tools\mpqeditor\x64\MPQEditor.exe' /console C:\work\pack.txt
```

GUI alternative: New MPQ → compatibility "World of Warcraft (WotLK)" → drag folders in → verify the
tree shows `World\…` at the root (not `loose\World\…`).

Both OSes: close `Wow.exe` before copying into `<client>/Data/`; the client holds archives open.
Only file **paths** are stored (hashed) — the archive needs its `(listfile)`, which both tools add.

## Building the extractors

```bash
# Linux (Debian/Ubuntu): deps as in .agents/docs/build.md, then
cmake -S . -B build-tools -DTOOLS_BUILD=all -DAPPS_BUILD=none -DSCRIPTS=none -DMODULES=none
cmake --build build-tools -j$(nproc)          # binaries in build-tools/src/tools/*/
```

```powershell
# Windows: same flags via the CMake GUI or the command line used by .github/workflows/tools_build.yml
# (MSVC, Boost, MySQL client libs under C:\tools\mysql\current). Output: build\bin\<Config>\*.exe
```

`TOOLS_BUILD` accepts `none | all | maps-only | db-only`. `maps-only` = the four data tools.

## Running the extractors

Run from a scratch directory; point at a **slim** client copy (base + locale archives + your
`patch-4` / `patch-enUS-4`) so other maps' WDTs are missing and skipped:

```bash
map_extractor  -i /path/to/slim-client -o /path/to/out -e 3      # maps + dbc, no cameras
cd /path/to/out && rm -rf Buildings && vmap4_extractor -d /path/to/slim-client/Data/
vmap4_assembler Buildings vmaps
cp /path/to/repo/src/tools/mmaps_generator/mmaps-config.yaml . && mmaps_generator 44 --threads 8
```

Windows: identical arguments with `.exe`; use forward or back slashes but quote paths with spaces.
`mmaps_generator` also needs `maps/` non-empty in the data dir even for a WMO-only map — keep at
least one `.map` file present (any map) or it exits with "'maps' directory is empty".

## Everyday differences that bite

| Topic | Windows | Linux |
|---|---|---|
| Path separators | `\` in scripts; MPQ internal names shown with `\` | `/`; StormLib stores what you pass (client accepts both) |
| Case | Filesystem case-insensitive | Case-sensitive. Never rename extracted files by hand; `Waxworks.wmo.vmo` must match the name the `.vmtree` references |
| Text encoding | PowerShell 5.1 writes UTF-8 **with BOM**; use `-Encoding ascii` for MPQEditor scripts and any listfile | UTF-8 without BOM by default |
| Symlinks | Git checks out `.claude/skills/*` links as plain files unless `git config core.symlinks true` + Developer Mode | Real symlinks |
| Line endings | Keep LF (`.gitattributes`); SQL/`.sh` with CRLF break `bash` on the VPS | LF |
| File locks | `Wow.exe` locks MPQs; MPQEditor GUI locks the archive it has open | No exclusive locks, but a running client still reads stale data until restarted |
| `tar` | `tar.exe` ships with Windows 10+; PowerShell script calls it | GNU tar |
| Python/jq | Not required by the `.ps1` scripts | Required by the `.sh` scripts |
| Client location | `C:\dev\wow-335\ChromieCraft_3.3.5a\` *(Windows scout)* | `/home/dan/dev/wow-3.3.5/` *(playable, Proton)*. Do not use `~/Downloads/ChromieCraft_*` |
| VPS access | OpenSSH Client optional feature; key in `%USERPROFILE%\.ssh` | `ssh`/`rsync` |

## Where each artefact ends up

| Artefact | Dev machine | VPS | Player |
|---|---|---|---|
| `patch-4.MPQ` | `client-patches/sources/client/mpq/` → `bundles/<v>/client/` | `/home/acore/client-patches/releases/<v>/client/` | `<WoW>/Data/patch-4.MPQ` |
| `patch-enUS-4.MPQ` | same | same | `<WoW>/Data/enUS/patch-enUS-4.MPQ` |
| `server-data.tar.gz` | `bundles/<v>/server/` | `releases/<v>/server/` → untarred into `/home/acore/server[-test]/data/` by `deploy-vps` | — |
| `manifest.json` | `bundles/<v>/` and `client-patches/manifest.json` (git) | `releases/<v>/manifest.json` | `.acore-client-patch-version` marker |
