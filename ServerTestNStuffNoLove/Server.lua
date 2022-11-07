local Account = require "Account"

local Accounts = {}
local Players = {}
local World = require "World"

-- test create account

Accounts["name"] = Account:new("name", "pass")

Accounts["name"]:CreatePlayer(1, Players, World, "name", "race", "class")

