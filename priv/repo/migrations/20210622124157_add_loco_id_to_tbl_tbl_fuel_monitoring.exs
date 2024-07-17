defmodule Rms.Repo.Migrations.AddLocoIdToTblTblFuelMonitoring do
  use Ecto.Migration

  def up do
    # alter table(:tbl_fuel_monitoring) do
    #   remove :loco_id
    #   add :loco_id, references(:tbl_locomotive_type, column: :id, on_delete: :nothing)
    # end
  end

  def down do
    # alter table(:tbl_fuel_monitoring) do
    #   remove :loco_id
    #   add :loco_id
    # end
  end
end
