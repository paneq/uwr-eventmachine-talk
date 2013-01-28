require 'eventmachine'

Connections = []

class ChatServer < EM::Connection
  def post_init
    Connections << self
  end

  def unbind
    Connections.delete(self)
  end

  def receive_data(data)
   @lt2_delimiter = "\n"
   @lt2_linebuffer ||= []

   if ix = data.index( @lt2_delimiter )
      @lt2_linebuffer << data[0...ix]
      ln = @lt2_linebuffer.join
      @lt2_linebuffer.clear
      if @lt2_delimiter == "\n"
        ln.chomp!
      end
      receive_line ln
      receive_data data[(ix+@lt2_delimiter.length)..-1]
    else
      @lt2_linebuffer << data
    end
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

EventMachine.run do
  timer = EM.add_periodic_timer(10) do
    Connections.each do |c|
      c.notify_about_connections(Connections.size)
    end
  end

  EventMachine.start_server "127.0.0.1", 8000, ChatServer
end
