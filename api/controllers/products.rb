# -*- encoding : utf-8 -*-
Szcgs::Api.controllers :v1, :products do  
	register WillPaginate::Sinatra
  enable :sessions

  get :index, :provides => [:json] do
    @products = Product.all(:show => true)
    @products = @products.all(:city_id => params[:city]) if params[:city]
    @total = @products.count
    render 'v1/products'
  end

  #产品详情
  get :product_info, :map => '/v1/products/:product_id', :provides => [:json] do
    @product = Product.get(params[:product_id])
    render 'v1/product'
  end

  #产品介绍
  get :show_vip_html, :map => '/v1/products/:product_id/html' do
    @product = Product.get(params[:product_id])
    render 'v1/product_html'
  end
end