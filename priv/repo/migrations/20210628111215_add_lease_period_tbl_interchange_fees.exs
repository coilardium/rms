defmodule Rms.Repo.Migrations.AddLeasePeriodTblInterchangeFees do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_fees) do
      add :lease_period, :string
    end
  end

  def down do
    alter table(:tbl_interchange_fees) do
      remove :lease_period
    end
  end
end
