defmodule Rms.Repo.Migrations.AddRateToTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :rate, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :rate
    end
  end
end
