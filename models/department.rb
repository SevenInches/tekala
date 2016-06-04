# -*- encoding : utf-8 -*-
class Department
  include DataMapper::Resource

  property :id, Serial
  property :value, String
  property :name, String
  
end
