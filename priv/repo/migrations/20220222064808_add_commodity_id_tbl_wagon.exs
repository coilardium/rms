defmodule Rms.Repo.Migrations.AddCommodityIdTblWagon do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :commodity_id, references(:tbl_commodity, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :commodity_id
    end
  end
end
