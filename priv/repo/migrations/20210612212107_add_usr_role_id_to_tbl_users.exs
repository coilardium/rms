defmodule Rms.Repo.Migrations.AddUsrRoleIdToTblUsers do
  use Ecto.Migration

  def up do
    alter table(:tbl_users) do
      remove :user_role
      add :role_id, references(:tbl_user_role, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_users) do
      remove :role_id
    end
  end
end
