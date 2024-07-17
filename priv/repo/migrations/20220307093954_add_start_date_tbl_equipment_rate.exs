defmodule Rms.Repo.Migrations.AddStartDateTblEquipmentRate do
  use Ecto.Migration

  def up do
    alter table(:tbl_equipment_rates) do
      add :start_date, :date
      remove :year
    end
  end

  def down do
    alter table(:tbl_equipment_rates) do
      remove :start_date
      add :year, :string
    end
  end
end
