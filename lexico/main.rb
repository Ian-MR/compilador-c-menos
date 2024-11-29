require "./scanner.rb"
scanner = Scanner.new("../teste.txt")

while((t = scanner.lex()) != nil)
  puts "#{t.type} - #{t.value}"
end