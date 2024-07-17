defmodule Rms.Repo.Migrations.AddTotalTblConsignment do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :total, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :total
    end
  end
end
