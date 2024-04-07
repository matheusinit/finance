class ChangeColumnFromLoginAttemptsFromUsersToAccounts < ActiveRecord::Migration[7.1]
  def up
    add_column :accounts, :login_attempts, :integer, default: 0

    remove_column :users, :login_attempts
  end

  def down
    remove_column :accounts, :login_attempts

    add_column :users, :login_attempts, :integer, default: 0
  end
end
