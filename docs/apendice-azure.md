# Apêndice — o mesmo servidor, na nuvem

**Para quem**: você terminou a Aula 4, tem a API rodando na VM do seu notebook, e quer colocá-la num
IP público, com domínio, certificado de CA pública e deploy automático a cada push.

**Quanto tempo**: ~2h na primeira vez, quase tudo clicando em portal.

**Quanto custa**: nada, com a [Azure for Students](https://azure.microsoft.com/free/students/) —
US$100 de crédito, sem cartão de crédito, mediante e-mail institucional. A verificação acadêmica
**pode demorar dias**; comece por ela.

> Nada aqui substitui a Aula 4. O Ubuntu, o Docker, o Kamal e o `deploy.yml` são **os mesmos**. O que
> este apêndice acrescenta é o que só existe quando a máquina está exposta ao mundo: firewall de
> provedor, DNS, certificado de CA e um jeito de o GitHub entrar na sua máquina sem guardar senha.

---

## O que muda

| | Na Aula 4 | Aqui |
|---|---|---|
| A máquina | `multipass launch` | portal da Azure: região, tamanho, imagem, cota |
| IP | privado | público, e o mundo inteiro alcança |
| Firewall | `ufw` | `ufw` **mais** o NSG da Azure |
| Nome | `/etc/hosts` | DNS de verdade, no Cloudflare |
| Certificado | autoassinado | Cloudflare Origin CA, com o público do Cloudflare na frente |
| Deploy | `kamal deploy` no seu terminal | GitHub Actions, por OIDC |
| Usuário | `ubuntu` | `azureuser` |

Esse último muda uma linha do `.env`:

```bash
KAMAL_SSH_USER=azureuser
```

---

## 1. Criar a VM na Azure

### Cotas antes de tudo

A assinatura Azure for Students não oferece todos os tamanhos em todas as regiões. O portal responde:

```
NotAvailableForSubscription
```

O caminho certo:

1. **Assinaturas → Azure for Students → Uso + cotas**
2. filtre por `Compute`
3. veja as cotas regionais
4. escolha uma região onde o tamanho aparece

> Não insista num tamanho marcado como indisponível. Pedir aumento de cota não resolve quando a
> oferta não está habilitada para a assinatura.

### O assistente

**Máquinas virtuais → Criar → Máquina virtual do Azure**

| Campo | Valor |
|---|---|
| Grupo de recursos | Novo: `rg-capacita-<seunome>` |
| Nome | `vm-capacita-<seunome>` |
| Região | uma com cota disponível |
| Imagem | Ubuntu Server 24.04 LTS — x64 Gen2 |
| Tamanho | `Standard_B1s` (1 vCPU, 1 GiB) ou maior, se houver crédito |
| Autenticação | Chave pública SSH |
| Usuário | `azureuser` |
| Tipo de chave | Ed25519 |
| **Portas públicas** | **Nenhuma** |

**"Nenhuma" é a escolha mais importante da tela.** O assistente, se deixado, cria uma regra liberando
SSH para a internet inteira. Bots varrem a porta 22 do IPv4 todo, o dia todo. Vamos abrir a 22 só
para o seu IP.

Rede:

- VNet e sub-rede: aceite os padrões
- IP público: Standard
- NSG: avançado (é o firewall — vamos mexer nele)

Marque tudo com tags (`ambiente=capacitacao`, `dono=<seunome>`): é assim que você acha recurso órfão
consumindo crédito depois.

### A chave privada

O portal oferece o download **uma vez**.

```bash
mkdir -p ~/.ssh
mv ~/Downloads/vm-capacita-seunome_key.pem ~/.ssh/azure-capacita
chmod 600 ~/.ssh/azure-capacita
```

`chmod 600` = só você lê. O SSH **recusa** usar uma chave com permissão frouxa.

### Abrir o SSH só para você

No NSG da VM, **Regras de segurança de entrada → Adicionar**:

| Campo | Valor |
|---|---|
| Origem | Endereços IP |
| IPs de origem | `SEU_IP/32` |
| Portas de destino | `22` |
| Protocolo | TCP |
| Prioridade | `100` |
| Nome | `allow-ssh-meu-ip` |

Descubra o seu IP:

```bash
curl -4 ifconfig.me
```

O `/32` significa "exatamente este endereço". Precisa também de:

| Porta | Para quê |
|---|---|
| `80` | HTTP (o Cloudflare precisa alcançar) |
| `443` | HTTPS |

> Internet de casa troca de IP. Quando o SSH parar de conectar do nada, é isso: atualize a regra.

**Este é o firewall que a sua VM local não tinha.** O `ufw` continua valendo dentro da máquina, e é
uma segunda camada — mas o NSG é o que faz o pacote nem chegar.

### Primeiro acesso, e o resto

```bash
ssh -i ~/.ssh/azure-capacita azureuser@SEU_IP_PUBLICO
```

Daqui em diante, **a seção 3 da Aula 4 inteira, sem mudar nada**: `apt upgrade`, `ufw`, Docker do
repositório oficial, `usermod -aG docker azureuser`, swap, endurecer o SSH.

O swap deixa de ser exercício e passa a ser necessidade: uma `B1s` tem 1 GiB.

```bash
ssh -i ~/.ssh/azure-capacita azureuser@SEU_IP 'sudo bash -s' < scripts/server-swap.sh
```

---

## 2. Cloudflare e TLS

### Por que uma CA pública

Na Aula 4 o certificado era autoassinado, e o `curl` reclamava até você passar `--cacert`. Aqui você
tem um domínio de verdade — dá para **provar** que ele é seu, e é isso que uma CA pública exige em
troca de um certificado em que o mundo já confia.

### DNS

No Cloudflare, no seu domínio:

| Campo | Valor |
|---|---|
| Tipo | `A` |
| Nome | `seunome.capacita` |
| Conteúdo | o IP público da sua VM |
| Proxy | **Proxied** (nuvem laranja) |

**Proxied** significa que o tráfego passa pelo Cloudflare antes de chegar na sua VM. Você ganha
cache, proteção contra DDoS e — o principal aqui — o IP real da sua máquina não aparece no DNS.

Agora há **dois** proxies reversos no caminho:

```
navegador → Cloudflare → kamal-proxy (na sua VM) → Rails
             (proxy 1)      (proxy 2)
```

### Certificado Origin CA

SSL/TLS → **Origin Server** → Create Certificate. O Cloudflare gera o par e mostra **uma vez**.

Ele protege o trecho **Cloudflare → sua VM**. O certificado que o *usuário* vê é o público do
Cloudflare — o Origin CA nunca aparece para o navegador, e por isso não precisa ser confiável por
ele.

É o mesmo lugar do `.env` que o autoassinado ocupava:

```bash
KAMAL_PROXY_SSL_CERTIFICATE="$(cat origin-ca.pem)"
KAMAL_PROXY_SSL_PRIVATE_KEY="$(cat origin-ca-key.pem)"
```

### Full (strict)

SSL/TLS → Overview → **Full (strict)**.

| Modo | Cloudflare → sua VM |
|---|---|
| Flexible | **em texto puro** — não use |
| Full | criptografado, mas aceita certificado inválido |
| **Full (strict)** | criptografado e o certificado é validado |

Com `Flexible`, o cadeado aparece para o usuário e a senha dele trafega em claro no último trecho. É
pior que não ter HTTPS, porque mente.

### Por que não Let's Encrypt

O Kamal sabe emitir Let's Encrypt sozinho. Atrás do Cloudflare proxied não dá:

- o desafio HTTP-01 não chega ao seu servidor como o Let's Encrypt espera;
- daria para tirar o proxy durante a emissão, mas isso expõe o IP e vira ritual manual a cada
  renovação.

**Sem Cloudflare na frente**, com o DNS apontando direto para a VM, o Let's Encrypt é o caminho mais
simples e o Kamal cuida sozinho:

```yaml
proxy:
  ssl: true
  host: <%= ENV.fetch("APP_HOST") %>
```

---

## 3. OIDC — deploy sem senha

O jeito comum seria criar um *client secret* na Azure e guardar como secret do GitHub. Problemas: ele
é longo, vale por meses, e quem tiver acesso ao repositório tem acesso à sua Azure.

**OIDC** (OpenID Connect) inverte: o GitHub emite, a cada execução, um token de curta duração que diz
"sou o workflow do repositório X, na branch Y". A Azure verifica e devolve um acesso temporário.

**Não existe segredo de longa duração em lugar nenhum.**

### Criando

**1. Registro de aplicativo** — Microsoft Entra ID → Registros de aplicativo → Novo registro:

- nome: `github-capacita-<seunome>`
- contas: somente este diretório
- URI de redirecionamento: vazia
- **não crie segredo do cliente**

Anote: Application (client) ID, Directory (tenant) ID, Subscription ID.

**2. Credencial federada** — no app criado, Certificados e segredos → Credenciais federadas →
Adicionar → cenário **GitHub Actions**:

| Campo | Valor |
|---|---|
| Organização | seu usuário do GitHub |
| Repositório | nome do repositório |
| Tipo de entidade | Branch |
| Branch | `main` |

O subject resultante:

```
repo:SEU-USUARIO/SEU-REPO:ref:refs/heads/main
```

> Precisa bater **caractere por caractere** com o que o GitHub emite. Erro de maiúscula, de nome ou
> de branch dá `AADSTS700213` — e a mensagem não ajuda.

**3. Permissão mínima** — no **NSG** (não na assinatura), IAM → Adicionar atribuição de função →
**Colaborador de Rede** → o app criado.

Escopo no NSG e não na assinatura: se a credencial vazar, o estrago se limita a regras de firewall
daquela máquina.

**4. Chave SSH de deploy** — separada da sua chave pessoal:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/capacita-github -C "github-actions" -N ""

ssh -i ~/.ssh/azure-capacita azureuser@SEU_IP \
  'umask 077; mkdir -p ~/.ssh; cat >> ~/.ssh/authorized_keys' < ~/.ssh/capacita-github.pub
```

Chave separada dá para revogar o acesso do CI sem trocar o seu.

---

## 4. O workflow de deploy

`.github/workflows/deploy.yml` roda a cada push na `main`. O ponto delicado é o SSH: a porta 22 está
fechada para a internet, e o runner do GitHub tem IP diferente a cada execução — não dá para liberar
antes.

```
1. autentica na Azure (OIDC)
2. descobre o próprio IP público
3. cria uma regra no NSG liberando a 22 só para esse IP/32
4. faz o deploy
5. APAGA a regra — mesmo se o deploy falhar
```

O passo 5 tem `if: always()`. **Deixar a 22 aberta é o erro que transforma um deploy ruim num
incidente de segurança.**

E aqui o build volta a acontecer no runner, não no seu notebook — que é o que você quer: o deploy
deixa de depender da sua máquina estar ligada.

### Cadastrando no GitHub

**Settings → Secrets and variables → Actions**

**Secrets:**

| Nome | Conteúdo |
|---|---|
| `AZURE_CLIENT_ID` | Application (client) ID |
| `AZURE_TENANT_ID` | Directory (tenant) ID |
| `AZURE_SUBSCRIPTION_ID` | Subscription ID |
| `AZURE_SSH_PRIVATE_KEY` | conteúdo de `~/.ssh/capacita-github` (a privada) |
| `RAILS_MASTER_KEY` | conteúdo de `config/master.key` |
| `AUTOMIC_AUTH_API_DATABASE_PASSWORD` | invente uma senha longa |
| `JWT_SECRET` | saída de `bin/rails secret` |
| `SMTP_ADDRESS` / `SMTP_USERNAME` / `SMTP_PASSWORD` | do provedor de e-mail |
| `KAMAL_PROXY_SSL_CERTIFICATE` | certificado Origin CA |
| `KAMAL_PROXY_SSL_PRIVATE_KEY` | chave do Origin CA |

Repare que **não existe `KAMAL_REGISTRY_PASSWORD`**: dentro do Actions, o `GITHUB_TOKEN` que o
próprio GitHub gera já autentica no ghcr.io. O PAT que você criou na Aula 4 só era necessário porque
você estava fora dele.

**Variables** (não são segredo):

| Nome | Exemplo |
|---|---|
| `GHCR_USER` | seu usuário do GitHub |
| `SERVER_IP` | `57.156.65.151` |
| `KAMAL_SSH_USER` | `azureuser` |
| `SERVER_ARCH` | `amd64` |
| `APP_HOST` | `seunome.capacita.exemplo.tech` |
| `AZURE_RESOURCE_GROUP` | `rg-capacita-seunome` |
| `AZURE_NSG_NAME` | nome do NSG |
| `CORS_ORIGINS` | `http://localhost:5173` |
| `MAILER_FROM` | `Capacitação <noreply@exemplo.tech>` |

Pelo CLI (não deixa o valor no histórico do shell):

```bash
gh secret set JWT_SECRET
gh secret set KAMAL_PROXY_SSL_CERTIFICATE < origin-ca.pem
gh variable set APP_HOST
```

### O primeiro deploy

**Actions → Deploy (Kamal) → Run workflow → command: `setup`**

`setup` instala o Docker se faltar, sobe os accessories e faz o primeiro deploy. Só na primeira vez —
depois é `deploy`, e ele acontece sozinho a cada push.

```bash
curl https://seunome.capacita.exemplo.tech/api/v1/status
```

```json
{"status":"ok","service":"automic-auth-api","environment":"production"}
```

E desta vez sem `--cacert`: o certificado que o seu `curl` recebeu foi assinado por uma CA em que ele
já confiava.

---

## 5. Antes de ir embora

- [ ] **Desligar a VM** no portal (`Parar`). Parada, ela não consome crédito de computação. Uma
      `B1s` ligada 24h custa ~US$8/mês: os US$100 dão quase um ano, se você desligar.
- [ ] Conferir que a regra temporária de SSH sumiu do NSG:

```bash
az network nsg rule list --resource-group SEU_RG --nsg-name SEU_NSG --query "[].name" -o tsv
```

Não pode ter `allow-github-actions-deploy-ssh` na lista.

---

## Recapitulando

- O trabalho é o mesmo. O que a nuvem acrescenta é **exposição** — e cada peça nova aqui existe por
  causa dela.
- O firewall do provedor vem antes do `ufw`: o pacote nem chega.
- CA pública exige prova de domínio. É a única diferença real entre ela e o seu `openssl`.
- Full (strict), sempre. `Flexible` mente para o usuário.
- OIDC troca segredo de longa duração por token de curta. Prefira sempre.
- A porta 22 abre por um minuto e fecha — inclusive quando dá errado.

Os erros que realmente acontecem neste percurso estão em
[`troubleshooting.md`](troubleshooting.md#apêndice-nuvem-azure-e-cloudflare).
