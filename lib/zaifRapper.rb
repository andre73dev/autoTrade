# Copyright (C) 2014 Masaki "monaka" Muranaka
# MIT License
#
# -*- coding: utf-8 -*-
require 'json'
require 'openssl'
require 'net/https'
require 'pp'

module Etwings
  class TradeApi
    attr_reader :result
    attr_reader :response

    def initialize public_key, secret_key
      @public_key = public_key
      @secret_key = secret_key
      @response = nil
      @result = nil
      @nonce = Time.new.to_i
    end

    def post(method, params)
      @nonce += 1
      hmac = OpenSSL::HMAC.new(@secret_key, OpenSSL::Digest::SHA512.new)
      params['nonce'] = @nonce.to_s
      params['method'] = method
      param = params.map { |k,v| "#{k}=#{v}" }.join("&")
      digest = hmac.update(param)

      http = Net::HTTP.new('exchange.etwings.com', 443)
      http.use_ssl = true
      http.set_debug_output(STDERR)
      headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Key' => @public_key,
        'Sign' => digest.to_s }
      path = '/tapi'
      response = http.post(path, URI.escape(param), headers)

      if response.code.to_i == 200
        @result = JSON.parse(response.body)
      else
        @result = nil
      end
      @response = response
      @result
    end
  end

  class PublicApi
    attr_reader :uri
    attr_reader :response
    attr_reader :result
    def initialize(uri)
      @uri = uri
    end
    def get()
      max_retry_count = 5
      url = URI.parse(@uri)
      response = nil
      max_retry_count.times do |retry_count|
        http = Net::HTTP.new(url.host, url.port)
        http.use_ssl = true if (443==url.port)

        http.verify_mode = OpenSSL::SSL::VERIFY_PEER
        http.verify_depth = 5
        response = http.get( url.path )

        case response
        when Net::HTTPSuccess
          break
        when Net::HTTPRedirection
          url = URI.parse(response['Location'])
          next
        else
          break
        end
      end
      if response.code.to_i == 200
        @result = JSON.parse(response.body)
      else
        @result = nil
      end
      @response = response
      @result
    end
  end
end