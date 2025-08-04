class AddDarkModeToUsuarios < ActiveRecord::Migration[7.1]
  def change
    add_column :usuarios, :dark_mode, :boolean
  end
end
