local typedefs = require "kong.db.schema.typedefs"

return {
    name = "middleware",
    fields = {
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { ssl_verify = { type = "boolean", default = false, required = false } },
                { auth = { type = "boolean", default = true, required = false } },
                { account = { type = "boolean", default = true, required = false } },
                { apiKeyAuth_header = { type = "string", default = "null", required = false } },
                { apiKeyAccount_header = { type = "string", default = "null", required = false } },
                { apiKeyFinance_header = { type = "string", default = "null", required = false } },
                { key = { type = "string", default = "null", required = true } },
            }
        }
        }
    }
}