.PHONY: all apply destroy inventory

all: apply inventory ssh-trust cluster kubeconfig monitoring-ingress monitoring-tfvars monitoring-tf ingress-rules 

apply:
	@if [ ! -d ".terraform" ]; then terraform init; fi
	terraform apply -auto-approve
	@echo "[*] Waiting 1 minute to allow VMs to boot..."
	sleep 60
ssh-trust:
	@echo "[*] Adding SSH host keys..."
	@bastion_ip=$$(terraform output -raw k8s_master_public_ip); \
	ssh-keyscan -H $$bastion_ip >> ~/.ssh/known_hosts 2>/dev/null || true; \
	for host in $$(terraform output -raw k8s_worker_b_ip) $$(terraform output -raw k8s_worker_d_ip); do \
	  ssh -o StrictHostKeyChecking=no ubuntu@$$bastion_ip "ssh-keyscan -H $$host" >> ~/.ssh/known_hosts || true; \
	done
	@echo "[+] SSH trust added for bastion and workers"

destroy:
	terraform destroy -auto-approve
	@echo "[+] Terraform ресурсы удалены"
	@rm -f ../ansible-kubespray/inventory/mycluster/hosts.yaml
	@rm -f ../monitoring/monitoring-ingress.yaml
	@rm -f ../monitoring/terraform.tfvars
	@rm -f ~/.kube/config

inventory:
	@mkdir -p ../ansible-kubespray/inventory/mycluster
	@echo "[*] Генерация ../ansible-kubespray/inventory/mycluster/hosts.yaml"

	@k8s_master_public_ip=$$(terraform output -raw k8s_master_public_ip); \
	k8s_master_private_ip=$$(terraform output -raw k8s_master_private_ip); \
	k8s_worker_b_ip=$$(terraform output -raw k8s_worker_b_ip); \
	k8s_worker_d_ip=$$(terraform output -raw k8s_worker_d_ip); \
	K8S_MASTER_PUBLIC_IP=$$k8s_master_public_ip \
	K8S_MASTER_PRIVATE_IP=$$k8s_master_private_ip \
	K8S_WORKER_B_IP=$$k8s_worker_b_ip \
	K8S_WORKER_D_IP=$$k8s_worker_d_ip \
	envsubst < generate_hosts.yaml.tmpl \
	> ../ansible-kubespray/inventory/mycluster/hosts.yaml

	@echo "[+] Файл hosts.yaml успешно создан"

# Установка Kubernetes с Kubespray
cluster:
	@echo "[*] Запуск Ansible Kubespray для развертывания кластера..."
	cd ../ansible-kubespray && \
	. venv/bin/activate && \
	ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root cluster.yml
	@echo "[+] Kubernetes кластер успешно развернут!"
#cfg:
#	@k8s_master_public_ip=$$(terraform output -raw k8s_master_public_ip); \
#	K8S_MASTER_PUBLIC_IP=$$k8s_master_public_ip \
#	envsubst < ansible.cfg.tmpl > ../ansible-kubespray/ansible.cfg
#	@echo "[+] ansible.cfg с ProxyCommand сгенерирован"

kubeconfig:
	@echo "[*] Копируем kubeconfig с мастер-ноды..."
	@mkdir -p ~/.kube
	@k8s_master_public_ip=$$(terraform output -raw k8s_master_public_ip); \
	ssh -o StrictHostKeyChecking=no ubuntu@$$k8s_master_public_ip "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config; \
	sed -i "s#server: https://.*:6443#server: https://$${k8s_master_public_ip}:6443#g" ~/.kube/config; \
	sed -i '/certificate-authority-data/d' ~/.kube/config; \
	if grep -q "insecure-skip-tls-verify" ~/.kube/config; then \
	    sed -i "s/insecure-skip-tls-verify.*/insecure-skip-tls-verify: true/" ~/.kube/config; \
	else \
	    sed -i "/server: https:\/\/$${k8s_master_public_ip}:6443/a \ \ \ \ insecure-skip-tls-verify: true" ~/.kube/config; \
	fi; \
	echo "[+] kubeconfig обновлён (server: https://$${k8s_master_public_ip}:6443, skip TLS verify, CA-data удалён)"

monitoring-ingress:
	@k8s_master_public_ip=$$(terraform output -raw k8s_master_public_ip); \
	K8S_MASTER_PUBLIC_IP=$$k8s_master_public_ip \
	envsubst < monitoring-ingress.yaml.tmpl > ../monitoring/monitoring-ingress.yaml; \
	echo "[+] monitoring-ingress.yaml создан с IP=$$k8s_master_public_ip"

monitoring-tfvars:
	@k8s_master_public_ip=$$(terraform output -raw k8s_master_public_ip); \
	echo "k8s_master_public_ip = \"$$k8s_master_public_ip\"" > ../monitoring/terraform.tfvars; \
	echo "[+] terraform.tfvars created in monitoring directory with IP=$$k8s_master_public_ip"

monitoring-tf:
	@echo "[*] Инициализация и применение Terraform для мониторинга..."
	@cd ../monitoring && \
	terraform init && \
	terraform apply -auto-approve
	@echo "[+] Система мониторинга развернута через Terraform"

ingress-rules:
	@echo "[*] Configuring ingress redirection rules..."
	@../monitoring/configure_ingress.sh $(shell terraform output -raw k8s_master_public_ip)