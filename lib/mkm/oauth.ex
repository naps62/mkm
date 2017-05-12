defmodule MKM.OAuth do
  alias MKM.Config

  def auth_header(method, url) do
    fields = fields(method, url)
    |> Enum.map(fn({key, val}) -> "#{key}=\"#{val}\"" end)
    |> Enum.join(",")

    "OAuth #{fields}"
  end

  def fields(method, url) do
    auth_fields = generate_base_fields()
    realm = realm(url)

    params = auth_fields
    |> Enum.into(parse_url_params(url))


    [
      realm: realm,
      oauth_signature: encrypted_signature(method, realm, params),
    ]
    |> Enum.into(auth_fields)
  end

  def generate_base_fields do
    [
      oauth_consumer_key: Config.app_token,
      oauth_nonce: Config.nonce,
      oauth_signature_method: "HMAC-SHA1",
      oauth_timestamp: Config.timestamp,
      oauth_token: Config.access_token,
      oauth_version: "1.0",
    ]
  end

  def realm(url) do
    Regex.replace(~r/\?.*/, url, "")
  end

  def parse_url_params(url) do
    (URI.parse(url).query || "") |> URI.query_decoder |> Enum.into(%{})
  end

  def encrypted_signature(method, realm, params) do
    signature = signature(method, realm, params)

    :crypto.hmac(:sha, signing_key(), signature)
    |> Base.encode64
  end

  def signature(method, realm, params) do
    [
      to_string(method) |> String.upcase,
      URI.encode(realm, &URI.char_unreserved?/1),
      params_for_signature(params),
    ]
    |> Enum.join("&")
  end

  def signing_key do
    [
      Config.app_secret,
      Config.access_token_secret,
    ]
    |> Enum.join("&")
  end

  def params_for_signature(params) do
    params
    |> Enum.sort_by(fn({key, _val}) -> to_string(key) end)
    |> Enum.map(fn({key, val}) ->
    Enum.join([key, val], "=")
    end)
    |> Enum.join("&")
    |> URI.encode(&URI.char_unreserved?/1)
  end
end
