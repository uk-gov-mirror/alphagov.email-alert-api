RSpec.describe "Subscribers OIDC", type: :request do
  include TokenHelpers

  let(:path) { "/subscribers/oidc" }

  before { login_with_internal_app }

  describe "requesting a URL" do
    let(:destination) { "/test" }
    let(:params) do
      {
        destination: destination,
      }
    end

    before do
      allow_any_instance_of(OIDCClient).to receive(:auth_uri).and_return("https://www.gov.uk")
    end

    it "returns a 200" do
      get path, params: params
      expect(response.status).to eq(200)
    end

    it "returns a nonce" do
      get path, params: params
      expect(data).to have_key(:nonce)
    end

    it "returns an auth URI" do
      get path, params: params
      expect(data).to have_key(:auth_uri)
    end
  end

  describe "verifying a code" do
    let(:code) { "code" }
    let(:nonce) { "nonce" }
    let(:params) do
      {
        code: code,
        nonce: nonce,
      }
    end

    let(:address) { "test@example.com" }
    let(:sub) { "some-uuid" }
    let(:email_verified) { true }

    let!(:subscriber) { create(:subscriber, address: address) }

    before do
      user_info = double("UserInfo")
      allow(user_info).to receive(:email).and_return(address)
      allow(user_info).to receive(:email_verified).and_return(email_verified)
      allow(user_info).to receive(:sub).and_return(sub)
      allow_any_instance_of(OIDCClient).to receive(:handle_redirect).with(code, nonce).and_return(user_info)
    end

    it "returns a 200" do
      post path, params: params
      expect(response.status).to eq(200)
    end

    it "returns subscriber details" do
      post path, params: params
      expect(data[:subscriber][:id]).to eq(subscriber.id)
    end

    it "returns the OIDC subject" do
      post path, params: params
      expect(data[:user_id]).to eq(sub)
    end

    context "when the user is unverified" do
      let(:email_verified) { false }

      it "doesn't return subscriber details" do
        post path, params: params
        expect(data[:subscriber]).to be_nil
      end
    end

    context "when it's a user we didn't previously know" do
      before { subscriber.delete }

      it "returns a 404" do
        post path, params: params
        expect(response.status).to eq(404)
      end
    end

    context "when we have a deactivated user" do
      before { subscriber.deactivate! }

      it "re-activates the subscriber" do
        expect { post path, params: params }
          .to change { subscriber.reload.activated? }
          .from(false)
          .to(true)
      end
    end
  end
end
