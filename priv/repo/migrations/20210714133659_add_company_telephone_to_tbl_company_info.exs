defmodule Rms.Repo.Migrations.AddCompanyTelephoneToTblCompanyInfo do
  use Ecto.Migration

  def up do
    alter table(:tbl_company_info) do
      add :company_telephone, :string
    end
  end

  def down do
    alter table(:tbl_company_info) do
      remove :company_telephone
    end
  end
end
