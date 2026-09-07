"""Tiny WDBC reader/appender (3.3.5 DBC: fixed 4-byte fields + string block)."""
import struct


class DBC:
    def __init__(self, path):
        data = open(path, "rb").read()
        assert data[:4] == b"WDBC", path
        self.n, self.nf, self.rs, self.ss = struct.unpack_from("<4I", data, 4)
        assert self.rs == self.nf * 4, "non-uniform record layout not supported"
        body = data[20:20 + self.n * self.rs]
        self.records = [list(struct.unpack_from(f"<{self.nf}I", body, i * self.rs)) for i in range(self.n)]
        self.strings = bytearray(data[20 + self.n * self.rs:20 + self.n * self.rs + self.ss])

    def string(self, ofs):
        end = self.strings.index(b"\0", ofs)
        return self.strings[ofs:end].decode("utf-8", "replace")

    def add_string(self, s):
        if not s:
            return 0
        ofs = len(self.strings)
        self.strings += s.encode("utf-8") + b"\0"
        return ofs

    def find(self, id_):
        for r in self.records:
            if r[0] == id_:
                return r
        return None

    def append(self, fields):
        """fields: list of int | float | str, one per column."""
        assert len(fields) == self.nf
        rec = []
        for f in fields:
            if isinstance(f, float):
                rec.append(struct.unpack("<I", struct.pack("<f", f))[0])
            elif isinstance(f, str):
                rec.append(self.add_string(f))
            else:
                rec.append(int(f) & 0xFFFFFFFF)
        self.records = [r for r in self.records if r[0] != rec[0]] + [rec]
        self.records.sort(key=lambda r: r[0])

    def write(self, path):
        with open(path, "wb") as f:
            f.write(b"WDBC" + struct.pack("<4I", len(self.records), self.nf, self.rs, len(self.strings)))
            for r in self.records:
                f.write(struct.pack(f"<{self.nf}I", *r))
            f.write(self.strings)


def as_float(u):
    return struct.unpack("<f", struct.pack("<I", u))[0]
