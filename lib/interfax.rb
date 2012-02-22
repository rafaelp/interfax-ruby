require 'savon'

class Interfax
  WSDL_URL = "https://ws.interfax.net/dfs.asmx?WSDL"
  def initialize(options = {})
    @username = options[:username]
    @password = options[:password]
  end

  def client
    @client ||= ::Savon::Client.new(WSDL_URL)
  end
end