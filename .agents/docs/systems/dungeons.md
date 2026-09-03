# Dungeons

When designing or implementing a 5-man (overlay or real instance), follow
`.agents/skills/build-dungeon/SKILL.md` before writing SQL or C++.

Short rules:

- Overlay on map 0 cannot grow caves or delete ADT doodads (trees).
- Never teleport to map 44 unless `patch-4` **replaced** the leftover Scarlet
  `Monastery.wdt`, the client was **restarted**, and the data volume has both
  `vmaps/044.vmtree` **and** the WMO mesh `vmaps/<Name>.wmo.vmo`. WMO-only maps
  have no `maps/044*.map`; a tiny vmtree is normal. Missing `.vmo` = underwater
  then fall. As shipped, map 44 is unused Scarlet interior, not a blank cave.
  WMO-only dest = −Blender XY; `liquid_type` 15; pad MODF AABB on all axes.
- Custom areatrigger ids not in `AreaTrigger.dbc` never fire.
- Trash needs `lootid` + gold or corpses are empty. 5-man trash is rank 1
  with HealthModifier ~2.4+, not outdoor HM 1.
- End-boss personal class weapons: C++ `AddItem` per player, not a shared
  loot group (copies of the same class must not collapse into one roll).
- WMO-only caves without mmaps: `IGNORE_PATHFINDING` on combat NPCs or they
  heal in combat (non-raid cannot-reach regen).
- Custom content: module SQL, ids `9000000+`, clone appearance only.

Mesh / extract / DBC details: `.agents/skills/build-dungeon/reference-mesh.md`.
Content bar (rooms, loot, shrines): `.agents/skills/build-dungeon/reference-content.md`.
Visual walk (screenshots, scout client, not SOAP-only): `.agents/skills/walk-instance/SKILL.md`.
