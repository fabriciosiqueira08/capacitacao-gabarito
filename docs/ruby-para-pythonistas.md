# Ruby para quem sabe Python

Você já sabe programar. Isto aqui é tradução, não curso de lógica.

---

## Sintaxe

| Python | Ruby |
|---|---|
| Indentação delimita bloco | `def` … `end` |
| `None` / `True` / `False` | `nil` / `true` / `false` |
| `snake_case` para funções | `snake_case` (igual) |
| `PascalCase` para classes | `PascalCase` (igual) |
| `CONSTANTE` por convenção | Constante é qualquer nome com inicial maiúscula |
| `f"Olá {nome}"` | `"Olá #{nome}"` |
| `# comentário` | `# comentário` |
| `return` explícito | A última expressão é o retorno |
| `and` / `or` / `not` | `&&` / `\|\|` / `!` |
| `elif` | `elsif` |
| `len(x)` | `x.length` |
| `str(x)` | `x.to_s` |
| `int("3")` | `"3".to_i` |
| `print(x)` | `puts x` |

### Só em Ruby

```ruby
faca_algo if condicao          # modificador: if no fim da linha
faca_algo unless condicao      # unless = if not
5.times { |i| puts i }         # número é objeto
nome = usuario&.nome           # safe navigation (o ?. de outras linguagens)
valor ||= "padrao"             # atribui só se estiver nil/false
```

---

## Estruturas de dados

| Python | Ruby |
|---|---|
| `[1, 2, 3]` | `[1, 2, 3]` — `Array` |
| `{"a": 1}` | `{ a: 1 }` — `Hash`, chave símbolo |
| `{"a": 1}["a"]` | `{ a: 1 }[:a]` |
| `(1, 2)` tupla | não existe (use array congelado) |
| `{1, 2}` set | `Set.new([1, 2])` |
| não tem | `:simbolo` |

```ruby
usuario = { nome: "Ana", role: :admin }
usuario[:nome]        # "Ana"
usuario.fetch(:idade, 0)   # 0 — como dict.get com padrão
```

### Símbolos

Um símbolo é uma **etiqueta**: um texto usado como nome, não como conteúdo. O mesmo símbolo é
sempre o mesmo objeto na memória, o que o torna barato de comparar.

```ruby
"admin" == "admin"   # true, mas são dois objetos diferentes
:admin  == :admin    # true, e é o mesmo objeto
```

**Regra prática**: conteúdo que o usuário lê → string. Nome de coisa no código → símbolo.

---

## Blocos, o coração do Ruby

Um bloco é código que você entrega para um método executar. Em Python isso é o `lambda`, usado de
vez em quando. Em Ruby é o caminho normal.

```python
# Python
for u in usuarios:
    print(u.nome)

nomes  = [u.nome for u in usuarios]
ativos = [u for u in usuarios if u.ativo]
total  = sum(u.pontos for u in usuarios)
```

```ruby
# Ruby
usuarios.each do |u|
  puts u.nome
end

nomes  = usuarios.map { |u| u.nome }
ativos = usuarios.select { |u| u.ativo? }
total  = usuarios.sum { |u| u.pontos }
```

Chaves quando cabe numa linha, `do ... end` quando não cabe.

| Python | Ruby |
|---|---|
| list comprehension | `.map` |
| `filter` / comprehension com `if` | `.select` (e `.reject` para o inverso) |
| `functools.reduce` | `.reduce` / `.inject` |
| `any()` / `all()` | `.any?` / `.all?` |
| `sorted(x, key=...)` | `x.sort_by { ... }` |
| `enumerate` | `.each_with_index` |
| `zip` | `.zip` |
| `next(x for x in l if ...)` | `.find { ... }` |

---

## Argumentos nomeados

```python
# Python
def login(email, password, client="mobile"): ...
login(email="a@b.c", password="x")
```

```ruby
# Ruby — os dois-pontos DEPOIS do nome tornam obrigatório nomear na chamada
def login(email:, password:, client: "mobile")
end

login(email: "a@b.c", password: "x")
```

Sem os dois-pontos, é argumento posicional como em Python. Com eles, quem chama **tem** que nomear —
e a ordem deixa de importar.

### O atalho do Ruby 3.1

Quando a variável tem o mesmo nome da chave, você omite o valor:

```ruby
email = "a@b.c"
password = "x"

login(email:, password:)        # em vez de login(email: email, password: password)
```

Isso aparece em **todo service do projeto**:

```ruby
Result.new(success?: true, user:)     # user: user
```

Não é erro de digitação.

---

## Struct

Quando você só quer agrupar valores, sem comportamento:

```ruby
Result = Struct.new(:success?, :user, :errors, keyword_init: true)

r = Result.new(success?: true, user: ana)
r.success?   # true
r.user       # ana
```

`keyword_init: true` obriga a nomear na criação. É o `namedtuple` / `dataclass` do Python. Todo
service deste projeto devolve um `Struct` desses.

---

## Exceções

| Python | Ruby |
|---|---|
| `try` | `begin` |
| `except` | `rescue` |
| `finally` | `ensure` |
| `raise` | `raise` |
| `Exception` (base para capturar) | `StandardError` |

```python
try:
    arriscado()
except ValueError as e:
    print(e)
finally:
    limpar()
```

```ruby
begin
  arriscado
rescue ArgumentError => e
  puts e.message
ensure
  limpar
end
```

Dentro de um método, o `begin` é implícito — dá para escrever só o `rescue` no fim:

```ruby
def call
  arriscado
rescue StandardError => e
  Rails.error.report(e)
  nil
end
```

Criando o seu tipo de erro:

```ruby
class InvalidToken < StandardError; end

raise InvalidToken if token_ruim?
```

> Herde sempre de `StandardError`, nunca de `Exception`. `rescue` sem classe captura
> `StandardError`; capturar `Exception` pega até `Ctrl+C` e erro de falta de memória.

`raise` sem argumento, dentro de um `rescue`, relança a exceção atual.

---

## Atalhos de literal

```ruby
%w[mobile web]      # => ["mobile", "web"]   — array de strings
%i[name email]      # => [:name, :email]     — array de símbolos
```

Só economizam aspas e vírgulas. Aparecem em constantes por todo o projeto:

```ruby
CLIENTS = %w[mobile web].freeze
REQUIRED_FIELDS = %i[name email password].freeze
```

`.freeze` congela o objeto: tentar alterar depois levanta erro. Em Ruby strings e arrays são
mutáveis (diferente de Python), então constante sem `freeze` é constante só no nome.

---

## Classes

```python
class Usuario:
    def __init__(self, nome):
        self.nome = nome

    def saudacao(self):
        return f"Oi, {self.nome}"

    @property
    def admin(self):
        return self.role == "admin"
```

```ruby
class Usuario
  attr_accessor :nome        # gera o getter e o setter

  def initialize(nome)
    @nome = nome             # @ marca variável de instância
  end

  def saudacao
    "Oi, #{@nome}"
  end

  def admin?
    role == "admin"
  end
end
```

| Python | Ruby |
|---|---|
| `__init__` | `initialize` |
| `self.x` | `@x` |
| `self` como primeiro parâmetro | `self` implícito |
| `@property` | método normal (não precisa de parênteses) |
| `@staticmethod` | `def self.metodo` |
| `_privado` por convenção | `private` de verdade |
| herança múltipla | módulos (`include`) |

### `?` e `!`

```ruby
user.admin?    # devolve true/false
user.save      # devolve false se falhar
user.save!     # estoura ActiveRecord::RecordInvalid se falhar
```

Convenção, não regra da linguagem. Mas todo mundo segue — e o Rails inteiro depende dela.

---

## Módulos e mixins

Ruby não tem herança múltipla. Tem módulo: um saco de métodos que você inclui.

```python
# Python: mixin por herança múltipla
class Usuario(Base, VerificavelPorEmail, RecuperaSenha):
    pass
```

```ruby
# Ruby: include
class Usuario < ApplicationRecord
  include EmailVerifiable
  include PasswordResettable
end
```

```ruby
module EmailVerifiable
  extend ActiveSupport::Concern

  def email_verificado?
    email_verified_at.present?
  end
end
```

No Rails, um módulo desses vive em `app/models/concerns/` e se chama **concern**. É o que impede o
`User` de virar um arquivo de 800 linhas.

---

## Dependências e ferramentas

| Python | Ruby |
|---|---|
| `pip install x` | `gem install x` |
| `requirements.txt` | `Gemfile` |
| `pip freeze > requirements.txt` | `Gemfile.lock` (gerado sozinho, sempre versionado) |
| `venv` / `virtualenv` | `bundler` isola por projeto |
| `pyenv` | `mise` / `rbenv` |
| `python -m x` | `bundle exec x` |
| `pytest` | `minitest` (padrão do Rails) ou `rspec` |
| `black` / `ruff` | `rubocop` |
| `mypy` | não há equivalente padrão — Ruby é dinâmica de ponta a ponta |
| `python` (REPL) | `irb` |

---

## Rails × Django

| Django | Rails |
|---|---|
| `models.py` com classes `Model` | `app/models/`, um arquivo por classe |
| `makemigrations` / `migrate` | `rails g migration` / `rails db:migrate` |
| `urls.py`, escrito à mão | `config/routes.rb` |
| `views.py` | `app/controllers/` |
| `serializers.py` (DRF) | `app/serializers/` (feito à mão neste projeto) |
| Django ORM: `User.objects.filter(...)` | ActiveRecord: `User.where(...)` |
| `manage.py` | `bin/rails` |
| `settings.py` | `config/application.rb` + `config/environments/` |
| `.env` + `django-environ` | `Rails.application.credentials` + ENV |
| `python manage.py shell` | `bin/rails console` |

### Consultas lado a lado

```python
User.objects.filter(role="admin")
User.objects.get(id=1)
User.objects.filter(email__icontains="ufop").order_by("-created_at")[:10]
User.objects.count()
```

```ruby
User.where(role: "admin")
User.find(1)
User.where("email ILIKE ?", "%ufop%").order(created_at: :desc).limit(10)
User.count
```

---

## Pegadinhas de quem vem do Python

| Pegadinha | O que acontece |
|---|---|
| `0` e `""` são **verdadeiros** em Ruby | Só `nil` e `false` são falsos. `if 0` executa. |
| `puts` devolve `nil` | Não use o retorno de `puts` |
| Parênteses são opcionais | `user.save` e `user.save()` são a mesma coisa |
| `=` no fim do nome define setter | `def nome=(valor)` habilita `obj.nome = "x"` |
| Strings são mutáveis | Diferente de Python. Use `.freeze` em constantes. |
| `and`/`or` existem, mas têm precedência diferente de `&&`/`\|\|` | Use `&&` e `\|\|` sempre |
| Não existe `elif` | É `elsif` |
| Range com `..` inclui o fim, com `...` não | `(1..3).to_a` → `[1,2,3]`; `(1...3).to_a` → `[1,2]` |
