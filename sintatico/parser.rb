#require "./console_output"
require_relative "../lexico/scanner"

class Parser
  include TokenType
  attr_reader :token

  def initialize(file_in_path)
    @scanner = Scanner.new(file_in_path)
    @token = @scanner.lex()
  end

  def parse
    programa()
    puts "Compilação com sucesso"
  end

  def comparar(token)
    if !@token
      puts "Erro de Compilação"
      exit
    end
    if token == @token.type
      @token = @scanner.lex()
    else
      puts "Símbolo não esperado!"
      puts "O esperado era #{token}, mas encontrou #{@token.type}"
      puts "#{caller.first}"
      exit
    end
  end

  def programa
    declaracoes_lista()
  end

  def declaracoes_lista
    declaracoes()
    while @token
      declaracoes()
    end
  end
  
  def declaracoes
    tipo()
    comparar(IDENT)
    if @token.type == PONTO_VIRGULA || @token.type == COLCHETE_ABERTO
      declaracao_var()
    elsif @token.type == PARENTESES_ABERTO
      declaracao_func()
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def tipo
    if @token.type == INT
      comparar(INT)
    elsif @token.type == VOID
      comparar(VOID)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def declaracao_var
    if @token.type == PONTO_VIRGULA
      comparar(PONTO_VIRGULA)
    elsif @token.type == COLCHETE_ABERTO
      comparar(COLCHETE_ABERTO)
      comparar(CONST_INT)
      comparar(COLCHETE_FECHADO)
      comparar(PONTO_VIRGULA)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def declaracao_func
    comparar(PARENTESES_ABERTO)
    par_formais()
    comparar(PARENTESES_FECHADO)
    declaracao_composto()
  end

  def par_formais
    if @token.type != PARENTESES_FECHADO
      lista_par_formais()
    end
  end

  def lista_par_formais
    parametro()
    if @token.type == VIRGULA
      comparar(VIRGULA)
      lista_par_formais()
    end
  end

  def parametro
    tipo()
    comparar(IDENT)
    if @token.type == COLCHETE_ABERTO
      comparar(COLCHETE_ABERTO)
      comparar(COLCHETE_FECHADO)
    end
  end

  def declaracao_composto
    comparar(CHAVE_ABERTA)
    declaracoes_locais()
    lista_comandos()
    comparar(CHAVE_FECHADA)
  end

  def declaracoes_locais
    while(@token.type == INT || @token.type == VOID)
      tipo()
      comparar(IDENT)
      declaracao_var()
    end
  end

  def lista_comandos
    while (@token.type == IDENT || @token.type == CHAVE_ABERTA || @token.type == IF || @token.type == WHILE || @token.type == RETURN)
      comando()
    end
  end

  def comando
    case @token.type
    when IDENT
      comando_expressao()
    when CHAVE_ABERTA
      comando_composto()
    when IF
      comando_selecao()
    when WHILE
      comando_iteracao()
    when RETURN
      comando_retorno()
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def comando_expressao
    expressao()
    comparar(PONTO_VIRGULA)
  end

  def comando_composto
    comparar(CHAVE_ABERTA)
    lista_comandos()
    comparar(CHAVE_FECHADA)
  end

  def comando_selecao
    comparar(IF)
    comparar(PARENTESES_ABERTO)
    expressao()
    comparar(PARENTESES_FECHADO)
    comando()
    if @token.type == ELSE
      comparar(ELSE)
      comando()
    end
  end

  def comando_iteracao
    comparar(WHILE)
    comparar(PARENTESES_ABERTO)
    expressao()
    comparar(PARENTESES_FECHADO)
    comando()
  end

  def comando_retorno
    comparar(RETURN)
    if @token.type == PONTO_VIRGULA
      comparar(PONTO_VIRGULA)
    elsif @token.type == IDENT
      expressao()
      comparar(PONTO_VIRGULA)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def expressao
    if @token.type == IDENT
      comparar(IDENT)
      if @token.type == IGUAL
        var()
        comparar(IGUAL)
        expressao_simples()
      else
        expressao_simples()
      end
    end
  end

  def var
    if @token.type == COLCHETE_ABERTO
      comparar(COLCHETE_ABERTO)
      expressao()
      comparar(COLCHETE_FECHADO)
    end
  end

  def expressao_simples
    expressao_soma()
    if (@token.type == MAIOR_QUE || @token.type == MAIOR_IGUAL_QUE || @token.type == MENOR_QUE || @token.type == MENOR_IGUAL_QUE || @token.type == IGUAL_A || @token.type == DIFERENTE_DE)
      op_relacional()
      expressao_soma()
    end
  end

  def op_relacional
    case @token.type
    when MAIOR_QUE
      comparar(MAIOR_QUE)
    when MAIOR_IGUAL_QUE
      comparar(MAIOR_IGUAL_QUE)
    when MENOR_QUE
      comparar(MENOR_QUE)
    when MENOR_IGUAL_QUE
      comparar(MENOR_IGUAL_QUE)
    when IGUAL_A
      comparar(IGUAL_A)
    when DIFERENTE_DE
      comaparar(DIFERENTE_DE)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def expressao_soma
    termo()
    while (@token.type == ADICAO || @token.type == SUBTRACAO)
      op_aditivo()
      termo()
    end
  end

  def op_aditivo
    case @token.type
    when ADICAO
      comparar(ADICAO)
    when SUBTRACAO 
      comparar(SUBTRACAO)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def termo
    fator()
    while (@token.type == MULTIPLICACAO || @token.type == DIVISAO)
      op_mult()
      fator()
    end
  end

  def op_mult
    case @token.type
    when MULTIPLICACAO
      comparar(MULTIPLICACAO)
    when DIVISAO 
      comparar(DIVISAO)
    else
      puts "Erro! #{caller.first}"
      exit
    end
  end

  def fator
    if @token.type == PARENTESES_ABERTO
      comparar(PARENTESES_ABERTO)
      expressao()
      comparar(PARENTESES_FECHADO)
    elsif @token.type == CONST_INT
      comparar(CONST_INT)
    elsif @token.type == IDENT
      comparar(IDENT)
      if @token.type == PARENTESES_ABERTO
        ativacao()
      else
        var()
      end
    end
  end

  def ativacao
    comaparar(PARENTESES_ABERTO)
    argumentos()
    comparar(PARENTESES_FECHADO)
  end

  def argumentos
    if @token.type != PARENTESES_FECHADO
      argumentos_lista()
    end
  end

  def argumentos_lista
    expressao()
    while @token.type == VIRGULA
      comparar(VIRGULA)
      expressao()
    end
  end
end
