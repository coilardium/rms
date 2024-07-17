defmodule Rms.Repo.Migrations.CreateTblSpares do
  use Ecto.Migration

  def change do
    create table(:tbl_spares) do
      add :code, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:tbl_spares, [:description])
  end
end
