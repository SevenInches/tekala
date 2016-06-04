# -*- encoding : utf-8 -*-
class Timeline
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :num, Integer
  property :content, String
  property :type, Integer
  property :drive_date, DateTime
  property :detail, Text, :lazy => false
  property :note, Text, :lazy => false
end
