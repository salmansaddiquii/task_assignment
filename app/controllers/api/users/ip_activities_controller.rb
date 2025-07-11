# frozen_string_literal: true

module Api
  module Users
    class IpActivitiesController < Api::BaseController
      DEFAULT_ORDER_FIELD = :created_at
      DEFAULT_ORDER_DIRECTION = :desc
      MAX_LIMIT = 3000
      KYC_LIMIT = 10
      LOGIN_LIMIT = 1000

      before_action :set_user

      def index
        render json: filtered_ip_activities
      end

      def filter_metadata
        render json: IpActivityFilterPresenter.new(@user).as_json
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def filtered_ip_activities
        if params[:activity_type].present?
          scope = IpActivity.for_user(@user)
                            .by_type(params[:activity_type])
                            .limit(activity_limit_for(params[:activity_type]))
        else
          scope = IpActivity.latest_limited_activities(
            @user,
            kyc_limit: KYC_LIMIT,
            login_limit: LOGIN_LIMIT,
            trade_limit: MAX_LIMIT - KYC_LIMIT - LOGIN_LIMIT
          )
        end

        if params[:from_date] || params[:to_date]
          scope = scope.with_date_range(params[:from_date], params[:to_date])
        end

        if params[:phase].present?
          scope = scope.joins(:trading_account)
                       .where(trading_accounts: { phase: params[:phase] })
        end

        if params[:platform].present?
          scope = scope.joins(:trading_account)
                       .where(trading_accounts: { platform: params[:platform] })
        end

        if params[:trading_account_login].present?
          scope = scope.by_trading_account(params[:trading_account_login])
        end

        # Final ordering
        scope.order(DEFAULT_ORDER_FIELD => DEFAULT_ORDER_DIRECTION)
      end

      def activity_limit_for(type)
        case type
        when 'kyc' then KYC_LIMIT
        when 'login' then LOGIN_LIMIT
        when 'trade' then MAX_LIMIT - KYC_LIMIT - LOGIN_LIMIT
        else 100
        end
      end
    end
  end
end
