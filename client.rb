require 'eventmachine'

Connections = []

class ChatClient < EM::Connection
  include EventMachine::Protocols::LineText2

  def receive_line(line)
    puts "[#{object_id}] Received: #{line}"
  end

  def connection_completed
    Connections << self
    @greeting = EM.add_timer(1) do
      say("Hello world")
    end

    @chatting = EM.add_periodic_timer(3) do
      say(ENV.keys.sample)
    end
  end

  def say(text)
    puts "[#{object_id}] Said: #{text}"
    send_line(text)
  end

  def send_line(text)
    send_data("#{text}\n")
  end

  def unbind
    Connections.delete(self)
    EM.cancel_timer(@greeting)
    EM.cancel_timer(@chatting)

    EM.stop if Connections.empty?
  end

end

EM.run do
  EM.connect "127.0.0.1", 8000, ChatClient
  EM.add_timer(5) do
    EM.connect "127.0.0.1", 8000, ChatClient
  end
end

