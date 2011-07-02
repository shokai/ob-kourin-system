class User
  include Mongoid::Document
  field :name
  field :addr
  field :expire, :type => Integer
  def to_hash
    {
      :name => name || '??',
      :addr => addr,
      :expire => expire
    }
  end
end
