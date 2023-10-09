local _Access = { conf = {} }
local http = require "resty.http"
local cjson = require "cjson.safe"

local activasiAccountPath = "/auth/activasi-account"
local logoutPath = "/auth/logout"
local kongError = "Authentication internal server error"
local keyKong = "secretkeyjasanyaauth"

function _Access.error_response(errors, status, message, data, code)
    local dataJson = {
        errors = errors,
        status = status,
        message = message,
        data = data,
    }
    local json_data = cjson.encode(dataJson)
    ngx.header["Content-Type"] = "application/json"
    ngx.status = code
    ngx.say(json_data)
    ngx.exit(code)
end

function _Access.getActvitedHeader(path)
    local request_path = path
    if request_path == activasiAccountPath then
        return "true"
    elseif request_path == logoutPath then
        return "true"
    else
        return "false"
    end
end

function _Access.otorisasi_auth(token, appId, userId, otorisasiActivitedAccountCondition)
    local httpc = http:new()

    local res, err = httpc:request_uri("https://auth.jasanya.tech/auth/otorisasi", {
        method = "POST",
        ssl_verify = _Access.conf.ssl_verify,
        headers = {
            ["Content-Type"] = "application/json",
            ["Authorization"] = token,
            ["App-ID"] = appId,
            ["User-ID"] = userId,
            ["Activasi"] = otorisasiActivitedAccountCondition,
            ["X-Api-Key"] = _Access.conf.apiKeyAuth_header
        }
    })

    if not res then
        ngx.log(ngx.ERR, err)
        return res
    end

    ngx.req.set_header("Authorization", res.headers["Authorization"])
    ngx.req.set_header("X-Api-Key", _Access.conf.apiKeyAuth_header)

    if res.status ~= 200 then
        return { status = res.status, body = res.body, autho = res.headers["Authorization"] }
    end

    return { status = res.status, body = res.body, autho = res.headers["Authorization"] }
end

function _Access.otorisasi_account(userId)
    local httpc = http:new()

    local res, err = httpc:request_uri("https://account.dueit.my.id/account/otorisasi", {
        method = "POST",
        ssl_verify = _Access.conf.ssl_verify,
        headers = {
            ["Content-Type"] = "application/json",
            ["User-ID"] = userId,
            ["X-Api-Key"] = _Access.conf.apiKeyAccount_header
        }
    })

    if not res then
        ngx.log(ngx.ERR, err)
        return res
    end

    ngx.req.set_header("Profile-ID", res.headers["Profile-ID"])
    ngx.req.set_header("X-Api-Key", _Access.conf.apiKeyAccount_header)

    if res.status ~= 200 then
        return { status = res.status, body = res.body, profile_id = res.headers["Profile-ID"] }
    end

    ngx.log(ngx.ERR, res.headers["Profile-ID"])

    return { status = res.status, body = res.body, profile_id = res.headers["Profile-ID"] }
end

function _Access.otorisasi(token, appId, userId, otorisasiActivitedAccountCondition, conf)
    if conf.auth then
        ngx.log(ngx.ERR, "auth otorisasi")
        local res = _Access.otorisasi_auth(token, appId, userId, otorisasiActivitedAccountCondition)
        if not res or res.status ~= 200 then
            return res
        end
    end

    if conf.account then
        ngx.log(ngx.ERR, "account otorisasi")
        local res = _Access.otorisasi_account(userId)
        if not res or res.status ~= 200 then
            return res
        end
    end

    return ngx.null
end

function _Access.run(conf)
    _Access.conf = conf
    if keyKong ~= ngx.req.get_headers()["X-Key"] then
        _Access.error_response("invalid key", "05", "FORBIDDEN", ngx.null, 403)
    end

    ngx.log(ngx.ERR, "masuk satu")
    local token = ngx.req.get_headers()["Authorization"]
    local appId = ngx.req.get_headers()["App-ID"]
    local userId = ngx.req.get_headers()["User-ID"]

    ngx.log(ngx.ERR, "masuk dua")
    local activited = _Access.getActvitedHeader(ngx.var.request_uri)

    ngx.log(ngx.ERR, "masuk tiga")
    local res = _Access.otorisasi(token, appId, userId, activited, _Access.conf)

    ngx.log(ngx.ERR, "masuk empat")
    if res ~= ngx.null then
        ngx.log(ngx.ERR, "masuk lima")
        if not res then
            _Access.error_response(kongError, "99", "internal server error", ngx.null, ngx.HTTP_INTERNAL_SERVER_ERROR)
        end

        ngx.log(ngx.ERR, "masuk enam")
        if res.status ~= 200 then
            ngx.log(ngx.ERR, "masuk tuju")
            ngx.header["Content-Type"] = "application/json"

            ngx.status = res.status
            ngx.say(res.body)
            ngx.exit(res.status)
        end
    end

    ngx.log(ngx.ERR, "masuk delapan")
    ngx.req.set_header("X-Api-Key", _Access.conf.key)

    ngx.log(ngx.ERR, "masuk sembilan")
    -- ngx.req.clear_header(_Access.conf.token_header)
end

return _Access