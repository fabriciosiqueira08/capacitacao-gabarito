# Gabarito: Capacitação Back-end da Automic Jr.

Este repositório é o **gabarito** da capacitação de back-end: o código pronto de uma API de
autenticação em Ruby on Rails, para você consultar quando travar ou quando quiser comparar com o
seu.

O app aqui é um recorte do [`seem-backend`](https://github.com/fabriciosiqueira08/seem-backend), o
back-end real da XXIII Semana de Estudos da Escola de Minas (SEEM). As decisões, os padrões e a
infraestrutura são os mesmos; o que muda é o tamanho.

> **Você não escreve aqui.** Na Aula 1 você cria o seu próprio projeto, e é nele que você trabalha
> nos quatro encontros. Este repositório é só leitura.

```
~/capacitacao-gabarito/    ← este repo. Só leitura.
~/automic_auth_api/        ← o seu projeto. É aqui que você escreve.
```

---

## As quatro branches

Cada aula tem uma branch com o código **como ele fica no fim daquele encontro**:

```bash
git checkout aula-01   # como ficou no fim da Aula 1
git checkout aula-02   # …e assim por diante
git checkout main      # tudo pronto
```

| Branch | Contém |
|---|---|
| `aula-01` | App gerado + a rota de status |
| `aula-02` | + migrations, `User`, concerns, associações, validador de senha |
| `aula-03` | + rotas, services, mailer, serializer, testes |
| `aula-04` | + Dockerfile, Kamal, `.env.example`, GitHub Actions |
| `main` | Tudo |

Travou no meio de um exercício? Abra o arquivo correspondente aqui, entenda, e escreva no seu.
**Copiar sem ler é o único jeito de sair da capacitação sem aprender nada.**

---

## A API

| Método | Rota | O que faz |
|---|---|---|
| `POST` | `/api/v1/registrations` | Cadastra o usuário e dispara um código por e-mail |
| `POST` | `/api/v1/sessions` | Login: devolve um JWT no cabeçalho |
| `DELETE` | `/api/v1/sessions` | Logout: revoga o token de verdade, no servidor |
| `POST` | `/api/v1/password_resets/request` | Envia código de recuperação por e-mail |
| `POST` | `/api/v1/password_resets/confirm` | Troca a senha e derruba as sessões ativas |

Mais a confirmação de e-mail (`/api/v1/email_verifications/confirm` e `/resend`), que é o que faz o
login só liberar depois que a conta é ativada, e duas rotas autenticadas: `GET /api/v1/me` e
`GET /api/v1/me/login_events`.

---

## Rodando o gabarito

Você não precisa disso para acompanhar a capacitação, só se quiser ver o projeto pronto funcionando
na sua máquina.

```bash
docker compose up -d          # sobe o Postgres
bin/setup                     # instala gems e prepara o banco
bin/rails server              # http://localhost:3000
curl localhost:3000/api/v1/status
```

```bash
bin/rails test                # 71 testes
```

> Já tem um Postgres na porta 5432? Use `DB_PORT=5433 docker compose up -d` e exporte
> `DB_PORT=5433` no mesmo shell.

---

## A apostila

A apostila, o glossário e o troubleshooting **não estão aqui**: seu instrutor entrega o PDF.

É lá que estão o passo a passo das aulas, as práticas com o que você deve ver na tela, e as tabelas
de erro com os problemas que acontecem de verdade e a saída de cada um.
