defmodule Rms.Repo.Migrations.AddTblWagonStatusMissigTable do
  use Ecto.Migration

  def up do
    drop_if_exists table("tbl_wagon_status")

    flush()

    create table(:tbl_wagon_status) do
      add :code, :string
      add :description, :string
      add :rec_status, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nilify_all)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_status, [:maker_id])
    create index(:tbl_wagon_status, [:checker_id])
  end

  def down do
    drop_if_exists table("tbl_wagon_status")

    flush()

    create table(:tbl_wagon_status) do
      add :code, :string
      add :description, :string
      add :rec_status, :string
      add :status, :string
      add :maker_id, references(:tbl_users, on_delete: :nilify_all)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_status, [:maker_id])
    create index(:tbl_wagon_status, [:checker_id])
  end
end
