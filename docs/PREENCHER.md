# O que falta preencher

Cinco coisas. Só as duas primeiras dependem de você mandar alguma informação — o resto é conferir.

Quando responder, é só me passar os valores e eu aplico em todos os lugares de uma vez, incluindo
slides e PDFs.

---

## 1. URL do repositório da capacitação — **preciso de você**

É o link que o aluno usa para clonar o gabarito.

| Onde | Linha |
|---|---|
| `README.md` | `git clone <url-deste-repo> ~/capacitacao-gabarito` |
| `docs/00-preparacao.md` | `git clone <url-do-repositório> ~/capacitacao-gabarito` |

**Dois lugares.** Me mande a URL (ex.: `https://github.com/fabriciosiqueira08/capacitacao-backend`)
e eu troco.

> Se o repositório for **privado**, os alunos precisam de acesso. Com o `gh` que já está na
> preparação, `gh repo clone` resolve — mas você tem que adicionar cada um como colaborador. Se for
> público, nada a fazer.

## 2. Domínio da capacitação — **preciso de você**

O domínio de onde saem os subdomínios `<aluno>.capacita.SEU-DOMINIO`. Hoje está como
`exemplo.tech` / `<domínio>`.

| Arquivo | Ocorrências |
|---|---|
| `docs/04-deploy.md` | 6 |
| `docs/troubleshooting.md` | 3 |
| `docs/roteiro-aula-04.md` | 2 |
| `slides/conteudo/aula-04.yml` | 1 |
| `README.md` | 1 |

**13 ocorrências.** Me mande o domínio e eu troco em tudo.

Lembrando dos dois preparativos de véspera que dependem dele: os registros DNS de cada aluno e **um**
certificado Origin CA wildcard `*.capacita.SEU-DOMINIO`.

## 3. Seus dados na capa da Aula 1 — **preciso de você**

O slide 1 da Aula 1 espelha o do Fiuza, que se apresentava. Está assim:

```
Fabrício Siqueira
[idade]
[cidade - UF]

[curso]
[período]
```

Me mande os quatro e eu preencho. As capas das Aulas 2, 3 e 4 só têm o seu nome, e já estão prontas.

> A foto do Fiuza foi removida do slide doador. O espaço à esquerda está livre para você colocar a
> sua no Canva.

## 4. Link do `seem-backend` — **só confirmar**

Está preenchido como `https://github.com/fabriciosiqueira08/seem-backend`, em 3 lugares
(`README.md`, `docs/04-deploy.md`, `docs/roteiro-aula-04.md`).

**Confirme se está certo e se os alunos conseguem abrir.** O slide de encerramento da Aula 4 convida
a turma a ler esse código — se o repositório for privado, o convite não funciona.

## 5. `api.seemxxiii.tech` — **só confirmar**

Aparece em 10 lugares da Aula 1, e não é enfeite: é a **demo ao vivo** do primeiro `curl`, o momento
em que a turma vê que back-end não é abstração.

```bash
curl -i https://api.seemxxiii.tech/api/v1/status
```

**Confirme que vai estar no ar no dia do primeiro encontro.** Se não for, me diga qual URL usar no
lugar — pode ser qualquer API pública que responda JSON.

---

## O que **não** precisa trocar

Estes são placeholders de propósito: cada aluno preenche o seu, na hora.

| Placeholder | Quem preenche |
|---|---|
| `SEU_IP`, `SEU_IP_PUBLICO` | o aluno, com o IP da VM dele |
| `SEU-USUARIO`, `SEU-REPO`, `seu-usuario` | o aluno, com o GitHub dele |
| `seunome`, `<seunome>` | o aluno, no subdomínio dele |
| `SEU_RG`, `SEU_NSG` | o aluno, com os recursos da Azure dele |
| `aluno.ufop.edu.br` | e-mail de exemplo nos comandos |
| `painel.exemplo.com`, `noreply@exemplo.com` | exemplos de CORS e de remetente |
