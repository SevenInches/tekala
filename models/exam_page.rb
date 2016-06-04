class ExamPage
  include DataMapper::Resource

  property :id, Serial
  property :page, Integer, :default => 1, :min => 1
  property :total_page, Integer, :default => 1, :min => 1
  
  property :created_at, DateTime
end
