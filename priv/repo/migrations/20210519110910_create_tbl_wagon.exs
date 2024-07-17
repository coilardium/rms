defmodule Rms.Repo.Migrations.CreateTblWagon do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon) do
      add :code, :string
      add :description, :string
      add :wagon_type, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon, [:maker_id])
    create index(:tbl_wagon, [:checker_id])
  end
end
