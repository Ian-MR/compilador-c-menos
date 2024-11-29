require "./sintatico/parser.rb"

if ARGV.empty?
  puts "Informe o nome do arquivo!"
  exit
end
puts ARGV[0]
p = Parser.new(ARGV[0])
p.parse()