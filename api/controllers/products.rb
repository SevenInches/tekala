# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :products do  
	register WillPaginate::Sinatra
  enable :sessions
  
  get :index, :provides => [:json] do 
  	@product_bindings = ProductBinding.all(:show => true)
    @product_bindings = @product_bindings.all(:city => params[:city]) if params[:city]
  	@total = @product_bindings.count
  	render 'v1/product_bindings'
  end

  #产品详情
  get :product_info, :map => '/v1/products/:product_id', :provides => [:json] do
    @product_binding = ProductBinding.get(params[:product_id])
    render 'v1/product_binding'
  end

   get :show_vip_html, :map => '/v1/products/:product_id/html' do 
    @product_binding = ProductBinding.get(params[:product_id])
    render 'v1/product_html'
  end
  
end