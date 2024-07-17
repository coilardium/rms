defmodule Rms.Repo.Migrations.ModifyUserIdToTblLocoDriver do
  use Ecto.Migration

  def up do
    alter table(:tbl_loco_driver) do
      remove :user_id
      add :user_id, references(:tbl_users, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_loco_driver) do
      modify :user_id, :string
    end
  end
end
