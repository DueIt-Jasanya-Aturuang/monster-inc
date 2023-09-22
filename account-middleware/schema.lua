local typedefs = require "kong.db.schema.typedefs"

return {
    name = "account-middleware",
    fields = {
        { protocols = typedefs.protocols_http },
        { config = {
            type = "record",
            fields = {
                { validation_endpoint = typedefs.url({ required = true }) },
                { ssl_verify = { type = "boolean", default = false, required = false } },
                { userid_header = { type = "string", default = "User-ID", required = false } },
            }
        }
        }
    }
}