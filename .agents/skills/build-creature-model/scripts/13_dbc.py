"""Append the WaxCandle CreatureModelData / CreatureDisplayInfo rows to the client DBCs and emit the
matching server overlay SQL (creaturemodeldata_dbc, creaturedisplayinfo_dbc, creature_model_info)."""
import os
from dbc import DBC, as_float
from wowlib import OUT

CMD_ID = CDI_ID = 60000          # docs/custom-npc-skills/README.md registry block 60000-60999
MODEL_PATH = r"Creature\WaxCandle\WaxCandle.mdx"
TEXTURE = "WaxCandleSkin"
MODEL_SCALE = 1.3                # kobold-unit body top 1.42 -> ~1.85 yd (6 ft) in game
COLL_W, COLL_H = 0.7, 1.95
GEO = (-0.35, -0.45, 0.0, 0.35, 0.45, 1.95)
KOBOLD_CMD, KOBOLD_CDI = 26, 26

src = os.path.join(OUT, "donor", "DBFilesClient")
dst = os.path.join(OUT, "DBFilesClient")
os.makedirs(dst, exist_ok=True)

cmd = DBC(os.path.join(src, "CreatureModelData.dbc"))
k = cmd.find(KOBOLD_CMD)
cmd_row = [CMD_ID, 0, MODEL_PATH, 1, 1.0, k[5], k[6], as_float(k[7]), as_float(k[8]), as_float(k[9]), k[10],
           as_float(k[11]), as_float(k[12]), k[13], COLL_W, COLL_H, 0.0, *GEO, 1.0, 1.0, 0.0, 0.0, 0.0]
cmd.append(cmd_row)
cmd.write(os.path.join(dst, "CreatureModelData.dbc"))

cdi = DBC(os.path.join(src, "CreatureDisplayInfo.dbc"))
kd = cdi.find(KOBOLD_CDI)
cdi_row = [CDI_ID, CMD_ID, kd[2], 0, MODEL_SCALE, 255, TEXTURE, "", "", "", 0, 0, 0, 0, 0, 0]
cdi.append(cdi_row)
cdi.write(os.path.join(dst, "CreatureDisplayInfo.dbc"))

# verify round trip
c2 = DBC(os.path.join(dst, "CreatureDisplayInfo.dbc")).find(CDI_ID)
m2 = DBC(os.path.join(dst, "CreatureModelData.dbc")).find(CMD_ID)
print("CDI", c2[0], c2[1], "scale", as_float(c2[4]), "tex", DBC(os.path.join(dst, "CreatureDisplayInfo.dbc")).string(c2[6]))
print("CMD", m2[0], DBC(os.path.join(dst, "CreatureModelData.dbc")).string(m2[2]), "coll", as_float(m2[14]), as_float(m2[15]))


def sqlv(v):
    if isinstance(v, str):
        return "'" + v.replace("\\", "\\\\") + "'"
    if isinstance(v, float):
        return repr(round(v, 4))
    return str(v)


cmd_cols = ["ID", "Flags", "ModelName", "SizeClass", "ModelScale", "BloodID", "FootprintTextureID",
            "FootprintTextureLength", "FootprintTextureWidth", "FootprintParticleScale", "FoleyMaterialID",
            "FootstepShakeSize", "DeathThudShakeSize", "SoundID", "CollisionWidth", "CollisionHeight", "MountHeight",
            "GeoBoxMinX", "GeoBoxMinY", "GeoBoxMinZ", "GeoBoxMaxX", "GeoBoxMaxY", "GeoBoxMaxZ", "WorldEffectScale",
            "AttachedEffectScale", "MissileCollisionRadius", "MissileCollisionPush", "MissileCollisionRaise"]
cdi_cols = ["ID", "ModelID", "SoundID", "ExtendedDisplayInfoID", "CreatureModelScale", "CreatureModelAlpha",
            "TextureVariation_1", "TextureVariation_2", "TextureVariation_3", "PortraitTextureName", "BloodLevel",
            "BloodID", "NPCSoundID", "ParticleColorID", "CreatureGeosetData", "ObjectEffectPackageID"]


def wrap(cols):
    lines, cur = [], " "
    for i, c in enumerate(cols):
        tok = f"`{c}`" + ("," if i < len(cols) - 1 else ")")
        if len(cur) + len(tok) + 1 > 118:
            lines.append(cur)
            cur = " "
        cur += " " + tok
    lines.append(cur)
    return "\n".join(lines)


def wrap_vals(vals):
    lines, cur = [], ""
    toks = [sqlv(v) + ("," if i < len(vals) - 1 else ");") for i, v in enumerate(vals)]
    for tok in toks:
        if len(cur) + len(tok) + 1 > 118:
            lines.append(cur)
            cur = ""
        cur += (" " if cur else "") + tok
    lines.append(cur)
    return "\n".join(lines)


sql = f"""-- WaxCandle model: server copies of the DBC rows shipped in patch-enUS-4 (client-data contract).
DELETE FROM `creaturemodeldata_dbc` WHERE `ID` = {CMD_ID};
INSERT INTO `creaturemodeldata_dbc` (
{wrap(cmd_cols)} VALUES
({wrap_vals(cmd_row)[1:] if False else wrap_vals(cmd_row)}

DELETE FROM `creaturedisplayinfo_dbc` WHERE `ID` = {CDI_ID};
INSERT INTO `creaturedisplayinfo_dbc` (
{wrap(cdi_cols)} VALUES
({wrap_vals(cdi_row)}

DELETE FROM `creature_model_info` WHERE `DisplayID` = {CDI_ID};
INSERT INTO `creature_model_info` (`DisplayID`, `BoundingRadius`, `CombatReach`, `Gender`, `DisplayID_Other_Gender`,
 `VerifiedBuild`) VALUES
({CDI_ID}, 0.45, 1.5, 2, 0, 0);
"""
with open(os.path.join(OUT, "dbc_overlay.sql"), "w", newline="\n") as f:
    f.write(sql)
print(sql)
