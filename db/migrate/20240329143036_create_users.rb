class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :name
      t.string :email
      t.string :password_digest
      t.timestamps
      t.datetime :deleted_at, default: nil, null: true
    end
  end
end
