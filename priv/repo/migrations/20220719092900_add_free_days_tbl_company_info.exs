defmodule Rms.Repo.Migrations.AddFreeDaysTblCompanyInfo do
  use Ecto.Migration

  def up do
    alter table(:tbl_company_info) do
      add :free_days, :integer
    end
  end

  def down do
    alter table(:tbl_company_info) do
      remove :free_days
    end
  end
end
