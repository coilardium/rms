defmodule Rms.Repo.Migrations.AddNewFieldsToTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :month, :string
      add :year, :string
      add :days_at, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :month
      remove :year
      remove :days_at
    end
  end
end
