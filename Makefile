SEALED_CERT = ./sealed-secrets-cluster-cert.pem

.PHONY: prod all

define gen_app_secret
	set -a; \
	. $(1); \
	set +a; \
	kubectl create secret generic app-secret \
		-n default \
		--from-literal=POSTGRES_USER=$$POSTGRES_USER \
		--from-literal=POSTGRES_PASSWORD=$$POSTGRES_PASSWORD \
		--from-literal=POSTGRES_DB=$$POSTGRES_DB \
		--from-literal=MESSENGER_API_KEY=$$MESSENGER_API_KEY \
		--dry-run=client -o yaml | \
	kubeseal --cert $(SEALED_CERT) --format yaml --namespace default -o yaml > $(2)/app-secret-sealed.yaml
endef

prod:
	@mkdir -p prod
	$(call gen_app_secret,.env.prod,prod)

all: prod