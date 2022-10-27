module Shop
    class OrderService
   
                 
        def request(params,id)
          @request_id = ServiceCenter.find(params[:id])
          @a = @request_id.clients.find_by(request_date:params[:request_date].split("-").reverse.join(" "))
          @client = @request_id.clients.find_by(vehicle_number:params[:vehicle_number])
          @cat = @request_id.service_types.find_by(name:params[:category])
          if @client&.next_date.present?
            if @client.next_date[0,2].to_i >= Time.now.strftime("%d").to_i && @client.next_date[2,3].strip.to_i >= Time.now.strftime("%m").to_i && @client.next_date[5,7].to_i >= Time.now.strftime("%y").to_i
              @request_id.clients.create(name:params[:name],vehicle_number:params[:vehicle_number],contact_number:params[:contact_number],user_id:id,category:@cat.name,cost:@cat.cost,request_time:params[:request_time],request_date:params[:request_date],category_time:@cat.time)
            else
              raise "Your vehicle already serviced and Apply after #{@client.next_date}"
              redirect_to client_request_path(@client.service_center_id)
            end  
          elsif true
            @request_id.clients.create!(name:params[:name],vehicle_number:params[:vehicle_number],contact_number:params[:contact_number],user_id:id,category:@cat.name,cost:@cat.cost,request_time:params[:request_time].upcase,request_date:params[:request_date].split("-").reverse.join("-"),category_time:@cat.time)
          end  
     
        end  



        def order_confirmation(params)
          @data = Client.find(params[:data])
          @service = ServiceCenter.find(@data.service_center_id) 
          @slots = @service.slots.where(status:"available").first
          if @slots
            @slots.update(status:"booked")
            @user = User.find_by(id:@data.user_id)
            @data.update(confirm_date:Time.now.strftime("%d-%m-%y"),confirm_time:Time.now.strftime("%T"))
            if @data.category == "car washing" || @data.category == "bike washing"
              @data.update(next_date:nil,status:"booked",confirm_slot:@slots.name)
              UserMailer.with(email: @user.email).order_mail.deliver_later
            else
              @next_date = next_service(@data.confirm_date,@data)
              @data.update(status:"booked",confirm_slot:@slots.name)
              UserMailer.with(email: @user.email,service:@service).order_mail.deliver_later
            end     
          else
      
          end    
        end 
        
        def payment_gate_way(params,user)
          service_center = ServiceCenter.find_by(id: params[:id])
          check = true
          if check
            s = StripeService.new
            token = s.create_card_token(params)
            customer = s.find_or_create_customer(user)
            token = s.create_card_token(params)
            card = s.create_stripe_customer_card(token.id,customer)
            s.create_stripe_charge(params[:cost], customer.id, card.id, service_center)
            user.change_user_to_paid
            s.service_payment(user.id, params[:id], params[:cost])
            true
          else
            false
          end
        end  
       



         
        def next_service(date,client)
          month = date[3,3].to_i
          year = date[6,7].to_i
          date = date[0,2].to_i
          sum = month+3
          if sum<=12
            t = "#{date} #{sum} #{year}"
            client.update(next_date:t)
          else 
            year = year+1
            month = sum - 12
            t = "#{date} #{month} #{year}"
            client.update(next_date:t)
          end  
        end 
         
     
        # if @a
        #   if params[:request_time][0,2].to_i >  @a.another_request_time[0,2].to_i
        #     @request_id.clients.create(name:params[:name],vehicle_number:params[:vehicle_number],contact_number:params[:contact_number],user_id:id,category:@cat.name,cost:@cat.cost,request_time:params[:request_time].upcase,request_date:params[:request_date].split("-").reverse.join(" "),category_time:@cat.time)
        #   else
        #     raise "Already booked Choose another time"
        #   end 


        def pending_order_for_date(params)
          @client = Client.find_by(name:params[:client][:name]) 
          if @client
            if @client.alloted_slot.present?
              if params[:client][:request_time][0,2].to_i >  @client.another_request_time[0,2].to_i
                @client.update(confirm_time:params[:client][:confirm_time],confirm_date:params[:client][:confirm_date],alloted_slot:params[:client][:alloted_slot],another_request_time:params[:client][:another_request_time])
              else
                raise "Already booked please select another time"
              end    
            else
              @client.update(confirm_time:params[:client][:confirm_time],confirm_date:params[:client][:confirm_date],alloted_slot:params[:client][:alloted_slot],another_request_time:params[:client][:another_request_time])
            end    
          else
            @client.update(confirm_time:params[:client][:confirm_time],confirm_date:params[:client][:confirm_date],alloted_slot:params[:client][:alloted_slot],another_request_time:params[:client][:another_request_time])
          end              
        end     
       


        def get_association(params) 
            @a = ServiceCenter.find(params[:id])
            @list = @a.service_types.all.pluck(:name)
            @category = CategoryList.find_by(name:params[:category])
            if @list.include?(params[:category])
              raise  "This category already exits"
            else  
              @a.service_types.create(name:@category.name,cost:@category.cost,time:@category.time)
            end  
        end


    end     
end    





