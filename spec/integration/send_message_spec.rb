RSpec.describe "Sending a message", type: :request do
  let(:valid_request_params) do
    {
      title: "My title",
      body: "My body",
      sender_message_id: SecureRandom.uuid,
      criteria_rules: [
        {
          type: "tag",
          key: "brexit_checker_criteria",
          value: "eu-national"
        },
      ]
    }
  end

  context "with authentication and authorisation" do
    before do
      login_with_internal_app
      post "/messages",
           params: valid_request_params.to_json,
           headers: JSON_HEADERS
    end

    it "creates a Message" do
      expect(Message.count).to eq(1)
    end
  end

  context "when a duplicate message exists" do
    before do
      create(:message, sender_message_id: valid_request_params[:sender_message_id])
    end

    it "returns a 409" do
      post "/messages",
           params: valid_request_params.to_json,
           headers: JSON_HEADERS
      expect(response.status).to eq(409)
    end
  end

  context "without authentication" do
    it "returns 401" do
      without_login do
        post "/messages", params: {}.to_json, headers: {}
        expect(response.status).to eq(401)
      end
    end
  end

  context "without authorisation" do
    it "returns 403" do
      login_with_signin
      post "/messages", params: {}.to_json, headers: {}

      expect(response.status).to eq(403)
    end
  end
end
