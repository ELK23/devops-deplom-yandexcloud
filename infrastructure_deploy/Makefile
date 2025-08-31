-include .cluster.env

# Пример файла:
# K8S_MASTER_PUBLIC_IP   = <public IP of master/bastion>
# K8S_MASTER_PRIVATE_IP  = <private IP of master> (for hosts.yaml)
# K8S_WORKER_B_IP        = <private IP of worker in zone b>
# K8S_WORKER_D_IP        = <private IP of worker in zone d>

export K8S_MASTER_PUBLIC_IP
export K8S_MASTER_PRIVATE_IP
export K8S_WORKER_B_IP
export K8S_WORKER_D_IP


.PHONY: all check-vars wait-ssh ssh-trust destroy inventory cluster kubeconfig monitoring-ingress monitoring-tfvars monitoring-tf ingress-rules

# Проверка наличия переменных
REQUIRED_VARS = K8S_MASTER_PUBLIC_IP K8S_MASTER_PRIVATE_IP K8S_WORKER_B_IP K8S_WORKER_D_IP

check-vars:
	@missing=""; \
	for v in $(REQUIRED_VARS); do \
	  eval val=\$$v; \
	  if [ -z "$$val" ]; then missing="$$missing $$v"; fi; \
	done; \
	if [ -n "$$missing" ]; then \
	  echo "[!] Missing required vars:$$missing"; \
	  echo "    Provide via: make <target> VAR=value ...  or ./.cluster.env"; \
	  exit 2; \
	fi

wait-ssh: check-vars
	@echo "[*] Waiting for SSH on $(K8S_MASTER_PUBLIC_IP):22 ..."
	@for i in $$(seq 1 60); do \
	  nc -z $(K8S_MASTER_PUBLIC_IP) 22 >/dev/null 2>&1 && echo "[+] SSH is up" && exit 0; \
	  sleep 2; \
	done; \
	echo "[!] SSH still not reachable after 120s" >&2; exit 1


all: inventory ssh-trust cluster kubeconfig monitoring-ingress monitoring-tfvars monitoring-tf ingress-rules

ssh-trust: check-vars wait-ssh
	@echo "[*] Adding SSH host keys..."
	@ssh-keyscan -H $(K8S_MASTER_PUBLIC_IP) >> ~/.ssh/known_hosts 2>/dev/null || true
	@for host in $(K8S_WORKER_B_IP) $(K8S_WORKER_D_IP); do \
	  ssh -o StrictHostKeyChecking=no ubuntu@$(K8S_MASTER_PUBLIC_IP) "ssh-keyscan -H $$host" >> ~/.ssh/known_hosts || true; \
	done
	@echo "[+] SSH trust added for bastion and workers"

destroy:
	@echo "[+] (Local) cleanup only — no Terraform destroy executed"
	@rm -f ../ansible-kubespray/inventory/mycluster/hosts.yaml
	@rm -f ../monitoring/monitoring-ingress.yaml
	@rm -f ../monitoring/terraform.tfvars
	@rm -f ~/.kube/config || true

inventory: check-vars
	@mkdir -p ../ansible-kubespray/inventory/mycluster
	@echo "[*] Генерация ../ansible-kubespray/inventory/mycluster/hosts.yaml"
	@envsubst < generate_hosts.yaml.tmpl > ../ansible-kubespray/inventory/mycluster/hosts.yaml
	@echo "[+] Файл hosts.yaml успешно создан"

cluster: check-vars
	@echo "[*] Запуск Ansible Kubespray для развертывания кластера..."
	cd ../ansible-kubespray && \
	. venv/bin/activate && \
	ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu --become --become-user=root cluster.yml
	@echo "[+] Kubernetes кластер успешно развернут!"

kubeconfig: check-vars wait-ssh
	@echo "[*] Копируем kubeconfig с мастер-ноды..."
	@mkdir -p ~/.kube
	@ssh -o StrictHostKeyChecking=no ubuntu@$(K8S_MASTER_PUBLIC_IP) "sudo cat /etc/kubernetes/admin.conf" > ~/.kube/config; \
	sed -i "s#server: https://.*:6443#server: https://$(K8S_MASTER_PUBLIC_IP):6443#g" ~/.kube/config; \
	sed -i '/certificate-authority-data/d' ~/.kube/config; \
	if grep -q "insecure-skip-tls-verify" ~/.kube/config; then \
	    sed -i "s/insecure-skip-tls-verify.*/insecure-skip-tls-verify: true/" ~/.kube/config; \
	else \
	    sed -i "/server: https:\/\/$(K8S_MASTER_PUBLIC_IP):6443/a \ \ \ \ insecure-skip-tls-verify: true" ~/.kube/config; \
	fi; \
	echo "[+] kubeconfig обновлён (server: https://$(K8S_MASTER_PUBLIC_IP):6443, skip TLS verify, CA-data удалён)"

monitoring-ingress: check-vars
	@envsubst < monitoring-ingress.yaml.tmpl > ../monitoring/monitoring-ingress.yaml
	@echo "[+] monitoring-ingress.yaml создан с IP=$(K8S_MASTER_PUBLIC_IP)"

monitoring-tfvars: check-vars
	@echo "k8s_master_public_ip = \"$(K8S_MASTER_PUBLIC_IP)\"" > ../monitoring/terraform.tfvars
	@echo "[+] terraform.tfvars created in monitoring directory with IP=$(K8S_MASTER_PUBLIC_IP)"

monitoring-tf:
	@echo "[*] Инициализация и применение Terraform для мониторинга..."
	@cd ../monitoring && \
	terraform init && \
	terraform apply -auto-approve
	@echo "[+] Система мониторинга развернута через Terraform"

ingress-rules: check-vars
	@echo "[*] Configuring ingress redirection rules..."
	@../monitoring/configure_ingress.sh $(K8S_MASTER_PUBLIC_IP)