# frozen_string_literal: true

class Usuarios::RegistrationsController < Devise::RegistrationsController

  before_action :configure_permitted_parameters
  
  protected

  def configure_permitted_parameters
  
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :endereco, :data_nascimento])
  
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :endereco, :data_nascimento])
  
  end
end
