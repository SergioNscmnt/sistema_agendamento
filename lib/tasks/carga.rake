# lib/tasks/cargas.rake
namespace :cargas do
  desc "Popula o banco com dados de exemplo"
  task popular: :environment do
    puts "==> Limpando toda a base"

    # Se estiver no Rails 7+
    if ActiveRecord::Base.respond_to?(:truncate_all)
      ActiveRecord::Base.truncate_all
    else
      # Para Rails < 7
      conn = ActiveRecord::Base.connection
      conn.disable_referential_integrity do
        conn.tables.each do |table|
          conn.execute("TRUNCATE TABLE #{table} RESTART IDENTITY CASCADE") unless table == "schema_migrations"
        end
      end
    end

    puts "==> Base limpa"
    # Usuario.delete_all  # descomente se quiser resetar usuários também

    def say(msg) = puts " • #{msg}"

    # -----------------------------
    # Helpers
    # -----------------------------
    def cria_usuario!(email:, nome:, perfil:, endereco: "Endereço não informado",
                      especialidades: "Geral", data_inicio_funcao: Date.today,
                      likes: 0, dislikes: 0, dark_mode: false, senha: "12345678")
      Usuario.find_or_create_by!(email: email) do |u|
        u.password             = senha
        u.password_confirmation= senha
        u.nome                 = nome
        u.perfil               = perfil
        u.endereco             = endereco
        u.especialidades       = especialidades
        u.data_inicio_funcao   = data_inicio_funcao
        u.likes                = likes
        u.dislikes             = dislikes
        u.dark_mode            = dark_mode
      end
    end

    def cria_janela(func, dia_sym, inicio_h, fim_h, passo_min = 30, ativo: true, duracao_minutos: 60)
      h = inicio_h
      while h < fim_h
        t = Time.zone.parse("#{Time.zone.today} #{format('%02d:00', h)}")
        (0...(60 / passo_min)).each do |i|
          horario = t + (i * passo_min).minutes
          HorarioFuncionario.find_or_create_by!(
            usuario_id: func.id,
            dia_da_semana: HorarioFuncionario.dia_da_semanas[dia_sym.to_s],
            hora: horario # ⬅️ passa o Time/AS::TimeWithZone, não `strftime`
          ) do |hf|
            hf.ativo = true
            hf.duracao_minutos = duracao_minutos
            hf.status = :livre
          end
        end
        h += 1
      end
    end

    def proximo_slot_livre(func:, a_partir_de: Time.zone.now)
      base = a_partir_de + 1.day
      (0..10).each do |delta|
        d = base.to_date + delta.days
        wday = d.wday # 0..6
        hf = HorarioFuncionario.where(usuario_id: func.id, dia_da_semana: wday, ativo: true)
                               .order(:hora)
                               .first
        next unless hf
        hora = hf.hora
        dt = Time.zone.local(d.year, d.month, d.day, hora.hour, hora.min, 0)
        livre = Agendamento.where(funcionario_id: func.id, horario: dt).blank?
        return dt if livre
      end
      nil
    end

    # -----------------------------
    # Usuários
    # -----------------------------
    say "Criando usuários…"

    admin = cria_usuario!(
      email: "admin@exemplo.com",
      nome:  "Admin",
      perfil:"administrador",
      especialidades: "Administração do sistema"
    )

    func1 = cria_usuario!(
      email: "joao@exemplo.com",
      nome:  "João Barbeiro",
      perfil:"funcionario",
      endereco: "Av. das Flores, 200",
      especialidades: "Corte masculino, Barba"
    )

    func2 = cria_usuario!(
      email: "maria@exemplo.com",
      nome:  "Maria Cabeleireira",
      perfil:"funcionario",
      endereco: "Rua das Acácias, 50",
      especialidades: "Corte feminino, Coloração"
    )

    cli1 = cria_usuario!(email: "ana@exemplo.com",   nome: "Ana Cliente",   perfil: "cliente")
    cli2 = cria_usuario!(email: "bruno@exemplo.com", nome: "Bruno Cliente", perfil: "cliente")
    cli3 = cria_usuario!(email: "carla@exemplo.com", nome: "Carla Cliente", perfil: "cliente")

    say "Usuários prontos."

    # -----------------------------
    # Serviços
    # -----------------------------
    say "Criando serviços…"

    servicos = [
      { nome: "Corte masculino", duracao: 30, preco: 35.0 },
      { nome: "Barba",           duracao: 30, preco: 30.0 },
      { nome: "Corte + Barba",   duracao: 60, preco: 60.0 },
      { nome: "Barbaterapia",    duracao: 45, preco: 50.0 }
    ]

    servicos.each do |attrs|
      Servico.find_or_create_by!(nome: attrs[:nome]) do |s|
        s.duracao = attrs[:duracao]   # <- coluna correta
        s.preco   = attrs[:preco]     # <- se houver validação de presença
      end
    end

    corte       = Servico.find_by!(nome: "Corte masculino")
    barba       = Servico.find_by!(nome: "Barba")
    corte_barba = Servico.find_by!(nome: "Corte + Barba")

    say "Serviços prontos."

    # -----------------------------
    # Horários semanais (seg–sex, 08–12 e 14–18)
    # -----------------------------
    say "Criando horários semanais…"
    [:segunda, :terca, :quarta, :quinta, :sexta, :sabado].each do |dia|
      [func1, func2].each do |func|
        cria_janela(func, dia, 8, 12, 30, ativo: true, duracao_minutos: 30)
        cria_janela(func, dia, 14, 18, 30, ativo: true, duracao_minutos: 30)
      end
    end
    say "Horários criados."

    # -----------------------------
    # Agendamentos exemplo
    # -----------------------------
    say "Criando agendamentos…"

    [[cli1, func1, corte],
     [cli2, func2, barba],
     [cli3, func1, corte_barba]].each do |cliente, funcionario, servico|
      dt = proximo_slot_livre(func: funcionario)
      next unless dt
      Agendamento.find_or_create_by!(
        cliente_id: cliente.id,
        funcionario_id: funcionario.id,
        horario: dt
      ) do |a|
        a.servico_id = servico.id
        a.status     = :agendado if a.respond_to?(:status)
      end
    end

    say "Agendamentos prontos."

    puts "✅ Carga finalizada!"
    puts "   Admin:     admin@exemplo.com / 12345678"
    puts "   Func1:     joao@exemplo.com  / 12345678"
    puts "   Func2:     maria@exemplo.com / 12345678"
    puts "   Clientes:  ana, bruno, carla  (senha 12345678)"
  end
end
