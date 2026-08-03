module Api
  module V1
    # A rota mais simples que existe: prova que a aplicação está de pé.
    # É a primeira coisa que você chama depois de um deploy.
    class StatusController < ApplicationController
      def show
        render json: {
          status: "ok",
          service: "automic-auth-api",
          environment: Rails.env
        }
      end
    end
  end
end
