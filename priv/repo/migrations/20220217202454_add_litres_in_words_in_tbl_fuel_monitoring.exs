defmodule Rms.Repo.Migrations.AddLitresInWordsInTblFuelMonitoring do
  use Ecto.Migration

  def up do
    alter table(:tbl_fuel_monitoring) do
      add :litres_in_words, :string
    end
  end

  def down do
    alter table(:tbl_fuel_monitoring) do
      remove :litres_in_words
    end
  end
end
