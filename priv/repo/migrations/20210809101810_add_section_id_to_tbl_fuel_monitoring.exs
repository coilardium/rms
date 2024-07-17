defmodule Rms.Repo.Migrations.AddSectionIdToTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :section_id, references(:tbl_section, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :section_id
    end
  end
end
