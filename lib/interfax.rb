require 'savon'
require 'base64'

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
    @session_id ||= request :start_file_upload do |response|
      return @session_id = response[:session_id]
    end
  end

  def upload_file_chunk(file_path, options = {})
    chunk_size = options.delete(:chunk_size) || 200000
    @session_id ||= start_file_upload

    bytes_uploaded = 0
    each_chunk(file_path, chunk_size) do |chunk, is_last|
      request :upload_file_chunk, {
        :chunk => Base64.encode64(chunk),
        :session_ID => @session_id,
        :is_last => is_last ? 1 : 0
      } do |response, result|
        bytes_uploaded = result.to_i
      end
    end
    return bytes_uploaded == File.size(file_path)
  end

  def cancel_file_upload
    return if @session_id.nil?
    request :cancel_file_upload, { :session_id => @session_id }
  end

  private
  def request(method_name, params = {}, &block)
    raw_response = client.request :int, method_name, {:body => {:username => @username, :password => @password}.merge(params)}
    return false unless raw_response.success?
    result = raw_response.to_hash["#{method_name}_response".to_sym]["#{method_name}_result".to_sym].to_i
    response = raw_response.to_hash["#{method_name}_response".to_sym]
    yield response, result if block_given?
    return result >= 0
  end

  # reads the given +file+ in chunks set though +chunk_size+ and yields
  # the current chunk and whether it's the last chunk to iterate over.
  def each_chunk(file_path, chunk_size)
    File.open(file_path, "rb") { |f| yield(f.read(chunk_size), f.eof?) until f.eof? }
  end

end