class Error
  attr_accessor :line, :message

  def initialize(line, message)
    @line = line
    @message = message
  end
end
