defmodule Rms.Repo.Migrations.AddMakerIdCheckerIdStatusTblEquipment do
  use Ecto.Migration

  def up do
    alter table(:tbl_equipments) do
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_equipments) do
      remove :maker_id
      remove :checker_id
      remove :status, :string
    end
  end
end
