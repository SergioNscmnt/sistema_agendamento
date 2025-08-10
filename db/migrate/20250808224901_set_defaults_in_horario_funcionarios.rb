class SetDefaultsInHorarioFuncionarios < ActiveRecord::Migration[7.1]
  def up
    # corrige nulos existentes antes de travar
    execute "UPDATE horario_funcionarios SET status = 0 WHERE status IS NULL"
    execute "UPDATE horario_funcionarios SET duracao_minutos = 60 WHERE duracao_minutos IS NULL"
    execute "UPDATE horario_funcionarios SET ativo = true WHERE ativo IS NULL"

    change_column_default :horario_funcionarios, :status, 0
    change_column_null    :horario_funcionarios, :status, false

    change_column_default :horario_funcionarios, :duracao_minutos, 60
    change_column_null    :horario_funcionarios, :duracao_minutos, false

    change_column_null    :horario_funcionarios, :ativo, false
  end

  def down
    change_column_null    :horario_funcionarios, :ativo, true
    change_column_null    :horario_funcionarios, :duracao_minutos, true
    change_column_default :horario_funcionarios, :duracao_minutos, nil
    change_column_null    :horario_funcionarios, :status, true
    change_column_default :horario_funcionarios, :status, nil
  end
end
