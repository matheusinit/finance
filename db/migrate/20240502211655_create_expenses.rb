class CreateExpenses < ActiveRecord::Migration[7.1]
  def change
    create_table :expenses, id: :uuid do |t|
      t.string :name, null: false
      t.integer :value, null: false
      t.boolean :is_paid, null: false, default: false
      t.integer :payment_day, null: true
      t.integer :installments_number, null: false, default: 1
      t.references :receipt, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
