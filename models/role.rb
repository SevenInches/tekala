class Role
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :school_id, Integer

  has n, :role_users

  belongs_to :school

  def total
    role_users.count
  end

end
