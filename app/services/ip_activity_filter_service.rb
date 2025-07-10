# frozen_string_literal: true

class IpActivityFilterService
  def self.apply_filters(scope, params)
    new(scope, params).apply_filters
  end

  def initialize(scope, params)
    @scope = scope
    @params = params
  end

  def apply_filters
    scope = apply_date_filter
    scope = apply_activity_type_filter(scope)
    scope = apply_phase_filter(scope)
    scope = apply_platform_filter(scope)
    scope = apply_trading_account_login_filter(scope)
    scope
  end

  private

  def apply_date_filter(scope = @scope)
    return scope unless @params[:from_date] || @params[:to_date]

    from_date = @params[:from_date] ? Date.parse(@params[:from_date]) : nil
    to_date = @params[:to_date] ? Date.parse(@params[:to_date]) : nil

    if from_date && to_date
      scope.between_dates(from_date, to_date)
    elsif from_date
      scope.where("created_at >= ?", from_date.beginning_of_day)
    elsif to_date
      scope.where("created_at <= ?", to_date.end_of_day)
    else
      scope
    end
  end

  def apply_activity_type_filter(scope = @scope)
    return scope unless @params[:activity_type]
    scope.by_type(@params[:activity_type])
  end

  def apply_phase_filter(scope = @scope)
    return scope unless @params[:phase]
    scope.joins(:trading_account)
         .where(trading_accounts: { phase: @params[:phase] })
  end

  def apply_platform_filter(scope = @scope)
    return scope unless @params[:platform]
    platforms = Array(@params[:platform])
    platforms = platforms.first.split(",") if platforms.size == 1
    scope.joins(:trading_account)
         .where(trading_accounts: { platform: platforms })
  end

  def apply_trading_account_login_filter(scope = @scope)
    return scope unless @params[:trading_account_login]
    logins = Array(@params[:trading_account_login])
    logins = logins.first.split(",") if logins.size == 1
    scope.where(trading_account_login: logins)
  end
end
