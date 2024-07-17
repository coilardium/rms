defmodule Rms.Repo.Migrations.AlterTblCompanyInfoAddUnmatchedAgingPeriod do
  use Ecto.Migration

  def up do
    alter table(:tbl_company_info) do
      add :unmatched_aging_period, :integer
    end
  end

  def down do
    alter table(:tbl_company_info) do
      remove :unmatched_aging_period
    end
  end
end
