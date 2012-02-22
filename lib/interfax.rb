require 'savon'

class Interfax
  WSDL_URL = "https://ws.interfax.net/dfs.asmx?WSDL"
  def initialize(options = {})
    @username = options[:username] || ENV['INTERFAX_USERNAME']
    @password = options[:password] || ENV['INTERFAX_PASSWORD']
    Gyoku.convert_symbols_to(:camelcase)
  end

  def client
    @client ||= ::Savon::Client.new(WSDL_URL)
  end

  def start_file_upload
    return true unless @session_id.nil?
    response = request :start_file_upload
    return false unless response.success?
    result = response.to_hash[:start_file_upload_response][:start_file_upload_result].to_i
    if result >= 0
      @session_id = response.to_hash[:start_file_upload_response][:session_id]
    end
    return !@session_id.nil?
  end

  private
  def request(method_name, params = {})
    client.request :int, method_name, {:body => {:username => @username, :password => @password}.merge(params)}
  end
end