defmodule Rms.Repo.Migrations.CreateTblInterchangeMaterial do
  use Ecto.Migration

  def change do
    create table(:tbl_interchange_material) do
      add :direction, :string
      add :date_sent, :date
      add :date_received, :date
      add :status, :string
      add :equipment_id, references(:tbl_equipments, on_delete: :nothing)
      add :admin_id, references(:tbl_railway_administrator, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_interchange_material, [:equipment_id])
    create index(:tbl_interchange_material, [:admin_id])
    create index(:tbl_interchange_material, [:maker_id])
  end
end
