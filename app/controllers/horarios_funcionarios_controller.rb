class HorariosFuncionariosController < ApplicationController
  before_action :authenticate_usuario!
  load_and_authorize_resource class: 'HorarioFuncionario', except: [:create]

  def index
    @horarios_funcionarios = HorarioFuncionario.accessible_by(current_ability).order(:usuario_id, :dia_da_semana, :hora)
    @horario_funcionario ||= HorarioFuncionario.new(ativo: true)
    
    now     = Time.zone.now.change(sec: 0)
    offset  = (30 - now.min % 30) % 30
    proximo = now + offset.minutes
        
    @horario_funcionario.hora ||= proximo
  end

  def new; end

  def create
    # constrói a partir dos strong params
    @horario_funcionario = HorarioFuncionario.new(horario_funcionario_params)

    # garante o dono do registro (se não veio no form)
    @horario_funcionario.usuario_id ||= current_usuario.id

    authorize! :create, @horario_funcionario

    if @horario_funcionario.save
      redirect_to horario_funcionarios_path, notice: "Horário adicionado com sucesso."
    else
      @horarios_funcionarios = HorarioFuncionario
                                 .accessible_by(current_ability)
                                 .order(:usuario_id, :dia_da_semana, :hora)
      render :index, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @horario_funcionario.update(horario_funcionario_params)
      redirect_to horario_funcionarios_path, notice: "Horário atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @horario_funcionario.destroy
    redirect_to horario_funcionarios_path, notice: "Horário removido com sucesso."
  end

  private

  def horario_funcionario_params
    params.require(:horario_funcionario)
          .permit(:dia_da_semana, :hora, :ativo, :duracao_minutos)
  end
end
