#!/usr/bin/env bash
# Prepara a máquina para a capacitação, num comando só.
#
#   curl -fsSL https://raw.githubusercontent.com/fabriciosiqueira08/capacitacao-gabarito/main/scripts/instalar.sh | bash
#
# Rode DENTRO do Ubuntu (WSL2) se você usa Windows. Pode rodar quantas vezes
# quiser: ele pula o que já está feito.
#
# Vai pedir a sua senha do sudo uma vez, no começo.

set -uo pipefail

VERDE=$'\033[32m'; VERMELHO=$'\033[31m'; AMARELO=$'\033[33m'; CINZA=$'\033[90m'; FIM=$'\033[0m'
[ -t 1 ] || { VERDE=""; VERMELHO=""; AMARELO=""; CINZA=""; FIM=""; }
passo() { printf "\n${CINZA}==>${FIM} %s\n" "$1"; }
ok()    { printf "    ${VERDE}✓${FIM} %s\n" "$1"; }
pula()  { printf "    ${CINZA}· %s${FIM}\n" "$1"; }
erro()  { printf "    ${VERMELHO}✗ %s${FIM}\n" "$1"; }

LOG=/tmp/instalar-capacitacao.log
: > "$LOG"

NO_WSL=false; grep -qi microsoft /proc/version 2>/dev/null && NO_WSL=true
NO_MAC=false; [ "$(uname -s)" = "Darwin" ] && NO_MAC=true

printf "\n${CINZA}Instalador da capacitação de back-end${FIM}\n"
$NO_WSL && printf "${CINZA}Windows, dentro do WSL2 — é o lugar certo.${FIM}\n"

# ── 1. os pacotes do sistema ──────────────────────────────────────────────
# São três, e só três. O Ruby não é mais compilado aqui (o mise baixa um
# binário pronto), então as bibliotecas de compilação que este guia já pediu
# um dia não fazem mais falta. O build-essential fica porque algumas gems
# ainda têm extensão em C — a bcrypt, por exemplo.
passo "Pacotes do sistema"
if $NO_MAC; then
  xcode-select -p >/dev/null 2>&1 || xcode-select --install
  ok "ferramentas de linha de comando da Apple"
else
  FALTAM=()
  for p in curl git build-essential openssh-server rsync; do
    dpkg -s "$p" >/dev/null 2>&1 || FALTAM+=("$p")
  done
  $NO_WSL && ! dpkg -s wslu >/dev/null 2>&1 && FALTAM+=(wslu)
  command -v gh >/dev/null 2>&1 || FALTAM+=(gh)

  if [ ${#FALTAM[@]} -eq 0 ]; then
    pula "já estão todos"
  else
    printf "    instalando: %s\n" "${FALTAM[*]}"
    # A saída do apt vai para um log. São mil e duzentas linhas de
    # "Unpacking..." que não dizem nada a ninguém, e que numa sala fazem o
    # aluno perder de vista se deu certo ou não.
    if sudo apt-get update -qq >>"$LOG" 2>&1 && sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "${FALTAM[@]}" >>"$LOG" 2>&1; then
      ok "instalados"
    else
      erro "falhou — o que aconteceu está em $LOG"
      tail -5 "$LOG"
    fi
  fi
fi

# ── 2. as duas configurações do WSL2 ──────────────────────────────────────
# Sem systemd, o sshd não sobe no boot e a Aula 4 quebra toda vez que você
# reinicia o Windows. Sem generateHosts=false, o WSL reescreve o /etc/hosts a
# cada boot e apaga o nome do seu site.
if $NO_WSL; then
  passo "WSL2: systemd e /etc/hosts"
  MUDOU=false
  grep -q "systemd *= *true" /etc/wsl.conf 2>/dev/null \
    || { printf '[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf >/dev/null; MUDOU=true; }
  grep -q "generateHosts *= *false" /etc/wsl.conf 2>/dev/null \
    || { printf '[network]\ngenerateHosts=false\n' | sudo tee -a /etc/wsl.conf >/dev/null; MUDOU=true; }
  if $MUDOU; then
    ok "gravado em /etc/wsl.conf"
    printf "    ${AMARELO}! rode 'wsl --shutdown' no PowerShell depois, para valer${FIM}\n"
  else
    pula "já configurado"
  fi
fi

# ── 3. o servidor de SSH, que a Aula 4 usa ────────────────────────────────
passo "Servidor de SSH (a Aula 4 precisa)"
if $NO_MAC; then
  pula "no macOS: Ajustes → Geral → Compartilhamento → Sessão remota"
else
  sudo service ssh start >/dev/null 2>&1
  ss -tln 2>/dev/null | grep -q ':22 ' && ok "escutando na porta 22" || erro "não subiu: sudo service ssh start"
fi

passo "O par de chaves da capacitação"
if [ -f ~/.ssh/capacita ]; then
  pula "~/.ssh/capacita já existe"
else
  ssh-keygen -t ed25519 -f ~/.ssh/capacita -C "capacita-servidor" -N "" -q
  ok "criado"
fi
mkdir -p ~/.ssh && chmod 700 ~/.ssh && chmod 600 ~/.ssh/capacita
grep -qF "$(cat ~/.ssh/capacita.pub)" ~/.ssh/authorized_keys 2>/dev/null \
  || cat ~/.ssh/capacita.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
ok "autorizado em authorized_keys"

# ── 4. Ruby e Rails ───────────────────────────────────────────────────────
passo "mise, Ruby 3.4.9 e Rails 8.1.3"
if [ ! -x ~/.local/bin/mise ]; then
  curl -fsSL https://mise.run | sh >/dev/null 2>&1 && ok "mise instalado"
else
  pula "mise já existe"
fi
RC=~/.bashrc; [ -n "${ZSH_VERSION:-}" ] && RC=~/.zshrc
grep -q 'mise activate' "$RC" 2>/dev/null \
  || echo 'eval "$(~/.local/bin/mise activate bash)"' >> "$RC"
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"

if ruby -v 2>/dev/null | grep -q "3\.4\.9"; then
  pula "Ruby 3.4.9 já instalado"
else
  printf "    baixando o Ruby (binário pronto, uns 20 segundos)\n"
  mise use --global ruby@3.4.9 >/dev/null 2>&1
  ruby -v 2>/dev/null | grep -q "3\.4\.9" && ok "$(ruby -v)" || erro "o Ruby não instalou"
fi

if rails -v 2>/dev/null | grep -q "8\.1"; then
  pula "$(rails -v)"
else
  gem install rails -v 8.1.3 --no-document >/dev/null 2>&1
  rails -v 2>/dev/null | grep -q "8\.1" && ok "$(rails -v)" || erro "o Rails não instalou"
fi

# ── 5. o gabarito ─────────────────────────────────────────────────────────
passo "O gabarito"
if [ -d ~/capacitacao-gabarito/.git ]; then
  pula "já clonado em ~/capacitacao-gabarito"
elif [ -e ~/capacitacao-gabarito ]; then
  erro "~/capacitacao-gabarito existe mas não é um clone do git"
  printf "    ${CINZA}apague ou renomeie a pasta e rode de novo${FIM}
"
elif git clone -q https://github.com/fabriciosiqueira08/capacitacao-gabarito.git ~/capacitacao-gabarito 2>>"$LOG"; then
  ok "clonado em ~/capacitacao-gabarito"
else
  erro "não consegui clonar — veja $LOG"


fi

# ── 6. a conferência ──────────────────────────────────────────────────────
printf "\n${CINZA}─────────────────────────────────────────────────${FIM}\n"
if [ -f ~/capacitacao-gabarito/scripts/doctor.sh ]; then
  bash ~/capacitacao-gabarito/scripts/doctor.sh
else
  erro "sem o gabarito não dá para conferir. Resolva o passo acima e rode de novo."
fi
