defmodule MKM.Config do

  def base_url, do: config(:base_url)
  def app_token, do: config(:app_token)
  def app_secret, do: config(:app_secret)
  def page_size, do: config(:page_size)
  def access_token, do: ""
  def access_token_secret, do: ""

  def nonce, do: :crypto.strong_rand_bytes(16) |> Base.url_encode64 |> binary_part(0, 16)
  def timestamp, do: to_string(:os.system_time(:seconds))

  defp config(key) do
    Application.get_env(:mkm, key)
  end
end
