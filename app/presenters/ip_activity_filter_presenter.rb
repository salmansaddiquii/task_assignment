# frozen_string_literal: true

class IpActivityFilterPresenter
  def initialize(user)
    @user = user
    @base_scope = IpActivity.for_user(user)
  end

  def as_json
    {
      filters: IpActivityFilterMetadataService.call(@user),
      stats: {
        total_activities: @base_scope.count,
        kyc_activities: @base_scope.by_type(:kyc).count,
        login_activities: @base_scope.by_type(:login).count,
        trade_activities: @base_scope.by_type(:trade).count
      }
    }
  end
end
