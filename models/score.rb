# -*- encoding : utf-8 -*-
class Score
  include DataMapper::Resource

  # property <name>, <type>
  property :id, Serial
  property :user_id, Integer
  property :score, Integer
  property :type, Integer
  property :note, Text, :lazy => false
  property :created_at, DateTime
end
