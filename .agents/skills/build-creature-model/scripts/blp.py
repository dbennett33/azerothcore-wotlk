"""Minimal BLP2 writer: DXT1 (no alpha) or DXT5, full mip chain. Pure numpy.

BLP2 layout: 148-byte header + 1024-byte palette (unused for DXT, kept for reader compat) + mips.
"""
import struct
import numpy as np


def _rgb565(c):
    r, g, b = c[..., 0].astype(np.uint32), c[..., 1].astype(np.uint32), c[..., 2].astype(np.uint32)
    return ((r >> 3) << 11) | ((g >> 2) << 5) | (b >> 3)


def _from565(v):
    r = ((v >> 11) & 31) * 255 // 31
    g = ((v >> 5) & 63) * 255 // 63
    b = (v & 31) * 255 // 31
    return np.stack([r, g, b], axis=-1).astype(np.float32)


def encode_dxt1(rgb):
    """rgb: (H, W, 3) uint8, H and W multiples of 4 (pad smaller mips). Returns bytes."""
    h, w, _ = rgb.shape
    out = bytearray()
    for by in range(0, h, 4):
        for bx in range(0, w, 4):
            blk = rgb[by:by + 4, bx:bx + 4].reshape(-1, 3).astype(np.float32)
            # endpoints: extremes along the principal axis (fallback min/max luminance)
            mean = blk.mean(axis=0)
            d = blk - mean
            cov = d.T @ d
            if np.allclose(cov, 0):
                axis = np.array([1.0, 1.0, 1.0])
            else:
                _, vec = np.linalg.eigh(cov)
                axis = vec[:, -1]
            proj = d @ axis
            c0 = blk[np.argmax(proj)]
            c1 = blk[np.argmin(proj)]
            v0, v1 = int(_rgb565(c0[None])[0]), int(_rgb565(c1[None])[0])
            if v0 == v1:
                out += struct.pack("<HHI", v0, v1, 0)
                continue
            if v0 < v1:          # 4-colour mode needs c0 > c1
                v0, v1 = v1, v0
            e0, e1 = _from565(np.array([v0]))[0], _from565(np.array([v1]))[0]
            palette = np.stack([e0, e1, (2 * e0 + e1) / 3, (e0 + 2 * e1) / 3])
            dist = ((blk[:, None, :] - palette[None, :, :]) ** 2).sum(axis=-1)
            idx = dist.argmin(axis=1)
            bits = 0
            for i, k in enumerate(idx):
                bits |= int(k) << (2 * i)
            out += struct.pack("<HHI", v0, v1, bits)
    return bytes(out)


def encode_dxt5_alpha(a):
    """a: (4,4) uint8 alpha block -> 8 bytes (interpolated alpha, 8-value mode)."""
    a = a.reshape(-1).astype(np.int32)
    a0, a1 = int(a.max()), int(a.min())
    if a0 == a1:
        return struct.pack("<BB", a0, a1) + bytes(6)
    pal = [a0, a1] + [((6 - i) * a0 + (i + 1) * a1) // 7 for i in range(6)]
    codes = [int(np.argmin([abs(int(v) - p) for p in pal])) for v in a]
    bits = 0
    for i, c in enumerate(codes):
        bits |= c << (3 * i)
    return struct.pack("<BB", a0, a1) + bits.to_bytes(6, "little")


def encode_dxt5(rgba):
    h, w, _ = rgba.shape
    out = bytearray()
    for by in range(0, h, 4):
        for bx in range(0, w, 4):
            out += encode_dxt5_alpha(rgba[by:by + 4, bx:bx + 4, 3])
            out += encode_dxt1(rgba[by:by + 4, bx:bx + 4, :3])
    return bytes(out)


def _downsample(img):
    h, w = img.shape[:2]
    if h == 1 and w == 1:
        return None
    nh, nw = max(1, h // 2), max(1, w // 2)
    img = img[:nh * 2, :nw * 2].astype(np.float32)
    if h > 1 and w > 1:
        img = (img[0::2, 0::2] + img[1::2, 0::2] + img[0::2, 1::2] + img[1::2, 1::2]) / 4
    elif h > 1:
        img = (img[0::2] + img[1::2]) / 2
    else:
        img = (img[:, 0::2] + img[:, 1::2]) / 2
    return np.clip(np.rint(img), 0, 255).astype(np.uint8)


def _pad4(img):
    h, w = img.shape[:2]
    ph, pw = (4 - h % 4) % 4, (4 - w % 4) % 4
    if ph or pw:
        img = np.pad(img, ((0, ph), (0, pw), (0, 0)), mode="edge")
    return img


def write_blp2(path, rgba, alpha=False):
    """rgba: (H, W, 4) uint8. alpha=False -> DXT1 (alphaDepth 0); True -> DXT5 (alphaDepth 8, alphaEncoding 7)."""
    rgba = np.ascontiguousarray(rgba, dtype=np.uint8)
    h, w = rgba.shape[:2]
    mips = []
    cur = rgba
    while cur is not None and len(mips) < 16:
        blk = _pad4(cur)
        mips.append(encode_dxt5(blk) if alpha else encode_dxt1(blk[..., :3]))
        cur = _downsample(cur)
    header_size = 148 + 1024
    offsets, sizes, pos = [], [], header_size
    for m in mips:
        offsets.append(pos); sizes.append(len(m)); pos += len(m)
    offsets += [0] * (16 - len(offsets)); sizes += [0] * (16 - len(sizes))
    hdr = struct.pack("<4sIBBBBII", b"BLP2", 1, 2, 8 if alpha else 0, 7 if alpha else 0, 1, w, h)
    hdr += struct.pack("<16I", *offsets) + struct.pack("<16I", *sizes)
    with open(path, "wb") as f:
        f.write(hdr)
        f.write(bytes(1024))
        for m in mips:
            f.write(m)
    return len(mips), pos
