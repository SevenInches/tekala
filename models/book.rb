# -*- encoding : utf-8 -*-
class Book
  include DataMapper::Resource

  property :id, Serial
  property :user_id, Integer
  property :exam_name, String
  property :exam_time, DateTime
  property :book_result, Integer
  property :book_type, Integer
end
