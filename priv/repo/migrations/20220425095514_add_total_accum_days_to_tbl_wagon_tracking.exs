defmodule Rms.Repo.Migrations.AddTotalAccumDaysToTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :total_accum_days, :integer
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :total_accum_days
    end
  end
end
