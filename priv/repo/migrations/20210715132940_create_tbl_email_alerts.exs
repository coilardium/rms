defmodule Rms.Repo.Migrations.CreateTblEmailAlerts do
  use Ecto.Migration

  def change do
    create table(:tbl_email_alerts) do
      add :type, :string
      add :email, :string
      add :status, :string

      timestamps()
    end
  end
end
