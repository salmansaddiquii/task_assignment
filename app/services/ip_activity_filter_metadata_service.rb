# frozen_string_literal: true
class IpActivityFilterMetadataService
  def self.call(user)
    new(user).call
  end

  def initialize(user)
    @user = user
  end

  def call
    {
      activity_types: activity_types,
      trading_account_logins: trading_account_logins,
      phases: phases,
      platforms: platforms,
      date_range: date_range_options,
      limits: {
        kyc: 10,
        login: 1000,
        trade: 1990,
        total: 3000
      }
    }
  end

  private

  def activity_types
    IpActivity.activity_types.keys
  end

  def trading_account_logins
    @user.trading_accounts.pluck(:login)
  end

  def phases
    TradingAccount.phases.keys
  end

  def platforms
    TradingAccount.platforms.keys
  end

  def date_range_options
    {
      default: {
        from: 7.days.ago.to_date,
        to: Date.today
      },
      max_range: 30.days,
      available_ranges: [
        { label: "Last 7 days", range: { from: 7.days.ago.to_date, to: Date.today } },
        { label: "Last 30 days", range: { from: 30.days.ago.to_date, to: Date.today } },
        { label: "Last 90 days", range: { from: 90.days.ago.to_date, to: Date.today } }
      ]
    }
  end
end
