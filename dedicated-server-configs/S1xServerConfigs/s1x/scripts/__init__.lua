--[[
   Mod: Custom GunGame
   Version: V1.0.0
   Client: s1x - COD Advanced Warfare
   Author: DoktorSAS 
   Special Thanks to quaK

   Socials:
   Twitter  : https://twitter.com/DoktorSAS
   Discord  : https://discord.gg/8HNGUTVvmd
   Youtube  : https://www.youtube.com/channel/UCfMGaICm89h7g-54iBTFA4w
   Github   : https://github.com/DoktorSAS
]]--

--[[ Gametype Config ]]--
local Config = {}
--[[
    1 -> Enable
    0 -> Disable
]]--
Config.HighJump = 1
Config.HighJumpDrop = 1
Config.Dodge = 1
Config.PowerSlide = 1
Config.BoostJump = 1
Config.KillstreaksPerks = 1
Config.HumiliatonsForKill = 1
--[[
    dm  -> Free For All
    war -> Team Deathmatch
]]--
Config.Gametype = "war"

--[[ GunGame ]]--
include("utilities")
if game:getdvar("g_gametype") ~= Config.Gametype then
    game:setdvar("g_gametype", Config.Gametype)
	game:executecommand("map_restart")
end
game:setdvar("sct_game_high_jump", Config.HighJump)
if Config.Gametype == "dm" then
    game:setdvar("scr_dm_score_kill", 1)
    game:setdvar("scr_dm_score_assist", 0)
elseif Config.Gametype == "war" then
    game:setdvar("scr_war_score_kill", 1)
    game:setdvar("scr_war_score_assist", 0)
end

game:setdvar("g_maxDroppedWeapons", 2)

require("bots")

local colors = {    red = "^1",
					green = "^2",
					yellow = "^3",
					blue = "^4",
					cyan = "^5",
					pink = "^6",
                    white = "^7",
					team_color = "^8",
					grey = "^9",
					black = "^0",
					rainbow = "^:"
					}
local teams = { 	spectator = "spectator",
					axis = "axis",
					allies = "allies"
					}
local sessionstates = {	spectator = "spectator",
						dead = "dead",
						playing = "playing"
}

local social = {    author = "DoktorSAS",
                    twitter = "DoktorSAS",
					instagram = "DoktorSAS",
					website = "https://github.com/DoktorSAS",
					discord = "https://discord.gg/8HNGUTVvmd"
}

print("=====================================================")
print("\t GunGame Developed by " .. social.author)
print("\t Special thanks to quaK")
print("=====================================================")
local players = {}
for i = 0, 18, 1 do
    players[i] = {isBot = false, suicide = false, gun = 1, humiliator = "", lastgun = "", streak = 0, isConnected = false};
end

local guns = {
                "iw5_pbw_mp", -- Pistol
                "iw5_rw1_mp",
                "iw5_titan45_mp",
                "iw5_uts19_mp", -- Shotgun
                "iw5_maul_mp",
                "iw5_rhino_mp",
                "iw5_kf5_mp", -- SMG
                "iw5_sac3_mp_akimbosac3",
                "iw5_asm1_mp",
                "iw5_hmr9_mp",
                "iw5_sn6_mp",
                "iw5_mp11_mp",
                "iw5_himar_mp",
                "iw5_hbra3_mp", -- Rifle
                "iw5_bal27_mp",
                "iw5_ak12_mp",
                "iw5_epm3_mp",
                "iw5_arx160_mp",
                "iw5_m182spr_mp",
                "iw5_asaw_mp", -- MG
                "iw5_exoxmg_mp",
                "iw5_lsat_mp",
                "iw5_mahem_mp", -- Launcher
                "iw5_maaws_mp",
                "iw5_mors_mp", -- Snipers
                "iw5_thor_mp",
                "iw5_m990_mp",
                "iw5_gm6_mp",
                "iw5_em1_mp", -- Beam
                "iw5_exocrossbow_mp", -- Crossbow
                "iw5_combatknife_mp" -- Knife
}
if Config.Gametype == "war" then
    game:setdvar("scr_war_scorelimit", 0) 
elseif Config.Gametype == "dm" then
    game:setdvar("scr_dm_scorelimit", size(guns)) 
end

function entity:onPlayerSpawned(  )
    entity_number = self:getentitynumber()
    if players[entity_number].sucide then
        self:iclientprintlnbold("You got ".. colors.red .. "Humiliated")
        players[entity_number].sucide = false
        if players[entity_number].gun > 1 then
            players[entity_number].gun = players[entity_number].gun - 1
        end
        self:setPoints( (indexof(guns, guns[players[entity_number].gun])-1+Config.HumiliatonsForKill) )
        self:playlocalsound("mp_prestige_purchase") 
    elseif players[entity_number].humiliator ~= "" then
        self:iclientprintlnbold("You got ".. colors.red .. "Humiliated")
        self:iclientprintln(players[entity_number].humiliator .." humiliate " .. colors.white .. "you")
        players[entity_number].humiliator = ""
        if players[entity_number].gun > 1 then
            players[entity_number].gun = players[entity_number].gun - 1
        end
        self:setPoints( (indexof(guns, guns[players[entity_number].gun])-1+Config.HumiliatonsForKill) )
        self:playlocalsound("mp_prestige_purchase")
    end
    self:takeallweapons()
    if players[entity_number].gun <= 0 then
        players[entity_number].gun = 1
    end
    self:giveweapon(guns[players[entity_number].gun])
    self:switchtoweapon(guns[players[entity_number].gun])
    self:setspawnweapon(guns[players[entity_number].gun])
    game:ontimeout(function()
        self:clearperks()
    end, 50)
end

function entity:onWeaponChange(  )
    entity_number = self:getentitynumber()
    if self:getcurrentweapon() ~= "none" and self:getcurrentweapon() ~= nil and self:getcurrentweapon() ~= guns[players[entity_number].gun] then
        self:takeweapon( self:getcurrentweapon() )
        if players[entity_number].gun <= 0 then
            players[entity_number].gun = 1
        end
        if self.score > 0 and self:hasweapon( guns[players[entity_number].gun] ) == 1 then 
            self:switchtoweapon(guns[players[entity_number].gun])
        else
            self:giveweapon(guns[players[entity_number].gun])
            self:switchtoweapon(guns[players[entity_number].gun])
        end
    else
        self:switchtoweapon(guns[players[entity_number].gun])
    end
end

function forceend()
    if game:getdvar("g_gametype") == "war" then
        game:setdvar("scr_war_timelimit", 0.1)
        game:executecommand("set scr_war_timelimit 0.01")
    end
end

function entity:onWeaponReload(  )
    if( players[entity_number].humiliator ~= "") then
        players[entity_number].humiliator = ""
    end
	self:givestartammo( self:getcurrentweapon() )
    
end


local bots_spawned = 8
local players_in_game = 0

local onPlayerConnected = function ( player )

    local onMovements = game:oninterval(function ()
        player:allowdodge(Config.Dodge)
        player:allowpowerslide(Config.PowerSlide)
        player:allowboostjump(Config.BoostJump)
        player:allowhighjump(Config.HighJump)
        player:allowhighjumpdrop(Config.HighJumpDrop)
    end, 50)

    if string.find(player:getguid(), "bot") then
        players[player:getentitynumber()].isBot = true
    else
        players[player:getentitynumber()].isBot = false
    end
    local pID = player:getentitynumber();
    players_in_game = players_in_game + 1
    players[player:getentitynumber()].gun = 1
    players[player:getentitynumber()].isConnected = true

    local onPlayerSpawned = player:onnotify("spawned_player", function()
        player:iclientprintln("Mod developed by @"..colors.cyan.. social.twitter);
        player:iclientprintln( colors.red .. "kill".. colors.white .." players to progress with weapons");
        player:iclientprintln("Welcome to".. colors.cyan .." GunGame " .. colors.white .. "Server");
        player:onPlayerSpawned( )
    end)
    local onWeaponChange = player:onnotify("weapon_change", function()
        player:onWeaponChange()
    end)
    local onPlayerReload = player:onnotify("reload", function( ) 
        player:onWeaponReload()
    end)

    local onWeaponFired = player:onnotify("weapon_fired", function ( weapon )
        if weapon == "iw5_maaws_mp" or weapon == "throwingknife_mp" then
            player:givemaxammo( player:getcurrentweapon() )
        end
    end)
    
    local onGivingLoadout = player:onnotify("givingLoadout", function ( )
        player:onPlayerSpawned()
    end)
    
    player:onnotifyonce("disconnect", function ()
        onPlayerSpawned:clear()
        onWeaponChange:clear()
        onPlayerReload:clear()
        onWeaponFired:clear()
        onGivingLoadout:clear()
        onMovements:clear()
        players[pID] = {isBot = false, suicide = false, gun = 1, humiliator = "", lastgun = "", streak = 0, isConnected = false};
        players_in_game = players_in_game - 1
    end);
end

function show_message(player, msg)
    local elem = game:newclienthudelem(player)
    elem.elemType = "font"
    elem.font = "default"
    elem.fontscale = 2
    elem.x = 0
    elem.y = -100
    elem.alignx = "center"
    elem.aligny = "middle"
    elem.horzalign = "center"
    elem.vertalign = "middle"
    elem.color = vector:new(1.0, 1.0, 1.0)
    elem.alpha = 1
    elem:settext( msg )
    elem:setpulsefx(40, 6000, 600)
    
    game:ontimeout(function()
        elem:destroy()
    end, 8000)
end

function team_win( team )
    local players = game:getentarray("player", "classname")
    for i = 1, #players do 
        if players[i].team == team then
            show_message(players[i], "Your team ^2Win ^7the Game")
        else
            show_message(players[i], "Your team ^1Lost ^7the Game")
        end
    end
   
end


level:onnotifyonce("connected", function ()

    game:onplayerdamage(function(_self, _inflictor, _attacker, damage, dflags, _mod, _weapon, _vPoint, _vDir, _hitLoc)
        return damage
    end)

    game:onplayerkilled(function(_self, _inflictor, _attacker, damage, _mod, _weapon, _vPoint, _vDir, _hitLoc)
        if _attacker.name ~= nil and _attacker:getentitynumber() < 18 then
            entity_number = _attacker:getentitynumber()
            if  players[entity_number].humiliator ~= "" then
                players[entity_number].humiliator = ""
            end
            game_ended = false
            if _mod == "MOD_MELEE_ALT" then
                players[_self:getentitynumber()].humiliator = _attacker.name
                _attacker:setPoints( (_attacker.score-1) )
            elseif _self:getguid() == _attacker:getguid() then
                players[entity_number].humiliator = ""
                _self:setPoints( (_self.score-1+Config.HumiliatonsForKill) )
            elseif players[entity_number].gun > 0 and _weapon == guns[players[entity_number].gun] and (players[entity_number].lastgun == "" or players[entity_number].lastgun ~= guns[players[entity_number].gun]) then
                if Config.Gametype == "war" then
                    if players[entity_number].gun >= size(guns) then
                        forceend()
                        team_win( _attacker.team )
                        game_ended = true
                    end
                end
                if game_ended == false then
                    players[entity_number].lastgun = _weapon
                    _attacker:takeweapon(guns[players[entity_number].gun])
                    players[entity_number].lastgun = guns[players[entity_number].gun-1] 
                    players[entity_number].gun = players[entity_number].gun + 1
                    _attacker:giveweapon(guns[players[entity_number].gun]);
                    _attacker:switchtoweapon(guns[players[entity_number].gun])
                    _attacker:playlocalsound("mp_level_up")
                    players[entity_number].streak = players[entity_number].streak + 1
                    if Config.KillstreaksPerks then
                        if players[entity_number].streak == 3 then
                            _attacker:iclientprintlnbold("Quick Reload ^6Unlocked")
                            _attacker:setperk("specialty_quickdraw", 1, 1)
                        elseif players[entity_number].streak == 5 then
                            _attacker:iclientprintlnbold("Sprint Reload ^6Unlocked")
                            _attacker:setperk("specialty_sprintreload", 1, 1)
                        elseif players[entity_number].streak == 8 then
                            _attacker:iclientprintlnbold("Longer Sprint ^6Unlocked")
                            _attacker:setperk("specialty_longersprint", 1, 1)
                        elseif players[entity_number].streak == 11 then
                            _attacker:iclientprintlnbold("Faster Melee ^6Unlocked")
                            _attacker:setperk("specialty_fastermelee", 1, 1)
                        elseif players[entity_number].streak == 14 then
                            _attacker:iclientprintlnbold("Faster Sprint Recovery ^6Unlocked")
                            _attacker:setperk("specialty_fastsprintrecovery", 1, 1)
                        elseif players[entity_number].streak == 17 then
                            _attacker:iclientprintlnbold("Steady Aim ^6Unlocked")
                            _attacker:setperk("specialty_steadyaimpro", 1, 1)
                        end  
                    end
                end
            elseif players[entity_number].lastgun == "" then
                players[entity_number].lastgun = _weapon
            end
            players[_self:getentitynumber()].streak = 0; 
            _attacker:setPoints( (indexof(guns, guns[players[entity_number].gun])-2) )
            _attacker:setnormalhealth(_attacker.maxhealth )
          
           
        end
        if _weapon ~= nil and _weapon ~= "" and _mod == "MOD_TRIGGER_HURT" or _mod == "MOD_SUICIDE" or _mod == "MOD_PROJECTILE_SPLASH" or  _mod == "MOD_TRIGGER_HURT" then
            players[_self:getentitynumber()].humiliator = _self.name
        elseif _mod == "MOD_TRIGGER_HURT" or _mod == "MOD_SUICIDE" or _mod == "MOD_PROJECTILE_SPLASH" or  _mod == "MOD_TRIGGER_HURT" then
            players[_self:getentitynumber()].sucide = true
            _self:setPoints( (_self.score-1+Config.HumiliatonsForKill) )
        end
    end)
    
end);

level:onnotify("connected", onPlayerConnected)