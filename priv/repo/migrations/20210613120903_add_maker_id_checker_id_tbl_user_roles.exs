defmodule Rms.Repo.Migrations.AddMakerIdCheckerIdTblUserRoles do
  use Ecto.Migration

  def up do
    alter table(:tbl_user_role) do
      remove :maker_id
      add :maker_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :checker_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_user_role) do
      remove :maker_id
      remove :checker_id
      add :maker_id, :integer
    end
  end
end
