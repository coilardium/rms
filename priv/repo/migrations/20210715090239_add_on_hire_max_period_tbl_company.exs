defmodule Rms.Repo.Migrations.AddOnHireMaxPeriodTblCompany do
  use Ecto.Migration

  def up do
    alter table(:tbl_company_info) do
      add :on_hire_max_period, :integer
    end
  end

  def down do
    alter table(:tbl_company_info) do
      remove :on_hire_max_period
    end
  end
end
