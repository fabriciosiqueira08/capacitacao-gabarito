# Roteiros — índice para quem apresenta

Um runbook por encontro, com cronograma, o que falar em cada bloco, as demos ao vivo, as perguntas
que a turma faz e o plano B:

| | Roteiro | Slides | Estimado | Disponível |
|---|---|---|---|---|
| 1 | [Back-end, Ruby e o primeiro Rails](roteiro-aula-01.md) | 64 | 3h31 | 3h |
| 2 | [Banco, ActiveRecord e o model `User`](roteiro-aula-02.md) | 48 | 3h20 | 3h |
| 3 | [As rotas de autenticação](roteiro-aula-03.md) | 57 | 3h30 * | 3h |
| 4 | [VPS, Docker, Kamal e deploy](roteiro-aula-04.md) | 61 | 4h02 * | 3h |

\* já contando o plano recomendado. Digitando todo o código da Aula 3 seriam ~6h30; fazendo o
pipeline OIDC completo na Aula 4, ~4h45.

---

## O número honesto

**São ~14h de conteúdo em 12h de encontro.** Cada roteiro traz os cortes específicos, em ordem de
prioridade, e um **ponto de decisão** com relógio: se às tantas horas a turma não estiver em tal
lugar, faça tal coisa.

As duas decisões que resolvem a maior parte do problema:

1. **Aula 3 — não digitem o código.** `git checkout aula-03` no começo e leitura guiada dos
   arquivos projetados. A prática vira modificar o que existe. **Economiza ~3h30.**
2. **Aula 4 — prepare o que não ensina.** Registros DNS e um certificado Origin CA wildcard, feitos
   na véspera. **Economiza ~40 min.** Se ainda assim não couber, o roteiro traz dois planos B.

Base do cálculo: slide a ~2 min, digitação guiada a ~5 linhas/min, cliques em portal cronometrados
no percurso real.

---

## As marcações nos slides

| Marca | Significa |
|---|---|
| `# CORTÁVEL` | Pré-requisito. Corte se a turma já sabe Git, terminal, SQL ou Linux. |
| `# EXTRA` | Conceito de fundo (rede, TLS, XSS…). O exercício funciona sem ele — mas é o que separa "copiei" de "entendi". |

```bash
grep -n "CORTÁVEL\|EXTRA" slides/conteudo/aula-0*.yml
```

Cortar todos os `# EXTRA` devolve ~45 slides, uns 90 minutos no total das quatro aulas.
**A recomendação é o contrário**: mantenha os `# EXTRA` e economize no código, com a decisão 1 acima.

---

## Regra geral para o dia

> Quando atrasar, corte **conteúdo**, nunca **prática**. Uma turma que viu 40 slides e fez a coisa
> funcionar aprendeu mais que uma que viu 60 e foi embora com o erro na tela.
