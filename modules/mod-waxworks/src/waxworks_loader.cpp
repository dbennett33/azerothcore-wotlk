/*
 * This file is part of the AzerothCore Project. See AUTHORS file for Copyright information
 *
 * This program is free software; you can redistribute it and/or modify it
 * under the terms of the GNU Affero General Public License as published by the
 * Free Software Foundation; either version 3 of the License, or (at your
 * option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License
 * for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program. If not, see <http://www.gnu.org/licenses/>.
 */

void AddSC_waxworks_player();
void AddSC_npc_sergeant_wickham();
void AddSC_boss_king_wick();
void AddSC_boss_chef_snarlroast();
void AddSC_boss_foreman_voss();
void AddSC_boss_princess();
void AddSC_waxworks_portal();
void AddSC_instance_waxworks();

// Folder mod-waxworks -> Addmod_waxworksScripts()
void Addmod_waxworksScripts()
{
    AddSC_waxworks_player();
    AddSC_npc_sergeant_wickham();
    AddSC_boss_king_wick();
    AddSC_boss_chef_snarlroast();
    AddSC_boss_foreman_voss();
    AddSC_boss_princess();
    AddSC_waxworks_portal();
    AddSC_instance_waxworks();
}
