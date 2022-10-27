class Client < ApplicationRecord    
    validates :name, presence: true
    validates :contact_number, presence: true
    validates :vehicle_number, presence: true
    validate :must_have_valid_future_date


private
  def must_have_valid_future_date
    if request_date.present?
        
        if request_date.split("-")[0].to_i < Time.now.strftime("%d").to_i 
            errors.add(:request_date, "date not valid")
        end
      

        if request_date.split("-")[1].to_i < Time.now.strftime("%m").to_i 
            errors.add(:request_date, "month not valid")
        end


        if request_date.split("-")[2].to_i < Time.now.strftime("%Y").to_i 
            errors.add(:request_date, "Year not valid")
        end

     

    end
  end
end
                                                                  
