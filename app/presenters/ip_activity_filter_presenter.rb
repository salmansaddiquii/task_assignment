# frozen_string_literal: true

class IpActivityFilterPresenter
  def initialize(user)
    @user = user
  end

  def as_json
    {
      ip_activities_count: IpActivityService.activity_count(@user),
      trading_account_logins: IpActivityService.distinct_trading_account_logins(@user),
      activity_types: IpActivity.activity_types.keys,
      phases: TradingAccount.phases.keys,
      platforms: TradingAccount.platforms.keys
    }
  end
end
