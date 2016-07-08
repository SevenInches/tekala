# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :products do  
	register WillPaginate::Sinatra
  enable :sessions

  get :index, :provides => [:json] do
    @product_bindings = ProductBinding.all(:school_id => params[:school_id])
    @total = @product_bindings.count
    render 'v1/product_bindings'
  end

  #产品详情
  get :product_info, :map => '/v1/products/:product_id', :provides => [:json] do
    @product_binding = ProductBinding.get(params[:product_id])
    render 'v1/product_info'
  end

end