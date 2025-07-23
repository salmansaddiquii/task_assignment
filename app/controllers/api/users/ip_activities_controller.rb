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
        render json: IpActivityFilterMetadataService.call(@user), serializer: IpActivityFilterMetadataSerializer
      end

      private

      def set_user
        @user = User.find(params[:user_id])
      end

      def filtered_ip_activities
        filter_params = params[:filters] || {}
        if params[:saved_filter_id]
          saved_filter = SavedFilter.find(params[:saved_filter_id])
          filter_params = saved_filter.symbolized_parameters
        end
        activities = IpActivity.apply_filters(filter_params)
        activities = activities.order(DEFAULT_ORDER_FIELD => DEFAULT_ORDER_DIRECTION)
        if filter_params[:activity_type].present?
          activities = activities.limit(activity_limit_for(filter_params[:activity_type]))
        else
          activities = activities.limit(MAX_LIMIT)
        end
        activities
      end

      def save_filter
        SavedFilter.create!(
          user: current_user,
          filterable_type: "IpActivity",
          parameters: params[:filters],
          name: params[:name]
        )
        head :created
      end

      def load_filter
        filter = SavedFilter.find(params[:id])
        render json: filter
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
