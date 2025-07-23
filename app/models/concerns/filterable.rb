module Filterable
  extend ActiveSupport::Concern

  class_methods do
    def apply_filters(params)
      results = all
      params.each do |key, value|
        next if value.blank?
        if respond_to?("filter_by_#{key}")
          results = results.public_send("filter_by_#{key}", value)
        end
      end
      results
    end
  end
end
