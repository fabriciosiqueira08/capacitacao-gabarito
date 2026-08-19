# Capacitação Back-end: Automic Jr.

Material da capacitação de back-end da Automic: **4 encontros de ~3h** em que a turma constrói, do
zero, uma API de autenticação em Ruby on Rails e a coloca no ar num servidor Linux que cada um sobe
no próprio notebook, com HTTPS e Kamal.

O app construído aqui é um recorte do [`seem-backend`](https://github.com/fabriciosiqueira08/seem-backend)
— o back-end real da XXIII Semana de Estudos da Escola de Minas (SEEM). As decisões, os padrões e a
infraestrutura são os mesmos; o que muda é o tamanho.

> Esta capacitação segue a mesma lógica e formatação da capacitação de front-end do Gabriel Fiuza.

---

## O que a turma vai ter no fim

Uma API rodando em `https://<seu-nome>.test`, dentro de uma máquina virtual Ubuntu que eles mesmos
provisionaram, com quatro rotas de autenticação:

| Método | Rota | O que faz |
|---|---|---|
| `POST` | `/api/v1/registrations` | Cadastra o usuário e dispara um código por e-mail |
| `POST` | `/api/v1/sessions` | Login — devolve um JWT |
| `DELETE` | `/api/v1/sessions` | Logout — revoga o token de verdade, no servidor |
| `POST` | `/api/v1/password_resets/request` | Envia código de recuperação por e-mail |
| `POST` | `/api/v1/password_resets/confirm` | Troca a senha e derruba as sessões ativas |

Mais a confirmação de e-mail (`/api/v1/email_verifications/confirm` e `/resend`), que é o que faz o
login só liberar depois que a conta é ativada, e duas rotas autenticadas: `GET /api/v1/me` e
`GET /api/v1/me/login_events` (o histórico de acessos, que existe para exercitar associações).

---

## Os quatro encontros

| Aula | Tema | Termina com |
|---|---|---|
| **1** | O que é back-end, Ruby (para quem sabe Python) e o primeiro Rails | `GET /api/v1/status` respondendo JSON |
| **2** | Banco de dados, ActiveRecord e o model `User` | `User` com validações e senha hasheada, testado no console |
| **3** | As rotas de autenticação | Os cinco fluxos rodando e testados |
| **4** | Servidor Linux, Docker, Kamal e deploy | O app de cada um no ar, na própria VM, com HTTPS |

---

## Como você vai usar este repositório

**Você não escreve neste repositório.** Ele é o **gabarito**: o código pronto, para consultar quando
travar ou quando quiser comparar com o seu.

Na Aula 1 você cria o **seu próprio projeto**, e é nele que você trabalha nos quatro encontros. Isso
não é preciosismo: na Aula 4 o CI roda no **seu** repositório e a imagem Docker vai para a **sua**
conta do GitHub Container Registry.

```
~/capacitacao-gabarito/    ← este repo. Só leitura.
~/automic_auth_api/        ← o seu projeto. É aqui que você escreve.
```

### O setup, uma vez só (Aula 1)

```bash
# 1. o gabarito, para consultar
git clone <url-deste-repo> ~/capacitacao-gabarito

# 2. o seu projeto (o passo a passo está em docs/01-fundamentos.md)
cd ~ && rails new automic_auth_api --api -d postgresql \
  --skip-action-mailbox --skip-action-text --skip-active-storage \
  --skip-jbuilder --skip-action-cable
cd automic_auth_api && git init && git add -A && git commit -m "Projeto inicial"

# 3. publique no SEU GitHub — a Aula 4 depende disso
gh repo create automic_auth_api --private --source=. --push
```

### Consultando o gabarito

Cada aula tem uma branch com o código **como ele fica no fim daquele encontro**:

```bash
cd ~/capacitacao-gabarito
git checkout aula-01   # como ficou no fim da Aula 1
git checkout aula-02   # …e assim por diante
git checkout main      # tudo pronto, mais slides, PDFs e roteiros
```

Travou no meio de um exercício? Abra o arquivo correspondente no gabarito, entenda, e escreva no
seu. **Copiar sem ler é o único jeito de sair daqui sem aprender nada.**

Precisa mesmo copiar (a Aula 3 tem bastante código)? Então copie de propósito:

```bash
cd ~/capacitacao-gabarito && git checkout aula-03
rsync -a app config db test Gemfile Gemfile.lock ~/automic_auth_api/
cd ~/automic_auth_api && bundle install && bin/rails db:migrate && bin/rails test
```

O `Gemfile` vai junto de propósito: a Aula 3 acrescenta as gems `jwt`, `rack-cors` e
`letter_opener`. Sem ele, a aplicação nem sobe.

| Branch | Contém |
|---|---|
| `aula-01` | App gerado + rota de status |
| `aula-02` | + migrations, `User`, concerns, associações, validador de senha |
| `aula-03` | + rotas, services, mailer, serializer, testes |
| `aula-04` | + Dockerfile, Kamal, `.env.example`, GitHub Actions |
| `main` | Tudo, mais os slides, os PDFs e os roteiros |

Cada checkpoint carrega **o código daquele ponto e as apostilas até aquela aula** — nada além
disso. Slides, PDFs e roteiros do instrutor são gerados e vivem só na `main`, para não ficarem
desatualizados em quatro lugares a cada regeração.

---

## Como as aulas são construídas

Cada bloco de conteúdo termina numa **prática**: explica, faz, explica, faz. São **31 práticas** nos
quatro encontros, de 5 a 35 minutos, todas com um item avançado para quem terminar antes.

Na apostila, cada prática traz os comandos, uma linha **Confere** e uma tabela **Se der errado**, no
formato *erro → causa → saída* — com os erros que acontecem de verdade, não os hipotéticos.

| Aula | Práticas | Da mais básica à mais avançada |
|---|--:|---|
| 1 | 7 | `curl` na mão → Ruby no `irb` → projeto no ar → rota → teste → GitHub |
| 2 | 8 | banco de pé → migrations → bcrypt no console → validador → model → associação → concerns → testes |
| 3 | 8 | ler a arquitetura → cadastro → confirmação → token na mão → logout → recuperação → qualidade → forjar um token |
| 4 | 8 | subir a VM → firewall e Docker → registry → `.env` → certificado → deploy → TLS com os olhos → produção |

A sintaxe de Ruby que o projeto usa está na
[seção 5 da Aula 1](docs/01-fundamentos.md), organizada como referência: cada construção diz **onde
no projeto ela aparece**. O comparativo completo com Python fica em
[`ruby-para-pythonistas.md`](docs/ruby-para-pythonistas.md).

---

## Documentação

| Arquivo | Para quê |
|---|---|
| [`docs/00-preparacao.md`](docs/00-preparacao.md) | **Leia antes do primeiro encontro.** O que instalar e quais contas criar. |
| [`docs/01-fundamentos.md`](docs/01-fundamentos.md) | Apostila da Aula 1 |
| [`docs/02-activerecord.md`](docs/02-activerecord.md) | Apostila da Aula 2 |
| [`docs/03-autenticacao.md`](docs/03-autenticacao.md) | Apostila da Aula 3 |
| [`docs/04-deploy.md`](docs/04-deploy.md) | Apostila da Aula 4 |
| [`docs/apendice-azure.md`](docs/apendice-azure.md) | O mesmo servidor na nuvem: Azure, Cloudflare, OIDC e deploy automático |
| [`docs/ruby-para-pythonistas.md`](docs/ruby-para-pythonistas.md) | Cheat sheet Python ↔ Ruby, lado a lado |
| [`docs/PREENCHER.md`](docs/PREENCHER.md) | **Leia primeiro**: o que ainda falta preencher antes de usar o material |
| [`docs/guia-do-instrutor.md`](docs/guia-do-instrutor.md) | **Para quem apresenta, leia primeiro**: conduzir a sala, os três primeiros minutos, a curva de energia, o "não sei" |
| [`docs/roteiro-de-tempo.md`](docs/roteiro-de-tempo.md) | **Para quem apresenta**: índice dos quatro roteiros de aula |
| `docs/roteiro-aula-0N.md` | Runbook de cada encontro: cronograma, falas, demos, perguntas e plano B |
| [`docs/glossario.md`](docs/glossario.md) | VM, VPS, ufw, CA, JWT, OTP, ORM, CI/CD… |
| [`docs/troubleshooting.md`](docs/troubleshooting.md) | Erros que realmente acontecem, e a saída de cada um |

## Slides

Em [`slides/`](slides/). Os `.pptx` de cada aula ficam em `slides/build/` e são gerados por
`slides/gerar_slides.py` a partir dos roteiros em `slides/conteudo/*.yml`.

```bash
python3 slides/gerar_slides.py                # gera as quatro aulas
python3 slides/gerar_slides.py --aula 1       # só a Aula 1
```

---

## Rodando o gabarito

Você não precisa disso para acompanhar a capacitação — só se quiser ver o projeto pronto
funcionando na sua máquina.

```bash
docker compose up -d          # sobe o Postgres
bin/setup                     # instala gems e prepara o banco
bin/rails server              # http://localhost:3000
curl localhost:3000/api/v1/status
```

> Se você já tem um Postgres na porta 5432, use `DB_PORT=5433 docker compose up -d` e exporte
> `DB_PORT=5433` no shell.
