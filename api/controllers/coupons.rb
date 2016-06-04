Szcgs::Api.controllers :v1, :coupons do  
	register WillPaginate::Sinatra
  enable :sessions
  current_url = '/api/v1'

  before do 
    @user = User.get(session[:user_id])
    redirect_to("#{current_url}/unlogin") if @user.nil?
  end

  get :index,  :provides => [:json] do
    @user_coupons = UserCoupon.all(:user_id => @user.id, :status.lt => 2, :coupon_id.not => nil, :order => :created_at.desc)
    @coupon_available = []
    @coupon_unavailable = []
    if params[:type] == 'available'
      @user_coupons.each do |coupon|
        @coupon_available.push(coupon) if coupon && coupon.available == 200
      end
      @user_coupons = @coupon_available
    end
    if params[:type] == 'unavailable'
      @user_coupons.each do |coupon|
        @coupon_available.push(coupon) if coupon && coupon.available != 200
      end
      @user_coupons = @coupon_unavailable
    end
    
    #加上这句会减少数据库查询次数
    @user_coupons.each do |coupon|
      puts coupon.available
    end
    #加上这句会减少数据库查询次数
    render 'v1/user_coupons'
  end

end