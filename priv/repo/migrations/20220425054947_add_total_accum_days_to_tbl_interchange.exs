defmodule Rms.Repo.Migrations.AddTotalAccumDaysToTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :total_accum_days, :integer
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :total_accum_days
    end
  end
end
