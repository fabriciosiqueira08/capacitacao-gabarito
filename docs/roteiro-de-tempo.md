# Roteiros — índice para quem apresenta

Um runbook por encontro, com cronograma, o que falar em cada bloco, as demos ao vivo, as perguntas
que a turma faz e o plano B:

> **Antes de qualquer roteiro, leia o [guia do instrutor](guia-do-instrutor.md).** Ele não é sobre
> conteúdo: é sobre conduzir uma sala por três horas — os três primeiros minutos, o que fazer quando
> você não souber a resposta, onde a energia da turma cai, e o que dizer quando alguém travar.

| | Roteiro | Slides | Práticas | Sem cortes | Com o plano de corte | Disponível |
|---|---|--:|--:|--:|--:|--:|
| 1 | [Back-end, Ruby e o primeiro Rails](roteiro-aula-01.md) | 69 | 7 | 4h17 | **3h21** | 3h |
| 2 | [Banco, ActiveRecord e o model `User`](roteiro-aula-02.md) | 54 | 8 | 4h39 | **3h02** | 3h |
| 3 | [As rotas de autenticação](roteiro-aula-03.md) | 66 | 8 | 5h06 | **3h19** | 3h |
| 4 | [Servidor, Docker, Kamal e deploy](roteiro-aula-04.md) | 71 | 8 | 5h17 | **3h48** | 3h |

---

## O número honesto

**São ~19h20 de conteúdo em 12h de encontro**, e ~13h30 depois dos planos de corte. Cada roteiro traz
os cortes específicos, numerados em ordem de prioridade, e um **ponto de decisão** com relógio: se às
tantas horas a turma não estiver em tal lugar, faça tal coisa.

Não tente caber tudo. **Decida os cortes na véspera**, não no meio da aula.

E guarde o parágrafo que mais importa para você: **se a turma sair com a coisa funcionando, a aula
foi ótima — mesmo que você tenha entregue 70% do que planejou.** Há mais conteúdo do que cabe, de
propósito, para você escolher o que serve àquela turma.

---

## A regra que organiza o dia

> Quando atrasar, corte **conteúdo**, nunca **prática**. Uma turma que viu 40 slides e fez a coisa
> funcionar aprendeu mais que uma que viu 68 e foi embora com o erro na tela.

Os quatro decks são construídos em cima disso: **cada bloco de conteúdo termina numa prática**, e a
prática está marcada em negrito no cronograma.

```
explica  →  faz  →  explica  →  faz  →  ...
```

Não é enfeite de estrutura. Antes, as aulas 2 e 3 tinham **uma** prática, no penúltimo slide: três
horas ouvindo, e "agora façam tudo". Agora são 8 práticas de 5 a 35 minutos, e ninguém passa mais
que ~25 min sem pôr a mão.

### Como conduzir uma prática

1. **Projete o slide da prática** e leia os itens em voz alta. São 30 segundos.
2. **Mande abrir a apostila** na prática correspondente — os comandos, a conferência e a tabela de
   erros estão lá. Não dite comando.
3. **Circule.** As notas do slide dizem quais são os dois ou três erros que vão aparecer.
4. **Cobre a conferência** antes de seguir. Toda prática tem uma linha "Confere".

Cada prática tem, no fim, um item **avançado** para quem terminar antes. Use-o: é o que evita que
metade da turma fique parada esperando a outra metade.

### As tabelas de erro

Toda prática da apostila termina com uma tabela `Se der errado`, no formato
**erro → causa → saída**. Elas cobrem os erros que acontecem de verdade, e existem para você não ser
o único caminho de desbloqueio numa sala de 12 pessoas.

Quando alguém travar, a primeira pergunta é *"o que a tabela da sua prática diz?"*.

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
**A recomendação é o contrário**: mantenha os `# EXTRA`, e siga o plano de corte de cada roteiro.

---

## Base do cálculo

Slide a ~2 min; digitação guiada a ~5 linhas/min; prática cronometrada no percurso real, incluindo
o tempo de quem erra uma vez. Os tempos de download (`multipass launch`, `bundle install`, build da
imagem) estão contados pelo pior caso de wi-fi compartilhado.
