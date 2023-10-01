package main

import (
	"encoding/json"

	"github.com/Kong/go-pdk"
)

type Config struct {
	Apikey string
}

func New() interface{} {
	return &Config{}
}

func (conf Config) Access(kong *pdk.PDK) {
	key, err := kong.Request.GetHeader("key")
	apiKey := conf.Apikey

	if err != nil {
		kong.Log.Err(err.Error())
	}

	x := make(map[string][]string)
	x["Content-Type"] = append(x["Content-Type"], "application/json")

	resp := map[string]interface{}{
		"status":  "05",
		"message": "FORBIDDEN",
		"errors":  "invalid key",
		"data":    nil,
	}
	marshal, err := json.Marshal(resp)
	if err != nil {
		kong.Response.Exit(500, "internal server error", x)
	}

	if apiKey != key {
		kong.Response.Exit(403, string(marshal), x)
	}
}
