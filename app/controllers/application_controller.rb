class ApplicationController < ActionController::Base
    before_action :authenticate_usuario!

    def after_sign_in_path_for(resource)
       root_path
    end
end
