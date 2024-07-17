defmodule Rms.Repo.Migrations.AlterDaysAtToIntergerTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      remove :days_at
      add :days_at, :integer
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :days_at
      add :days_at, :decimal
    end
  end
end
