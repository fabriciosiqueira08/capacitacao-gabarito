# PDFs

As apostilas e os roteiros em PDF, para enviar à turma e para imprimir.

```bash
pip install --user markdown weasyprint
python3 docs/pdf/gerar_pdfs.py               # tudo
python3 docs/pdf/gerar_pdfs.py --alunos      # só o material da turma
python3 docs/pdf/gerar_pdfs.py --instrutor   # só os roteiros
```

Saída em `build/`: um PDF por documento, mais dois combinados.

| Arquivo | Para quem |
|---|---|
| `apostila-completa.pdf` | **A turma.** Capa, sumário e as oito apostilas. |
| `roteiros-completo.pdf` | **Você.** Os quatro roteiros de aula mais o índice. |
| os demais | Avulsos, se você quiser mandar uma aula por vez |

O `weasyprint` é quem entrega rodapé e número de página. Sem ele o script cai para o Chrome
headless, que ignora as margin boxes do `@page` e sai sem paginação.

Links entre arquivos `.md` viram texto em negrito no PDF — não existe para onde apontar num
documento impresso.
