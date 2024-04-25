class CreateIncomes < ActiveRecord::Migration[7.1]
  def change
    create_table :incomes, id: :uuid do |t|
      t.string :name, null: false
      t.integer :value, null: false
      t.boolean :is_monthly_recurring, null: false, default: false
      t.date :payment_date, null: true
      t.references :receipt, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
