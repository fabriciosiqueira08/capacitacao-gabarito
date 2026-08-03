# Capacitação Back-end — Automic Jr.

Material da capacitação de back-end da Automic: **4 encontros de ~3h** em que a turma constrói, do
zero, uma API de autenticação em Ruby on Rails e a coloca no ar numa VPS própria, com HTTPS e
deploy automático.

O app construído aqui é um recorte do [`seem-backend`](https://github.com/fabriciosiqueira08/seem-backend)
— o back-end real da XXIII Semana de Estudos da Escola de Minas (SEEM). As decisões, os padrões e a
infraestrutura são os mesmos; o que muda é o tamanho.

> Esta capacitação segue a mesma lógica e formatação da capacitação de front-end do Gabriel Fiuza.

---

## O que a turma vai ter no fim

Uma API rodando em `https://<seu-nome>.capacita.<dominio>` com quatro rotas de autenticação:

| Método | Rota | O que faz |
|---|---|---|
| `POST` | `/api/v1/registrations` | Cadastra o usuário e dispara um código por e-mail |
| `POST` | `/api/v1/sessions` | Login — devolve um JWT |
| `DELETE` | `/api/v1/sessions` | Logout — revoga o token de verdade, no servidor |
| `POST` | `/api/v1/password_resets/request` | Envia código de recuperação por e-mail |
| `POST` | `/api/v1/password_resets/confirm` | Troca a senha e derruba as sessões ativas |

Mais a confirmação de e-mail (`/api/v1/email_verifications/confirm` e `/resend`), que é o que faz o
login só liberar depois que a conta é ativada.

---

## Os quatro encontros

| Aula | Tema | Termina com |
|---|---|---|
| **1** | O que é back-end, Ruby (para quem sabe Python) e o primeiro Rails | `GET /api/v1/status` respondendo JSON |
| **2** | Banco de dados, ActiveRecord e o model `User` | `User` com validações e senha hasheada, testado no console |
| **3** | As rotas de autenticação | Os cinco fluxos rodando e testados |
| **4** | VPS, Docker, Kamal e deploy | O app de cada um no ar, com HTTPS e deploy automático |

---

## Como acompanhar o código

O histórico é linear e cada aula tem uma branch de checkpoint. Se você se perder no meio de um
encontro, dá `checkout` do checkpoint anterior e continua de um estado que funciona.

```bash
git checkout aula-01   # estado do código no fim da Aula 1
git checkout aula-02   # …e assim por diante
git checkout main      # tudo pronto (o que aparece projetado na aula)
```

| Branch | Contém |
|---|---|
| `aula-01` | App gerado + rota de status |
| `aula-02` | + migrations, `User`, concerns, validador de senha |
| `aula-03` | + rotas, services, mailer, serializer, testes |
| `aula-04` | + Dockerfile, Kamal, GitHub Actions |
| `main` | Tudo + slides + documentação completa |

---

## Documentação

| Arquivo | Para quê |
|---|---|
| [`docs/00-preparacao.md`](docs/00-preparacao.md) | **Leia antes do primeiro encontro.** O que instalar e quais contas criar. |
| [`docs/01-fundamentos.md`](docs/01-fundamentos.md) | Apostila da Aula 1 |
| [`docs/02-activerecord.md`](docs/02-activerecord.md) | Apostila da Aula 2 |
| [`docs/03-autenticacao.md`](docs/03-autenticacao.md) | Apostila da Aula 3 |
| [`docs/04-deploy.md`](docs/04-deploy.md) | Apostila da Aula 4 |
| [`docs/ruby-para-pythonistas.md`](docs/ruby-para-pythonistas.md) | Cheat sheet Python ↔ Ruby, lado a lado |
| [`docs/glossario.md`](docs/glossario.md) | VPS, NSG, OIDC, JWT, OTP, ORM, CI/CD… |
| [`docs/troubleshooting.md`](docs/troubleshooting.md) | Erros que realmente acontecem, e a saída de cada um |

## Slides

Em [`slides/`](slides/). Os `.pptx` de cada aula ficam em `slides/build/` e são gerados por
`slides/gerar_slides.py` a partir dos roteiros em `slides/conteudo/*.yml`.

```bash
python3 slides/gerar_slides.py                # gera as quatro aulas
python3 slides/gerar_slides.py --aula 1       # só a Aula 1
```

---

## Rodando o projeto

Pré-requisitos e instalação passo a passo em [`docs/00-preparacao.md`](docs/00-preparacao.md).
Com tudo instalado:

```bash
docker compose up -d          # sobe o Postgres
bin/setup                     # instala gems e prepara o banco
bin/rails server              # http://localhost:3000
```
