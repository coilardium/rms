defmodule Rms.Repo.Migrations.AddTotalAccumDays do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :total_accum_days, :integer
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :total_accum_days
    end
  end
end
