require 'eventmachine'

Connections = []

class ChatServer < EM::Connection
  include EventMachine::Protocols::LineText2

  def post_init
    Connections << self
  end

  def unbind
    Connections.delete(self)
  end

  def receive_line(line)
    Connections.each do |c|
      next if c == self
      c.notify_about_line(line)
    end
  end

  def notify_about_line(line)
    send_data("Someone says, quote: '#{line}'\n")
  end

  def notify_about_connections(size)
    send_data( number_of_connections(size) )
  end

  private

  def number_of_connections(size)
    "# of connections: #{size}\n"
  end

end

EM.run do

  trap("INT") do
    EM.stop
  end

  trap("TERM") do
    EM.stop
  end

  timer = EM.add_periodic_timer(10) do
    Connections.each do |c|
      c.notify_about_connections(Connections.size)
    end
  end

  EventMachine.start_server "127.0.0.1", 8000, ChatServer
end
