puts "Criando serviços..."

servicos = [
  { nome: "Corte" },
  { nome: "Barba" },
  { nome: "Barbaterapia" },
  { nome: "Corte + Barba" }
]

servicos.each do |servico|
  Servico.find_or_create_by!(nome: servico[:nome])
end

puts "Serviços criados com sucesso!"
