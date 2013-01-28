require 'eventmachine'

Connections = []

class ChatServer < EM::Connection
  def post_init
    Connections << self
    send_data(number_of_connections)
    @timer = EM.add_timer(10) do
      send_data(number_of_connections)
    end
  end

  def unbind
    EM.cancel_timer(@timer)
    Connections.delete(self)
  end

  private

  def number_of_connections
    "# of connections: #{Connections.size}\n"
  end

end

EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8000, ChatServer
}
