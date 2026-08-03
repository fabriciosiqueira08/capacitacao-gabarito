# CORS — Cross-Origin Resource Sharing.
#
# O navegador bloqueia, por padrão, uma página em https://painel.exemplo.com de
# chamar https://api.exemplo.com. Esta config é a API dizendo quais origens ela
# aceita. O app nativo NÃO passa por CORS: isso é regra de navegador.
#
# As origens vêm de CORS_ORIGINS, separadas por vírgula:
#   CORS_ORIGINS="https://painel.exemplo.com,http://localhost:5173"

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(ENV.fetch("CORS_ORIGINS", "http://localhost:5173").split(","))

    resource "*",
      headers: :any,
      # expose: o navegador só deixa o JavaScript ler os cabeçalhos listados
      # aqui. Sem isso o painel não consegue pegar o token do login.
      expose: [ "Authorization" ],
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true
  end
end
