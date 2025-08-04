class ConfiguracoesController < ApplicationController
  before_action :authenticate_usuario!

  def show
    @usuario = current_usuario
  end

  def edit
    @usuario = current_usuario
  end

  def update
    @usuario = current_usuario

    # remove senha em branco, se não quiser mudar…
    if params[:usuario][:password].blank?
      params[:usuario].delete(:password)
      params[:usuario].delete(:password_confirmation)
    end

    respond_to do |format|
      if @usuario.update(configuracao_params)
        format.html { redirect_to configuracoes_path, notice: 'Configurações atualizadas.' }
        format.json { head :no_content }
      else
        format.html { render :edit }
        format.json { render json: @usuario.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private

  def configuracao_params
    params.require(:usuario).permit(
      :nome,
      :password,
      :password_confirmation,
      :avatar,
      :dark_mode
    )
  end
end
