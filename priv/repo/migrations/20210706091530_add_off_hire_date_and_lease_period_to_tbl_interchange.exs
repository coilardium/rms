defmodule Rms.Repo.Migrations.AddOffHireDateAndLeasePeriodToTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :off_hire_date, :date
      add :lease_period, :integer
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :off_hire_date
      remove :lease_period
    end
  end
end
