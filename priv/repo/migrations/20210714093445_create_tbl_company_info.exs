defmodule Rms.Repo.Migrations.CreateTblCompanyInfo do
  use Ecto.Migration

  def change do
    create table(:tbl_company_info) do
      add :company_name, :string
      add :company_address, :string
      add :company_email, :string
      add :vat, :decimal, precision: 18, scale: 2
      add :password_expiry_days, :integer
      add :login_attempts, :integer
      add :status, :string
      add :prefered_ccy_id, references(:tbl_currency, on_delete: :nothing)
      add :current_railway_admin, references(:tbl_railway_administrator, on_delete: :nothing)
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_company_info, [:prefered_ccy_id])
    create index(:tbl_company_info, [:current_railway_admin])
    create index(:tbl_company_info, [:maker_id])
    create index(:tbl_company_info, [:checker_id])
  end
end
