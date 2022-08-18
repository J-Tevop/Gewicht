do-start:
	@echo "\n=== Starting project containers ===\n"
	@${docker-compose-up} || ( echo "\n Could not start containers \n"; exit 1 )
	@echo "\n=== Containers are running! ==="
	@echo "\n> Visit https://cfaa-dev.nl to see the project"

do-start-proxy:
	@echo "\n=== Start hosts proxy ===\n"
	@./start.sh

do-connect-proxy:
	@echo "\n=== Connect to hosts proxy ===\n"
	@docker network connect gew gew-dev-proxy && echo "Connected." || true

do-stop-proxy:
	@echo "\n=== Stop hosts proxy ===\n"
	@docker container stop gew-dev-proxy && echo "Stopped." || true

do-prepare-proxy:
	@echo "\n=== Creating certificates ===\n"
	@mkdir -p ./dev/traefik-config/certs || true \
	&& cd ./dev/traefik-config/certs \
	&& (mkcert gew-dev.nl \
	&& echo "> certificates created") \
	|| echo "> could not create certificates, did you install mkcert?"
	@echo "\n=== Copy dev proxy config ===\n"
	@cp ./dev/traefik-config/gew.yml ~/.gew-dev-proxy/config/gew.yml
	@cp ./dev/traefik-config/certs/* ~/.gew-dev-proxy/certs/
	@echo "> configuration copied"

do-check-hosts-file:
	@cat /etc/hosts | grep gew-dev.nl> /dev/null \
	|| (echo "\n=== HOSTS MISSING ===\n\n \
	You are missing some hosts in your /etc/hosts file:" \
	"127.0.0.1 gew-dev.nl" \
	&& false)