local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local jecs = require(ReplicatedStorage.ecs)
local schedule = require(ReplicatedStorage.schedule)

local SYSTEM = schedule.SYSTEM
local RUN = schedule.RUN

require(ReplicatedStorage.components)
local world = jecs.world()

local systems = ServerScriptService.systems

SYSTEM(world, systems.replication)
SYSTEM(world, systems.players_added)
SYSTEM(world, systems.poison_hurts)
SYSTEM(world, systems.health_regen)
SYSTEM(world, systems.lifetimes_expire)
SYSTEM(world, systems.life_is_painful)
SYSTEM(world, ReplicatedStorage.systems.entities_delete)
RUN(world, 0)
