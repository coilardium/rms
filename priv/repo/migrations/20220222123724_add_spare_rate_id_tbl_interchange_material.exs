defmodule Rms.Repo.Migrations.AddSpareRateIdTblInterchangeMaterial do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_material) do
      add :spare_rate_id, references(:tbl_spare_fees, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_interchange_material) do
      remove :spare_rate_id
    end
  end
end
