defmodule MKM.OAuthTest do
  use ExUnit.Case

  alias MKM

  import Mock

  def mocks do
    [
      base_url: fn() -> "https://www.mkmapi.eu/ws/v1.1" end,
      app_token: fn() -> "bfaD9xOU0SXBhtBP" end,
      app_secret: fn() -> "pChvrpp6AEOEwxBIIUBOvWcRG3X9xL4Y" end,
      access_token: fn() -> "lBY1xptUJ7ZJSK01x4fNwzw8kAe5b10Q" end,
      access_token_secret: fn() -> "hc1wJAOX02pGGJK2uAv1ZOiwS7I9Tpoe" end,
      nonce: fn() -> "53eb1f44909d6" end,
      timestamp: fn() -> "1407917892" end,
    ]
  end

  @request_url "https://www.mkmapi.eu/ws/v1.1/account"
  @signature "GET&https%3A%2F%2Fwww.mkmapi.eu%2Fws%2Fv1.1%2Faccount&oauth_consumer_key%3DbfaD9xOU0SXBhtBP%26oauth_nonce%3D53eb1f44909d6%26oauth_signature_method%3DHMAC-SHA1%26oauth_timestamp%3D1407917892%26oauth_token%3DlBY1xptUJ7ZJSK01x4fNwzw8kAe5b10Q%26oauth_version%3D1.0"
  @signing_key "pChvrpp6AEOEwxBIIUBOvWcRG3X9xL4Y&hc1wJAOX02pGGJK2uAv1ZOiwS7I9Tpoe"
  @encrypted_signature "DLGHHYV9OsbB/ARf73psEYaNWkI="

  test "realm corresponds to the full url without arguments" do
    url = "http://www.google.pt/"

    assert MKM.OAuth.realm(url) == url
    assert MKM.OAuth.realm(url <> "?a=1") == url
  end

  test "params_for_signature with auth_fields" do
    fields = %{
      b: "1",
      a: " ",
    }

    result = MKM.OAuth.params_for_signature(fields)

    assert result == "a%3D%20%26b%3D1"
  end

  test_with_mock "signature matches MKM's docs example", MKM.Config, mocks() do
    # https://www.mkmapi.eu/ws/documentation/API:Auth_OAuthHeader
    base_auth_fields = MKM.OAuth.generate_base_fields

    signature = MKM.OAuth.signature(:get, @request_url, base_auth_fields)

    assert signature == @signature
  end

  test_with_mock "signing_key", MKM.Config, mocks() do
    assert MKM.OAuth.signing_key == @signing_key
  end

  test_with_mock "oauth_signature", MKM.Config, mocks() do
    result = MKM.OAuth.fields(:get, @request_url)

    assert result[:oauth_signature] == @encrypted_signature
  end
end
