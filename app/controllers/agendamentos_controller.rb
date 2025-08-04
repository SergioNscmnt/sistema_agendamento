class AgendamentosController < ApplicationController
  before_action :set_agendamento, only: %i[ show edit update destroy ]

  # GET /agendamentos or /agendamentos.json
  def index
    if current_usuario.cliente?
      @agendamentos_concluidos = current_usuario.agendamentos_concluidos
      @ultimos_servicos = current_usuario.ultimos_servicos
    elsif current_usuario.funcionario?
      @agendamentos_hoje = current_usuario.agendamentos_do_dia
      @horarios_disponiveis = current_usuario.horarios_disponiveis
      @atendimentos_concluidos = current_usuario.agendamentos_concluidos.count
    elsif current_usuario.administrador?
      @agendamentos_hoje = Agendamento.do_dia
      @horarios_disponiveis = current_usuario.horarios_disponiveis_para
      @atendimentos_concluidos = Agendamento.concluido.count
      @funcionarios = Usuario.funcionarios
    end
  end

  # GET /agendamentos/1 or /agendamentos/1.json
  def show
  end

  # GET /agendamentos/new
  def new
    @agendamento = Agendamento.new    
    if current_usuario.cliente?
      @agendamento.cliente_id = current_usuario.id
    end
  end

  # GET /agendamentos/1/edit
  def edit
  end

  # POST /agendamentos or /agendamentos.json
  def create
    @agendamento = Agendamento.new(agendamento_params)
    
    if current_usuario.cliente?
      @agendamento.cliente = current_usuario
    end

    if @agendamento.save
      redirect_to agendamentos_path, notice: "Agendamento criado com sucesso."
    else
      render :new
    end
  end

  # PATCH/PUT /agendamentos/1 or /agendamentos/1.json
  def update
    respond_to do |format|
      if @agendamento.update(agendamento_params)
        format.html { redirect_to @agendamento, notice: "Agendamento was successfully updated." }
        format.json { render :show, status: :ok, location: @agendamento }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @agendamento.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /agendamentos/1 or /agendamentos/1.json
  def destroy
    @agendamento.destroy!

    respond_to do |format|
      format.html { redirect_to agendamentos_path, status: :see_other, notice: "Agendamento was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_agendamento
      @agendamento = Agendamento.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def agendamento_params
      params.require(:agendamento).permit(:cliente_id, :funcionario_id, :servico_id, :horario, :status)
    end
end
