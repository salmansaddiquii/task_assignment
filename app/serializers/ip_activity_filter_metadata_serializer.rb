# frozen_string_literal: true

class IpActivityFilterMetadataSerializer < ActiveModel::Serializer
  attributes :activity_types, :trading_account_logins, :phases, :platforms, :date_range, :limits

  def activity_types
    object[:activity_types]
  end

  def trading_account_logins
    object[:trading_account_logins]
  end

  def phases
    object[:phases]
  end

  def platforms
    object[:platforms]
  end

  def date_range
    object[:date_range]
  end

  def limits
    object[:limits]
  end
end
