# Troubleshooting

Erros que acontecem de verdade, e a saída de cada um. Os da parte de infraestrutura vieram do
histórico real de deploy do `seem-backend`.

---

## Ambiente

### `mise: command not found`

A linha de `activate` não foi para o arquivo certo. Confira o fim do `~/.bashrc` (ou `~/.zshrc`) e
rode `exec bash`.

### A instalação do Ruby falha compilando

Faltou dependência de build. Rode o bloco de `apt install` / `brew install` de
[`00-preparacao.md`](00-preparacao.md#3-ruby-349-via-mise) e tente `mise install ruby@3.4.9` de novo.

### `gem install rails` reclama de permissão

Você está usando o Ruby do sistema, não o do mise. Confira:

```bash
which ruby   # tem que apontar para dentro de ~/.local/share/mise
```

### `permission denied` ao rodar `docker`

Você não está no grupo `docker`:

```bash
sudo usermod -aG docker $USER
```

E **saia e entre de novo na sessão**. Reabrir o terminal não basta.

### No Windows, `docker` não aparece dentro do Ubuntu

Docker Desktop → Settings → Resources → WSL Integration → habilite a distro `Ubuntu-24.04`.

---

## Banco

### `address already in use` ao subir o compose

Já existe um Postgres na sua máquina ocupando a 5432.

```bash
DB_PORT=5433 docker compose up -d
export DB_PORT=5433          # e exporte no shell onde roda o Rails
```

Para achar quem ocupa: `ss -ltnp | grep 5432`.

### `PG::ConnectionBad: could not connect to server`

Nesta ordem:

```bash
docker compose ps            # o container está "healthy"?
docker compose logs db       # o que ele diz?
echo $DB_PORT                # bate com a porta publicada?
```

### `PG::UndefinedTable` ou `PendingMigrationError`

Faltou migrar:

```bash
bin/rails db:migrate
```

### Quero começar do zero

```bash
bin/rails db:reset      # apaga, recria, carrega o schema e roda os seeds
```

---

## Testes

### Um teste passa sozinho e falha junto com os outros

Vazamento de estado entre testes. Suspeitos, em ordem:

1. um `Rails.cache` compartilhado (o `test_helper` troca por `MemoryStore` a cada teste);
2. `ActionMailer::Base.deliveries` não limpo;
3. dependência de ordem — o Minitest embaralha de propósito, e isso é uma qualidade.

Rode com a mesma semente para reproduzir: `bin/rails test --seed 1234`.

### O teste de logout passa mas a revogação não funciona

Em teste, o `Rails.cache` padrão é o `null_store`: não guarda nada, e `revoked?` sempre devolve
`false`. O `test_helper.rb` troca por `MemoryStore` justamente por isso. Se você recriou o arquivo,
recoloque o `setup`.

### `Bullet::Notification::UnoptimizedQueryError`

Consulta N+1: você carregou uma coleção e acessou uma associação item a item. Adicione `includes`.
(O `seem-backend` usa o Bullet; o app do curso não.)

---

## Autenticação

### Sempre 401, mesmo com o token certo

Cheque, nesta ordem:

1. o cabeçalho é exatamente `Authorization: Bearer <token>`, com o espaço;
2. o token não foi revogado (você fez logout com ele?);
3. o `token_version` do banco bate com o `ver` do token — trocar a senha incrementa a versão;
4. o `JWT_SECRET` é o mesmo que emitiu o token. Reiniciar o app em dev sem `JWT_SECRET` definido
   usa o `secret_key_base`, que é estável — mas em produção um segredo diferente invalida tudo.

Decodifique o token em [jwt.io](https://jwt.io) e olhe o `exp` e o `ver`.

### O e-mail não chega em desenvolvimento

Ele não é enviado: o `letter_opener` abre no navegador. Se você está rodando `curl` e não vendo
nada, o arquivo está em `tmp/letter_opener/`.

### `ActionController::ParameterMissing` (400)

Faltou um campo obrigatório no corpo. O `params.expect` exige todas as chaves declaradas. Confira o
JSON e o `Content-Type: application/json`.

### 422 no cadastro sem dizer o motivo direito

Olhe `error.details` na resposta: cada item tem `field` e `message`.

---

## Azure e VM

### `NotAvailableForSubscription` ao criar a VM

O tamanho escolhido não está habilitado para a sua assinatura naquela região.

**Assinaturas → Uso + cotas → filtre por Compute** e escolha outra região ou outro tamanho.
Pedir aumento de cota **não** resolve quando a oferta não está habilitada.

### SSH dá timeout

Quase sempre é o NSG:

1. o seu IP mudou? `curl -4 ifconfig.me` e compare com a regra;
2. a regra libera a porta 22, protocolo TCP, direção Entrada?
3. a prioridade da regra de permissão é **menor** que a de alguma negação?

### `Permission denied (publickey)`

```bash
chmod 600 ~/.ssh/azure-capacita
ssh -i ~/.ssh/azure-capacita -o IdentitiesOnly=yes azureuser@SEU_IP
```

O `IdentitiesOnly=yes` importa: sem ele o SSH tenta todas as chaves do agente, o servidor recusa
depois de algumas e você leva `Too many authentication failures` com a chave certa na mão.

### Perdi o acesso depois de mexer no sshd

Se você seguiu o guia, tinha uma sessão aberta — desfaça por ela. Se não, sobrou o **Serial
Console** do portal da Azure (menu da VM → Suporte + solução de problemas → Console Serial), que
não passa pelo SSH.

Da próxima vez: `sudo sshd -t` antes de `reload`, e teste em outro terminal antes de fechar o
primeiro.

---

## Deploy

### OIDC: `AADSTS700213`

O *subject* da credencial federada não bate com o que o GitHub emite. Ele precisa ser, caractere por
caractere:

```
repo:SEU-USUARIO/SEU-REPO:ref:refs/heads/main
```

Confira maiúsculas, o nome do repositório e a branch.

### `az: command not found` ou falha transitória do Azure CLI

O `azure/login` às vezes falha por instabilidade. Rode o workflow de novo antes de investigar.

### A regra temporária ficou no NSG

O passo de remoção tem `if: always()`, mas se o job for cancelado à força a regra pode sobrar.
Apague na mão:

```bash
az network nsg rule delete \
  --resource-group SEU_RG --nsg-name SEU_NSG \
  --name allow-github-actions-deploy-ssh
```

E confira depois de todo deploy que falhou de forma estranha.

### Kamal: `Docker is not installed`

O primeiro deploy precisa ser `setup`, não `deploy`. Rode o workflow por
**Actions → Run workflow → command: setup**.

### A aplicação sobe mas não acha o banco

`kamal deploy` **não** sobe accessories. O workflow tem um passo `kamal accessory boot db`, mas se
você rodou o Kamal à mão:

```bash
kamal accessory boot db
```

Depois de mudar env de accessory, `boot` não basta — é `kamal accessory reboot db`.

### Cloudflare 521 / 522

O Cloudflare não conseguiu falar com o seu servidor.

- a porta 443 está aberta no NSG?
- `docker ps` na VM mostra o `kamal-proxy` rodando?
- o registro A aponta para o IP certo?

### Cloudflare 525 / 526

Falha no handshake TLS entre Cloudflare e a sua VM.

- **525**: o proxy não apresentou certificado. Os secrets `KAMAL_PROXY_SSL_*` estão cadastrados?
- **526**: o certificado é inválido para o modo Full (strict). Ele cobre o hostname exato? Um
  wildcard `*.capacita.exemplo.tech` cobre `seunome.capacita.exemplo.tech`, mas **não** cobre
  `x.y.capacita.exemplo.tech`.

### Let's Encrypt falha atrás do Cloudflare

Esperado. Com o DNS proxied, o desafio HTTP-01 não chega como o Let's Encrypt espera. Use o
certificado Origin CA — é a razão de ele existir.

### SMTP dá timeout na VM

Vários provedores de nuvem bloqueiam a saída na porta 25, e alguns na 587. Teste a alternativa do
seu provedor de e-mail (o Resend aceita 2587) e ajuste `SMTP_PORT` no `env.clear`.

### O deploy passa mas o site responde 500

```bash
kamal app logs -f
```

Suspeitos comuns: migration pendente (`kamal app exec "bin/rails db:migrate"`), `RAILS_MASTER_KEY`
errada, ou um `ENV.fetch` sem default para uma variável que ninguém cadastrou.

### Preciso voltar atrás agora

```bash
kamal rollback
```

Volta para a versão anterior da imagem, que ainda está na VM.
