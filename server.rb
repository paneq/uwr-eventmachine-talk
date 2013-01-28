require 'eventmachine'

class ChatServer < EM::Connection
end

EventMachine.run {
  EventMachine.start_server "127.0.0.1", 8000, ChatServer
}
