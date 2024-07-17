defmodule Rms.Repo.Migrations.AddEscalatedPeriodTblInterchngeFee do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_fees) do
      add :escalated_period, :integer
    end
  end

  def down do
    alter table(:tbl_interchange_fees) do
      remove :escalated_period
    end
  end
end
