class AgendamentosController < ApplicationController
  before_action :authenticate_usuario!

  def index
    @agendamentos = Agendamento
                      .accessible_by(current_ability)
                      .order(:horario)
  end

  def new
    @agendamento = Agendamento.new
    authorize! :create, @agendamento
    @agendamento.cliente_id ||= current_usuario.id if current_usuario.cliente?
  end

  def create
    @agendamento = Agendamento.new(agendamento_params_for_role)
    authorize! :create, @agendamento

    if @agendamento.save
      redirect_to agendamentos_path, notice: "Agendamento criado com sucesso."
    else
      flash.now[:alert] = @agendamento.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @agendamento = Agendamento.find(params[:id])
    authorize! :read, @agendamento
  end

  def edit
    @agendamento = Agendamento.find(params[:id])
    authorize! :update, @agendamento
  end

  def update
    @agendamento = Agendamento.find(params[:id])
    authorize! :update, @agendamento

    if @agendamento.update(agendamento_params_for_role)
      redirect_to @agendamento, notice: "Agendamento atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @agendamento = Agendamento.find(params[:id])
    authorize! :destroy, @agendamento
    @agendamento.destroy!
    redirect_to agendamentos_path, status: :see_other, notice: "Agendamento removido."
  end

  def novos_horarios
    authorize! :read, HorarioFuncionario
    func = Usuario.funcionarios.find(params[:funcionario_id])
    data = (params[:data].presence&.to_date) || Time.zone.today
    @horarios = Agendamento.disponiveis_para_funcionario_no_dia(func, data)
  end

  private

  def agendamento_params_for_role
    base = params.require(:agendamento).permit(:funcionario_id, :servico_id, :horario, :status, :cliente_id)
    if current_usuario.cliente?
      base = base.except(:status, :cliente_id)
      base[:cliente_id] = current_usuario.id
    end
    base
  end
end
