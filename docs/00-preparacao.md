# Aula 0 — Preparação

> **Faça isso antes do primeiro encontro.** Instalar Ruby, Docker e criar contas leva tempo, e é o
> que mais atrasa capacitação. Se travar em algum passo, manda mensagem no grupo — não espere o dia.

Ao final você deve conseguir rodar os quatro comandos da seção [Checagem final](#checagem-final).

---

## 1. Se você usa Windows: instale o WSL2 primeiro

Ruby e Rails rodam mal no Windows nativo. A forma suportada é o **WSL2** (um Linux de verdade dentro
do Windows). Todo o resto deste guia você fará **dentro do WSL2**, não no PowerShell.

No PowerShell **como administrador**:

```powershell
wsl --install -d Ubuntu-24.04
```

Reinicie o computador. Ao abrir o Ubuntu pela primeira vez, ele pede um usuário e uma senha —
anote a senha, ela é o seu `sudo`.

A partir daqui, "terminal" significa **o terminal do Ubuntu (WSL2)**.

> Se você usa Linux ou macOS, pule esta seção.

---

## 2. Git

```bash
# Ubuntu / WSL2
sudo apt update && sudo apt install -y git curl build-essential

# macOS (instala as ferramentas de linha de comando da Apple, que incluem o git)
xcode-select --install
```

Configure seu nome e e-mail — eles vão em todo commit que você fizer:

```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
```

---

## 3. Ruby 3.4.9 via mise

O `mise` é um gerenciador de versões: ele instala a versão exata de Ruby que o projeto pede, sem
mexer no Ruby do sistema. É o equivalente do `pyenv` do mundo Python.

> **Por que não `apt install ruby`?** Porque a versão do sistema é antiga e compartilhada. Se dois
> projetos pedirem versões diferentes, você fica sem saída. `mise` resolve isso por projeto.

### Instalar o mise

```bash
curl https://mise.run | sh
echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
exec bash
```

Usa `zsh` (padrão do macOS)? Troque as duas ocorrências de `bash` por `zsh` e o `~/.bashrc` por
`~/.zshrc`.

### Instalar as dependências de compilação do Ruby

```bash
# Ubuntu / WSL2
sudo apt install -y autoconf patch rustc libssl-dev libyaml-dev libreadline-dev \
  zlib1g-dev libgmp-dev libncurses-dev libffi-dev libgdbm-dev libdb-dev uuid-dev \
  libpq-dev libvips

# macOS (precisa do Homebrew: https://brew.sh)
brew install openssl@3 readline libyaml gmp libpq vips
```

### Instalar o Ruby

```bash
mise use --global ruby@3.4.9
```

Isso compila o Ruby do zero — leva de **5 a 15 minutos**. É normal.

```bash
ruby -v      # ruby 3.4.9 ...
gem -v
```

### Instalar o Rails

```bash
gem install rails -v 8.1.3
rails -v     # Rails 8.1.3
```

---

## 4. Docker

O banco de dados (PostgreSQL) vai rodar dentro de um container Docker, em vez de instalado na sua
máquina. Assim todo mundo tem exatamente a mesma versão, e desinstalar é apagar um container.

- **Windows/WSL2 e macOS**: instale o [Docker Desktop](https://www.docker.com/products/docker-desktop/).
  No Windows, nas configurações, habilite a integração com a distro `Ubuntu-24.04`.
- **Linux**: siga o [guia oficial](https://docs.docker.com/engine/install/ubuntu/) e depois rode
  `sudo usermod -aG docker $USER` e **saia e entre de novo na sessão**.

Testando:

```bash
docker run --rm hello-world
```

Se aparecer "Hello from Docker!", está pronto.

---

## 5. VS Code e extensões

Baixe em [code.visualstudio.com](https://code.visualstudio.com). No Windows, instale no **Windows**
(não dentro do WSL) — ele se conecta ao WSL sozinho.

Extensões (Ctrl+Shift+X e busque pelo nome):

| Extensão | Para quê |
|---|---|
| **Ruby LSP** (Shopify) | Autocomplete, ir para definição, erros em tempo real |
| **Ruby Rails** (Aki) | Navegação entre model/controller/view |
| **Docker** (Microsoft) | Ver e gerenciar containers pela barra lateral |
| **WSL** (Microsoft) | *Só Windows* — abrir projetos do Ubuntu no VS Code |
| **GitLens** | Ver quem escreveu cada linha e quando |
| **vscode-icons** | Ícones por tipo de arquivo (a mesma da capacitação de front) |

---

## 6. Insomnia (ou Postman)

Nossa API não tem tela — ela responde JSON. Para chamar as rotas, usaremos um cliente HTTP.
Baixe o [Insomnia](https://insomnia.rest/download) (mais simples) ou o
[Postman](https://www.postman.com/downloads/), o que preferir.

---

## 7. Contas

### GitHub

Crie em [github.com](https://github.com) se ainda não tem. Depois **ative o GitHub Student Pack**
em [education.github.com](https://education.github.com/pack) com seu e-mail `@aluno.ufop.edu.br` —
a aprovação pode levar alguns dias, e você ganha créditos e ferramentas de graça.

Instale o **GitHub CLI**, que na Aula 1 publica o seu projeto num comando e na Aula 4 cadastra os
segredos do deploy:

```bash
# Ubuntu / WSL2
sudo apt install -y gh
# macOS
brew install gh

gh auth login          # escolha GitHub.com → HTTPS → login pelo navegador
gh auth status         # tem que dizer "Logged in to github.com"
```

Configure também o acesso por SSH ao GitHub, se ainda não tem:

```bash
ssh-keygen -t ed25519 -C "seu@email.com"     # Enter em tudo
gh ssh-key add ~/.ssh/id_ed25519.pub --title "meu-notebook"
ssh -T git@github.com                        # tem que cumprimentar você pelo nome
```

### Azure for Students — **faça isso com antecedência**

Na Aula 4 cada um vai subir a própria máquina virtual na nuvem. Usaremos o
[Azure for Students](https://azure.microsoft.com/free/students/): **US$ 100 de crédito, sem cartão
de crédito**, mediante e-mail institucional.

1. Acesse o link e clique em **Comece gratuitamente**.
2. Entre com seu e-mail institucional (`@aluno.ufop.edu.br`).
3. Confirme a verificação acadêmica.
4. Entre no [portal.azure.com](https://portal.azure.com) e confirme que o crédito aparece.

> A verificação **pode demorar dias**. Faça agora, não na véspera da Aula 4.

---

## Checagem final

Cole os quatro comandos no terminal. Se todos responderem, você está pronto:

```bash
ruby -v          # ruby 3.4.9
rails -v         # Rails 8.1.3
docker -v        # Docker version 2x.x.x
git --version
gh auth status   # Logged in to github.com
```

## Como a capacitação funciona

Você vai trabalhar em **dois diretórios**:

```
~/capacitacao-gabarito/    ← o repositório da capacitação. Só leitura.
~/automic_auth_api/        ← o SEU projeto. Criado na Aula 1, é onde você escreve.
```

Clone o gabarito já:

```bash
git clone <url-do-repositório> ~/capacitacao-gabarito
```

O seu projeto você cria no primeiro encontro, com o passo a passo de
[`01-fundamentos.md`](01-fundamentos.md). Ele precisa ficar no **seu** GitHub: na Aula 4, a
credencial que autoriza o deploy é emitida para `repo:SEU-USUARIO/SEU-REPO`.

---

## Se algo deu errado

| Sintoma | Provável causa e saída |
|---|---|
| `mise: command not found` | A linha do `activate` não foi para o arquivo certo. Confira `~/.bashrc` (ou `~/.zshrc`) e rode `exec bash`. |
| A instalação do Ruby falha com erro de compilação | Faltou alguma dependência do passo 3. Rode o `apt install`/`brew install` de novo e tente `mise install ruby@3.4.9` outra vez. |
| `permission denied` no `docker` | Você não está no grupo `docker`. Rode `sudo usermod -aG docker $USER` e **saia e entre de novo** (só reabrir o terminal não basta). |
| No Windows, o `docker` não aparece dentro do Ubuntu | Docker Desktop → Settings → Resources → WSL Integration → habilite a distro `Ubuntu-24.04`. |
| `gem install rails` reclama de permissão | Você está usando o Ruby do sistema, não o do `mise`. Confira com `which ruby` — deve apontar para dentro de `~/.local/share/mise`. |

Mais casos em [`troubleshooting.md`](troubleshooting.md).
