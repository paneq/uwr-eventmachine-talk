require 'eventmachine'

class ChatServer < EM::Connection
  def post_init
    puts "Someone connected"
  end
end

EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8000, ChatServer
}
