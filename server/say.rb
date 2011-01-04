require 'rubygems'
require 'net/http'
require 'uri'

class Say
  def initialize(api_uri)
    @uri = URI.parse(api_uri)
  end

  def post(message)
    query = {:message => message}.map{|k,v|"#{k}=#{v}"}.join('&')
    @res = nil
    Net::HTTP.start(@uri.host, @uri.port){|http|
      @res = http.post(@uri.path, query)
    }
    return @res
  end
end
