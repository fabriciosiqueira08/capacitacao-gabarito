ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

Dir[Rails.root.join("test/support/**/*.rb")].each { |file| require file }

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include AuthTestHelper

    # A denylist do logout vive no Rails.cache. Em teste o padrão é o null_store
    # (não guarda nada), então o teste de "token revogado para de funcionar"
    # passaria sem a revogação existir. Aqui usamos memória de verdade.
    setup do
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      ActionMailer::Base.deliveries.clear
    end
  end
end
