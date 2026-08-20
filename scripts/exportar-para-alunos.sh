#!/usr/bin/env bash
# Monta, numa pasta separada, o repositório que a turma vai clonar.
#
#   ./scripts/exportar-para-alunos.sh [destino]
#
# Este repositório aqui é o SEU: tem os slides, os roteiros e o guia do
# instrutor. O que a turma clona é um recorte dele, sem essas coisas.
#
# O script é para rodar de novo sempre que o material mudar: ele apaga o
# destino e refaz do zero, então nunca desencontra do original.
#
# O que a turma recebe:
#   - o código do gabarito, nas quatro branches de checkpoint
#   - as apostilas, o glossário, o troubleshooting, as versões e o apêndice
#   - os PDFs da turma, prontos para ler ou imprimir
#
# O que fica só com você:
#   - slides/  (fonte e .pptx)
#   - docs/roteiro-*.md, docs/guia-do-instrutor.md, docs/PREENCHER.md
#   - docs/pdf/ (o gerador, o estilo e os PDFs do instrutor)

set -euo pipefail

ORIGEM="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESTINO="${1:-$(dirname "$ORIGEM")/capacitacao-backend-alunos}"

# Só de instrutor. Sai de TODAS as branches.
SO_DO_INSTRUTOR=(
  "slides"
  "docs/roteiro-aula-01.md" "docs/roteiro-aula-02.md"
  "docs/roteiro-aula-03.md" "docs/roteiro-aula-04.md"
  "docs/roteiro-de-tempo.md"
  "docs/guia-do-instrutor.md"
  "docs/PREENCHER.md"
  "docs/pdf/gerar_pdfs.py" "docs/pdf/estilo.css" "docs/pdf/assets"
  "docs/pdf/build/roteiro-aula-01.pdf" "docs/pdf/build/roteiro-aula-02.pdf"
  "docs/pdf/build/roteiro-aula-03.pdf" "docs/pdf/build/roteiro-aula-04.pdf"
  "docs/pdf/build/roteiro-de-tempo.pdf" "docs/pdf/build/roteiros-completo.pdf"
  "docs/pdf/build/guia-do-instrutor.pdf"
  "scripts/exportar-para-alunos.sh"
)

if [[ -n "$(git -C "$ORIGEM" status --porcelain)" ]]; then
  echo "Há alterações não commitadas. Commite antes de exportar." >&2
  exit 1
fi

echo "Exportando para: $DESTINO"
rm -rf "$DESTINO"
git clone --quiet --local --no-hardlinks "$ORIGEM" "$DESTINO"
cd "$DESTINO"

# o clone só materializa a branch atual; as outras vêm como remote-tracking.
# Cria uma branch local para cada uma antes de descartar o remote.
for branch in aula-01 aula-02 aula-03 aula-04; do
  git branch --quiet --track "$branch" "origin/$branch"
done
git remote remove origin

for branch in main aula-01 aula-02 aula-03 aula-04; do
  git checkout --quiet "$branch"

  # tira o que é só do instrutor, e os .html intermediários do gerador de PDF
  for caminho in "${SO_DO_INSTRUTOR[@]}"; do
    git rm -rq --ignore-unmatch --cached "$caminho" 2>/dev/null || true
    rm -rf "$caminho"
  done
  git rm -rq --ignore-unmatch --cached "docs/pdf/build/*.html" 2>/dev/null || true
  rm -f docs/pdf/build/*.html

  # o README perde as seções que apontam para o que não existe mais aqui
  python3 - <<'PY'
import pathlib, re
p = pathlib.Path("README.md")
if not p.exists(): raise SystemExit
s = p.read_text()

for secao in ("Slides", "Publicando para a turma"):
    s = re.sub(rf'\n## {secao}\n.*?(?=\n---\n)', '\n', s, flags=re.S)
for linha in ("docs/PREENCHER.md", "docs/guia-do-instrutor.md",
              "docs/roteiro-de-tempo.md", "docs/roteiro-aula-0N.md"):
    s = re.sub(rf'^\|.*{re.escape(linha)}.*\|\n', '', s, flags=re.M)

s = s.replace("git checkout main      # tudo pronto, mais slides, PDFs e roteiros",
              "git checkout main      # tudo pronto, mais as apostilas e os PDFs")
s = s.replace("| `main` | Tudo, mais os slides, os PDFs e os roteiros |",
              "| `main` | Tudo, mais as apostilas completas e os PDFs |")
s = s.replace("""Cada checkpoint carrega **o código daquele ponto e as apostilas até aquela aula** — nada além
disso. Slides, PDFs e roteiros do instrutor são gerados e vivem só na `main`, para não ficarem
desatualizados em quatro lugares a cada regeração.""",
"""Cada checkpoint carrega **o código daquele ponto e as apostilas até aquela aula**, nada além disso.
As apostilas completas e os PDFs ficam na `main`, para não desatualizarem em quatro lugares.""")
p.write_text(re.sub(r'\n{3,}', '\n\n', s))
PY
  git add -A
  git diff --quiet --cached || git commit -q -m "Recorte da turma: sem slides, roteiros e guia do instrutor"
  echo "  $branch: $(git ls-files | wc -l) arquivos"
done

git checkout --quiet main
echo
echo "Pronto. Confira, e publique:"
echo "  cd $DESTINO"
echo "  gh repo create capacitacao-backend --public --source=. --push"
echo "  git push --all"
