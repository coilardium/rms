defmodule Rms.Repo.Migrations.AddAutoPasswordToTblUser do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      add :auto_password, :string
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :auto_password
    end
  end
end
