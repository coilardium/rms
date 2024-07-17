defmodule Rms.Repo.Migrations.AddUserIdTblFileuploadErrors do
  use Ecto.Migration

  def up do
    alter table(:tbl_upload_file_errors) do
      add :user_id, references(:tbl_users, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_upload_file_errors) do
      remove :user_id
    end
  end
end
