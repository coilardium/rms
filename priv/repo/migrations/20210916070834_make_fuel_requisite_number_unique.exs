defmodule Rms.Repo.Migrations.MakeFuelRequisiteNumberUnique do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_fuel_monitoring, [:requisition_no], name: :unique_requisition_no))
  end

  def down do
    drop(index(:tbl_fuel_monitoring, [:requisition_no], name: :unique_requisition_no))
  end
end
