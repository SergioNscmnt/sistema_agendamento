class FixAgendamentosForeignKeys < ActiveRecord::Migration[7.1]
  def up
    # Remover FKs antigas
    remove_foreign_key :agendamentos, :clientes
    remove_foreign_key :agendamentos, :funcionarios

    # Adicionar FKs corretas para usuarios
    add_foreign_key :agendamentos, :usuarios, column: :cliente_id
    add_foreign_key :agendamentos, :usuarios, column: :funcionario_id
  end

  def down
    # rollback para o estado anterior (se quiser)
    remove_foreign_key :agendamentos, column: :cliente_id
    remove_foreign_key :agendamentos, column: :funcionario_id

    add_foreign_key :agendamentos, :clientes
    add_foreign_key :agendamentos, :funcionarios
  end
end
