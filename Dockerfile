#FROM kong/go-plugin-tool:2.0.4-alpine-latest AS builder
#
#RUN mkdir -p /tmp/dueit-gateway/

#COPY . /tmp/dueit-gateway/

#RUN cd /tmp/dueit-gateway/ && go get github.com/Kong/go-pdk && rm -r go.mod && go mod init kong-go-plugin && go get -d -v github.com/Kong/go-pluginserver && go build github.com/Kong/go-pluginserver && go build -buildmode plugin key-checker.go


FROM kong:2.0.4-alpine

RUN mkdir /tmp/go-plugins
USER root
#COPY --from=builder  /tmp/dueit-gateway/go-pluginserver /usr/local/bin/go-pluginserver
#COPY --from=builder  /tmp/dueit-gateway/key-checker.so /tmp/go-plugins
# RUN sudo mkdir /usr/local/share/lua/5.1/kong/plugins/middleware
COPY  ./middleware /usr/local/share/lua/5.1/kong/plugins/middleware
#COPY --from=builder  /tmp/dueit-gateway/account-middleware /usr/local/share/lua/5.1/kong/plugins/baccount-middleware
COPY config.yml /tmp/config.yml
COPY config_production.yml /tmp/config_production_replace.yml

RUN sed "s/REPLACE_WITH_API_KEY_AUTH/$API_KEY_AUTH/g" /tmp/config_production_replace.yml > /tmp/config_production.yml


RUN #chown -R kong:kong /tmp
RUN chmod -R 777 /tmp
#RUN /usr/local/bin/go-pluginserver -version && \
#   cd /tmp/go-plugins && \
#   /usr/local/bin/go-pluginserver -dump-plugin-info key-checker
USER kong