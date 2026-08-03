module Auth
  # O segredo que assina os JWTs.
  #
  # Em produção é obrigatório vir do ambiente — `fetch` sem default estoura na
  # subida se ninguém configurou, em vez de assinar tokens com um segredo
  # previsível e só descobrir depois.
  module TokenSecret
    module_function

    def call
      return ENV.fetch("JWT_SECRET") if Rails.env.production?

      ENV.fetch("JWT_SECRET") { Rails.application.secret_key_base }
    end
  end
end
