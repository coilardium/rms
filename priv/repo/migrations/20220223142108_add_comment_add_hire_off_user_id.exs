defmodule Rms.Repo.Migrations.AddCommentAddHireOffUserId do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange_auxiliary) do
      add :hire_off_user_id, references(:tbl_users, column: :id, on_delete: :nothing)
      add :comment, :text
    end
  end

  def down do
    alter table(:tbl_interchange_auxiliary) do
      remove :hire_off_user_id
      remove :comment, :text
    end
  end
end
