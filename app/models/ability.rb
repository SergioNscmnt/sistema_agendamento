class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= Usuario.new # convidado

    alias_action :concluir, :cancelar, to: :alterar_status

    if user.administrador?
      can :manage, :all
      return
    end

    # Qualquer usuário logado pode ver horários ativos para escolher
    can :read, HorarioFuncionario, ativo: true

    if user.funcionario?
      can :create, Agendamento
      can :manage, HorarioFuncionario, usuario_id: user.id
      can [:read, :index, :update, :alterar_status], Agendamento, funcionario_id: user.id
    end

    if user.cliente?
      can :create, Agendamento
      can [:read, :index, :update, :destroy], Agendamento, cliente_id: user.id
    end
  end
end
