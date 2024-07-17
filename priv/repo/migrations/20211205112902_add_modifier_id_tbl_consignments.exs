defmodule Rms.Repo.Migrations.AddModifierIdTblConsignments do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :modifier_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :modifier_id
    end
  end
end
