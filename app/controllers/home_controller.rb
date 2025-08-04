class HomeController < ApplicationController

  include Pagy::Backend

  def index
      if usuario_signed_in? && current_usuario.administrador?
        @pagy, @funcionarios = pagy(
          Usuario.funcionarios.order(:nome), 
          items: 10
        )
    end
  end
end
