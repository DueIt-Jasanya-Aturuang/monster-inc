local BasePlugin = require "kong.plugins.base_plugin"
local access = require "kong.plugins.acustom-auth.access"

local TokenHandler = BasePlugin:extend()

function TokenHandler:new()
    TokenHandler.super.new(self, "acustom-auth")
end

function TokenHandler:access(conf)
    TokenHandler.super.access(self)
    access.run(conf)
end

return TokenHandler