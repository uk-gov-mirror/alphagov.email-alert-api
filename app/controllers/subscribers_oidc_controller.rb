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
    user_info = oidc.handle_redirect(
      expected_params.require(:code),
      expected_params.require(:nonce),
    )

    if user_info.email_verified
      subscriber = find_subscriber(user_info.email)
      render json: { user_id: user_info.sub, subscriber: subscriber }
    else
      # ideally we'd return a 401 here I think, but gds-api-adapters
      # doesn't look like it exposes the response if an exception is
      # thrown
      render json: { user_id: user_info.sub }
    end
  rescue Rack::OAuth2::Client::Error
    render json: {}, status: :forbidden
  end

private

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
    @oidc ||= OIDCClient.new(
      ENV["OIDC_PROVIDER_URI"],
      ENV["OIDC_CLIENT_ID"],
      ENV["OIDC_CLIENT_SECRET"],
      expected_params[:destination],
    )
  end
end
