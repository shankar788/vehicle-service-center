class ClientsController < ApplicationController
    before_action :authenticate_user!
    include Vehicle
    def index
    end     


    def order_cancel
        @client = Client.find(params[:id])
        @service = ServiceCenter.find(params[:service_id])
        @user = User.find(@client.user_id)
        UserMailer.with(email: @user.email,service:@service).order_cancel_mail.deliver_later
    end 

    def show_data
        @d = Client.find(params[:id])
        @data  = CategoryList.find_by(name:@d.category)
        @u = User.find(@d.user_id)
    end
    def show
        @client = client_info(params[:id])
    end

    
    def create
        @admin = CategoryList.new(client_params)
        @admin.save
    end
    def update_slot
        a = Slot.find(params[:id])
        s = Client.where(confirm_slot:a.name)
        if a.status == "booked"
            a.update(status:"available") 
            s.update(status:"not booked")
            redirect_to user_profile_clients_path
        else
            flash[:msg] = "invalid"
            redirect_to user_profile_clients_path
        end    

    end

    def bill_detail
        @bill = Payment.find_by(client_id:params[:id])
        @data = 0
        if @bill.present?
            @data = Client.find(params[:id])
        end 
           
    end

    def user_profile
        if current_user.user_rule == "shop owner" 
            @shop_owner = shop_info(current_user.id)
        elsif current_user.user_rule =="client"
            redirect_to client_path(current_user.id)
        else
            redirect_to admin_path_clients_path
        end            
    end    

    def revenue
        @shop = Payment.where(service_center_id:params[:id])
        @total = 0
        @shop.each do |i|
            @total = @total+i.amount
        end    
    end    


    private
    def client_params
        params.require(:category_list).permit(:name,:cost,:time)
    end    

   
end
