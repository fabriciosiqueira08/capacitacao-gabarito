#!/usr/bin/env python3
"""Renderiza as apostilas e os roteiros em PDF.

Mesma abordagem do render-guide.py do guia de infra do SEEM: Markdown → HTML com
uma folha de estilo de impressão, e o Chrome headless imprime o PDF.

    pip install --user markdown
    python3 docs/pdf/gerar_pdfs.py            # tudo
    python3 docs/pdf/gerar_pdfs.py --alunos   # só o que vai para a turma
"""

import argparse
import re
import shutil
import subprocess
from pathlib import Path

import markdown

DOCS = Path(__file__).resolve().parent.parent
BUILD = DOCS / "pdf" / "build"
CSS = DOCS / "pdf" / "estilo.css"

# O que a turma recebe, na ordem em que faz sentido ler.
ALUNOS = [
    ("00-preparacao.md", "Preparação"),
    ("01-fundamentos.md", "Aula 1 — Back-end, Ruby e o primeiro Rails"),
    ("02-activerecord.md", "Aula 2 — Banco, ActiveRecord e o model User"),
    ("03-autenticacao.md", "Aula 3 — As rotas de autenticação"),
    ("04-deploy.md", "Aula 4 — Servidor, Docker, Kamal e deploy"),
    ("apendice-azure.md", "Apêndice — o mesmo servidor, na nuvem"),
    ("ruby-para-pythonistas.md", "Ruby para quem sabe Python"),
    ("glossario.md", "Glossário"),
    ("troubleshooting.md", "Troubleshooting"),
]

# O que é só de quem apresenta.
INSTRUTOR = [
    ("guia-do-instrutor.md", "Guia do instrutor — conduzir, não apresentar"),
    ("roteiro-de-tempo.md", "Roteiros — índice"),
    ("roteiro-aula-01.md", "Roteiro — Aula 1"),
    ("roteiro-aula-02.md", "Roteiro — Aula 2"),
    ("roteiro-aula-03.md", "Roteiro — Aula 3"),
    ("roteiro-aula-04.md", "Roteiro — Aula 4"),
]

EXTENSOES = ["extra", "sane_lists", "toc", "admonition"]


def para_html(md_texto, titulo, rodape):
    # Links entre arquivos .md não existem no PDF: viram o texto do próprio link.
    md_texto = re.sub(r"\[([^\]]+)\]\((?!https?:)[^)]+\.md[^)]*\)", r"**\1**", md_texto)

    corpo = markdown.markdown(md_texto, extensions=EXTENSOES, output_format="html5")

    return f"""<!doctype html>
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<title>{titulo}</title>
<link rel="stylesheet" href="{CSS.as_uri()}">
<style>@page {{ @bottom-left {{ content: "{rodape}"; }} }}</style>
</head>
<body><main>
{corpo}
</main></body>
</html>
"""


def imprimir(html_path, pdf_path):
    """WeasyPrint quando disponível; Chrome como reserva.

    A diferença importa: o Chrome ignora as margin boxes do @page, então sai sem
    rodapé e sem número de página — que numa apostila impressa fazem falta.
    """
    try:
        from weasyprint import HTML
    except ImportError:
        _imprimir_com_chrome(html_path, pdf_path)
    else:
        HTML(filename=str(html_path)).write_pdf(str(pdf_path))


def _imprimir_com_chrome(html_path, pdf_path):
    chrome = next(
        (
            caminho
            for nome in ("google-chrome", "google-chrome-stable", "chromium")
            if (caminho := shutil.which(nome))
        ),
        None,
    )
    if chrome is None:
        raise SystemExit(
            "Instale o weasyprint (pip install --user weasyprint) ou tenha Chrome no PATH."
        )

    subprocess.run(
        [
            chrome,
            "--headless=new",
            "--disable-gpu",
            "--no-sandbox",
            "--allow-file-access-from-files",
            "--run-all-compositor-stages-before-draw",
            "--no-pdf-header-footer",
            f"--print-to-pdf={pdf_path}",
            html_path.resolve().as_uri(),
        ],
        check=True,
        capture_output=True,
    )


def gerar(arquivos, rodape, combinado=None, titulo_combinado=None):
    BUILD.mkdir(parents=True, exist_ok=True)
    partes = []

    for nome, titulo in arquivos:
        origem = DOCS / nome
        texto = origem.read_text(encoding="utf-8")
        partes.append(texto)

        html_path = BUILD / f"{origem.stem}.html"
        html_path.write_text(para_html(texto, titulo, rodape), encoding="utf-8")
        pdf_path = BUILD / f"{origem.stem}.pdf"
        imprimir(html_path, pdf_path)
        print(f"  {pdf_path.relative_to(DOCS.parent)}")

    if combinado:
        # Capa, sumário, e cada documento começando em página nova.
        capa = (
            f"<div class='capa'><h1>{titulo_combinado}</h1>"
            f"<p>Automic Jr. · quatro encontros</p></div>\n"
            # HTML cru, e não "## Sumário", para o próprio título não entrar no sumário.
            "<div class='quebra'></div>\n<h2>Sumário</h2>\n\n[TOC]\n"
        )
        junto = capa + "\n\n<div class='quebra'></div>\n\n".join(partes)
        html_path = BUILD / f"{combinado}.html"
        html_path.write_text(para_html(junto, titulo_combinado, rodape), encoding="utf-8")
        pdf_path = BUILD / f"{combinado}.pdf"
        imprimir(html_path, pdf_path)
        print(f"  {pdf_path.relative_to(DOCS.parent)}  ← mande este")


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--alunos", action="store_true", help="só o material da turma")
    parser.add_argument("--instrutor", action="store_true", help="só os roteiros")
    args = parser.parse_args()

    tudo = not (args.alunos or args.instrutor)

    if args.alunos or tudo:
        print("Apostilas:")
        gerar(
            ALUNOS,
            "Capacitação Back-end · Automic Jr.",
            combinado="apostila-completa",
            titulo_combinado="Capacitação Back-end — apostila completa",
        )

    if args.instrutor or tudo:
        print("Roteiros:")
        gerar(
            INSTRUTOR,
            "Capacitação Back-end · roteiro do instrutor",
            combinado="roteiros-completo",
            titulo_combinado="Capacitação Back-end — roteiros",
        )


if __name__ == "__main__":
    main()
