require "./error"
module ConsoleOutput
  def print_error(error)
    puts "Erro -> Linha: #{error.line} - #{error.message}"
  end

  def print_message(message)
    puts message
  end
end
