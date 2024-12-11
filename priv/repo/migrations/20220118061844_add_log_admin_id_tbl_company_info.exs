defmodule Rms.Repo.Migrations.AddLogAdminIdTblCompanyInfo do
  use Ecto.Migration

  def up do
  #   alter table(:tbl_company_info) do
  #     add :log_admin_id, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
  #   end
  end

  # def down do
  #   alter table(:tbl_company_info) do
  #     remove :log_admin_id
  #   end
  # end
end
