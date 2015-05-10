# -*- coding: utf-8 -*-

# WORK IN PROGRESS


=begin
RMEBuilder - Http
Copyright (C) 2015 Nuki <xaviervdw AT gmail DOT com>
Copyright (C) 2015 Grim <grimimi AT gmail DOT com>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.
This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.
You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
=end

class String
  def to_ws
    result = ""
    (0..self.size).each do |i|
      result += self[i, 1] + "\0" unless self[i] == "\0"
    end
    return result
  end
end

module Http

  # Micro protocol list
  PROTOCOL = {
    21    => :ftp,
    80    => :http,
    443   => :https
  }

  # Exception
  module Exception

    class << self
      def define(name)
        Exception.const_set(name, Class.new(::Exception))
      end
      def malformed_call(message = '')
        raise MalformedCall.new(message)
      end
      def download_failure(message = '')
        raise DownloadFailure.new(message)
      end
      def retreive_error
        sprintf("0x%.8X", GetLastError.call)
      end
      def raise_if(v, e)
        raise e.new(Exception.retreive_error) unless v
      end
    end

    # Local exception
    define :MalformedCall
    define :DownloadFailure
    define :NotConnected
    define :HttpOpenException
    define :HttpConnectException
    define :HttpRequestException
    define :HttpSendQueryException
    define :HttpAddHeaderException
    define :HttpReceptionException
    define :HttpUnavailableQueryException

  end

  # Win32API integration
  module Lib
    GetLastError              = Win32API.new('Kernel32','GetLastError', 'v', 'i')
    Download                  = Win32API.new('urlmon', 'URLDownloadToFile', 'LPPLL', 'L')
    State                     = Win32API.new('wininet','InternetGetConnectedState', 'ii', 'i')
    WinHttpOpen               = Win32API.new('winhttp','WinHttpOpen','pippi','i')
    WinHttpConnect            = Win32API.new('winhttp','WinHttpConnect','ppii','i')
    WinHttpOpenRequest        = Win32API.new('winhttp','WinHttpOpenRequest','pppppii','i')
    WinHttpSendRequest        = Win32API.new('winhttp','WinHttpSendRequest','piipiii','i')
    WinHttpAddRequestHeaders  = Win32API.new('winhttp','WinHttpAddRequestHeaders', 'ppii', 'i')
    WinHttpReceiveResponse    = Win32API.new('winhttp','WinHttpReceiveResponse','pp','i')
    WinHttpQueryDataAvailable = Win32API.new('winhttp','WinHttpQueryDataAvailable', 'pi', 'i')
    WinHttpReadData           = Win32API.new('winhttp','WinHttpReadData','ppip','i')
    WinHttpCloseHandle        = Win32API.new('winhttp','WinHttpCloseHandle', 'p','i')
  end

  # Singleton
  class << self

    def max_query_size
      1024000
    end

    # Retreive Connection state
    def connected?
      Lib::State.call(0, 0) == 1
    end

    # Retreive base name of an uri
    def base_name(url)
      url.split('/')[-1]
    end

    # Download file from url to destination
    # Example : Http.download from:my_url, to:my_target
    def download(hash)
      Exception.malformed_call('Need :from attributes') unless hash[:from]
      raise Exception::NotConnected.new unless connected?
      from = hash[:from].to_s
      to = hash[:to] || base_name(from)
      unless Lib::Download.call(0, from, to, 0, 0).zero?
        Exception.download_failure("#{from} could not be downloaded")
      end
    end

    def open_session
      opened = Lib::WinHttpOpen.call("RPG Maker VX Ace", 0, '', '', 0)
      Exception.raise_if(opened, Exception::HttpOpenException)
      return opened
    end

    def connect(session, prefix, port)
      connection = Lib::WinHttpConnect.call(session, prefix.to_ws, port, 0)
      Exception.raise_if(connection, Exception::HttpConnectException)
      return connection
    end

    def open_request(connection, path, method = 'GET')
      request = Lib::WinHttpOpenRequest.call(
        connection,
        method.to_ws,
        path.to_ws,
        'HTTP/1.1'.to_ws,
        '', 0, 0x00800000
      )
      Exception.raise_if(request, Exception::HttpRequestException)
      return request
    end

    def add_header_information(request, posts)
      if posts.length > 0
        hd      = "Content-Type: application/x-www-form-urlencoded\r\n"
        header  = Lib::WinHttpAddRequestHeaders.call(
          request, hd.to_ws,
          hd.length, 0 )
        Exception.raise_if(header, Exception::HttpAddHeaderException)
        return posts.map {|k, v| "#{k}=#{v}"}.join('&')
      end
      return ""
    end

    def send_request(request, post)
      result = Lib::WinHttpSendRequest.call(
        request, 0, 0,
        post, post.length, post.length, 0
      )
      Exception.raise_if(result, Exception::HttpSendQueryException)
      return result
    end

    def receive_response(request)
      response = Lib::WinHttpReceiveResponse.call(request, nil)
      Exception.raise_if(response, Exception::HttpReceptionException)
      return request
    end

    def query_available?(request)
      return Lib::WinHttpQueryDataAvailable.call(request, 0)
    end

    def read(request)
      buffer = [].pack("x#{max_query_size}")
      output = [].pack('x4')
      Lib::WinHttpReadData.call(request, buffer, max_query_size, output)
      len    = output.unpack('i!')[0]
      return buffer[0, len]
    end

  end

  # Describe a web resource
  class Resource

    attr_accessor :prefix
    attr_accessor :path
    attr_accessor :get_variables
    attr_accessor :post_variables
    attr_accessor :port

    def initialize(hash)
      @prefix           = hash[:prefix]
      @path             = hash[:path] || []
      @port             = hash[:port] || 80
      @post_variables   = hash[:post_variables] || {}
      @get_variables    = hash[:get_variables] || {}
    end

    def clone
      Resource.new(
        prefix: @prefix.dup,
        path: @path.dup,
        port: @port,
        get_variables: @get_variables.dup,
        post_variables: @post_variables.dup,
      )
    end

    def clean
      @post_variables = {}
      @get_variables = {}
    end

    def set_get_variable(name, value)
      @get_variables[name] = value
    end

    def set_post_variable(name, value)
      @post_variables[name] = value
    end

    def add_directory(name)
      @path << name
    end

    alias_method(:<<, :add_directory)

    def base_uri(prefix = '')
      path    = @path.join('/')
      prefix  += '/' unless path == ''
      prefix  += path
      unless @get_variables.empty?
        result    += '?'
        vars      = @get_variables.to_a.map {|k, v| "#{k}=#{v}"}
        prefix    += vars.join('&')
      end
      prefix
    end

    def uri(complete = false)
      uri_str     = ""
      if complete
        protocol  = PROTOCOL[@port] || :http
        uri_str   = "#{protocol}://"
      end
      uri_str     += prefix
      if !PROTOCOL.keys.include?(@port) && complete
        uri_str   += ":#{@port}"
      end
      base_uri(uri_str)
    end

    def to_s
      uri(true)
    end

    def process_query(method = 'GET')
      opened      = Http.open_session
      connection  = Http.connect(opened, @prefix, @port)
      request     = Http.open_request(connection, base_uri, method)
      response    = yield(request) if block_given?
      Lib::WinHttpCloseHandle.call(opened)
      Lib::WinHttpCloseHandle.call(connection)
      Lib::WinHttpCloseHandle.call(request)
      clean
      response
    end

    def query(method = 'GET')
      process_query do |request|
        post_data = ""
        if method == 'POST'
          post_data = Http.add_header_information(request, @post_variables)
        end
        Http.send_request(request, post_data)
        Http.receive_response(request)
        Exception.raise_if(
          Http.query_available?(request),
          Exception::HttpUnavailableQueryException
        )
        return Http.read(request)
      end
    end

    def download(target = nil)
      Http.download from:self, to:target
    end

  end

end
