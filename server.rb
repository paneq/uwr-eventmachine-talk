require 'eventmachine'

Connections = []

class ChatServer < EM::Connection
  def post_init
    Connections << self
  end

  def unbind
    Connections.delete(self)
  end

  def notify_about_connections(size)
    send_data( number_of_connections(size) )
  end

  private

  def number_of_connections(size)
    "# of connections: #{size}\n"
  end

end

EventMachine.run {
  timer = EM.add_periodic_timer(5) do
    Connections.each do |c|
      c.notify_about_connections(Connections.size)
    end
  end

  EventMachine.start_server "127.0.0.1", 8000, ChatServer
}
