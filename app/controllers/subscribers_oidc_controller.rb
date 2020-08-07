require "oidc_client"

class SubscribersOidcController < ApplicationController
  before_action :validate_params

  def get
    nonce = SecureRandom.hex(16)
    render json: {
      nonce: nonce,
      auth_uri: oidc.auth_uri(nonce),
    }
  end

  def verify
    response = oidc.handle_redirect(
      expected_params.require(:code),
      expected_params.require(:nonce),
    )

    bits = update_test_attribute(response[:access_token])

    if response[:user_info].email_verified
      subscriber = find_subscriber(response[:user_info].email)
      render json: { user_id: response[:user_info].sub, subscriber: subscriber, bits: bits }
    else
      # ideally we'd return a 401 here I think, but gds-api-adapters
      # doesn't look like it exposes the response if an exception is
      # thrown
      render json: { user_id: response[:user_info].sub, bits: bits }
    end
  rescue Rack::OAuth2::Client::Error
    render json: {}, status: :forbidden
  end

private

  def update_test_attribute(access_token)
    uri = URI.parse(oidc.userinfo_endpoint).tap do |uri|
      uri.path = "/v1/attributes/test"
      uri.to_s
    end

    response = access_token.get uri
    case response.status
    when 200
      body = JSON.parse(response.body).symbolize_keys
      old = body[:claim_value].to_i
      new = old * 2
      response2 = access_token.put uri, body: { value: new }
      raise "unexpected PUT http status: #{response2.status}" unless response2.status == 200
      [old, new]
    when 404
      response2 = access_token.put uri, body: { value: 1 }
      raise "unexpected PUT http status: #{response2.status}" unless response2.status == 200
      [nil, 1]
    else
      raise "unexpected GET http status: #{response.status}"
    end
  end

  def find_subscriber(address)
    Subscriber.find_by_address!(address).tap do |subscriber|
      subscriber.activate! if subscriber.deactivated?
    end
  end

  def expected_params
    params.permit(:address, :destination, :nonce, :code)
  end

  def validate_params
    ParamsValidator.new(expected_params).validate!
  end

  class ParamsValidator < OpenStruct
    include ActiveModel::Validations

    validates :destination, presence: true, allow_blank: true
    validates :destination, root_relative_url: true, allow_blank: true

    validates :nonce, presence: true, allow_blank: true
    validates :code, presence: true, allow_blank: true
  end

  def oidc
    @oidc ||= OidcClient.new(
      ENV["OIDC_PROVIDER_URI"],
      ENV["OIDC_CLIENT_ID"],
      ENV["OIDC_CLIENT_SECRET"],
      expected_params[:destination],
    )
  end
end
