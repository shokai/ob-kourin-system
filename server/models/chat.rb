class Chat
  include Mongoid::Document
  field :message
  field :name
  field :time, :type => Integer
end