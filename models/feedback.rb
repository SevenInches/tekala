class Feedback
  include DataMapper::Resource

  property :id, Serial
  property :content, String, :required => true, :messages => { :presence  => "内容不能为空" }
  property :user_id, Integer
  property :created_at, DateTime

  belongs_to :user

end
