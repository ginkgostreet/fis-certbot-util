
help:
	# Generate Let's Encrypt Certificates
	#
	# Use the Source Luke
	#
	# Of primary interest:
	# - refresh - will generate dev, stage, and prod files that list all of the sites in htdocs/sites for that environment
	#
	# TIP:
	# if a host doesn't have a DNS entry, do a `make lists`
	# and then edit the invalid entries before running obtain-certs

site-list:
	@ls /var/www/prod.israelscouts.org/htdocs/sites -1 | grep .org | sort | sed s/.israelscouts.org// > $@

define generate_urls
	for site in `cat site-list`; \
	do \
		echo -n $$site$(SITE_SUFFIX).israelscouts.org,; \
	done
endef

.PHONY: lists
lists: prod stage dev

prod: SITE_SUFFIX ?= 
prod: site-list
	@$(generate_urls) > $@
	@sed -i 's#,$$##' $@

stage: SITE_SUFFIX ?= -stage
stage: site-list
	@$(generate_urls) > $@
	@sed -i 's#,$$##' $@

dev: SITE_SUFFIX ?= -dev
dev: site-list
	@$(generate_urls) > $@
	@sed -i 's#,$$##' $@

.PHONY: clean
clean:
	- rm -f site-list
	- rm -f prod dev stage

.PHONY: refresh
refresh: clean
	@$(MAKE) lists
	@ echo "\n"
	@ cat prod
	@ echo "\n"
	@ cat stage
	@ echo "\n"
	@ cat dev

define obtain-cert
	certbot certonly -d $(shell cat $(TARGET_ENV)) --apache -m 'devs+fis@ginkgostreet.com'
endef

.PHONY: obtain-cert-prod
obtain-cert-prod: TARGET_ENV ?= prod
obtain-cert-prod:
	$(obtain-cert)

.PHONY: obtain-cert-stage
obtain-cert-stage: TARGET_ENV ?= stage
obtain-cert-stage: stage
	$(obtain-cert)

.PHONY: obtain-cert-dev
obtain-cert-dev: TARGET_ENV ?= dev
obtain-cert-dev:
	$(obtain-cert)

.PHONY: obtain-certs
obtain-certs: obtain-cert-prod obtain-cert-stage obtain-cert-dev

