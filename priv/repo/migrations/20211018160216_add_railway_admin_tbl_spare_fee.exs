defmodule Rms.Repo.Migrations.AddRailwayAdminTblSpareFee do
  use Ecto.Migration

  def up do
    alter table(:tbl_spare_fees) do
      add :railway_admin, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_spare_fees) do
      remove :railway_admin
    end
  end
end
