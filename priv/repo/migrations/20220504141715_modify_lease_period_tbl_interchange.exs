defmodule Rms.Repo.Migrations.ModifyLeasePeriodTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_fees) do
      modify :lease_period, :integer, null: true, from: :string
    end
  end

  def up do
    alter table(:tbl_interchange_fees) do
      modify :lease_period, :string, null: true, from: :integer
    end
  end
end
