defmodule Rms.Repo.Migrations.AddLastLoginDtToTblUsers do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      add :last_login_dt, :naive_datetime
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :last_login_dt
    end
  end
end
