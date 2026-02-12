# Xenin Inventory - DarkRP Weapon Dupe Hotfix

Hotfix for Xenin Inventory + DarkRP weapon duplication exploit during drop/holster race conditions.

## Problem

In some Xenin Inventory setups, `dropDRPWeapon` could be triggered more than once for the same weapon before the first drop finished.  
That race window could duplicate dropped weapons.

## Fix

This patch hardens the drop flow by:

- verifying ownership before drop (`weapon:GetOwner()`)
- locking the weapon entity while it is being dropped (`weapon.IsBeingDarkRPDropped`)

The lock blocks repeated drop calls on the same weapon entity and closes the dupe race condition.

## Installation

1. Place the file inside Xenin Inventory at:  
   `addons/xenin-inventory/lua/autorun/xenin_inventory_weapon_dupe_hotfix.lua`
2. Restart the server (or run `changelevel`).

## Verification

Run on server console:

```lua
lua_run local f=FindMetaTable("Player").dropDRPWeapon print(debug.getinfo(f).short_src)
```

Expected output includes:
`xenin_inventory_weapon_dupe_hotfix.lua`

## Reference

- DarkRP upstream fix:
  https://github.com/FPtje/DarkRP/commit/876267423c28bdb19f099bcafe558978ff3ee0d5
