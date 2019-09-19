.PHONY: ping hostname ip print-facts playbook gomplate

INVENTORY ?= inventory.yaml

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
