defmodule Rms.Repo.Migrations.AddPasswordExpiryDtLoginAttempts do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      add :password_expiry_dt, :date
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :password_expiry_dt
    end
  end
end
