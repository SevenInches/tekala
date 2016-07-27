# -*- encoding : utf-8 -*-
module Tekala
  class App < Padrino::Application
    register Padrino::Mailer
    register Padrino::Helpers
    enable :sessions

    before do
      #获取设备类型
      user_agent = request.env['HTTP_USER_AGENT']
      $client = DeviceDetector.new(user_agent)
    end

    get :index do 
      @path = 'index'
      render 'index'
    end

    get :about do
      render 'aboutUs'
    end

    get :article, :with => :id do
      @article= Article.get(params[:id])
      render 'article'
    end

    get :articles do
      @articles = Article.all(:order =>:created_at.desc)
      render 'information'
    end

    get :price do
      render 'price'
    end

    get :robot do
      render 'robot'
    end

    get :question do
      @questions = Question.all(:order=>:weight.asc, :show=>1)
      #@jl_questions = Question.all(:order=>:weight.asc, :show=>1, :type=>2)
      #@jx_questions = Question.all(:order=>:weight.asc, :show=>1, :type=>3)
      render 'question'
    end

    get :school do
      render 'school', :layout => false
    end

    post :demo do
      if params[:name].present? && params[:phone].present?
        school = School.new(:name => params[:name], :is_open => 1, :is_vip =>1 ,:password => '123456', :city_id => 236)
        school.contact_phone = params[:phone]
        school.address       = params[:address]  if params[:address].present?
        if school.save
          @name = school.name
          render 'success', :layout => false
        else
          redirect_to url(:school)
        end
      else
        redirect_to url(:school)
      end
    end

    #web端支付 ajax请求返回的charge内容 v3 -d
    post :pay_web, :provides => [:json] do

      api_key = (params[:is_live] == '1' && Padrino.env == :production ) ? CustomConfig::PINGLIVE : CustomConfig::PINGTEST

      app_id  = CustomConfig::PINGAPPID #应用id

      @order  = Signup.first(:order_no => params[:order_no], :user_id => params[:user_id], :status.lt => 2)

      return {:status => :failure, :msg => '没有该订单'}.to_json if @order.nil?

      amount  = @order.amount * 100.to_i

      subject = @order.subject

      return {:status => :failure, :msg => '未选择支付金额'}.to_json if @order == 0

      begin

        CustomConfig.pingxx
        order_result = Pingpp::Charge.create(
            :order_no  => @order.order_no,
            :amount    => amount,
            :subject   => subject,
            :body      => subject,
            :channel   => "wx_pub",
            :currency  => "cny",
            :client_ip => request.ip,
            :app       => { :id => app_id },
            :extra     => { :open_id => params[:open_id]}
        )

        result = JSON.parse(order_result.to_s)
        @order.ch_id = result['id']
        @order.pay_channel = 'wx_pub'
        @order.save

        return order_result.to_json

      rescue => err
        puts err
      ensure
      end

    end
  end
end
