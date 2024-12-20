defmodule Rms.Repo.Migrations.AlterTblUserRoleAllRoleStrAsMap do
  use Ecto.Migration

  def up do
    alter table(:tbl_user_role) do
      remove :role_str
      add :role_str, :map
    end
  end

  def down do
    alter table(:tbl_user_role) do
      remove :role_desc
    end
  end
end
