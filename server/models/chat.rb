require 'digest/md5'

class Chat
  include Mongoid::Document
  field :message
  field :name
  field :time, :type => Integer
  field :addr

  def local?
    return true if addr.to_s =~ /#{@@conf['local_ipaddr']}/
    return false
  end

  def to_hash
    {
      :message => message,
      :name => name,
      :time => time,
      :id => _id,
      :user_id => Digest::MD5.hexdigest(addr.to_s),
      :local => local?
    }
  end
end
