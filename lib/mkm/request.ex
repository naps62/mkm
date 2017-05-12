defmodule MKM.Request do
  use HTTPoison.Base

  alias MKM.Config
  alias MKM.OAuth

  def process_url(url) do
    Config.base_url <> url
  end

  def request(method, url, body \\ "", _headers \\ [], options \\ []) do
    url = process_url(url)
    headers = request_headers(method, url)

    HTTPoison.Base.request(__MODULE__, method, url, body, headers, options, &process_status_code/1, &process_headers/1, &process_response_body/1)
  end

  def request_headers(method, full_url) do
    [authorization: OAuth.auth_header(method, full_url)]
  end
end
