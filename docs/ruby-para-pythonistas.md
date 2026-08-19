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

### Aspas: a diferença que Python não tem

Em Python, `'a'` e `"a"` são a mesma coisa. **Em Ruby, não:**

```ruby
"Olá, #{nome}"     # interpola
'Olá, #{nome}'     # imprime literalmente #{nome}
```

Aspas simples são texto cru. Use aspas duplas por padrão; simples quando o texto tiver `#{` ou
muitas barras invertidas.

### Números: a pegadinha da divisão

```python
7 / 2      # 3.5   em Python 3
7 // 2     # 3
```

```ruby
7 / 2      # 3     ← inteiro dividido por inteiro dá inteiro
7.0 / 2    # 3.5
7.fdiv(2)  # 3.5
```

**Python 3 mudou esse comportamento; Ruby não.** É a origem de um bug silencioso quando se calcula
média ou porcentagem.

### Condicionais e `case`

```python
# Python
if x == 1:
    ...
elif x == 2:
    ...
else:
    ...

match x:                       # Python 3.10+
    case 1: ...
    case 2: ...
```

```ruby
# Ruby
if x == 1
  ...
elsif x == 2
  ...
else
  ...
end

case x
when 1 then ...
when 2 then ...
else ...
end
```

O `then` permite a linha única. O `case` de Ruby também aceita faixa, classe e regex:

```ruby
case idade
when 0..12  then "criança"
when 13..17 then "adolescente"
else             "adulto"
end
```

E, ao contrário de `switch` em C ou Java, **não existe `break`**: cada `when` já para sozinho.

Isso aparece no `SessionsController`:

```ruby
case session_params[:client]
when "mobile" then response.headers["Authorization"] = "Bearer #{token}"
when "web"    then set_auth_cookie(token)
end
```

### Ternário e loops

```ruby
mensagem = ativo ? "sim" : "não"     # em Python: "sim" if ativo else "não"

while restam > 0 ... end
until pronto ... end                 # o contrário do while — não existe em Python
loop do ... break if pronto ... end
```

### `puts`, `print` e `p`

| Ruby | Faz |
|---|---|
| `puts x` | imprime com quebra de linha. É o `print()` do dia a dia. |
| `print x` | imprime sem quebra de linha |
| `p x` | imprime a **representação** (com aspas, colchetes) e **devolve o objeto** |

`p` é o que você usa para depurar: `p usuario` mostra o objeto inteiro, e como ele devolve o valor,
dá para enfiar no meio de uma expressão sem quebrar nada.

### `require` × `import`

```python
import json                  # Python
from pathlib import Path
```

```ruby
require "json"               # Ruby: biblioteca ou gem
require_relative "helper"    # arquivo ao lado, caminho relativo
```

`require` carrega uma vez só e devolve `false` se já estava carregado. **Não** traz nomes para o
escopo como o `from x import y`: depois do `require`, você usa `JSON.parse` com o nome completo.

> **Dentro do Rails você nunca escreve `require`.** O Zeitwerk carrega a classe pelo nome do
> arquivo. Fora do Rails, num script solto, o `require` volta a ser necessário.

### Splat

```python
def f(*args, **kwargs): ...
```

```ruby
def f(*args, **opts); end

valores = [1, 2, 3]
f(*valores)                  # espalha o array nos argumentos
```

---

## Estruturas de dados

| Python | Ruby |
|---|---|
| `[1, 2, 3]` | `[1, 2, 3]`: `Array` |
| `{"a": 1}` | `{ a: 1 }`: `Hash`, chave símbolo |
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

### Bloco, proc e lambda

Bloco não é objeto: ele existe só na chamada do método. Quando você quer **guardar** o código numa
variável ou passar adiante, ele vira `Proc` ou `lambda`.

```python
dobro = lambda x: x * 2      # Python
dobro(3)
```

```ruby
dobro = ->(x) { x * 2 }      # Ruby: a "seta" é um lambda
dobro.call(3)
dobro.(3)                    # açúcar
```

A seta `->` é o que você vai ver no código deste projeto:

```ruby
scope :recentes, -> { order(occurred_at: :desc) }
validate :password_meets_policy, if: -> { password.present? }
```

Nos dois casos o Rails guarda aquele pedaço de código para executar **depois**: na hora da consulta
ou na hora da validação. Por isso precisa ser um objeto, e não um bloco.

> `->` e `Proc.new` são quase a mesma coisa. A diferença que importa: o lambda confere o número de
> argumentos e o `return` dele volta só do lambda. O `Proc` é relaxado nos dois pontos. Na dúvida,
> use `->`.

### Equivalências

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

Sem os dois-pontos, é argumento posicional como em Python. Com eles, quem chama **tem** que nomear,
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

Dentro de um método, o `begin` é implícito. Dá para escrever só o `rescue` no fim:

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

Convenção, não regra da linguagem. Mas todo mundo segue, e o Rails inteiro depende dela.

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
| `mypy` | não há equivalente padrão: Ruby é dinâmica de ponta a ponta |
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
| `7 / 2` dá `3`, não `3.5` | Python 3 mudou isso; Ruby não. Use `7.0 / 2` ou `7.fdiv(2)`. |
| `'texto #{x}'` não interpola | Só aspas duplas interpolam. |
| `case` não precisa de `break` | Cada `when` já para sozinho. |
| `and`/`or` existem, mas têm precedência diferente de `&&`/`\|\|` | Use `&&` e `\|\|` sempre |
| Não existe `elif` | É `elsif` |
| Range com `..` inclui o fim, com `...` não | `(1..3).to_a` → `[1,2,3]`; `(1...3).to_a` → `[1,2]` |
