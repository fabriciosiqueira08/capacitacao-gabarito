# Slides

Os decks são **gerados**, não editados à mão. O conteúdo mora em `conteudo/aula-0N.yml` e o visual
vem do deck de front-end do Gabriel Fiuza, em `template/`.

```bash
python3 gerar_slides.py            # gera as quatro aulas em build/
python3 gerar_slides.py --aula 1   # só a Aula 1
```

Depois é só subir o `.pptx` no Canva para ajustar imagens e prints.

## Por que gerar em vez de montar no Canva

O arquivo do Canva exportou tudo achatado: os 138 slides usam o layout `Blank` e o design é feito de
shapes posicionados absolutamente **dentro de cada slide**. Herdar o layout não herda nada. Então o
gerador **clona slides inteiros** — os "doadores" — e troca só o texto. Fundo, faixas, logo, cores e
bullets vêm de graça, idênticos ao original.

## Arquétipos e seus doadores

| `tipo:` | Slide doador | Como fica |
|---|---|---|
| `capa` | 1 | Fundo azul `#0E2766`, título grande, dados do palestrante. A foto foi removida — coloque a sua no Canva. |
| `objetivos` | 2 | Título azul centralizado + bullets |
| `secao` | 17 | Só o nome do bloco, em laranja gigante |
| `titulo` | 6 | Só o título, em azul |
| `bullets` | 22 | Título laranja no topo + bullets. O arroz com feijão. |
| `pratica` | 22 | Igual, com o título em ciano `#48B1FF` — sinaliza mão na massa |
| `codigo` | 22 | Título + bloco de código escuro desenhado por cima |
| `duas_colunas` | 9 | Título + duas colunas com subtítulo. Ideal para Python × Ruby. |
| `fim` | 138 | Encerramento |

## Escrevendo o conteúdo

```yaml
- tipo: bullets
  titulo: "OS VERBOS"
  bullets:
    - "GET — me dá isso"
    - "- sub-bullet: comece a linha com hífen e espaço"
  notas: |
    Vai para as notas do apresentador.
```

- `bullets:` é uma lista; `corpo:` é um bloco de texto — use um ou outro.
- Uma linha iniciada por `- ` vira sub-bullet (segundo nível).
- `codigo:` usa bloco literal (`|`) e preserva a indentação.
- `duas_colunas` pede `esquerda_titulo`, `esquerda`, `direita_titulo`, `direita`.
- Comentários `# CORTÁVEL` marcam blocos de pré-requisito que dá para pular se a turma já sabe.

A fonte encolhe sozinha quando o texto não cabe na caixa do doador. Se um slide ficar com letra
pequena demais, ele está pedindo para virar dois.

## Fontes

O deck usa `Open Sans Extra Bold` e `Montaser Arabic`, que são fontes do Canva. Abrindo o `.pptx`
localmente elas podem cair para uma substituta; reimportando no Canva voltam ao normal.
