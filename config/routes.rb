Rails.application.routes.draw do
  root to: "home#index"
  devise_for :usuarios, controllers: {
    registrations: 'usuarios/registrations'
  }

  resources :usuarios, only: [] do
    resources :horarios_funcionarios, only: [:index], controller: 'horarios_funcionarios'
  end
  resource :configuracoes, only: [:show, :edit, :update]
  resources :horarios_funcionarios, only: [:index, :create, :destroy]
  resources :agendamentos
  resources :servicos
  resources :funcionarios
  resources :clientes
end
