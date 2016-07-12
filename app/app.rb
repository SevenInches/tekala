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

    get :question do
      @xy_questions = Question.all(:order=>:weight.asc, :show=>1, :type=>1)
      @jl_questions = Question.all(:order=>:weight.asc, :show=>1, :type=>2)
      @jx_questions = Question.all(:order=>:weight.asc, :show=>1, :type=>3)
      render 'question'
    end

    # get :enroll do
    #   new_enroll = Enroll.new
    #   if params.present?
    #     new_enroll.school = params[:school] if params[:school].present?
    #     new_enroll.name = params[:name] if params[:name].present?
    #     new_enroll.phone = params[:phone] if params[:phone].present?
    #     if new_enroll.save
    #       [true].to_json
    #     end
    #   end
    # end
  end
end
