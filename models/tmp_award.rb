class TmpAward
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :name, String
  property :photo, String
  property :num, Integer
  property :chance, Integer
  property :created_at, DateTime

  has n, :tmp_award_records, :model => 'TmpAwardRecord', :parent_key => :id, :child_key => :award_id

  
end
