class ApplicationController < ActionController::Base
  before_action :authenticate_usuario!

  def current_ability
    @current_ability ||= Ability.new(current_usuario)
  end

  rescue_from CanCan::AccessDenied do |e|
    redirect_to root_path, alert: "Acesso negado: #{e.message}"
  end
end
