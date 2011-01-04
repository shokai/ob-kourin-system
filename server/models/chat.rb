require 'digest/md5'

class Chat
  include Mongoid::Document
  field :message
  field :name
  field :time, :type => Integer
  field :addr

  def to_hash
    if addr.to_s =~ /#{@@conf['local_ipaddr']}/
      is_local = true 
    else
      is_local = false
    end
    {
      :message => message,
      :name => name,
      :time => time,
      :id => _id,
      :user_id => Digest::MD5.hexdigest(addr.to_s),
      :local => is_local
    }
  end
end
