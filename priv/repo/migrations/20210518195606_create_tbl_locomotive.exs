defmodule Rms.Repo.Migrations.CreateTblLocomotive do
  use Ecto.Migration

  def change do
    create table(:tbl_locomotive) do
      add :description, :string
      add :loco_number, :string
      add :model, :string
      add :status, :string
      add :type_id, :string
      add :weight, :float
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_locomotive, [:maker_id])
    create index(:tbl_locomotive, [:checker_id])
  end
end
