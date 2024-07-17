defmodule Rms.Repo.Migrations.CreateTblUploadFileErrors do
  use Ecto.Migration

  def change do
    create table(:tbl_upload_file_errors) do
      add :col_index, :string
      add :error_msg, :string
      add :filename, :string

      timestamps()
    end
  end
end
