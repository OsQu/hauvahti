defmodule Hauvahti.Repo.Migrations.AddAlertStrategiesTable do
  use Ecto.Migration

  def change do
    create table(:alert_strategies) do
      add :type, :string
      add :parameters, :json
      add :enabled, :boolean
      add :user_id, references(:users)
    end
  end
end
