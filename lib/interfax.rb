require 'savon'

class Interfax
  WSDL_URL = "https://ws.interfax.net/dfs.asmx?WSDL"
  def initialize(options = {})
    @username = options[:username] || ENV['INTERFAX_USERNAME']
    @password = options[:password] || ENV['INTERFAX_PASSWORD']
    @raw_response = {}
    Gyoku.convert_symbols_to(:camelcase)
  end

  def client
    @client ||= ::Savon::Client.new(WSDL_URL)
  end

  def start_file_upload
    return true if !@session_id.nil?
    request :start_file_upload do |response|
      @session_id = response[:session_id]
    end
  end

  def cancel_file_upload
    return if @session_id.nil?
    request :cancel_file_upload, { :session_id => @session_id }
  end

  private
  def request(method_name, params = {}, &block)
    if @raw_response[method_name].nil?
      @raw_response[method_name] = client.request :int, method_name, {:body => {:username => @username, :password => @password}.merge(params)}
    end
    return false unless @raw_response[method_name].success?
    result = @raw_response[method_name].to_hash["#{method_name}_response".to_sym]["#{method_name}_result".to_sym].to_i
    response = @raw_response[method_name].to_hash["#{method_name}_response".to_sym]
    yield response if block_given?
    return result >= 0
  end
end