class Client < ApplicationRecord
    validates :name, presence: true
    validates :vehicle_number, presence: true
    validates :contact_number, presence: true
    validates_comparison_of :request_date, greater_than_or_equal_to: Time.now.strftime('%Y/%m/%d')
end
