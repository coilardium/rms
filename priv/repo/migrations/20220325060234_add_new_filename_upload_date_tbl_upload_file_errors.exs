defmodule Rms.Repo.Migrations.AddNewFilenameUploadDateTblUploadFileErrors do
  use Ecto.Migration

  def up do
    alter table(:tbl_upload_file_errors) do
      add :new_filename, :string
      add :upload_date, :date
      add :upload_user_id, references(:tbl_users, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_upload_file_errors) do
      remove :new_filename
      remove :upload_date
      remove :upload_user_id
    end
  end
end
