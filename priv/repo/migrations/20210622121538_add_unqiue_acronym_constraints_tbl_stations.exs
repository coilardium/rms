defmodule Rms.Repo.Migrations.AddUnqiueAcronymConstraintsTblStations do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_stations, [:acronym], name: :unique_acronym))
  end

  def down do
    drop(index(:tbl_stations, [:acronym], name: :unique_acronym))
  end
end
