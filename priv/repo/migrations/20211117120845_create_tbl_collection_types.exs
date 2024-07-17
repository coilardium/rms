defmodule Rms.Repo.Migrations.CreateTblCollectionTypes do
  use Ecto.Migration

  def change do
    create table(:tbl_collection_types) do
      add :description, :string
      add :code, :string

      timestamps()
    end

    create unique_index(:tbl_collection_types, [:description])
  end
end
