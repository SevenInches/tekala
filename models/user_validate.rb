class UserValidate
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :mobile, String
  property :code, String
  property :updated_at, DateTime
  property :created_at, DateTime

end
