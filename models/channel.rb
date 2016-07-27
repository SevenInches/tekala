class Channel
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :school_id, Integer
  property :gen_key, String
  property :name, String
  property :type, Integer
  property :scan_count, Integer
  property :signup_count, Integer
  property :pay_count, Integer
  property :refund_count, Integer
  property :fee, Integer
  property :created_at, DateTime
  property :updated_at, DateTime

  def self.channels
    self.all.collect { |cha| [cha.name, cha.id] }
  end
end
