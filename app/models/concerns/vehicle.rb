# frozen_string_literal: true

module Vehicle
  extend ActiveSupport::Concern
  included do
    $a= 0 
    def shop_info(user_id)
      @user = ServiceCenter.where(user_id: user_id)
    end
  end


  def slot_association(params)
    @service_center_id = ServiceCenter.find(params[:id])
    @service_center_id.slots.create(name:params[:name])
  end  

  def client_owner_association_for_order(params,id,cost,cat)
    @service_center_id = ServiceCenter.find(params[:id])
    @service_center_id.clients.create(name:params[:name],vehicle_number:params[:vehicle_number],contact_number:params[:contact_number],user_id:id,category:params[:category],cost:cost,request_time:Time.now.strftime("%T"),request_date:Time.now.strftime("%d %m %y"),category_time:cat)
  end  

  def add
    $a
  end 
  
  def client_info(id)
    @user = Client.where(user_id: id).pluck(:id)
  end  



end
