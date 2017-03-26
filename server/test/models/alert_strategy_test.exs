defmodule Hauvahti.AlertStrategyTest do
  use Hauvahti.ModelCase

  alias Hauvahti.AlertStrategy

  @valid_attrs %{type: "threshold"}

  describe "changeset" do
    test "validating changeset with valid type" do
      changeset = AlertStrategy.changeset(%AlertStrategy{}, @valid_attrs)
      assert changeset.valid? == true
    end

    test "validating changeset with invalid type" do
      with attrs = Map.merge(@valid_attrs, %{type: "foobar"}),
           changeset = AlertStrategy.changeset(%AlertStrategy{}, attrs)
      do
        assert changeset.valid? == false
      end
    end
  end
end
