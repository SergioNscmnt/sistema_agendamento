class HorariosFuncionariosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :set_usuario
  before_action :set_horario, only: [:destroy]

  def index
    @horarios = @usuario.horarios_funcionarios.order(:dia_da_semana, :hora)
    @novo_horario = @usuario.horarios_funcionarios.build
  end

  def create
    @novo_horario = @usuario.horarios_funcionarios.build(horario_params)
    if @novo_horario.save
      redirect_to horarios_funcionarios_path, notice: "Horário adicionado com sucesso."
    else
      @horarios = @usuario.horarios_funcionarios.order(:dia_da_semana, :hora)
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @horario.destroy
    redirect_to horarios_funcionarios_path, notice: "Horário removido com sucesso."
  end

  private

  def set_usuario
    if current_usuario.administrador? && params[:usuario_id]
      @usuario = Usuario.funcionarios.find(params[:usuario_id])
    else
      @usuario = current_usuario
    end
  end
  def set_horario
    @horario = @usuario.horarios_funcionarios.find(params[:id])
  end

  def horario_params
    params.require(:horario_funcionario).permit(:dia_da_semana, :hora, :ativo)
  end
end
