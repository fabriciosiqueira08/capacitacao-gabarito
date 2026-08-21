# A versão é a mesma do .ruby-version e do Dockerfile de produção, de
# propósito: o ambiente de desenvolvimento e o servidor rodam o mesmo Ruby.
FROM ruby:3.4.9-bookworm

# postgresql-client dá o psql e o pg_dump (o backup da Aula 4).
# As bibliotecas de build já vêm na imagem oficial do Ruby.
RUN apt-get update \
 && apt-get install -y --no-install-recommends postgresql-client \
 && rm -rf /var/lib/apt/lists/*

# Um usuário sem root, pela mesma razão do Dockerfile de produção: se algo
# escapar, cai num usuário sem privilégio. E os arquivos que você criar no
# editor não nascem pertencendo ao root.
ARG USERNAME=vscode
RUN useradd --create-home --shell /bin/bash "$USERNAME" \
 && mkdir -p /usr/local/bundle \
 && chown -R "$USERNAME" /usr/local/bundle

USER $USERNAME
