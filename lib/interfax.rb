require 'savon'
require 'base64'

class Interfax
  WSDL_URL = "https://ws.interfax.net/dfs.asmx?WSDL"
  def initialize(options = {})
    @username = options[:username] || ENV['INTERFAX_USERNAME']
    @password = options[:password] || ENV['INTERFAX_PASSWORD']
    @raw_response = {}
    @bytes_uploaded = 0
    Gyoku.convert_symbols_to(:camelcase)
  end

  def client
    @client ||= ::Savon::Client.new(WSDL_URL)
  end

  def start_file_upload
    @last_session_id = request :start_file_upload do |response|
      response[:session_id]
    end
  end

  def upload_file_chunk(file_path, options = {})
    chunk_size = options.delete(:chunk_size) || 200000
    session_id = options.delete(:session_id) || @last_session_id || start_file_upload
    @file_path = file_path

    each_chunk(chunk_size) do |chunk, is_last|
      request :upload_file_chunk, {
        :chunk => Base64.encode64(chunk),
        :SessionID => session_id,
        :IsLast => is_last ? 1 : 0
      } do |response, result|
        @bytes_uploaded = result
      end
    end
    return @bytes_uploaded == File.size(@file_path)
  end

  def cancel_file_upload(options = {})
    session_id = options.delete(:session_id) || @last_session_id
    return if session_id.nil?
    request :cancel_file_upload, :session_id => session_id
  end

  def sendfax_ex_2(options = {})
    default_options = {
      :retries_to_perform => 1,
      :page_size => 'A4',
      :page_orientation => 'Portrait',
      :is_high_resolution => false,
      :is_fine_rendering => true,
    }    
    default_options.merge!(
      :file_types => File.extname(@file_path)[1..4].upcase,
      :file_sizes => "#{@bytes_uploaded}/sessionID=#{@last_session_id}"
    ) unless @bytes_uploaded.zero?
    options = default_options.merge(options)
    options[:is_high_resolution] = options[:is_high_resolution] ? 1 : 0 unless options[:is_high_resolution].is_a? Integer
    options[:is_fine_rendering] = options[:is_fine_rendering] ? 1 : 0 unless options[:is_fine_rendering].is_a? Integer
    request :sendfax_ex_2, options
  end

  private
  def request(method_name, options = {}, &block)
    raw_response = client.request :int, method_name, {:body => {:username => @username, :password => @password}.merge(options)}
    return false unless raw_response.success?
    result = raw_response.to_hash["#{method_name}_response".to_sym]["#{method_name}_result".to_sym].to_i
    response = raw_response.to_hash["#{method_name}_response".to_sym]
    return result unless block_given?
    yield response, result
  end

  # reads the given +file+ in chunks set though +chunk_size+ and yields
  # the current chunk and whether it's the last chunk to iterate over.
  def each_chunk(chunk_size)
    File.open(@file_path, "rb") { |f| yield(f.read(chunk_size), f.eof?) until f.eof? }
  end

end