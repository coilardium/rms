defmodule Rms.Repo.Migrations.AlterTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :fuel_blc_figures, :string
      add :ctc_datestamp, :date
      add :ctc_time, :string
      add :fuel_blc_words, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :fuel_blc
      remove :ctc_datestamp
      remove :ctc_time
      remove :fuel_blc_words
    end
  end
end
