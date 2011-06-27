require 'digest/md5'

class User
  include Mongoid::Document
  field :name
  field :last, :type => Integer
end
