# Aula 1 — O que é back-end, Ruby e o primeiro Rails

**Duração**: ~3h · **Você sai daqui com**: uma API respondendo `GET /api/v1/status`.
**Checkpoint**: `git checkout aula-01`

Pré-requisitos instalados em [`00-preparacao.md`](00-preparacao.md).

---

## 1. Os dois lados

Na capacitação de front-end você aprendeu a fazer o que o usuário vê. Back-end é o outro lado.

| Front-end | Back-end |
|---|---|
| A parte visível, que o usuário toca | A parte lógica, nos bastidores |
| HTML, CSS, JavaScript | Ruby, Python, Java, Go, Node |
| Roda no navegador ou no celular | Roda num servidor, longe do usuário |
| Se cair, a tela quebra | Se cair, nada funciona |

O back-end guarda os dados, decide quem pode ver o quê, aplica as regras de negócio, autentica
usuários e conversa com outros sistemas (e-mail, pagamento, mapas).

**Por que isso não pode viver no front?** Porque tudo que roda no navegador o usuário consegue ler
e alterar. A validação de senha no front é conveniência; a que vale é a do back.

> **A analogia**: o salão do restaurante é o front-end — mesa, cardápio, garçom. A cozinha é o
> back-end: ninguém entra, mas é lá que a comida sai. O pedido é a requisição, o prato é a
> resposta. Você não pede pra ver a receita; você pede o prato.

---

## 2. HTTP em cinco minutos

Cliente é quem pede (navegador, app, outro servidor). Servidor é quem responde. **O cliente sempre
começa a conversa** — o servidor nunca liga primeiro.

Uma **requisição** tem método, caminho, cabeçalhos e corpo. Uma **resposta** tem status, cabeçalhos
e corpo.

### Os métodos

| Método | Significa |
|---|---|
| `GET` | Me dá isso. Não muda nada. |
| `POST` | Cria isso. |
| `PUT` / `PATCH` | Altera isso. |
| `DELETE` | Apaga isso. |

O método é uma promessa. Um `GET` que apaga registro é bug, não criatividade.

### Os status

| Faixa | Significa | Exemplos |
|---|---|---|
| `2xx` | Deu certo | `200` ok, `201` criado |
| `3xx` | Foi pra outro lugar | `301`, `302` |
| `4xx` | **Você** errou | `400` pedido mal feito, `401` não autenticado, `403` sem permissão, `404` não existe, `422` dado inválido |
| `5xx` | **Nós** erramos | `500` bug nosso |

`401` é "quem é você?". `403` é "sei quem você é, e você não pode". Vamos usar os dois na Aula 3.

### HTTP não tem memória

Cada requisição começa do zero. O servidor esquece tudo entre uma e outra.

**Guarde essa frase.** Ela é o problema inteiro da Aula 3: se o servidor esquece tudo, como ele
sabe que você já fez login?

### Veja funcionando

```bash
curl -i https://api.seemxxiii.tech/api/v1/status
```

```
HTTP/2 200
content-type: application/json; charset=utf-8

{"status":"ok","service":"seem-backend"}
```

Isso é uma API real, no ar. É exatamente o que você vai construir.

---

## 3. API REST

**API** é a porta de entrada do sistema para outros programas. **REST** é um estilo de organizar
essa porta: cada coisa do sistema é um **recurso**, com um endereço.

```
/api/v1/lectures        → as palestras
/api/v1/lectures/7      → a palestra 7
```

O que você faz com o recurso é o **verbo**, não o endereço:

```
GET    /api/v1/lectures       lista
POST   /api/v1/lectures       cria
GET    /api/v1/lectures/7     mostra uma
DELETE /api/v1/lectures/7     apaga
```

❌ `/criarPalestra` · ✅ `POST /lectures`

O `v1` no caminho é a versão. Quando a API mudar de forma incompatível, nasce uma `/v2` e a `/v1`
continua funcionando — porque o app na loja do celular demora dias para atualizar.

---

## 4. Ruby, partindo do Python

Ruby foi criado por **Yukihiro Matsumoto (Matz)** em 1995, no Japão, com um objetivo declarado:
*fazer o programador feliz*. É interpretada, dinâmica e orientada a objetos — como Python.

A tabela completa está em [`ruby-para-pythonistas.md`](ruby-para-pythonistas.md). O essencial:

```ruby
# Python                          # Ruby
def saudacao(nome, formal=False): def saudacao(nome, formal: false)
    if formal:                      return "Prezado #{nome}" if formal
        return f"Prezado {nome}"    "Oi, #{nome}"
    return f"Oi, {nome}"          end
```

Três coisas para reparar:

1. **`end`** fecha o bloco, em vez da indentação.
2. **`if` no fim da linha** — é o modificador, muito usado em Ruby.
3. **A última linha é o retorno.** Não precisa escrever `return`.

### Tudo é objeto

Em Python você chama `len(x)`. Em Ruby, `x.length`. Não existe função solta: é sempre método de
alguém. Até número é objeto — `3.times { puts "oi" }`.

### Símbolos

```ruby
:aluno   :email   :admin
```

Um símbolo é um texto que serve de **etiqueta**, não de conteúdo. O mesmo símbolo é sempre o mesmo
objeto na memória. Não existe em Python — lá você usaria uma string.

Regra prática: **conteúdo que o usuário lê → string. Nome de coisa no código → símbolo.**

### Blocos

Um bloco é um pedaço de código que você entrega para um método executar. É o `lambda` do Python,
mas usado o tempo todo.

```ruby
usuarios.each do |u|            # for u in usuarios
  puts u.nome
end

usuarios.map { |u| u.nome }     # [u.nome for u in usuarios]
usuarios.select { |u| u.ativo? }  # [u for u in usuarios if u.ativo]
```

Chaves quando cabe numa linha, `do ... end` quando não cabe.

### `?` e `!`

| Sufixo | Significa | Exemplo |
|---|---|---|
| `?` | Devolve verdadeiro ou falso | `user.admin?` |
| `!` | A versão perigosa: estoura erro em vez de devolver `false` | `user.save!` |

É convenção, não regra da linguagem. Mas todo mundo segue.

### Módulos e mixins

Ruby não tem herança múltipla. Tem **módulo**: um saco de métodos que você inclui numa classe.

```ruby
class User < ApplicationRecord
  include EmailVerifiable
  include PasswordResettable
end
```

Vamos escrever esses dois módulos na Aula 2. O nome deles no mundo Rails é **concern**.

### Dependências

| Python | Ruby |
|---|---|
| `pip install` | `gem install` |
| `requirements.txt` | `Gemfile` |
| `venv` por projeto | `bundler` resolve tudo |
| `pip freeze` para travar | `Gemfile.lock`, gerado sozinho |

O `Gemfile.lock` é o `requirements.txt` travado — só que automático e **sempre versionado**. Ele é
a garantia de que a sua máquina e o servidor rodam exatamente as mesmas versões.

### Prática rápida

```bash
irb
```

```ruby
3.class            # Integer
"oi".class         # String
:oi.class          # Symbol
nil.class          # NilClass

5.times { |i| puts i }

usuario = { nome: "Ana", role: :admin }
usuario[:nome]

[1, 2, 3].map { |n| n * n }
```

---

## 5. Rails

Framework web em Ruby, criado por **David Heinemeier Hansson** em 2004 — extraído do Basecamp, um
produto real. Traz tudo junto: rotas, banco, e-mail, filas, testes, deploy. Estamos na versão 8.

### As duas leis

**Convenção sobre configuração.** Você não configura o óbvio, você segue o combinado. Classe
`User`? Então a tabela é `users`, o arquivo é `user.rb`, a chave primária é `id`. Ninguém precisa
dizer. Seguindo a convenção você escreve quase nada; brigando com ela, o dobro.

**DRY** — *Don't Repeat Yourself*. Cada regra existe num lugar só.

E uma atitude: **omakase**, "deixa comigo, chef". O Rails já escolheu as ferramentas por você. Você
pode trocar, mas só troque quando tiver um motivo real. Isso é liberdade: sobra tempo pro problema
de verdade.

### Rails × Django

| Django | Rails |
|---|---|
| `models.py` | `app/models/`, um arquivo por classe |
| `makemigrations` / `migrate` | `rails g migration` / `db:migrate` |
| `urls.py` | `config/routes.rb` |
| `views.py` | `app/controllers/` |
| Django ORM | ActiveRecord |
| `manage.py` | `bin/rails` |

Quem vem de Flask ou FastAPI vai sentir mais diferença: lá você monta cada peça, aqui elas já vêm
encaixadas.

### MVC

- **Model** — os dados e as regras. Conversa com o banco.
- **View** — a tela. Na nossa API, é o JSON.
- **Controller** — recebe a requisição e decide o que fazer.
- **Rota** — o mapa: este endereço vai para aquele controller.

O caminho é sempre: **rota → controller → model → resposta**.

---

## 6. Mão na massa

### Criar o projeto

```bash
rails new automic_auth_api --api -d postgresql \
  --skip-action-mailbox --skip-action-text --skip-active-storage \
  --skip-jbuilder --skip-action-cable
cd automic_auth_api
```

- `--api` — sem HTML, sem CSS, sem sessão de navegador. Só JSON.
- `-d postgresql` — o mesmo banco que usamos em produção.
- Os `--skip` tiram peças que não vamos usar. Cada peça a menos é uma peça a menos para dar
  problema.

### Subir o banco

Crie o `compose.yaml` (ou copie o deste repositório) e rode:

```bash
docker compose up -d
docker compose ps          # tem que aparecer "healthy"
```

> Se der `address already in use`, você já tem um Postgres na máquina ocupando a 5432. Rode
> `DB_PORT=5433 docker compose up -d` e exporte `DB_PORT=5433` no shell.

### Preparar e subir a aplicação

```bash
bin/rails db:prepare
bin/rails server
```

Abra `http://localhost:3000/up`. Verde é a aplicação de pé.

### O tour das pastas

| Pasta | O que tem |
|---|---|
| `app/` | O seu código. É onde você passa 90% do tempo. |
| `config/` | Rotas, banco, ambientes, credenciais |
| `db/` | Migrations e o retrato atual do banco (`schema.rb`) |
| `test/` | Os testes |
| `bin/` | Os comandos: `rails`, `setup`, `dev` |
| `Gemfile` | As dependências |

### Os comandos do dia a dia

```bash
bin/rails server      # sobe a aplicação
bin/rails console     # um irb com o seu projeto carregado dentro
bin/rails routes      # todas as rotas que existem
bin/rails generate    # cria arquivos seguindo a convenção
bin/rails db:migrate  # aplica as mudanças de banco
bin/rails test        # roda os testes
```

O **console** é a ferramenta mais subestimada do Rails: dá para criar usuário, rodar query e testar
método sem escrever um arquivo.

---

## 7. A primeira rota

`config/routes.rb`:

```ruby
Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "status", to: "status#show"
    end
  end
end
```

`app/controllers/api/v1/status_controller.rb`:

```ruby
module Api
  module V1
    class StatusController < ApplicationController
      def show
        render json: {
          status: "ok",
          service: "automic-auth-api",
          environment: Rails.env
        }
      end
    end
  end
end
```

Repare na convenção: `namespace :api` + `namespace :v1` + `status#show` implica exatamente o
arquivo `app/controllers/api/v1/status_controller.rb`, classe `Api::V1::StatusController`, método
`show`. Ninguém configurou isso.

### Teste

`test/controllers/api/v1/status_controller_test.rb`:

```ruby
require "test_helper"

class Api::V1::StatusControllerTest < ActionDispatch::IntegrationTest
  test "responde ok" do
    get "/api/v1/status"

    assert_response :ok
    assert_equal "ok", response.parsed_body["status"]
  end
end
```

```bash
bin/rails test
```

---

## Exercício da aula

1. Crie o projeto com `rails new`.
2. Suba o Postgres com `docker compose up -d`.
3. Rode `bin/rails server` e abra `http://localhost:3000/up`.
4. Crie a rota `GET /api/v1/status`.
5. Chame ela no Insomnia e confira o status `200`.
6. Rode `bin/rails routes` e ache a sua rota na lista.
7. Escreva o teste e rode `bin/rails test`.

**Bônus**: faça a rota devolver também a versão do Ruby (`RUBY_VERSION`) e do Rails
(`Rails.version`).

Travou? `git checkout aula-01` e você continua de um estado que funciona.

---

## Recapitulando

- Back-end é a cozinha: regra, dado e permissão.
- HTTP é o idioma; verbo, status e JSON são o vocabulário.
- HTTP não tem memória — segure essa ponta até a Aula 3.
- Ruby é Python com outra sintaxe e mais açúcar.
- Rails decide o óbvio por você. Siga a convenção.

**Na próxima**: o banco de dados entra em cena, e a API ganha um `User` com senha de verdade.
