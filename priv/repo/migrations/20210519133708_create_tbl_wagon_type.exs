defmodule Rms.Repo.Migrations.CreateTblWagonType do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon_type) do
      add :code, :string
      add :description, :string
      add :type, :string
      add :capacity, :string
      add :weight, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_type, [:maker_id])
    create index(:tbl_wagon_type, [:checker_id])
  end
end
