# Glossário

Termos que aparecem nas quatro aulas, em ordem alfabética.

---

**Accessory** — Container que o Kamal gerencia mas não faz deploy junto com a aplicação. O Postgres
é um. `kamal deploy` não sobe accessory; use `kamal accessory boot|reboot`.

**ActiveRecord** — O ORM do Rails. Cada classe é uma tabela, cada objeto é uma linha. Equivalente
ao Django ORM.

**API** — *Application Programming Interface*. A porta de entrada do sistema para outros programas.
Aqui, uma API REST que responde JSON.

**Bcrypt** — Função de hash feita para senha. Lenta de propósito, com fator de custo ajustável e
salt aleatório por senha. Ver [`02-activerecord.md`](02-activerecord.md).

**Bearer** — O esquema do cabeçalho `Authorization: Bearer <token>`. "Portador": quem apresenta o
token é tratado como o dono dele.

**Brakeman** — Análise estática de segurança para Rails. Procura SQL injection, mass assignment,
redirect aberto e afins.

**Bundler** — O gerenciador de dependências do Ruby. Lê o `Gemfile`, resolve versões e escreve o
`Gemfile.lock`.

**CI/CD** — *Continuous Integration / Continuous Deployment*. CI roda testes e verificações a cada
push; CD publica automaticamente o que passou.

**Concern** — Módulo Ruby que uma classe inclui para ganhar um conjunto de métodos. É o mixin do
Rails. Vive em `app/models/concerns/` ou `app/controllers/concerns/`.

**Container** — Uma instância rodando de uma imagem Docker. Descartável.

**CORS** — *Cross-Origin Resource Sharing*. A regra do navegador que impede uma página de um domínio
chamar uma API de outro sem permissão explícita. Não se aplica a app nativo.

**Credentials** — Arquivo YAML criptografado do Rails (`config/credentials.yml.enc`), decriptado
pela `master.key`.

**CVE** — *Common Vulnerabilities and Exposures*. O identificador público de uma vulnerabilidade
conhecida. `bundler-audit` procura CVE nas suas gems.

**Denylist** — Lista de tokens revogados. No nosso logout, indexada pelo `jti` do JWT.

**Digest** — O resultado de passar um valor por uma função de hash. `password_digest` guarda o
digest, nunca a senha.

**Docker** — Empacota aplicação e dependências numa imagem que roda igual em qualquer lugar.

**Dockerfile** — A receita da imagem. O nosso é multi-stage: um estágio compila, o final só copia o
resultado.

**Enumeração de usuários** — Ataque em que respostas diferentes (mensagem, status ou tempo) revelam
quem tem conta no sistema. Combatido com respostas idênticas e tempo constante.

**Fixture** — Dados de teste em YAML, carregados antes de cada teste e limpos depois.

**Gem** — Biblioteca Ruby. O equivalente do pacote do pip.

**ghcr.io** — GitHub Container Registry. Onde a imagem Docker fica hospedada.

**Health check** — Rota que responde 200 se a aplicação está de pé. A nossa é `/up`. O Kamal só
troca o tráfego para o container novo depois que ela passa.

**Imagem** — A receita congelada: sistema, runtime, dependências e código. Imutável.

**Índice** — Estrutura no banco que acelera busca. Com `unique: true`, vira restrição: o banco
recusa duplicata mesmo com duas requisições simultâneas.

**JWT** — *JSON Web Token*. Cabeçalho, payload e assinatura, em Base64, separados por ponto. O
payload é **público**; a assinatura só garante que ninguém o alterou.

**jti** — *JWT ID*. Identificador único de um token, usado para revogá-lo individualmente.

**Kamal** — Ferramenta de deploy com Docker via SSH, feita pela equipe do Rails. Zero-downtime, sem
agente na máquina.

**Mass assignment** — Vulnerabilidade em que o cliente manda um campo que não devia poder mandar
(ex.: `role: admin`). Evitada com strong parameters.

**Migration** — Mudança no banco, versionada em código, que roda uma vez em cada máquina.

**Minitest** — O framework de teste que vem com o Rails.

**mise** — Gerenciador de versões de runtime. O `pyenv` do mundo Ruby.

**MVC** — *Model-View-Controller*. Model = dados e regras; View = a saída (aqui, JSON); Controller =
recebe a requisição e decide.

**NSG** — *Network Security Group*. O firewall da Azure, com regras de entrada e saída por porta e
origem.

**OIDC** — *OpenID Connect*. Permite o GitHub Actions autenticar na Azure com um token de curta
duração, sem guardar segredo de longa duração.

**OOM killer** — O mecanismo do kernel Linux que mata processos quando a RAM acaba. É por isso que
a VM tem swap.

**ORM** — *Object-Relational Mapping*. Traduz objetos em linhas de tabela.

**Origin CA** — Certificado emitido pelo Cloudflare para o trecho Cloudflare → seu servidor.
Navegador não confia nele diretamente, e não precisa: o usuário vê o certificado público do
Cloudflare.

**OTP** — *One-Time Password*. O código de 6 dígitos, válido por 15 minutos e uma vez só.

**Payload** — O miolo do JWT, onde ficam `sub`, `exp`, `jti`. Público.

**Postgres** — O banco relacional que usamos em desenvolvimento e em produção.

**Proxied (Cloudflare)** — Nuvem laranja no DNS: o tráfego passa pelo Cloudflare antes de chegar à
sua máquina, e o IP real não aparece no DNS.

**Puma** — O servidor web do Rails.

**rack-attack** — Middleware que bloqueia abuso por IP. Está no `seem-backend`, não no app do curso.

**Registry** — Repositório de imagens Docker. O "GitHub das imagens".

**REST** — Estilo de organizar a API: cada coisa é um recurso com um endereço, e o verbo HTTP diz o
que fazer com ele.

**RuboCop** — O linter de Ruby. O `black`/`ruff` do mundo Python.

**Salt** — Valor aleatório misturado à senha antes do hash, para que senhas iguais gerem digests
diferentes. O bcrypt gera um por senha, automaticamente.

**Serializer** — Decide o que de um objeto vai para o JSON — e, principalmente, o que não vai.

**Service object** — Classe que representa um caso de uso (`Users::Register`). Tira a regra de
negócio do controller.

**Solid Cache / Solid Queue** — Cache e fila do Rails 8, guardados no próprio Postgres. A denylist
do logout usa o cache.

**Strong parameters** — Filtro que declara quais campos a requisição pode mandar. No Rails 8,
`params.expect`.

**sub** — *Subject*. O claim do JWT que diz de quem é o token — no nosso caso, o `user.id`.

**Swap** — Área em disco usada como extensão da RAM. Lenta, mas evita que o OOM killer mate a
aplicação.

**Token version** — Contador no `User` que vai dentro do JWT. Incrementar invalida todos os tokens
daquele usuário de uma vez.

**Transação** — Bloco em que ou tudo acontece, ou nada acontece. `User.transaction do ... end`.

**TTL** — *Time To Live*. Por quanto tempo algo vale. Nosso código OTP tem TTL de 15 minutos; as
entradas da denylist têm o TTL do que restava do token.

**Volume (Docker)** — Área de disco que sobrevive ao container. É o que faz o banco não sumir a cada
deploy. **Não é backup.**

**VPS** — *Virtual Private Server*. Um computador virtual que é seu, com acesso root.

**WSL2** — *Windows Subsystem for Linux*. Um Linux de verdade dentro do Windows. Obrigatório para
quem desenvolve Rails no Windows.
