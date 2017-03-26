defmodule Hauvahti.User do
  use Hauvahti.Web, :model

  schema "users" do
    field :name, :string
    field :token, :string

    has_many :alert_strategies, Hauvahti.AlertStrategy
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :token])
    |> validate_required([:name, :token])
  end
end
