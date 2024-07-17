defmodule Rms.Repo.Migrations.AddUserIdTblUserActivity do
  use Ecto.Migration

  def up do
    alter table(:tbl_user_activity) do
      add :user_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_user_activity) do
      remove :user_id
    end
  end
end
