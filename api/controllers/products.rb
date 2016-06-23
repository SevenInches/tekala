# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :products do  
	register WillPaginate::Sinatra
  enable :sessions
  
  get :index, :map => '/v1/product/:product_id', :provides => [:json] do
  	@product = Product.get(params[:product_id])
  	render 'v1/product'
  end
end