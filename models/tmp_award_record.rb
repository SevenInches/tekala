class TmpAwardRecord
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :award_id, Integer
  property :status, Boolean
  property :created_at, Integer
end
