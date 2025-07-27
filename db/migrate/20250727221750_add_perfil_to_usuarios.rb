class AddPerfilToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :perfil, :string
  end
end
