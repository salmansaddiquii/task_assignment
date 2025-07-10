# frozen_string_literal: true

class IpActivityService
  def self.for_user(user)
    new(user).for_user
  end

  def self.smart_limit(scope, total_limit = 3000)
    new(scope).smart_limit(total_limit)
  end

  def self.recent_n_per_activity_type(scope, limit)
    new(scope).recent_n_per_activity_type(limit)
  end

  def self.activity_count(user)
    new(user).activity_count
  end

  def self.distinct_trading_account_logins(user)
    new(user).distinct_trading_account_logins
  end

  def initialize(user_or_scope = nil)
    @user = user_or_scope.is_a?(User) ? user_or_scope : nil
    @scope = user_or_scope.is_a?(User) ? IpActivity.all : user_or_scope
  end

  def for_user
    @scope.where("user_id = ? OR trading_account_login IN (SELECT login FROM trading_accounts WHERE user_id = ?)", @user.id, @user.id)
          .includes(:user, :trading_account, :ip_address_record)
  end

  def smart_limit(total_limit = 3000)
    kyc_limit = 10
    login_limit = 1000
    trade_limit = [total_limit - (kyc_limit + login_limit), 0].max

    kyc_ids = @scope.by_type(:kyc)
                    .order(created_at: :desc)
                    .limit(kyc_limit)
                    .pluck(:id)

    login_ids = @scope.by_type(:login)
                      .where.not(id: kyc_ids)
                      .order(created_at: :desc)
                      .limit(login_limit)
                      .pluck(:id)

    trade_ids = @scope.by_type(:trade)
                      .where.not(id: kyc_ids + login_ids)
                      .order(created_at: :desc)
                      .limit(trade_limit)
                      .pluck(:id)

    @scope.where(id: kyc_ids + login_ids + trade_ids)
          .includes(:user, :trading_account, :ip_address_record)
          .order(created_at: :desc)
  end

  def recent_n_per_activity_type(limit)
    query = <<-SQL.squish
      WITH recent_activities AS (
        SELECT DISTINCT ON (activity_type, user_id) activity_type, user_id, id, created_at
        FROM ip_activities
        WHERE user_id = $1 OR trading_account_login IN (SELECT login FROM trading_accounts WHERE user_id = $1)
        ORDER BY activity_type, user_id, created_at DESC
      )
      SELECT * FROM recent_activities
      ORDER BY activity_type, created_at DESC
    SQL

    @scope.from("(#{ApplicationRecord.sanitize_sql_array([query, @user.id])}) AS ip_activities")
          .includes(:user, :trading_account, :ip_address_record)
  end

  def activity_count
    @scope.where("user_id = ? OR trading_account_login IN (SELECT login FROM trading_accounts WHERE user_id = ?)", @user.id, @user.id)
          .count
  end

  def distinct_trading_account_logins
    @scope.select(:trading_account_login)
          .where("user_id = ? OR trading_account_login IN (SELECT login FROM trading_accounts WHERE user_id = ?)", @user.id, @user.id)
          .distinct
          .unscope(:order) # removes any implicit order that might break DISTINCT
          .pluck(:trading_account_login)
          .compact
  end
end
