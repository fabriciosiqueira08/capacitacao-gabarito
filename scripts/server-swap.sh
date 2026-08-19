#!/usr/bin/env bash
# Cria 2 GiB de swap na VM. Idempotente: rodar duas vezes não faz mal.
#
# Uma VM pequena roda Rails e Postgres na mesma RAM. Sem swap, o kernel mata o
# processo que estiver na frente (OOM killer) e o deploy falha com uma mensagem
# que não explica nada.
#
# Uso, da sua máquina:
#   ssh -i ~/.ssh/capacita ubuntu@SEU_IP 'sudo bash -s' < scripts/server-swap.sh

set -euo pipefail

TAMANHO=2G
ARQUIVO=/swapfile

if swapon --show | grep -q "${ARQUIVO}"; then
  echo "Swap já ativo:"
  swapon --show
  exit 0
fi

if [[ ! -f "${ARQUIVO}" ]]; then
  fallocate -l "${TAMANHO}" "${ARQUIVO}" || dd if=/dev/zero of="${ARQUIVO}" bs=1M count=2048
fi

# 600: só o root lê. O swap contém memória do processo — inclusive segredos.
chmod 600 "${ARQUIVO}"
mkswap "${ARQUIVO}"
swapon "${ARQUIVO}"

# Persiste no boot.
grep -q "^${ARQUIVO}" /etc/fstab || echo "${ARQUIVO} none swap sw 0 0" >> /etc/fstab

# swappiness baixo: só usa swap quando a RAM realmente acabar. Swap é lento.
sysctl -w vm.swappiness=10
grep -q "^vm.swappiness" /etc/sysctl.conf || echo "vm.swappiness=10" >> /etc/sysctl.conf

echo "Swap ativo:"
swapon --show
free -h
