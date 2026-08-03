class LoginEventSerializer
  def self.as_json(login_event)
    {
      id: login_event.id,
      client: login_event.client,
      ip_address: login_event.ip_address,
      occurred_at: login_event.occurred_at.iso8601
    }
  end
end
