# frozen_string_literal: true

require "test_helper"

class CentralOAuthClientTest < ActiveSupport::TestCase
  Response = Struct.new(:code, :body)
  Http = Struct.new(:response) do
    def request(_request)
      response
    end
  end

  test "classifies only the exact invalid grant response without retaining upstream detail" do
    error = assert_raises(Auth::CentralOAuthClient::RequestError) do
      client.send(:parse_response!, Response.new("400", '{"error":"invalid_grant","detail":"provider-secret"}'))
    end

    assert error.invalid_grant?
    assert_equal "invalid_grant", error.code
    assert_equal "Central auth request failed", error.message
    refute_includes error.message, "provider-secret"
  end

  test "keeps arbitrary error codes and malformed JSON generic and redacted" do
    error = assert_raises(Auth::CentralOAuthClient::RequestError) do
      client.send(:parse_response!, Response.new("400", '{"error":"provider_failure","detail":"raw-upstream-detail"}'))
    end
    refute error.invalid_grant?
    assert_nil error.code
    assert_equal "Central auth request failed", error.message
    refute_includes error.message, "raw-upstream-detail"

    malformed = assert_raises(Auth::CentralOAuthClient::RequestError) do
      client.send(:parse_response!, Response.new("502", "{not-json provider-secret"))
    end
    refute malformed.invalid_grant?
    assert_nil malformed.code
    assert_equal "Central auth request failed", malformed.message
    refute_includes malformed.message, "provider-secret"
  end

  test "preserves a parsed invalid grant through the request boundary" do
    http = Http.new(Response.new("400", '{"error":"invalid_grant","detail":"provider-secret"}'))

    error = Net::HTTP.stub(:start, ->(*_arguments, &block) { block.call(http) }) do
      assert_raises(Auth::CentralOAuthClient::RequestError) do
        client.exchange(params: { code: "one-time-code" }, tenant_slug: "native-temple")
      end
    end

    assert error.invalid_grant?
    assert_equal "invalid_grant", error.code
    refute_includes error.message, "provider-secret"
  end

  private

  def client
    Auth::CentralOAuthClient.new(base_url: "https://auth.example.test", client_id: "client", client_secret: "secret")
  end
end
