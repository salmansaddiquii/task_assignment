# frozen_string_literal: true

# class IpActivityFilterService
#   def self.apply_filters(scope, params)
#     new(scope, params).apply_filters
#   end

#   def initialize(scope, params)
#     @scope = scope
#     @params = params
#   end

#   def apply_filters
#     scope = apply_date_filter
#     scope = apply_activity_type_filter(scope)
#     scope = apply_phase_filter(scope)
#     scope = apply_platform_filter(scope)
#     scope = apply_trading_account_login_filter(scope)
#     scope
#   end

#   private

#   def apply_date_filter(scope = @scope)
#     return scope unless @params[:from_date] || @params[:to_date]
#     scope.with_date_range(@params[:from_date], @params[:to_date])
#   end

#   def apply_activity_type_filter(scope = @scope)
#     return scope unless @params[:activity_type]
    
#     case @params[:activity_type]
#     when 'kyc'
#       scope.by_type('kyc').limit(10)
#     when 'login'
#       scope.by_type('login').limit(1000)
#     when 'trade'
#       scope.by_type('trade').limit(1990) # MAX_LIMIT - KYC_LIMIT - LOGIN_LIMIT
#     else
#       scope
#     end
#   end

#   def apply_trading_account_login_filter(scope = @scope)
#     return scope unless @params[:trading_account_login]
#     scope.by_trading_account_login(@params[:trading_account_login])
#   end

#   def apply_phase_filter(scope = @scope)
#     return scope unless @params[:phase]
#     scope.joins(:trading_account)
#          .where(trading_accounts: { phase: @params[:phase] })
#   end

#   def apply_platform_filter(scope = @scope)
#     return scope unless @params[:platform]
#     scope.joins(:trading_account)
#          .where(trading_accounts: { platform: @params[:platform] })
#   end
# end
