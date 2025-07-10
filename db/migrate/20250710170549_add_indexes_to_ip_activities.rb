class AddIndexesToIpActivities < ActiveRecord::Migration[7.0]
  def change
    # Index for user activities
    add_index :ip_activities, [:user_id, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_user_created_at'
    add_index :ip_activities, [:trading_account_login, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_login_created_at'
    
    # Add indexes for activity type filtering
    add_index :ip_activities, [:activity_type, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_type_created_at'
    add_index :ip_activities, [:activity_type, :user_id, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_type_user_created_at'
    add_index :ip_activities, [:activity_type, :trading_account_login, :created_at], order: { created_at: :desc }, name: 'idx_ip_activities_type_login_created_at'
  end
end
