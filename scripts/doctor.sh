#!/usr/bin/env bash
# Confere o ambiente da capacitação e diz, item por item, o que falta.
#
#   bash scripts/doctor.sh          # tudo
#   bash scripts/doctor.sh --aula 1 # só o que a Aula 1 precisa
#
# Escrito em bash puro de propósito: ele precisa funcionar ANTES de o Ruby
# existir, que é justamente quando você mais precisa dele.

set -u

# O mise põe os atalhos do Ruby em ~/.local/share/mise/shims, e essa linha só
# entra no PATH de shell INTERATIVO — o ~/.bashrc do Ubuntu desiste antes disso
# quando não é um. Sem isto, o doctor diria que o Ruby não existe só porque
# você o chamou de um jeito diferente.
[ -d "$HOME/.local/share/mise/shims" ] && PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH

AULA_ALVO="${2:-0}"
[ "${1:-}" = "--aula" ] || AULA_ALVO=0

VERDE=$'\033[32m'; VERMELHO=$'\033[31m'; AMARELO=$'\033[33m'; CINZA=$'\033[90m'; FIM=$'\033[0m'
[ -t 1 ] || { VERDE=""; VERMELHO=""; AMARELO=""; CINZA=""; FIM=""; }

OK=0; FALHOU=0; AVISOS=0
PENDENCIAS=()

# checa <aula> <rótulo> <comando> <esperado-regex> <como-consertar>
checa() {
  local aula="$1" rotulo="$2" cmd="$3" esperado="$4" conserto="$5"
  [ "$AULA_ALVO" != "0" ] && [ "$aula" -gt "$AULA_ALVO" ] && return 0

  local saida
  saida="$(eval "$cmd" 2>/dev/null | head -1)"

  # Alinhamento contado em CARACTERE, não em byte: os rótulos têm acento, e o
  # %-34s conta bytes — a coluna sairia torta em metade das linhas.
  local pad=$((34 - ${#rotulo})); [ "$pad" -lt 1 ] && pad=1

  if [ -n "$saida" ] && printf '%s' "$saida" | grep -qE "$esperado"; then
    printf "  ${VERDE}✓${FIM} %s%*s${CINZA}%s${FIM}\n" "$rotulo" "$pad" "" "${saida:0:38}"
    OK=$((OK + 1))
  else
    printf "  ${VERMELHO}✗${FIM} %s%*s${VERMELHO}%s${FIM}\n" "$rotulo" "$pad" "" "${saida:-não respondeu}"
    printf "    ${CINZA}→ %s${FIM}\n" "$conserto"
    FALHOU=$((FALHOU + 1))
    PENDENCIAS+=("$rotulo")
  fi
}

avisa() {  # avisa <condição-verdadeira-é-problema> <rótulo> <texto>
  if eval "$1" 2>/dev/null; then
    local pad=$((34 - ${#2})); [ "$pad" -lt 1 ] && pad=1
    printf "  ${AMARELO}!${FIM} %s%*s${AMARELO}%s${FIM}\n" "$2" "$pad" "" "$3"
    AVISOS=$((AVISOS + 1))
  fi
}

secao() { printf "\n${CINZA}%s${FIM}\n" "$1"; }

# ── onde estamos ──────────────────────────────────────────────────────────
NO_WSL=false
grep -qi microsoft /proc/version 2>/dev/null && NO_WSL=true
SISTEMA="$(uname -s)"
$NO_WSL && SISTEMA="WSL2 ($(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME"))"
NO_CONTAINER=false
[ -f /.dockerenv ] && NO_CONTAINER=true && SISTEMA="devcontainer"

printf "\n${CINZA}Ambiente da capacitação — %s${FIM}\n" "$SISTEMA"

secao "Aula 1 — Ruby, Rails e Docker"
checa 1 "Ruby 3.4.9"        "ruby -v"              "3\.4\.9"        "mise use --global ruby@3.4.9   (Preparação, passo 3)"
checa 1 "Rails 8.1"         "(rails -v || bin/rails -v) 2>/dev/null" "Rails 8\.1" "gem install rails -v 8.1.3"
checa 1 "Docker"            "docker -v"            "Docker version" "Docker Desktop instalado E com a integração WSL ligada (Preparação, passo 4)"
checa 1 "o engine responde" "timeout 15 docker info --format '{{.ServerVersion}}'" "^[0-9]" "abra o Docker Desktop e espere a baleia parar de se mexer"
checa 1 "docker compose"    "docker compose version" "Docker Compose" "no Docker Desktop já vem junto; no Linux: apt install docker-compose-plugin"
checa 1 "git"               "git --version"        "git version"    "sudo apt install -y git"
checa 1 "identidade do git"  "git config --global user.email" "@"         "git config --global user.name 'Seu Nome' && git config --global user.email 'seu@email.com' — sem isso o commit da Prática 7 não sai"

if ! $NO_CONTAINER; then
  avisa '[ "$(ruby -e "print RUBY_VERSION" 2>/dev/null)" ] && ! command -v ruby | grep -q mise' \
        "ruby fora do mise" "which ruby: $(command -v ruby 2>/dev/null)"
fi
$NO_WSL && avisa 'case "$PWD" in /mnt/*) true;; *) false;; esac' \
      "o projeto está em /mnt/c" "mova para ~/ — em /mnt/c tudo fica lento e o reload para"

secao "Aula 1 — GitHub"
checa 1 "gh instalado"      "gh --version"         "gh version"     "sudo apt install -y gh"
checa 1 "gh autenticado"    "gh auth status 2>&1"  "Logged in|Conectado" "gh auth login → GitHub.com → HTTPS → navegador"

if [ -f Gemfile ]; then
secao "Aula 3 — a caixa de entrada"
checa 3 "letter_opener_web" "grep -h letter_opener_web Gemfile 2>/dev/null" "letter_opener_web" \
        "o Gemfile do gabarito é quem traz; refaça o rsync da Prática 1 da Aula 3"
fi

secao "Aula 4 — a sua máquina como servidor"
checa 4 "sshd escutando na 22" "ss -tln 2>/dev/null | grep ':22 '" ":22" \
        "sudo service ssh start   (e veja o systemd abaixo, para não repetir isso toda vez)"
checa 4 "a chave da capacitação" "ls ~/.ssh/capacita 2>/dev/null" "capacita" \
        "ssh-keygen -t ed25519 -f ~/.ssh/capacita -C capacita-servidor -N ''"
checa 4 "SSH em si mesmo" \
        "ssh -i ~/.ssh/capacita -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=8 \"\$USER\"@127.0.0.1 'echo SSH_OK' 2>&1" \
        "SSH_OK" "cat ~/.ssh/capacita.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
checa 4 "docker PELA ssh" \
        "ssh -i ~/.ssh/capacita -o IdentitiesOnly=yes -o BatchMode=yes -o ConnectTimeout=8 \"\$USER\"@127.0.0.1 'docker -v' 2>&1" \
        "Docker version" "é a integração WSL do Docker Desktop. NÃO instale docker-ce aqui dentro"

if $NO_WSL; then
  secao "Aula 4 — as duas armadilhas do WSL2"
  checa 4 "systemd ligado" "grep -A2 '^\[boot\]' /etc/wsl.conf 2>/dev/null | grep systemd" "systemd *= *true" \
          "põe [boot]/systemd=true em /etc/wsl.conf e roda 'wsl --shutdown' no PowerShell. Sem isso o sshd não sobe no boot"
  checa 4 "/etc/hosts preservado" "grep -A2 '^\[network\]' /etc/wsl.conf 2>/dev/null | grep generateHosts" "generateHosts *= *false" \
          "põe [network]/generateHosts=false em /etc/wsl.conf, senão o WSL apaga a linha do seunome.test a cada boot"
fi

# ── resumo ────────────────────────────────────────────────────────────────
printf "\n"
if [ "$FALHOU" -eq 0 ]; then
  printf "${VERDE}%d conferências, todas passaram.${FIM}" "$OK"
  [ "$AVISOS" -gt 0 ] && printf " ${AMARELO}(%d aviso(s) acima)${FIM}" "$AVISOS"
  printf "\n\n"
  exit 0
fi

printf "${VERMELHO}%d de %d falharam:${FIM} %s\n" "$FALHOU" "$((OK + FALHOU))" "${PENDENCIAS[*]}"
printf "${CINZA}Conserte de cima para baixo: as de baixo costumam depender das de cima.\nSe travar, manda esta saída no grupo.${FIM}\n\n"
exit 1
