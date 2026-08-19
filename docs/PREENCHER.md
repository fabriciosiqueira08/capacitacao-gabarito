# O que falta preencher

Quatro coisas. Só as duas primeiras dependem de você mandar alguma informação — o resto é conferir.

Quando responder, é só me passar os valores e eu aplico em todos os lugares de uma vez, incluindo
slides e PDFs.

> **Mudou desde a última versão**: o domínio da capacitação **não é mais necessário**. O servidor da
> Aula 4 é uma VM no notebook de cada aluno, e o nome (`seunome.test`) resolve pelo `/etc/hosts`.
> Nada de DNS, nada de certificado Origin CA wildcard, nada de conta Azure para a turma. O percurso
> de nuvem virou [`apendice-azure.md`](apendice-azure.md), que é demo sua e estudo de casa deles.

---

## 1. URL do repositório da capacitação — **preciso de você**

É o link que o aluno usa para clonar o gabarito.

| Onde | Linha |
|---|---|
| `README.md` | `git clone <url-deste-repo> ~/capacitacao-gabarito` |
| `docs/00-preparacao.md` | `git clone <url-do-repositório> ~/capacitacao-gabarito` (**duas vezes**) |

**Três ocorrências.** Me mande a URL (ex.: `https://github.com/fabriciosiqueira08/capacitacao-backend`)
e eu troco.

> Se o repositório for **privado**, os alunos precisam de acesso. Com o `gh` que já está na
> preparação, `gh repo clone` resolve — mas você tem que adicionar cada um como colaborador. Se for
> público, nada a fazer.

## 2. Seus dados na capa da Aula 1 — **preciso de você**

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

## 3. Link do `seem-backend` — **só confirmar**

Está preenchido como `https://github.com/fabriciosiqueira08/seem-backend`, em 3 lugares
(`README.md`, `docs/04-deploy.md`, `docs/roteiro-aula-04.md`).

**Confirme se está certo e se os alunos conseguem abrir.** O slide de encerramento da Aula 4 convida
a turma a ler esse código — se o repositório for privado, o convite não funciona.

## 4. `api.seemxxiii.tech` — **só confirmar**

Aparece em 10 lugares da Aula 1, e não é enfeite: é a **demo ao vivo** do primeiro `curl`, o momento
em que a turma vê que back-end não é abstração.

```bash
curl -i https://api.seemxxiii.tech/api/v1/status
```

**Confirme que vai estar no ar no dia do primeiro encontro.** Se não for, me diga qual URL usar no
lugar — pode ser qualquer API pública que responda JSON.

---

## O que virou trabalho de véspera, e não de preenchimento

Não é texto a trocar: é coisa a fazer antes da Aula 4. Está detalhado em
[`roteiro-aula-04.md`](roteiro-aula-04.md).

| # | O que | Quando |
|---|---|---|
| 1 | Cobrar de cada aluno o print de `ssh "$USER"@127.0.0.1 'echo ok'` | uma semana antes |
| 2 | Um SMTP (Resend ou outro) com domínio verificado, e uma key para a turma | véspera |
| 3 | Fazer o percurso da Aula 4 do zero, num usuário limpo | véspera |

O item 1 é o que tira o risco da Aula 4 do dia da aula: o Kamal só precisa de SSH e Docker na
máquina, e o SSH é o que costuma faltar.

---

## O que **não** precisa trocar

Estes são placeholders de propósito: cada aluno preenche o seu, na hora.

| Placeholder | Quem preenche |
|---|---|
| `SEU_IP` | só no apêndice de nuvem: o IP público da máquina alugada |
| `SEU-USUARIO`, `SEU-REPO`, `seu-usuario` | o aluno, com o GitHub dele |
| `seunome`, `seunome.test` | o aluno, no `/etc/hosts` e no certificado dele |
| `SEU_RG`, `SEU_NSG` | o aluno, se for fazer o apêndice de nuvem |
| `aluno.ufop.edu.br` | e-mail de exemplo nos comandos |
| `painel.exemplo.com`, `noreply@exemplo.com` | exemplos de CORS e de remetente |
| `exemplo.tech` | domínio de exemplo, só no apêndice de nuvem |
