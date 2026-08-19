#!/usr/bin/env bash
# Confere se DAQUI (de onde você programa) dá para alcançar a VM do Multipass.
#
# Rode ANTES da Aula 4, em casa. Se der errado no dia, custa a aula inteira;
# se der errado hoje, custa dez minutos.
#
#   ./scripts/checar-servidor.sh <IP-que-o-multipass-info-mostrou> [porta-ssh]
#
# Ele não conserta nada: ele diz se está bom e, se não estiver, qual é a saída
# para o seu caso.

set -uo pipefail

IP="${1:-}"
PORTA="${2:-22}"
CHAVE="${HOME}/.ssh/capacita"

if [[ -z "${IP}" ]]; then
  echo "uso: $0 <IP-da-VM> [porta-ssh]" >&2
  echo "     o IP é o que aparece em 'multipass info servidor'" >&2
  exit 2
fi

no_wsl2() { grep -qi microsoft /proc/version 2>/dev/null; }

# /dev/tcp é do bash: testa a porta sem depender de nc/telnet estarem instalados.
porta_aberta() {
  timeout 5 bash -c "exec 3<>/dev/tcp/${IP}/${PORTA}" 2>/dev/null
}

echo "Testando ${IP}:${PORTA}..."

if porta_aberta; then
  echo "  [ok] a porta ${PORTA} responde"
else
  echo "  [X]  não alcancei ${IP}:${PORTA}"
  echo
  if no_wsl2; then
    cat <<'AJUDA'
Você está no WSL2, e este é O problema conhecido da Aula 4.

O Multipass roda no Windows; o WSL2 é outra máquina virtual. Por padrão uma não
enxerga a outra. Duas saídas, nesta ordem:

  1. REDE ESPELHADA (Windows 11 22H2+) — um arquivo, e resolve de vez.

     Crie C:\Users\<seu-usuario>\.wslconfig com:

       [wsl2]
       networkingMode=mirrored

     Depois, no PowerShell:  wsl --shutdown
     E rode este script de novo.

  2. ENCAMINHAMENTO DE PORTA (funciona em qualquer Windows, inclusive o 10).

     No PowerShell COMO ADMINISTRADOR, trocando o IP pelo da sua VM:

       $vm = "SEU_IP_DA_VM"
       netsh interface portproxy add v4tov4 listenport=2222 listenaddress=0.0.0.0 connectport=22  connectaddress=$vm
       netsh interface portproxy add v4tov4 listenport=443  listenaddress=0.0.0.0 connectport=443 connectaddress=$vm
       netsh interface portproxy add v4tov4 listenport=80   listenaddress=0.0.0.0 connectport=80  connectaddress=$vm
       New-NetFirewallRule -DisplayName "Capacita VM" -Direction Inbound `
         -Action Allow -Protocol TCP -LocalPort 2222,443,80

     Agora, no WSL2, o endereço da VM passa a ser o do Windows:

       ip route show default | awk '{print $3}'

     Use esse endereço como SERVER_IP e no /etc/hosts, e ponha SSH_PORT=2222
     no seu .env. Rode este script de novo assim:

       ./scripts/checar-servidor.sh $(ip route show default | awk '{print $3}') 2222

     Atenção: o endereço do Windows muda a cada 'wsl --shutdown'. Quando o SSH
     parar de conectar do nada, é isso.
AJUDA
  else
    cat <<'AJUDA'
A VM está de pé? Confira, na máquina onde você rodou o multipass:

  multipass info servidor      # State tem que ser Running, e o IPv4 tem que bater

Se o IP mudou (acontece depois de stop/start), use o novo.
AJUDA
  fi
  exit 1
fi

if [[ ! -f "${CHAVE}" ]]; then
  echo "  [!]  não achei ${CHAVE} — você ainda não gerou o par de chaves."
  echo "       ssh-keygen -t ed25519 -f ~/.ssh/capacita -C capacita-servidor -N ''"
  exit 1
fi

if ssh -i "${CHAVE}" -p "${PORTA}" -o IdentitiesOnly=yes -o BatchMode=yes \
       -o StrictHostKeyChecking=no -o ConnectTimeout=10 \
       "ubuntu@${IP}" 'echo ok' >/dev/null 2>&1; then
  echo "  [ok] o SSH com a sua chave funciona"
  echo
  echo "Está tudo pronto para a Aula 4."
  [[ "${PORTA}" != "22" ]] && echo "Lembre de pôr SSH_PORT=${PORTA} no seu .env."
  exit 0
fi

echo "  [X]  a porta abre, mas o SSH recusou a chave"
cat <<AJUDA

A rede está boa; o que faltou foi a chave. Quase sempre é uma destas:

  1. permissão frouxa na chave privada — o SSH recusa usar:
       chmod 600 ${CHAVE}

  2. a chave pública não entrou na VM. Confira lá dentro:
       multipass exec servidor -- cat /home/ubuntu/.ssh/authorized_keys

     Se estiver vazio, o cloud-init.yaml não tinha o CONTEÚDO de
     ~/.ssh/capacita.pub (e sim o caminho do arquivo). Refaça:
       multipass delete servidor && multipass purge
AJUDA
exit 1
