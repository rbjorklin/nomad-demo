.PHONY: apply ping hostname ip print-facts playbook gomplate refresh go-gadget-go

INVENTORY ?= inventory.yaml
HOST = nbg12.rbjorklin.com
JOBS = haproxy.hcl node-exporter.hcl netdata.hcl gitea.hcl graylog.hcl jenkins.hcl nexus.hcl prometheus.hcl

apply:
	terraform apply -auto-approve

ping:
	ansible all -i $(INVENTORY) -m ping

host-info:
	ansible all -i $(INVENTORY) -m shell -a 'uname -a ; ip -4 addr show dev eth0'

print-facts:
	ansible all -i $(INVENTORY) -m setup

playbook:
	ansible-playbook -i $(INVENTORY) --diff playbook.yaml

playbook-dryrun:
	ansible-playbook -i $(INVENTORY) --diff --check playbook.yaml

gomplate:
	#gomplate --datasource config=job-config.yaml --file nomad-job-templates/$(TEMPLATE) --out nomad-jobs/$(TEMPLATE)
	gomplate --datasource config=job-config.yaml --input-dir nomad-job-templates/ --output-dir nomad-jobs/

refresh: gomplate
	scp -o stricthostkeychecking=no -r nomad-jobs root@$(HOST):
	ssh -o stricthostkeychecking=no root@$(HOST) /bin/bash -c 'ls -l ; cd nomad-jobs ; for job in $(JOBS) ; do nomad job run $$job ; done'

go-gadget-go: apply playbook gomplate refresh
