# As versões que usamos

Tudo o que aparece na capacitação, com a versão exata. Se algo se comportar diferente do que a
apostila descreve, **confira aqui primeiro**: quase sempre é diferença de versão.

Os números foram tirados do próprio projeto (`.ruby-version`, `Gemfile.lock`, `compose.yaml` e
`Dockerfile`), então eles são o que roda de verdade, e não o que se pretendia rodar.

---

## Na sua máquina

| Programa | Versão | Para quê | Onde instalar |
|---|---|---|---|
| **Ruby** | `3.4.9` | a linguagem | [`00-preparacao.md`](00-preparacao.md), via `mise` |
| **Rails** | `8.1.3` | o framework | `gem install rails -v 8.1.3` |
| **mise** | a mais recente | instala e troca a versão de Ruby por projeto | `curl https://mise.run \| sh` |
| **Docker** | 24 ou mais novo | roda o Postgres, e depois a sua API | Docker Desktop, ou `docker-ce` |
| **Git** | 2.30 ou mais novo | versionamento | pelo gerenciador do sistema |
| **GitHub CLI** (`gh`) | a mais recente | criar o repositório e cadastrar segredos | `apt install gh` / `brew install gh` |
| **OpenSSH** (cliente e servidor) | a do sistema | o Kamal chega no servidor por SSH | `apt install openssh-server` |
| **OpenSSL** | 3.x | gera o certificado da Aula 4 | já vem no sistema |
| **VS Code** | a mais recente | editor | [code.visualstudio.com](https://code.visualstudio.com) |
| **Insomnia** | a mais recente | montar requisições sem navegador | [insomnia.rest](https://insomnia.rest) |
| **WSL2** | Ubuntu 24.04 | só Windows: é o Linux onde você trabalha | `wsl --install -d Ubuntu-24.04` |

> **A versão do Ruby não é sugestão.** O `.ruby-version` do projeto tem `3.4.9`, e o `mise` troca
> sozinho ao entrar na pasta. Rodar noutra versão funciona quase sempre, e o "quase" costuma
> aparecer no pior momento.

---

## As gems do projeto

O `Gemfile` declara o que o projeto usa; o **`Gemfile.lock`** trava a versão exata de tudo,
inclusive das dependências das dependências. É por isso que ele vai para o Git: é a garantia de que
a sua máquina e o servidor rodam o mesmo código.

| Gem | Versão | Para quê | Aula |
|---|---|---|---|
| `rails` | `8.1.3.1` | o framework inteiro | 1 |
| `pg` | `1.6.3` | driver do PostgreSQL | 1 |
| `puma` | `8.0.2` | o servidor web | 1 |
| `bcrypt` | `3.1.22` | hash de senha, via `has_secure_password` | 2 |
| `jwt` | `3.2.0` | assina e verifica o token de sessão | 3 |
| `rack-cors` | `3.0.0` | libera o navegador a chamar a API de outra origem | 3 |
| `letter_opener` | `1.10.0` | abre o e-mail no navegador, em desenvolvimento | 3 |
| `solid_cache` | `1.0.10` | cache no próprio Postgres; guarda a denylist do logout | 3 |
| `solid_queue` | `1.6.0` | fila de jobs no próprio Postgres | 3 |
| `kamal` | `2.12.0` | o deploy | 4 |
| `thruster` | a do lock | proxy HTTP que acompanha o Rails 8 | 4 |
| `bootsnap` | a do lock | acelera o boot da aplicação | 1 |
| `brakeman` | `8.0.5` | análise estática de segurança, no CI | 3 |
| `bundler-audit` | a do lock | procura CVE conhecida nas gems, no CI | 3 |
| `rubocop-rails-omakase` | `1.1.0` | o estilo padrão do Rails, no CI | 3 |
| `debug` | a do lock | o depurador | 1 |

Para ver a versão exata de qualquer uma, no seu projeto:

```bash
bundle info bcrypt
bundle list | grep jwt
```

---

## Nas imagens Docker

| Imagem | Versão | Onde |
|---|---|---|
| `postgres` | **16** | `compose.yaml` em desenvolvimento, e o accessory do Kamal em produção |
| `ruby` | `3.4.9-slim` | base do `Dockerfile` da aplicação |

**O Postgres é o mesmo nos dois lugares, de propósito.** Desenvolver num banco e publicar noutro é
a forma mais barata de descobrir um bug só depois do deploy.

---

## Serviços de fora

| Serviço | O que usamos | Custa? |
|---|---|---|
| **GitHub** | repositório, Actions (CI) e o `ghcr.io` (registry de imagens) | não, em repositório público ou com a conta de estudante |
| **SMTP** (Resend ou similar) | entrega os e-mails de verificação e recuperação | plano gratuito serve |
| **Azure** | só no [apêndice de nuvem](apendice-azure.md) | US$100 de crédito pela Azure for Students, sem cartão |
| **Cloudflare** | só no apêndice: DNS e certificado | não |

---

## Conferindo tudo de uma vez

Cole no terminal, dentro do seu projeto:

```bash
ruby -v                          # ruby 3.4.9
bin/rails -v                     # Rails 8.1.3.1
docker -v
docker compose version
git --version
gh --version
openssl version                  # OpenSSL 3.x
ssh -V                           # OpenSSH_9.x
bundle exec kamal version        # 2.12.0
ssh "$USER"@127.0.0.1 'echo ok'  # ok  (o servidor da Aula 4)
```

Se algum deles não responder, a saída está em [`00-preparacao.md`](00-preparacao.md) ou em
[`troubleshooting.md`](troubleshooting.md).

---

## Se você estiver lendo isto no futuro

Versões envelhecem, e este material foi escrito com as de cima. Duas coisas envelhecem mais rápido
que as outras:

- **O Rails.** A cada versão maior mudam padrões e geradores. `rails new` numa versão diferente pode
  gerar um projeto com outra cara.
- **O Kamal.** Ele é novo e ainda muda. O `deploy.yml` deste material é da linha **2.x**; a 1.x usava
  outro formato para proxy e segredos.

O resto (HTTP, SQL, bcrypt, JWT, Docker, SSH, TLS) muda devagar, e é a maior parte do que você está
aprendendo aqui.
