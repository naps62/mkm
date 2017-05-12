defmodule MKM do
  alias MKM.Request
  alias MKM.Config

  # the id of Magic the Gathering on MKM's database
  @game_id 1

  def page_size, do: Config.page_size

  def product(mkm_id: id) do
    get("/products/#{id}")
    |> only_key("product")
  end

  def meta_product(mkm_id: id) do
    get("/metaproducts/#{id}")
    |> only_key("metaproduct")
  end

  def meta_products(start: start, max_results: max_results) do
    get("/metaproducts/find?search=&exact=false&idGame=#{@game_id}&start=#{start}&maxResults=#{max_results}")
    |> only_key("metaproduct")
  end

  def expansions do
    get("/games/#{@game_id}/expansions")
    |> only_key("expansion")
  end

  def expansion_singles(expansion_mkm_id: expansion_mkm_id) do
    get("/expansions/#{expansion_mkm_id}/singles")
    |> only_key("single")
  end

  def get(endpoint) do
    case Request.get(endpoint) do
      {:ok, response} -> parse_response(response)
      error -> {:error, "Error while making the request", error}
    end
  end

  defp only_key({:ok, body}, key, default \\ []) do
    case body[key] do
      nil -> {:ok, default}
      result -> {:ok, result}
    end
  end

  defp parse_response(%{status_code: code, body: body})
    when code == 200 or code == 206 do

    {:ok, Poison.decode!(body)}
  end

  defp parse_response(%{status_code: 204}) do
    {:ok, %{}}
  end

  defp parse_response(response = %{status_code: 401}) do
    {:error, "Unauthorized", response}
  end

  defp parse_response(response) do
    {:error, "Don't know how to parse response", response}
  end
end
