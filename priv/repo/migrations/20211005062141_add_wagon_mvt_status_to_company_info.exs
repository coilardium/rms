defmodule Rms.Repo.Migrations.AddWagonMvtStatusToCompanyInfo do
  use Ecto.Migration

  def up do
    alter table(:tbl_company_info) do
      add :wagon_mvt_status, :integer
    end
  end

  def down do
    alter table(:tbl_company_info) do
      remove :wagon_mvt_status
    end
  end
end
