# Aula 2 — Banco de dados, ActiveRecord e o model `User`

**Duração**: ~3h · **Você sai daqui com**: um `User` com validações e senha hasheada, testado.
**Checkpoint**: `git checkout aula-02`

---

## 1. Por que Postgres, e não SQLite

SQLite é um arquivo. Funciona muito bem para um app de celular ou um script. Para um servidor com
várias requisições ao mesmo tempo, ele trava — só uma escrita por vez no banco inteiro.

Postgres é um servidor: aguenta concorrência, tem tipos ricos (`jsonb`, arrays, intervalos de
tempo), índices parciais e transações de verdade. É o que o `seem-backend` usa em produção, então é
o que usamos aqui — **desenvolver no mesmo banco da produção evita a categoria inteira de bug que
só aparece no deploy.**

---

## 2. ActiveRecord

É o ORM do Rails: cada classe é uma tabela, cada objeto é uma linha.

| Django ORM | ActiveRecord |
|---|---|
| `User.objects.filter(role="admin")` | `User.where(role: "admin")` |
| `User.objects.get(id=1)` | `User.find(1)` |
| `User.objects.all().order_by("-created_at")` | `User.order(created_at: :desc)` |
| `User.objects.count()` | `User.count` |
| `u.save()` | `u.save` |

A diferença de filosofia: no Django você declara os campos na classe. **No Rails a classe não
declara nada** — ela lê as colunas do banco em tempo de execução. A fonte da verdade é a migration.

```ruby
class User < ApplicationRecord
end
```

Isso já tem `name`, `email`, `id`, `created_at` — tudo que existir na tabela `users`.

---

## 3. Migrations

Uma migration é uma **mudança no banco, versionada em código**. Ela roda uma vez, em ordem, em
todas as máquinas: a sua, a do colega e o servidor.

```bash
bin/rails generate migration CreateUsers
```

Isso cria `db/migrate/20260803142949_create_users.rb`. O número é a data e hora — é ele que define
a ordem.

```ruby
class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :course, null: false
      t.string :matricula, null: false
      t.datetime :terms_accepted_at, null: false

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :matricula, unique: true
  end
end
```

```bash
bin/rails db:migrate
```

Repare em duas coisas:

- **`t.timestamps`** cria `created_at` e `updated_at`, e o Rails mantém as duas sozinho.
- **`add_index ... unique: true`** é uma restrição no banco, não só validação no model. Isso
  importa: duas requisições simultâneas passam pela validação juntas (as duas consultam e as duas
  não acham ninguém), mas só uma vence o índice único. **Validação de model é para dar mensagem
  bonita; índice é para garantir.**

### `schema.rb`

Depois de migrar, o Rails reescreve `db/schema.rb` — o retrato atual do banco. É ele que `db:prepare`
usa para criar o banco de teste, e por isso **vai versionado**. Você nunca edita esse arquivo à mão.

### Migrations são incrementais

Neste projeto a tabela `users` nasceu em três migrations, porque as funcionalidades chegaram em
momentos diferentes:

```
20260803142949_create_users.rb                    # o básico
20260803142950_add_email_verification_to_users.rb # confirmação de e-mail
20260803142951_add_password_reset_to_users.rb     # recuperação de senha
```

É assim que acontece na vida real. Nunca edite uma migration que já rodou em produção — crie outra.

---

## 4. Senha: o que nunca fazer

**Nunca guarde senha em texto.** Se o banco vazar — e bancos vazam — você entregou a senha de
todos. E como as pessoas repetem senha, você entregou o e-mail e o banco delas junto.

### Hash não é criptografia

Criptografia tem volta (com a chave). **Hash não tem volta**: é um caminho só. Você não guarda a
senha; guarda o resultado de passar a senha pela função. Na hora do login, passa de novo e compara
os resultados.

### Por que bcrypt e não SHA-256

SHA-256 é rápido — **e isso é o problema**. Uma GPU testa bilhões de SHA-256 por segundo. bcrypt foi
feito para ser **lento de propósito** e tem um fator de custo ajustável: quando o hardware melhora,
você aumenta o custo.

bcrypt também gera um **salt** aleatório por senha. Sem salt, duas pessoas com a mesma senha teriam
o mesmo hash, e uma tabela pronta (*rainbow table*) quebraria as duas de uma vez.

```
$2a$12$R9h/cIPz0gi.URNNX3kh2O...
 │   │  └── salt + hash
 │   └── fator de custo (12 = 2^12 iterações)
 └── versão do algoritmo
```

### `has_secure_password`

```ruby
# Gemfile
gem "bcrypt", "~> 3.1.7"
```

```ruby
class User < ApplicationRecord
  has_secure_password validations: false
end
```

Isso dá ao model:

- `user.password = "..."` — recebe a senha em texto e grava o digest em `password_digest`
- `user.authenticate("...")` — devolve o usuário se bater, `false` se não
- `user.password_confirmation` — a confirmação, se você usar

A senha em texto **nunca toca o banco**. Ela vive na memória durante a requisição e some.

> `validations: false` desliga as validações padrão porque a nossa política de senha é mais
> exigente. Ela mora em `PasswordPolicyValidator`.

---

## 5. Validações

```ruby
validates :name, presence: true, length: { maximum: 120 }
validates :email, presence: true,
                  uniqueness: { case_sensitive: false },
                  format: { with: URI::MailTo::EMAIL_REGEXP }
validates :course, presence: true
validates :matricula, presence: true, uniqueness: true, format: { with: /\A\d{7}\z/ }
validates :terms_accepted_at, presence: true, on: :create
validate  :password_meets_policy, if: -> { password.present? }
```

- `validates` (plural) usa um validador pronto. `validate` (singular) chama um método seu.
- `on: :create` só valida na criação — os termos são aceitos uma vez.
- `if:` recebe um lambda. Só valida a senha quando ela foi informada (na edição de perfil ela não é).

No console:

```ruby
u = User.new(name: "Teste")
u.valid?          # false
u.errors.full_messages
```

### Regra de ouro: normalize antes de validar

`Ana@UFOP.br` e `ana@ufop.br` são o mesmo e-mail. `20.112-34` e `2011234` são a mesma matrícula.

```ruby
def self.normalize_email(email)
  email.to_s.strip.downcase
end

def self.normalize_matricula(matricula)
  matricula.to_s.gsub(/\D/, "")
end
```

Sem isso o índice único não serve para nada: o banco acha que são valores diferentes.

---

## 6. Concerns — o mixin da Aula 1, na prática

O `User` vai ganhar confirmação de e-mail e recuperação de senha. São dois assuntos que não
conversam entre si. Jogar os dois no `user.rb` produz um arquivo de 800 linhas que ninguém abre com
vontade.

Cada assunto vira um módulo em `app/models/concerns/`:

```ruby
# app/models/concerns/email_verifiable.rb
module EmailVerifiable
  extend ActiveSupport::Concern

  CODE_TTL = 15.minutes
  RESEND_COOLDOWN = 1.minute

  included do
    scope :email_verified, -> { where.not(email_verified_at: nil) }
  end

  def email_verified?
    email_verified_at.present?
  end

  def issue_email_verification_code!
    code = format("%06d", SecureRandom.random_number(1_000_000))

    update!(
      email_verification_code_digest: BCrypt::Password.create(code),
      email_verification_expires_at: CODE_TTL.from_now,
      email_verification_sent_at: Time.current
    )

    code
  end
end
```

```ruby
class User < ApplicationRecord
  include EmailVerifiable
  include PasswordResettable
end
```

- `extend ActiveSupport::Concern` habilita o bloco `included do ... end`, onde vão coisas que só
  fazem sentido na classe (scopes, validações, associações).
- O código completo dos dois concerns está em `app/models/concerns/`.

### Três decisões dentro do concern, e o porquê de cada uma

**1. O código de 6 dígitos também vira digest bcrypt.** Ele é uma senha temporária. Quem lê o banco
não pode confirmar a conta de ninguém.

**2. O código em texto só existe no retorno do método.** `issue_email_verification_code!` devolve o
código para o service mandar por e-mail, e depois ele some. Não fica em coluna, nem em log.

**3. `email_verified_at` é data, não booleano.** Um booleano responde "sim". Uma data responde "sim,
em 12 de agosto às 14h" — e isso você vai querer saber quando alguém abrir um chamado.

---

## 7. O console

```bash
bin/rails console
```

```ruby
u = User.new(
  name: "Ana Souza",
  email: "ana@aluno.ufop.edu.br",
  password: "Automic@2026",
  course: "Engenharia de Controle e Automação",
  matricula: "2011234",
  terms_accepted_at: Time.current
)

u.valid?
u.save
u.password_digest          # o hash, não a senha
u.authenticate("Automic@2026")   # devolve o user
u.authenticate("errada")         # false

User.count
User.where("email LIKE ?", "%ufop%")
User.find_by(email: "ana@aluno.ufop.edu.br")

codigo = u.issue_email_verification_code!
u.verify_email_code!(codigo)
u.email_verified?
```

> `bin/rails console --sandbox` desfaz tudo ao sair. Bom para experimentar sem sujar o banco.

---

## 8. Seeds e fixtures

**Seeds** povoam o banco de desenvolvimento:

```bash
bin/rails db:seed
```

**Fixtures** são os dados dos testes, em `test/fixtures/users.yml`. O Rails carrega antes de cada
teste e limpa depois — todo teste começa do mesmo estado.

```yaml
ana:
  name: Ana Souza
  email: ana@aluno.ufop.edu.br
  password_digest: <%= BCrypt::Password.create("Automic@2026") %>
  email_verified_at: <%= 1.day.ago.to_fs(:db) %>
```

No teste, `users(:ana)` devolve esse registro.

---

## 9. Testando o model

```ruby
test "guarda o digest e nunca a senha em texto" do
  user = build_user
  user.save!

  assert_not_equal "Automic@2026", user.password_digest
  assert user.authenticate("Automic@2026")
  assert_not user.authenticate("outra-senha")
end
```

```bash
bin/rails test
bin/rails test test/models/user_test.rb          # só um arquivo
bin/rails test test/models/user_test.rb:42       # só um teste
```

O Rails vem com **Minitest**. Se você conhece `pytest`, a ideia é a mesma; a sintaxe é `assert_*`.

---

## 10. Uma sutileza de segurança: `authenticate_by_email`

```ruby
DUMMY_PASSWORD_DIGEST = BCrypt::Password.create("automic-timing-safe-dummy").freeze

def self.authenticate_by_email(email, password)
  user = find_by(email: normalize_email(email))
  digest = user&.password_digest || DUMMY_PASSWORD_DIGEST
  autenticado = BCrypt::Password.new(digest).is_password?(password.to_s)

  user if autenticado
end
```

Por que esse `DUMMY_PASSWORD_DIGEST`?

O jeito ingênuo seria `return nil unless user`. Só que bcrypt é lento **de propósito**. Se o e-mail
não existe, a resposta volta em 1ms; se existe e a senha está errada, volta em 100ms. Cronometrando
as respostas, dá para descobrir quem tem conta no sistema — é um **ataque de temporização**.

Rodando o bcrypt sempre, com um digest descartável quando não há usuário, as duas respostas custam
o mesmo. Vamos usar esse método na Aula 3.

---

## Exercício da aula

1. Crie as três migrations e rode `bin/rails db:migrate`.
2. Abra `db/schema.rb` e confira que as colunas estão lá.
3. Escreva o `User` com `has_secure_password` e as validações.
4. Crie os dois concerns e inclua no `User`.
5. No console: crie um usuário, veja o `password_digest`, teste `authenticate`.
6. Emita um código de verificação e confirme com ele. Depois tente confirmar de novo — tem que
   recusar.
7. Escreva os testes e rode `bin/rails test`.

**Bônus**: faça um `scope :recentes` que devolve os usuários criados nos últimos 7 dias.

Travou? `git checkout aula-02`.

---

## Recapitulando

- Migration é a fonte da verdade do banco. O model não declara colunas.
- Índice único é garantia; validação é mensagem bonita. Você quer os dois.
- Senha vira hash bcrypt, com salt, e nunca volta.
- Concern é o mixin do Rails: um assunto por arquivo.
- Normalize antes de validar, ou o índice único não serve para nada.

**Na próxima**: as rotas. O usuário vai conseguir se cadastrar, entrar, sair e recuperar a senha.
