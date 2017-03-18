defmodule Hauvahti.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :token, :string
    end
  end
end
