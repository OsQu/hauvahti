defmodule Hauvahti.AlertStrategy do
  use Hauvahti.Web, :model

  schema "alert_strategies" do
    field :type, :string
    field :parameters, :map
    field :enabled, :boolean, default: true

    belongs_to :user, Hauvahti.User
  end

  def changeset(alert_strategy, params \\ %{}) do
    alert_strategy
    |> cast(params, [:type, :parameters, :enabled, :user_id])
    |> validate_required([:type]) # TODO: Custom validations for each type?
    |> validate_inclusion(:type, ["threshold"])
    |> assoc_constraint(:user)
  end
end
