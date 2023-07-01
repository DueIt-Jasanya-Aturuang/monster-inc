local _Access = { conf = {} }
local http = require "resty.http"
local pl_stringx = require "pl.stringx"
local cjson = require "cjson.safe"

function _Access.error_response(res)
    local jsonString = '{"data": [], "error": { "code":"' .. "res" ..'", "message": "' .. res .. '"}}'
    ngx.header["Content-Type"] = "application/json"
    ngx.status = res.status
    ngx.say(jsonString)
    ngx.exit(res.status)
end

function _Access.validate_token(token,appId,userId,activasiAccount)
    local httpc = http:new()

    local res, err = httpc:request_uri(_Access.conf.validation_endpoint, {
	method = "POST",
	ssl_verify = _Access.conf.ssl_verify,
	headers = {
	    ["Content-Type"] = "application/json",
	    ["Authorization"] = token,
        ["App-Id"] = appId,
        ["User-Id"] = userId,
        ["Activasi-Account"] = activasiAccount
	}
    })

    if not res then
	return res
    end

    if res.status ~= 200 then
	return { status = res.status, body = res.body }
    end

    return { status = res.status, body = res.body }
end

function _Access.run(conf)
    _Access.conf = conf
    local token = ngx.req.get_headers()[_Access.conf.token_header]
    local appId = ngx.req.get_headers()[_Access.conf.appid_header]
    local userId = ngx.req.get_headers()[_Access.conf.userid_header]
    local activasiAccount = ngx.req.get_headers()[_Access.conf.activasi_account]

    -- if not token then
	-- _Access.error_response("Unauthenticated", ngx.HTPP_UNAUTHORIZED)
    -- end

    local request_path = ngx.var.request_uri

    local res = _Access.validate_token(token,appId,userId,activasiAccount)

    -- if not res then
	-- _Access.error_response("Authentication server error", ngx.HTTP_INTERNAL_SERVER_ERROR)
    -- end
    if not res then
    ngx.header["Content-Type"] = "application/json"
    ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
	ngx.say("Authentication server error")
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
    end


    if res.status ~= 200 then
    ngx.header["Content-Type"] = "application/json"
    ngx.status = res.status
	ngx.say(res.body)
    ngx.exit(res.status)
    end
    -- if res.status ~= 200 then
	-- _Access.error_response("Authentication refused the resquest", ngx.HTTP_UNAUTHORIZED)
    -- end

    -- ngx.req.clear_header(_Access.conf.token_header)
end

return _Access