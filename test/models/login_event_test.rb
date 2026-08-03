require "test_helper"

class LoginEventTest < ActiveSupport::TestCase
  test "pertence a um usuário" do
    evento = users(:ana).login_events.create!(client: "mobile", occurred_at: Time.current)

    assert_equal users(:ana), evento.user
    assert_includes users(:ana).login_events, evento
  end

  test "belongs_to exige o usuário" do
    assert_not LoginEvent.new(client: "mobile", occurred_at: Time.current).valid?
  end

  test "recusa client fora da lista" do
    evento = users(:ana).login_events.build(client: "desktop", occurred_at: Time.current)

    assert_not evento.valid?
  end

  test "o scope recentes ordena do mais novo para o mais antigo" do
    antigo = users(:ana).login_events.create!(client: "web", occurred_at: 2.days.ago)
    novo = users(:ana).login_events.create!(client: "mobile", occurred_at: 1.hour.ago)

    assert_equal [ novo, antigo ], users(:ana).login_events.recentes.to_a
  end

  test "apagar o usuário apaga o histórico junto" do
    users(:ana).login_events.create!(client: "web", occurred_at: Time.current)

    assert_difference "LoginEvent.count", -1 do
      users(:ana).destroy
    end
  end
end
