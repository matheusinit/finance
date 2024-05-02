class AddIsPaidColumnToIncomesTable < ActiveRecord::Migration[7.1]
  def change
    add_column :incomes, :is_paid, :boolean, null: false, default: false
  end
end
