node(:status) { 'success' }
node(:total) { @total }
node(:msg){'消息设为已读'}
child(@messages => :data){
  attributes :id, :user_id, :from_user_id, :reply_user_id, :tweet_id, :content, :type, :created_at, :status
  child(:from_user) {
    attributes :id, :name, :nickname, :avatar_url
  }
  
  child(:reply_user => :reply_user){
    attributes :id, :name, :nickname, :avatar_url
  }
}