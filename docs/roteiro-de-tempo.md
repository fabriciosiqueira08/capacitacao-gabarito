# Roteiro de tempo — para quem apresenta

Este arquivo é só para você. Ele existe porque o material **não cabe confortavelmente em 4 × 3h**, e
é melhor você saber onde está atrasado do que descobrir às 21h com metade da turma perdida.

## O número honesto

| Aula | Slides | Código digitado | Tempo estimado | Disponível |
|---|---|---|---|---|
| 1 | 62 | 111 linhas | ~185 min | 180 |
| 2 | 48 | ~520 linhas | ~170 min | 180 |
| 3 | 57 | 1396 linhas | ~390 min | 180 |
| 4 | 61 | 311 linhas + 20 segredos + portal Azure/Entra/Cloudflare | ~370 min | 180 |

Base do cálculo: slide a ~2 min, digitação guiada a ~5 linhas/min.

**As aulas 3 e 4 estão ~2× acima.** As duas saídas, em ordem de eficácia:

1. **Entregar o código pronto e ler junto.** Nas aulas 3 e 4, dê `git checkout aula-03` e percorra
   os arquivos explicando, em vez de todos digitarem. A prática vira *modificar* o que já existe
   (o exercício bônus de cada apostila serve para isso).
2. **Cortar os blocos marcados.** Ver abaixo.

## Marcações no YAML dos slides

| Marca | Significa |
|---|---|
| `# CORTÁVEL` | Pré-requisito. Corte se a turma já sabe Git, terminal, SQL ou Linux. |
| `# EXTRA` | Conceito de fundo (rede, TLS, XSS…). Não é necessário para o exercício funcionar, mas é o que separa "copiei" de "entendi". |

```bash
grep -n "CORTÁVEL\|EXTRA" slides/conteudo/aula-0*.yml
```

Cortar todos os `# EXTRA` devolve cerca de 45 slides — uns 90 minutos no total das quatro aulas.
**Minha recomendação é o contrário**: mantenha os `# EXTRA` e use a saída 1 para o código.

---

## Blocos por aula

Os tempos abaixo assumem que os `# EXTRA` ficam.

### Aula 1 — 185 min

| Bloco | Slides | Min | Se atrasar |
|---|---|---|---|
| Capa e objetivos | 2 | 5 | — |
| Ferramentas e setup | 8 | 25 | manda instalar em casa (`docs/00-preparacao.md`) |
| Back-end: conceito e analogia | 4 | 10 | — |
| **Rede: servidor, IP, porta, DNS, URL** | 4 | 12 | corte DNS, volta na Aula 4 |
| **HTTP: crua, cabeçalhos, Content-Type** | 6 | 18 | não corte — o curso todo depende |
| Verbos, status, JSON, REST | 5 | 15 | — |
| **Ruby para pythonistas** | 16 | 45 | corte Struct e exceções e explique quando aparecerem |
| Rails: história, convenção, MVC, Zeitwerk, ambientes | 9 | 25 | corte Zeitwerk |
| `rails new`, pastas, comandos, primeira rota | 6 | 20 | — |
| **Prática** | 2 | 30 | inegociável |

> Se o setup não estiver feito, some 40 min e a aula não termina. Cobre isso na semana anterior.

### Aula 2 — 170 min

| Bloco | Slides | Min | Se atrasar |
|---|---|---|---|
| Objetivos e retomada | 3 | 5 | — |
| Banco, transação, Postgres, container | 7 | 18 | corte o bloco SQL (`# CORTÁVEL`) |
| ActiveRecord, ActiveSupport, `blank?` | 6 | 18 | — |
| Migrations e `schema.rb` | 6 | 20 | — |
| Senha: hash, bcrypt, `has_secure_password` | 6 | 20 | não corte |
| Validações e normalização | 5 | 15 | — |
| **Associações e N+1** | 7 | 22 | corte N+1, fica na apostila |
| Concerns | 4 | 15 | — |
| Console ao vivo, seeds, fixtures | 5 | 17 | — |
| **Prática** | 1 | 40 | inegociável |

### Aula 3 — 390 min de conteúdo em 180

O bloco de código é o problema: 1396 linhas em 37 arquivos.

| Bloco | Slides | Min | Nota |
|---|---|---|---|
| Arquitetura: service, serializer, erro, `before_action`, middleware | 11 | 30 | |
| Cadastro e enumeração de usuários | 3 | 10 | |
| Mailer e `deliver_now` | 4 | 12 | |
| Sessão, JWT, Base64, assinatura | 8 | 25 | não corte |
| Login, cookie, XSS, CSRF, 401×403 | 9 | 28 | |
| Logout: denylist e `token_version` | 7 | 22 | o coração da aula |
| Recuperação de senha e transação | 6 | 18 | |
| Testes e ferramentas | 5 | 15 | |
| **Escrever o código** | — | **210** | ← aqui estoura |

**Recomendação**: `git checkout aula-03` no começo, percorra os arquivos projetados, e a prática
vira o bônus (`PATCH /me` e brincar com o `true` do `JWT.decode`). Cai para ~190 min.

### Aula 4 — 370 min de conteúdo em 180

Aqui o gargalo não é digitar, é **clicar**.

| Bloco | Slides | Min | Nota |
|---|---|---|---|
| VPS, comparação, por que não Kubernetes | 6 | 15 | |
| Criar a VM + cotas + chave + NSG | 7 | **35** | some 15 min se alguém pegar `NotAvailableForSubscription` |
| Ubuntu: Docker, root/permissões, swap, SSH | 7 | **35** | |
| Docker: imagem, Dockerfile, registry | 6 | 18 | |
| Kamal: deploy.yml, accessory, segredos, ENV | 10 | 30 | |
| CI/CD e OIDC | 8 | 25 | |
| **Configurar o OIDC no portal** | — | **30** | o *subject* erra na primeira tentativa |
| **Cadastrar 13 secrets + 7 variables** | — | **20** | |
| TLS, certificado, CA, proxy reverso, Cloudflare | 9 | 28 | |
| **DNS + Origin CA no painel** | — | **20** | |
| Primeiro deploy (`setup`) e espera | 4 | **25** | |
| Operar, backup, recapitular | 4 | 15 | |

**Recomendação**: prepare antes do encontro o que não ensina nada ao ser feito 12 vezes — os
registros DNS e o certificado Origin CA wildcard. Isso devolve ~20 min. Mesmo assim são ~5h.
Se puder, esta é a aula para virar duas.

---

## Sinais de que você está atrasado

- **Aula 1**: passou de 40 min e ainda tem gente instalando Ruby → pare o setup, dê o Codespaces ou
  pareie quem travou com quem terminou, e siga.
- **Aula 2**: chegou nas associações com menos de 50 min restantes → pule para a prática e deixe
  associações para o começo da Aula 3.
- **Aula 3**: chegou no logout com menos de 40 min → o logout é o ponto alto da aula. Corte
  recuperação de senha e mande fazer em casa com a apostila.
- **Aula 4**: passou de 90 min e ninguém tem VM de pé → mude para demo: projete o seu deploy e
  distribua o roteiro. Melhor todo mundo ver funcionar do que metade travar no NSG.
