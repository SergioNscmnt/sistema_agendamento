class AgendamentosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_agendamento, only: [:show, :edit, :update, :destroy, :concluir, :cancelar]
  before_action :set_collections, only: [:new, :edit, :create, :update]

  def index
    @agendamentos = Agendamento
                    .accessible_by(current_ability)
                    .includes(:servico, :funcionario)
                    .order(horario: :asc)
  end

  def new
    debugger
    @agendamento = Agendamento.new
    set_collections
    if turbo_frame_request?
      render partial: "agendamentos/modal_frame",
             locals: { agendamento: @agendamento },
             layout: false
    end
  end

  def create
    @agendamento = Agendamento.new(agendamento_params_for_role)

    if @agendamento.save
      scope = Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("agendamentos_table",
              partial: "agendamentos/agendamentos_table",
              locals: { agendamentos: Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario) }
            ),
            turbo_stream.update("agendamento_modal", "")
          ]
        end
        format.html { redirect_to agendamentos_path, notice: "Agendamento criado com sucesso." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          set_collections
          render partial: "agendamentos/form", locals: { agendamento: @agendamento }, status: :unprocessable_entity, layout: false
        end
        format.html do
          @agendamentos = Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario)
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  def show
    @agendamento
  end

  def edit
    set_collections
    if turbo_frame_request?
      render partial: "agendamentos/modal_frame",
             locals: { agendamento: @agendamento },
             layout: false
    end
  end

  
  def update
    if @agendamento.update(agendamento_params_for_role)
      scope = Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario)
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace("agendamentos_table",
              partial: "agendamentos/agendamentos_table",
              locals: { agendamentos: Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario) }
            ),
            turbo_stream.update("agendamento_modal", "")
          ]
        end
        format.html { redirect_to agendamentos_path, notice: "Agendamento atualizado." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          set_collections
          render partial: "agendamentos/form", locals: { agendamento: @agendamento }, status: :unprocessable_entity, layout: false
        end
        format.html do
          @agendamentos = Agendamento.accessible_by(current_ability).includes(:servico, :funcionario).order(:horario)
          render :index, status: :unprocessable_entity
        end
      end
    end
  end

  def concluir
    authorize! :alterar_status, @agendamento
    if @agendamento.update(status: :concluido)
      redirect_to agendamento_path(@agendamento), notice: "Agendamento concluído."
    else
      redirect_to agendamento_path(@agendamento), alert: @agendamento.errors.full_messages.to_sentence
    end
  end

  def cancelar
    authorize! :alterar_status, @agendamento
    if @agendamento.update(status: :cancelado)
      redirect_to agendamento_path(@agendamento), notice: "Agendamento cancelado."
    else
      redirect_to agendamento_path(@agendamento), alert: @agendamento.errors.full_messages.to_sentence
    end
  end

  def destroy
    @agendamento = Agendamento.find(params[:id])
    authorize! :destroy, @agendamento
    @agendamento.destroy!
    redirect_to agendamentos_path, status: :see_other, notice: "Agendamento removido."
  end

  def novos_horarios
    # params esperados: funcionario_id, servico_id, data (YYYY-MM-DD)
    funcionario_id = params[:funcionario_id]
    servico_id     = params[:servico_id]
    data_str       = params[:data]

    return head :bad_request if funcionario_id.blank? || servico_id.blank? || data_str.blank?

    data = Date.parse(data_str) rescue nil
    return head :bad_request unless data

    servico = Servico.find(servico_id)
    wday    = data.wday

    # slots livres no template do funcionário para o dia escolhido
    slots = HorarioFuncionario
              .where(usuario_id: funcionario_id, ativo: true, dia_da_semana: wday, status: :livre)
              .order(:hora)

    # Converte slots de :time + data → objetos Time daquele dia
    horarios = slots.map do |hf|
      Time.zone.local(data.year, data.month, data.day, hf.hora.hour, hf.hora.min, 0)
    end

    # Remove horários já ocupados por outro agendamento
    ocupados = Agendamento.where(funcionario_id: funcionario_id, horario: data.beginning_of_day..data.end_of_day)
                          .pluck(:horario)
    disponiveis = horarios - ocupados

    # (Opcional) Se quiser filtrar por duração do serviço (p.ex. 60min precisa que o próximo bloco também esteja livre)
    duracao = servico.duracao.presence || 30 # ajuste conforme sua coluna
    if duracao.to_i > 30
      disponiveis.select! do |inicio|
        fim = inicio + duracao.to_i.minutes
        # garanta que não atravessa outro agendamento (verificação simples)
        Agendamento.where(funcionario_id: funcionario_id, horario: (inicio...fim)).none?
      end
    end

    @disponiveis = disponiveis

    render partial: "agendamentos/horarios_disponiveis", locals: { disponiveis: @disponiveis }
  end

  private

  def set_agendamento
    @agendamento = Agendamento.find(params[:id])
  end

  def set_collections
    @servicos = Servico.order(:nome)
    @funcionarios = Usuario.funcionario.order(:nome)
  end

  def agendamento_params_for_role
    permitted = params.require(:agendamento)
                      .permit(:funcionario_id, :servico_id, :horario, :status, :cliente_id, :nome_cliente_convidado)

    # Converte o horário se vier como String (ex.: do radio no Turbo Frame)
    if permitted[:horario].is_a?(String)
      begin
        permitted[:horario] = Time.zone.parse(permitted[:horario])
      rescue ArgumentError, TypeError
        permitted[:horario] = nil
      end
    end

    if current_usuario.cliente?
      # Cliente nunca escolhe status/cliente_id pelo form
      permitted.delete(:status)
      permitted[:cliente_id] = current_usuario.id
    else
      # Só aceita status válido do enum (e opcionalmente só admin altera)
      if !current_usuario.administrador?
        permitted.delete(:status)
      else
        allowed = Agendamento.statuses.keys
        permitted[:status] = permitted[:status].to_s if allowed.include?(permitted[:status].to_s)
      end
    end

    permitted
  end
end
