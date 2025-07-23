class OptimizeTradingAccountLoginIndexOnIpActivities < ActiveRecord::Migration[7.0]
  def change
    # Remove any previous trading_account_login-related indexes
    remove_index :ip_activities, name: 'idx_ip_activities_login_created_at' if index_exists?(:ip_activities, [:trading_account_login, :created_at], name: 'idx_ip_activities_login_created_at')

    # Add only the required index
    add_index :ip_activities, [:trading_account_login, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_login_created_at'
  end
end
