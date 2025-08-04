def seed_servicos
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
end

def seed_horarios
  usuario = Usuario.funcionarios.first
  
  (8..17).each do |hora|
    HorarioFuncionario.create!(
      usuario: usuario,
      dia_da_semana: 1, # segunda
      hora: Time.parse("#{hora}:00"),
      ativo: true
    )
  end
end