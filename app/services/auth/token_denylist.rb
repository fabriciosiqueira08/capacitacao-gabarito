module Auth
  # Lista de tokens revogados no logout, indexada pelo `jti` (o id único do token).
  #
  # O problema: um JWT é válido até expirar, e o servidor não guarda sessão. Se
  # o usuário faz logout, o token continua funcionando por até 24h.
  #
  # A saída: guardar em cache o `jti` dos tokens revogados. O TTL de cada entrada
  # é o tempo que faltava para o token expirar — então a lista se limpa sozinha,
  # sem varredura e sem lixo acumulado.
  module TokenDenylist
    module_function

    KEY_PREFIX = "auth:revoked_jti:".freeze

    # Recebe o payload já decodificado. Devolve false se não houver `jti` ou se
    # o token já expirou (não há o que revogar).
    def revoke(payload)
      jti = payload[:jti]
      ttl = payload[:exp].to_i - Time.current.to_i
      return false if jti.blank? || ttl <= 0

      Rails.cache.write(key(jti), true, expires_in: ttl.seconds)
      true
    end

    def revoked?(jti)
      return false if jti.blank?

      Rails.cache.exist?(key(jti))
    end

    def key(jti)
      "#{KEY_PREFIX}#{jti}"
    end
  end
end
