
class ServiceCentersController < ApplicationController
  load_and_authorize_resource except: %i[index client_request your_profile client_profile order_confirmation charge payment create show]
  before_action :authenticate_user!, except: %i[index]
  before_action :set_values, only: %i[client_request]
  include Vehicle
  

  def index
    @all = ServiceCenter.all
    @q = ServiceCenter.ransack(params[:q])
    @address = @q.result(distinct: true)
  end
  
  def all_shop
    @all = ServiceCenter.all
  end  

  def show_data
    @a = ServiceCenter.find(params[:id])
  end  
  def shop_list

  end   
   
  def order_pending
    @a = ServiceCenter.find(params[:client][:service_center_id])
    begin
      Shop::OrderService.new().pending_order_for_date(params)
    rescue =>e
      flash[:msg] = e
      redirect_to request_to_owner_path(@a)
    end    
  end  

  def edit
    @edit = ServiceCenter.find(params[:id])
  end 

  def update
    @service_center = ServiceCenter.find(params[:id])
    @service_center.update(service_params)
  end  


  def destroy
    @destroy = ServiceCenter.find(params[:id])
    @destroy.destroy
    flash[:msg] = "deleted successfully"
    redirect_to all_shop_service_centers_path
  end 



  def order_confirmation
    authorize! :update, ServiceCenter
    Shop::OrderService.new().order_confirmation(params)
  end  

  def admin 
  end


  def request_to_owner
    @service_center_id = ServiceCenter.find(params[:id])
    service_center_id = @service_center_id.slots.where(status:"available")
    @data = Client.where(service_center_id:params[:id])
  end  
  
  def create
    @service = ServiceCenter.new(service_params)
    @service.user = current_user
    unless @service.save
      render :new, status: :unprocessable_entity
    else
      redirect_to shop_detail_service_centers_path 
    end
  end   


  def new
    @service_center = ServiceCenter.new
  end


 
  def show
    @request_id = ServiceCenter.find(params[:id])
    begin 
      Shop::OrderService.new().request(params,current_user.id)  
    rescue => e
      debugger
      flash[:error] = e
      redirect_to client_request_path(@request_id)
    end    
  end


  def add_service
    begin 
      Shop::OrderService.new().get_association(params)
      flash[:n] = 'Your are added the category succesfully'
      redirect_to shop_detail_service_centers_path
    rescue => e
      flash[:n] = e
      redirect_to shop_detail_service_centers_path
    end    
  end

  def shop_detail
    @shop = shop_info(current_user.id)
    @category = CategoryList.all
  end

  def client_request 
  end
  
  
  def charge
    flash[:alert] = Shop::OrderService.new().payment_gate_way(params,current_user) ? "bill charged successfully" : "some error occoured" 
    @payment = Payment.new(user_id: current_user.id, service_center_id: params[:service_center_id], client_id: params[:id],amount: params[:cost])
    @payment.save
    redirect_to root_path
  end

  def payment 
  end

  private
  def service_params
    params.require(:service_center).permit(:shop_name, :shop_owner, :location, :address,:image)
  end


  def set_values
    @request_id = ServiceCenter.find(params[:id])
    @a = @request_id.service_types.pluck(:name)
    @time = Client.where(service_center_id:@request_id)
    @slots  = Slot.where(service_center_id:params[:id])
  end
end

