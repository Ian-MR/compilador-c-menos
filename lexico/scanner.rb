require_relative "./token.rb"
require_relative "./token_type.rb"
class Scanner
  include TokenType

  def initialize(file_in_path)
    @file_in = File.open(file_in_path, "r")
    @back = false
  end

  def next_char
    @current_char = @file_in.getc unless @back
    @string_buffer << @current_char if @current_char
    @back = false
    true
  end

  def clear_string_buffer
    @string_buffer.chop!
  end

  def set_back
    @back = true
    clear_string_buffer()
  end

  def lex
    state = 0
    error = false
    @string_buffer = ""

    while (!error)
      case state
      when 0
        next_char()
        if !@current_char
          return nil
        elsif @current_char.match?(/[a-zA-Z]/)
          state = 1
        elsif @current_char.match?(/[0-9]/)
          state = 3
        elsif @current_char == ">"
          state = 5
        elsif @current_char == "<"
          state = 8
        elsif @current_char == "="
          state = 11
        elsif @current_char == "!"
          state = 14
        elsif @current_char == "+"
          return Token.new(ADICAO,@string_buffer)
        elsif @current_char == "-"
          return Token.new(SUBTRACAO,@string_buffer)
        elsif @current_char == "*"
          return Token.new(MULTIPLICACAO,@string_buffer)
        elsif @current_char == "/"
          return Token.new(DIVISAO,@string_buffer)
        elsif @current_char == "("
          return Token.new(PARENTESES_ABERTO,@string_buffer)
        elsif @current_char == ")"
          return Token.new(PARENTESES_FECHADO,@string_buffer)
        elsif @current_char == "{"
          return Token.new(CHAVE_ABERTA,@string_buffer)
        elsif @current_char == "}"
          return Token.new(CHAVE_FECHADA,@string_buffer)
        elsif @current_char == "["
          return Token.new(COLCHETE_ABERTO,@string_buffer)
        elsif @current_char == "]"
          return Token.new(COLCHETE_FECHADO,@string_buffer)
        elsif @current_char == ";"
          return Token.new(PONTO_VIRGULA,@string_buffer)
        elsif @current_char == ","
          return Token.new(VIRGULA,@string_buffer)
        elsif (@current_char == " " || @current_char == "\n" || @current_char == "\t" || @current_char == "\r")
          clear_string_buffer()
        else
          error = true
        end
      when 1
        next_char()
        state = 2 if !@current_char.match?(/[a-zA-Z0-9]/)
      when 2
        set_back()
        case @string_buffer.downcase
        when "int"
          return Token.new(INT,@string_buffer)
        when "void"
          return Token.new(VOID,@string_buffer)
        when "if"
          return Token.new(IF,@string_buffer)
        when "else"
          return Token.new(ELSE,@string_buffer)
        when "while"
          return Token.new(WHILE,@string_buffer)
        when "return"
          return Token.new(RETURN,@string_buffer)
        end
        return Token.new(IDENT,@string_buffer)
      when 3
        next_char()
        state = 4 if !@current_char.match?(/[0-9]/)
      when 4
        set_back()
        return Token.new(CONST_INT,@string_buffer)
      when 5
        next_char()
        if @current_char == "="
          state = 6
        else
          state = 7
        end
      when 6
        return Token.new(MAIOR_IGUAL_QUE,@string_buffer)
      when 7
        set_back()
        return Token.new(MAIOR_QUE,@string_buffer)
      when 8
        next_char()
        if @current_char == "="
          state = 6
        else
          state = 7
        end
      when 9
        return Token.new(MENOR_IGUAL_QUE,@string_buffer)
      when 10
        set_back()
        return Token.new(MENOR_QUE,@string_buffer)
      when 11
        next_char()
        if @current_char == "="
          state = 12
        else
          state = 13
        end
      when 12
        return Token.new(IGUAL_A,@string_buffer)
      when 13
        set_back()
        return Token.new(IGUAL,@string_buffer)
      when 14
        next_char()
        if @current_char == "="
          return Token.new(DIFERENTE_DE,@string_buffer)
        end
      else
        error = true
      end
    end
  end
end



