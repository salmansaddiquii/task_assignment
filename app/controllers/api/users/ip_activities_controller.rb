# frozen_string_literal: true

module Api
  module Users
    class IpActivitiesController < Api::BaseController
      DEFAULT_ORDER_FIELD = :created_at
      DEFAULT_ORDER_DIRECTION = :desc

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
        scope = IpActivityService.for_user(@user)
        scope = IpActivityFilterService.apply_filters(scope, params)
        scope.reorder(order)
      end

      def order
        direction = params[:direction]&.to_sym == :asc ? :asc : :desc
        { DEFAULT_ORDER_FIELD => direction }
      end
    end
  end
end
