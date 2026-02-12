if not SERVER then return end

hook.Add("Initialize", "XeninInventory.WeaponDupeHotfix", function()
  timer.Simple(11, function()
    local PLY = FindMetaTable("Player")
    if not PLY then return end

    function PLY:dropDRPWeapon(weapon, callback, holster)
      callback = callback or function() end

      if (not IsValid(weapon) or weapon:GetOwner() ~= self or weapon:GetModel() == "" or weapon.IsBeingDarkRPDropped) then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return
      end

      local canDrop = hook.Run("canDropWeapon", self, weapon)
      if not canDrop then
        DarkRP.notify(self, 1, 4, DarkRP.getPhrase("cannot_drop_weapon"))
        return
      end

      weapon.IsBeingDarkRPDropped = true

      if not holster then
        self:DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_DROP)
      end

      local time = 0
      if holster then
        time = (XeninInventory and XeninInventory.Config and XeninInventory.Config.HolsterTime and XeninInventory.Config.HolsterTime[weapon:GetClass()]) or 1

        if (time > 1 and self.XeninInventory) then
          self:XeninInventory():Message("It will take " .. time .. " seconds to holster")
        end
      end

      local function Drop()
        if (not IsValid(self) or not IsValid(weapon)) then
          if IsValid(weapon) then
            weapon.IsBeingDarkRPDropped = nil
          end
          return
        end

        local ammo = self:GetAmmoCount(weapon:GetPrimaryAmmoType())
        self:DropWeapon(weapon)

        local ent = ents.Create("spawned_weapon")
        local model = (weapon:GetModel() == "models/weapons/v_physcannon.mdl" and "models/weapons/w_physics.mdl") or weapon:GetModel()
        model = util.IsValidModel(model) and model or "models/weapons/w_rif_ak47.mdl"

        ent:SetPos(self:GetShootPos() + self:GetAimVector() * 30)
        ent:SetModel(model)
        ent:SetSkin(weapon:GetSkin() or 0)
        ent:SetWeaponClass(weapon:GetClass())
        ent.nodupe = true
        ent.clip1 = weapon:Clip1()
        ent.clip2 = weapon:Clip2()
        ent.ammoadd = ammo

        hook.Call("onDarkRPWeaponDropped", nil, self, ent, weapon)

        self:RemoveAmmo(ammo, weapon:GetPrimaryAmmoType())
        self:RemoveAmmo(self:GetAmmoCount(weapon:GetSecondaryAmmoType()), weapon:GetSecondaryAmmoType())

        ent:Spawn()
        weapon:Remove()

        callback(ent)
      end

      if time == 0 then
        Drop()
      else
        timer.Simple(time, Drop)
      end
    end
  end)
end)
