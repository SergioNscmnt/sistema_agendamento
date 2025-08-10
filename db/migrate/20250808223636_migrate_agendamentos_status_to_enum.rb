class MigrateAgendamentosStatusToEnum < ActiveRecord::Migration[7.1]
  def up
    # 1) converter status:string -> integer com mapeamento
    # mapeamento: agendado=0, concluido=1, cancelado=2
    execute <<~SQL
      ALTER TABLE agendamentos
      ALTER COLUMN status DROP DEFAULT;
    SQL

    # cria coluna nova temporária
    add_column :agendamentos, :status_int, :integer, default: 0, null: false

    # migra valores existentes
    execute <<~SQL
      UPDATE agendamentos
      SET status_int =
        CASE LOWER(COALESCE(status, 'agendado'))
          WHEN 'agendado' THEN 0
          WHEN 'concluido' THEN 1
          WHEN 'concluído' THEN 1
          WHEN 'cancelado' THEN 2
          ELSE 0
        END;
    SQL

    # remove coluna antiga e renomeia a nova
    remove_column :agendamentos, :status
    rename_column :agendamentos, :status_int, :status

    # 2) índice único de slot ativo (impede dupla reserva no mesmo dia/hora p/ mesmo funcionário)
    add_index :agendamentos, [:funcionario_id, :horario],
              unique: true,
              where: "status IN (0,1)", # 0: agendado, 1: concluido
              name: "idx_agendamento_slot_unico"
  end

  def down
    # rollback simples: volta para string (perde o mapeamento)
    add_column :agendamentos, :status_str, :string, default: "agendado", null: false

    execute <<~SQL
      UPDATE agendamentos
      SET status_str =
        CASE status
          WHEN 0 THEN 'agendado'
          WHEN 1 THEN 'concluido'
          WHEN 2 THEN 'cancelado'
          ELSE 'agendado'
        END;
    SQL

    remove_index :agendamentos, name: "idx_agendamento_slot_unico"
    remove_column :agendamentos, :status
    rename_column :agendamentos, :status_str, :status
  end
end
