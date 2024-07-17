defmodule Rms.Repo.Migrations.AlterTblConsignmentsAddRouteId do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :route_id, references(:tbl_train_routes, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :route_id
    end
  end
end
