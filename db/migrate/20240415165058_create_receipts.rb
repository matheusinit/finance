class CreateReceipts < ActiveRecord::Migration[7.1]
  def change
    create_table :receipts, id: :uuid do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true, type: :uuid

      t.timestamps
      t.datetime :deleted_at, default: nil, null: true
    end
  end
end
