defmodule MKM.RequestTest do
  use ExUnit.Case

  test "prepends the base_url" do
    processed_url = MKM.Request.process_url("/path")

    assert processed_url == "https://sandbox.mkmapi.eu/ws/v2.0/output.json/path"
  end
end
