defmodule Rms.Repo.Migrations.AddPayeeAdminTblHaulage do
  use Ecto.Migration

  def up do
    alter table(:tbl_haulage) do
      add :payee_admin_id, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_haulage) do
      remove :payee_admin_id
    end
  end
end
