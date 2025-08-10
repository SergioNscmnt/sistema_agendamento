Rails.application.routes.draw do
  root to: "home#index"

  devise_for :usuarios, controllers: {
    sessions: 'usuarios/sessions',
    registrations: 'usuarios/registrations'
  }

  resource :configuracoes, only: [:show, :edit, :update]

  # Admin pode ver horários de um usuário específico (helpers baseados em "horario_"; URL segue "horarios_")
  resources :usuarios, only: [:index] do
    resources :horario_funcionarios,
              path: 'horarios_funcionarios',
              controller: 'horarios_funcionarios',
              only: [:index]
  end

  # Funcionário gerencia os próprios horários (CRUD) — helpers "horario_", URL "/horarios_funcionarios"
  resources :horario_funcionarios,
            path: 'horarios_funcionarios',
            controller: 'horarios_funcionarios',
            except: [:show]

  resources :agendamentos do
    collection { get :novos_horarios }
    member do
      patch :concluir
      patch :cancelar
    end
  end

  resources :servicos
end