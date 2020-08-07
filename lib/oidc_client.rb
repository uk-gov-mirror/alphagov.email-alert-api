require "openid_connect"

class OidcClient
  attr_reader :client_id,
              :destination,
              :provider_uri

  delegate :authorization_endpoint,
           :token_endpoint,
           :userinfo_endpoint,
           :end_session_endpoint,
           to: :discover

  def initialize(provider_uri, client_id, secret, destination)
    @provider_uri = provider_uri
    @client_id = client_id
    @secret = secret
    @destination = destination
  end

  def auth_uri(nonce)
    client.authorization_uri(
      scope: %i[email test_scope_write],
      state: nonce,
      nonce: nonce,
    )
  end

  def redirect_uri
    Plek.new.website_uri.tap { |u| u.path = URI.parse(destination).path }.to_s
  end

  def handle_redirect(code, nonce)
    client.authorization_code = code
    access_token = client.access_token!
    id_token = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, discover.jwks
    id_token.verify! client_id: client_id, issuer: discover.issuer, nonce: nonce
    {
      access_token: access_token,
      user_info: access_token.userinfo!,
    }
  end

private

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier: client_id,
      secret: @secret,
      redirect_uri: redirect_uri,
      authorization_endpoint: authorization_endpoint,
      token_endpoint: token_endpoint,
      userinfo_endpoint: userinfo_endpoint,
    )
  end

  def discover
    @discover ||= OpenIDConnect::Discovery::Provider::Config.discover! provider_uri
  end
end
