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
    end

    # Local exception
    define :MalformedCall
    define :DownloadFailure
    define :NotConnected
    
  end

  # Win32API integration
  module Lib
    Download = Win32API.new('urlmon', 'URLDownloadToFile', 'LPPLL', 'L')
    State = Win32API.new('wininet','InternetGetConnectedState', 'ii', 'i')
  end

  # Singleton
  class << self

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
    
  end

  # Describe a web resource
  class Resource

    attr_accessor :prefix
    attr_accessor :path
    attr_accessor :variables
    attr_accessor :port
    
    def initialize(hash)
      @prefix     = hash[:prefix]
      @path       = hash[:path] || []
      @port       = hash[:port] || 80
      @variables  = hash[:variables] || {}
    end

    def clone
      Resource.new(
        prefix: @prefix.dup,
        path: @path.dup,
        port: @port,
        variables: @variables.dup
      )
    end

    def clean
      @variables = {}
    end

    def set_variable(name, value)
      @variables[name] = value
    end

    alias_method(:[]=, :set_variable)
    alias_method(:build_query, :variables=)

    def add_directory(name)
      @path << name
    end

    alias_method(:<<, :add_directory)

    def base_uri(prefix = '')
      path    = @path.join('/')
      prefix  += '/' unless path == ''
      prefix  += path
      unless @variables.empty?
        result    += '?'
        vars      = @variables.to_a.map {|k, v| "#{k}=#{v}"}
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

    def download(target = nil)
      Http.download from:self, to:target
    end

  end
  
end
