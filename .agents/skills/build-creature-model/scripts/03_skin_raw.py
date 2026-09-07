"""Raw-parse the donor skin to confirm bone palette semantics (no pywowlib)."""
import os
import struct
from wowlib import OUT

D = os.path.join(OUT, "donor", "Creature", "Kobold")


def m2array(buf, ofs):
    return struct.unpack_from("<II", buf, ofs)


m2 = open(os.path.join(D, "Kobold.m2"), "rb").read()
# MD20 header offsets (v264): magic 0, version 4, name 8, flags 16, globalseq 20, seq 28, seqlookup 36,
# bones 44, keybonelookup 52, vertices 60, nViews 68, colors 72, textures 80, texweights 88, texanims 96,
# replacable 104, materials 112, bonelookup 120, texlookup 128, texunitlookup 136, translookup 144,
# texanimlookup 152, bbox 160 (2*vec3), bsphere 184, cbox 188, csphere 212, coltris 216, colverts 224,
# colnormals 232, attachments 240, attlookup 248, events 256, lights 264, cameras 272, camlookup 280,
# ribbons 288, particles 296 [, blendmapoverrides 304 if flag 0x8]
nverts, ofsverts = m2array(m2, 60)
nlut, ofslut = m2array(m2, 120)
lut = struct.unpack_from(f"<{nlut}H", m2, ofslut)
nviews = struct.unpack_from("<I", m2, 68)[0]
print("nViews (skin count):", nviews, " nverts:", nverts)
verts = []
for i in range(nverts):
    o = ofsverts + i * 48
    px, py, pz = struct.unpack_from("<3f", m2, o)
    bw = struct.unpack_from("<4B", m2, o + 12)
    bi = struct.unpack_from("<4B", m2, o + 16)
    verts.append((bi, bw))

skin = open(os.path.join(D, "Kobold00.skin"), "rb").read()
assert skin[:4] == b"SKIN"
nv, ov = m2array(skin, 4)
ni, oi = m2array(skin, 12)
nb, ob = m2array(skin, 20)
ns, os_ = m2array(skin, 28)
nbat, obat = m2array(skin, 36)
bone_count_max = struct.unpack_from("<I", skin, 44)[0]
print(f"skin: vertices={nv} indices={ni} bones={nb} submeshes={ns} batches={nbat} boneCountMax={bone_count_max} size={len(skin)}")
vidx = struct.unpack_from(f"<{nv}H", skin, ov)
# submesh (48 bytes): id u16, level u16, vstart u16, vcount u16, istart u16, icount u16, bonecount u16,
# bonecombo u16, boneinfl u16, centerbone u16, center 3f, sortcenter 3f, sortradius f
for s in range(ns):
    o = os_ + s * 48
    sid, lvl, vs, vc, is_, ic, bc, bci, binf, cb = struct.unpack_from("<10H", skin, o)
    print(f"submesh {s}: id={sid} lvl={lvl} v={vs}+{vc} i={is_}+{ic} bones={bc} combo={bci} infl={binf} centerbone={cb}")
    palette = lut[bci:bci + bc]
    print("  palette (lookup slice):", list(palette))
    ok = True
    for i in range(vs, vs + vc):
        sb = struct.unpack_from("<4B", skin, ob + i * 4)
        bi, bw = verts[vidx[i]]
        for k in range(4):
            if bw[k] and palette[sb[k]] != bi[k]:
                ok = False
        if i < vs + 4:
            print("   vert", i, "m2 bones", bi, "weights", bw, "skin palette idx", sb)
    print("  palette[skin.bones] == m2 vertex bone ids for all weighted influences:", ok)
# batch (24 bytes): flags u8, priority i8, shader u16, submesh u16, geoset u16, color i16, material u16,
# layer u16, texcount u16, texcombo u16, texcoordcombo u16, weightcombo u16, transformcombo u16
for b in range(nbat):
    o = obat + b * 24
    print("batch", b, struct.unpack_from("<BbHHHhHHHHHHH", skin, o))
