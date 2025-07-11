# frozen_string_literal: true

class IpActivity < ApplicationRecord
  enum :activity_type, { trade: 0, login: 1, kyc: 2 }

  validates :activity_type, :ip_address, presence: true
  validate :resource_presence

  belongs_to :ip_address_record,
             primary_key: :address,
             foreign_key: :ip_address,
             inverse_of:  :ip_activities,
             class_name:  "IpAddress"

  belongs_to :trading_account,
             primary_key: :login,
             foreign_key: :trading_account_login,
             inverse_of:  :ip_activities,
             optional:    true

  belongs_to :user, optional: true
  belongs_to :owning_user, class_name: "User", optional: true

  # ========= SCOPES =========

  scope :for_user, lambda { |user|
    where(user:).includes(:user, :trading_account, :ip_address_record)
                .or(where(trading_account_login: user.trading_accounts.select(:login)))
  }

  scope :by_type, ->(type) {
    type_value = activity_types[type.to_s]
    raise ArgumentError, "Invalid activity_type: #{type}" unless type_value
    where(activity_type: type_value)
  }

  scope :between_dates, ->(from_date, to_date) {
    return all unless from_date || to_date

    if from_date && to_date
      where(created_at: from_date.beginning_of_day..to_date.end_of_day)
    elsif from_date
      where("created_at >= ?", from_date.beginning_of_day)
    else
      where("created_at <= ?", to_date.end_of_day)
    end
  }

  scope :by_trading_account, ->(login) { where(trading_account_login: login) }
  scope :by_user, ->(user) { where(user_id: user.id) }

  # Scope to fetch a limited set of latest activities grouped by type
  scope :latest_limited_activities, lambda { |user, kyc_limit:, login_limit:, trade_limit:|
    kyc_type   = activity_types['kyc']
    login_type = activity_types['login']
    trade_type = activity_types['trade']

    query = <<-SQL.squish
      SELECT * FROM (
        (SELECT * FROM ip_activities WHERE user_id = #{user.id} AND activity_type = #{kyc_type} ORDER BY created_at DESC LIMIT #{kyc_limit})
        UNION ALL
        (SELECT * FROM ip_activities WHERE user_id = #{user.id} AND activity_type = #{login_type} ORDER BY created_at DESC LIMIT #{login_limit})
        UNION ALL
        (SELECT * FROM ip_activities WHERE user_id = #{user.id} AND activity_type = #{trade_type} ORDER BY created_at DESC LIMIT #{trade_limit})
      ) AS activities
    SQL

    from("(#{query}) AS ip_activities").select("ip_activities.*")
  }

  # ========= INSTANCE METHODS =========

  def resource
    trading_account || user
  end

  private

  def resource_presence
    errors.add(:base, "Either user or trading_account must be present") unless user.present? || trading_account.present?
  end
end
