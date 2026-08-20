# Gabarito da Capacitação Back-end

Uma API de autenticação em Ruby on Rails: cadastro com confirmação por e-mail, login com JWT,
logout que revoga o token de verdade, e recuperação de senha que derruba as sessões abertas.

Este repositório é o **gabarito**: o código pronto, para consultar quando travar ou para comparar
com o seu. **Você não escreve aqui** — o seu projeto é outro, e é nele que você trabalha.

```
~/capacitacao-gabarito/    ← este repo. Só leitura.
~/automic_auth_api/        ← o seu projeto.
```

Travou num exercício? Abra o arquivo correspondente aqui, entenda, e escreva no seu.
**Copiar sem ler é o único jeito de sair da capacitação sem aprender nada.**

O app é um recorte do [`seem-backend`](https://github.com/fabriciosiqueira08/seem-backend), o
back-end real da XXIII Semana de Estudos da Escola de Minas. As decisões, os padrões e a
infraestrutura são os mesmos; o que muda é o tamanho.

---

## As rotas

| Método | Rota | O que faz |
|---|---|---|
| `POST` | `/api/v1/registrations` | Cadastra o usuário e dispara um código por e-mail |
| `POST` | `/api/v1/email_verifications/confirm` | Ativa a conta com o código de 6 dígitos |
| `POST` | `/api/v1/email_verifications/resend` | Reenvia o código, respeitando um intervalo mínimo |
| `POST` | `/api/v1/sessions` | Login. Devolve o JWT no cabeçalho `Authorization` |
| `DELETE` | `/api/v1/sessions` | Logout. Revoga aquele token, no servidor |
| `POST` | `/api/v1/password_resets/request` | Envia o código de recuperação |
| `POST` | `/api/v1/password_resets/confirm` | Troca a senha e derruba as sessões ativas |
| `GET` | `/api/v1/me` | Os dados de quem está autenticado |
| `GET` | `/api/v1/me/login_events` | O histórico de acessos |
| `GET` | `/api/v1/status` | Responde `ok`. Serve para saber se subiu |

---

## Onde está cada coisa

O controller recebe a requisição e devolve a resposta. **A regra de negócio não mora nele**: fica
num service, que devolve um `Struct` dizendo se deu certo.

```
app/
├── controllers/api/v1/        recebem e respondem
│   ├── registrations_controller.rb   sessions_controller.rb
│   ├── email_verifications_controller.rb
│   ├── password_resets_controller.rb  me_controller.rb
│   └── concerns/api/v1/
│       ├── authentication.rb          o before_action que valida o token
│       └── error_rendering.rb         um formato de erro só, para toda a API
│
├── services/                  a regra de negócio, um caso de uso por classe
│   ├── auth/
│   │   ├── issue_token.rb             monta e assina o JWT
│   │   ├── decode_token.rb            verifica assinatura, expiração e versão
│   │   ├── token_denylist.rb          é o que faz o logout revogar de verdade
│   │   ├── token_secret.rb            de onde vem a chave que assina
│   │   └── login.rb
│   └── users/
│       ├── register.rb                confirm_email_verification.rb
│       ├── request_password_reset.rb  complete_password_reset.rb
│       └── send_email_verification.rb  resend_email_verification.rb
│
├── models/
│   ├── user.rb                        validações, has_secure_password
│   ├── login_event.rb
│   └── concerns/
│       ├── email_verifiable.rb        emitir e conferir o código de ativação
│       └── password_resettable.rb     o mesmo, para recuperação de senha
│
├── serializers/               decidem o que sai no JSON, e o que NÃO sai
├── validators/                a política de senha, fora do model de propósito
└── mailers/                   o e-mail com o código de 6 dígitos
```

**Para entender o sistema, leia nesta ordem**: `users/register.rb`, `auth/issue_token.rb`,
`concerns/api/v1/authentication.rb`, `auth/token_denylist.rb` e `users/complete_password_reset.rb`.
Cinco arquivos, e depois deles o resto se explica.

---

## Consultando cada etapa

Cada branch tem o código **até um ponto** da capacitação. Use quando quiser comparar com o seu sem
ver o que ainda não foi explicado.

| Branch | O código tem |
|---|---|
| `aula-01` | O app gerado e a rota `/api/v1/status` |
| `aula-02` | `+` migrations, `User`, os dois concerns, `LoginEvent`, o validador de senha |
| `aula-03` | `+` as rotas, os services, o mailer, os serializers e os testes |
| `aula-04` | `+` `Dockerfile`, `config/deploy.yml` do Kamal, `.env.example`, GitHub Actions |
| `main` | Tudo |

```bash
git checkout aula-02
git checkout main
```

---

## Rodando

Você não precisa disto para acompanhar a capacitação, só se quiser ver o projeto pronto funcionando.

```bash
docker compose up -d          # sobe o Postgres
bin/setup                     # instala as gems e prepara o banco
bin/rails server              # http://localhost:3000

curl localhost:3000/api/v1/status
bin/rails test                # 71 testes
```

> Já tem um Postgres na porta 5432? Use `DB_PORT=5433 docker compose up -d` e exporte
> `DB_PORT=5433` **no mesmo shell** do `rails`.

**Ruby 3.4.9 · Rails 8.1.3 · PostgreSQL 16 · bcrypt · JWT · Kamal**

---

## A apostila

A apostila, o glossário e o troubleshooting **não estão aqui**: o instrutor entrega o PDF.

É lá que estão o passo a passo, as práticas com o que você deve ver na tela a cada comando, e as
tabelas de erro com o que costuma dar errado e a saída de cada caso.
