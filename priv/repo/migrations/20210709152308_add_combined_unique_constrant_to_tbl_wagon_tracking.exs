defmodule Rms.Repo.Migrations.AddCombinedUniqueConstrantToTblWagonTracking do
  use Ecto.Migration

  def up do
    # flush()
    # create unique_index(:tbl_wagon_tracking, [:wagon_id, :current_location_id, :update_date], name: :unique_wagon_tracker)
  end

  def down do
    # drop index(:tbl_wagon_tracking, [:wagon_id, :current_location_id, :update_date], name: :unique_wagon_tracker)
    # flush()
  end
end
