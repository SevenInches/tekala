# -*- encoding : utf-8 -*-
module Szcgs
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

    get :enroll do
      new_enroll = Enroll.new
      if params.present?
        new_enroll.school = params[:school] if params[:school].present?
        new_enroll.name = params[:name] if params[:name].present?
        new_enroll.phone = params[:phone] if params[:phone].present?
        if new_enroll.save
          [true].to_json
        end
      end
    end
  end
end
