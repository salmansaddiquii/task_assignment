class OptimizeIpActivitiesIndexes < ActiveRecord::Migration[7.0]
  def change
    # Remove all previous indexes that may be redundant or suboptimal
    remove_index :ip_activities, name: 'idx_ip_activities_type_created_at' if index_exists?(:ip_activities, [:activity_type, :created_at], name: 'idx_ip_activities_type_created_at')
    remove_index :ip_activities, name: 'idx_ip_activities_type_user_created_at' if index_exists?(:ip_activities, [:activity_type, :user_id, :created_at], name: 'idx_ip_activities_type_user_created_at')
    remove_index :ip_activities, name: 'idx_ip_activities_type_login_created_at' if index_exists?(:ip_activities, [:activity_type, :trading_account_login, :created_at], name: 'idx_ip_activities_type_login_created_at')
    remove_index :ip_activities, name: 'idx_ip_activities_user_created_at' if index_exists?(:ip_activities, [:user_id, :created_at], name: 'idx_ip_activities_user_created_at')
    remove_index :ip_activities, name: 'idx_ip_activities_login_created_at' if index_exists?(:ip_activities, [:trading_account_login, :created_at], name: 'idx_ip_activities_login_created_at')

    # Add only the optimized indexes needed for your queries
    add_index :ip_activities, [:user_id, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_user_created_at'
    add_index :ip_activities, [:trading_account_login, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_login_created_at'
    add_index :ip_activities, [:activity_type, :user_id, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_type_user_created_at'
    add_index :ip_activities, [:activity_type, :trading_account_login, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_type_login_created_at'
  end
end
