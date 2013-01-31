class BarcodeMaker
  include Mongoid::Document
  belongs_to :network

  field :count, type: Integer
  field :layout, type: Integer	
end
