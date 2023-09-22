local _Access = { conf = {} }
local http = require "resty.http"
--local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"

function _Access.error_response(res)
    ngx.log(ngx.ERR, "procces error_response")
    local jsonString = '{"data": [], "error": { "code":"' .. "res" .. '", "message": "' .. res .. '"}}'
    ngx.header["Content-Type"] = "application/json"
    ngx.status = res.status
    ngx.say(jsonString)
    ngx.exit(res.status)
end

function _Access.validate_token(userId)
    local httpc = http:new()

    local res, err = httpc:request_uri(_Access.conf.validationaccount_endpoint, {
        method = "POST",
        ssl_verify = _Access.conf.ssl_verify,
        headers = {
            ["Content-Type"] = "application/json",
            ["User-ID"] = userId,
        }
    })

    if not res then
        ngx.log(ngx.ERR, err)
        return res
    end

    if res.status ~= 200 then
        return { status = res.status, body = res.body, profile_id = res.headers["Profile-ID"] }
    end

    ngx.log(ngx.ERR, res.headers["Profile-ID"])

    return { status = res.status, body = res.body, profile_id = res.headers["Profile-ID"] }
end

function _Access.run(conf)
    _Access.conf = conf
    local userId = ngx.req.get_headers()[_Access.conf.useridaccount_header]
    -- if not token then
    -- _Access.error_response("Unauthenticated", ngx.HTPP_UNAUTHORIZED)
    -- end

    --local request_path = ngx.var.request_uri

    local res = _Access.validate_token(userId)
    -- if not res then
    -- _Access.error_response("Authentication server error", ngx.HTTP_INTERNAL_SERVER_ERROR)
    -- end
    if not res then
        local data = {
            errors = "Authentication internal server error",
        }
        local json_data = cjson.encode(data)
        ngx.header["Content-Type"] = "application/json"
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.say(json_data)
        ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end

    if res.status ~= 200 then
        ngx.header["Content-Type"] = "application/json"
        ngx.status = res.status
        ngx.say(res.body)
        ngx.exit(res.status)
    end

    ngx.req.set_header("Profile-ID", res.profile_id)
    -- if res.status ~= 200 then
    -- _Access.error_response("Authentication refused the resquest", ngx.HTTP_UNAUTHORIZED)
    -- end

    -- ngx.req.clear_header(_Access.conf.token_header)
end

return _Access