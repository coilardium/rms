defmodule Rms.Repo.Migrations.CreateTblDefects do
  use Ecto.Migration

  def change do
    create table(:tbl_defects) do
      add :code, :string
      add :description, :string

      timestamps()
    end

    create unique_index(:tbl_defects, [:description])
  end
end
