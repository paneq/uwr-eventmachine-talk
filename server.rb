require 'eventmachine'

Connections = []

class ChatServer < EM::Connection
  def post_init
    Connections << self
    puts "# of connections: #{Connections.size}"
  end

  def unbind
    Connections.delete(self)
  end

end

EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8000, ChatServer
}
