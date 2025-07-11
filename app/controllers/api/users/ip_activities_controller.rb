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
        # Start with the base scope
        scope = IpActivity.for_user(@user)
        
        # Apply type-specific limit if filtering by type
        if params[:activity_type].present?
          scope = scope.by_type(params[:activity_type])
                       .limit(activity_limit_for(params[:activity_type]))
        else
          # For all activities, use the latest_limited_activities scope
          scope = IpActivity.latest_limited_activities(
            @user,
            kyc_limit: KYC_LIMIT,
            login_limit: LOGIN_LIMIT,
            trade_limit: MAX_LIMIT - KYC_LIMIT - LOGIN_LIMIT
          )
        end

        # Apply all filters using the filter service
        scope = IpActivityFilterService.apply_filters(scope, params)

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
