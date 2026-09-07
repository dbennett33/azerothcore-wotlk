#!/usr/bin/env python3
"""Keep this fork's documentation discoverable by humans and agents.

Fails when:
- AGENTS.md lacks the "This fork" section or does not point at docs/README.md;
- a doc in docs/, a system doc in .agents/docs/systems/, or a skill in .agents/skills/ is not
  linked from docs/README.md;
- a skill or system doc is not routed from AGENTS.md;
- a skill has no matching relative symlink in .claude/skills/ (or the entry is a plain file);
- a .cursor/rules/*.mdc file lacks a description, or has neither alwaysApply: true nor globs;
- a relative markdown link in the fork's docs, agent docs, skills, or rules does not resolve.

Run from the repository root: python3 apps/codestyle/codestyle-docs.py
"""

import glob
import os
import re
import sys

ROOT = os.getcwd()
INDEX = "docs/README.md"
AGENTS = "AGENTS.md"

# Upstream AzerothCore files that live next to the fork's; they are not part of the fork index.
UPSTREAM_SKILLS = {"generate-pr-description"}
UPSTREAM_SYSTEM_DOCS: set = set()

LINK_RE = re.compile(r"(?<!!)\[[^\]]*\]\(([^)\s]+)\)")
LINK_SCOPES = [
    "docs/*.md",
    AGENTS,
    ".agents/README.md",
    ".agents/docs/**/*.md",
    ".agents/skills/**/*.md",
    ".cursor/rules/*.mdc",
    "apps/deploy/README.md",
    "client-patches/README.md",
]

errors = []


def read(path: str) -> str:
    with open(os.path.join(ROOT, path), encoding="utf-8") as fh:
        return fh.read()


def fail(msg: str) -> None:
    errors.append(msg)


def check_agents_md(agents: str) -> None:
    if not re.search(r"^## This fork", agents, re.M):
        fail(f"{AGENTS}: missing '## This fork' section")
    if INDEX not in agents:
        fail(f"{AGENTS}: does not mention {INDEX}")


def check_index_covers(index: str, agents: str) -> None:
    for path in sorted(glob.glob("docs/*.md")):
        name = os.path.basename(path)
        if name == "README.md":
            continue
        if f"]({name})" not in index and f"]({name}#" not in index:
            fail(f"{INDEX}: {path} is not linked")

    for path in sorted(glob.glob(".agents/docs/systems/*.md")):
        name = os.path.basename(path)
        if name[:-3] in UPSTREAM_SYSTEM_DOCS:
            continue
        if f"](../{path})" not in index:
            fail(f"{INDEX}: {path} is not linked")
        if path not in agents:
            fail(f"{AGENTS}: {path} has no routing bullet")

    for skill_dir in sorted(glob.glob(".agents/skills/*/")):
        skill = os.path.basename(skill_dir.rstrip("/"))
        skill_md = f".agents/skills/{skill}/SKILL.md"
        if not os.path.isfile(skill_md):
            fail(f"{skill_dir}: missing SKILL.md")
            continue
        link = f".claude/skills/{skill}"
        if not os.path.islink(link):
            fail(f"{link}: missing or not a symlink (must be a relative symlink to ../../{skill_dir.rstrip('/')})")
        elif os.readlink(link) != f"../../.agents/skills/{skill}":
            fail(f"{link}: points to {os.readlink(link)}, expected ../../.agents/skills/{skill}")
        if skill in UPSTREAM_SKILLS:
            continue
        if f"](../{skill_md})" not in index:
            fail(f"{INDEX}: {skill_md} is not linked")
        if skill not in agents:
            fail(f"{AGENTS}: skill '{skill}' is not mentioned")


def check_cursor_rules() -> None:
    for path in sorted(glob.glob(".cursor/rules/*.mdc")):
        text = read(path)
        match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
        if not match:
            fail(f"{path}: missing YAML frontmatter")
            continue
        front = match.group(1)
        if not re.search(r"^description:\s*\S", front, re.M):
            fail(f"{path}: frontmatter has no description")
        always = re.search(r"^alwaysApply:\s*true", front, re.M)
        globs = re.search(r"^globs:\s*\S", front, re.M)
        if not (always or globs):
            fail(f"{path}: needs 'alwaysApply: true' or a 'globs:' list, otherwise it never loads")


def check_links() -> None:
    files: list = []
    for pattern in LINK_SCOPES:
        files.extend(glob.glob(pattern, recursive=True))
    for path in sorted(set(files)):
        if not os.path.isfile(path) or os.path.islink(path):
            continue
        text = read(path)
        base = os.path.dirname(path)
        for target in LINK_RE.findall(text):
            if target.startswith(("http://", "https://", "mailto:", "#")):
                continue
            target = target.split("#", 1)[0]
            if not target:
                continue
            resolved = os.path.normpath(os.path.join(base, target))
            if not os.path.exists(os.path.join(ROOT, resolved)):
                fail(f"{path}: broken link -> {target}")


def main() -> int:
    for required in (INDEX, AGENTS):
        if not os.path.isfile(required):
            print(f"{required} is missing; run from the repository root", file=sys.stderr)
            return 1
    index = read(INDEX)
    agents = read(AGENTS)
    check_agents_md(agents)
    check_index_covers(index, agents)
    check_cursor_rules()
    check_links()
    if errors:
        print("Documentation index check failed:\n")
        for err in errors:
            print(f"  - {err}")
        print(f"\n{len(errors)} problem(s). See docs/README.md 'Adding a doc' and .agents/README.md.")
        return 1
    print("Documentation index check passed.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
