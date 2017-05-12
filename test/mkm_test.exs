defmodule MKMTest do
  use ExUnit.Case
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  alias MKM

  test "gets expansions" do
    use_cassette "expansions" do
      {:ok, expansions} = MKM.expansions

      assert length(expansions) > 0
    end
  end

  test "gets meta products" do
    use_cassette "meta_products/first_10" do
      {:ok, meta_products} = MKM.meta_products(start: 0, max_results: 10)

      assert length(meta_products) == 10
    end
  end

  test "gets products" do
    use_cassette "products/single" do
      {:ok, data} = MKM.product(mkm_id: 1)

      assert data
    end
  end
end
