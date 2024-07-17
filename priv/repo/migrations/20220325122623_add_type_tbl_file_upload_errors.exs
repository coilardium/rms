defmodule Rms.Repo.Migrations.AddTypeTblFileUploadErrors do
  use Ecto.Migration

  def up do
    alter table(:tbl_upload_file_errors) do
      add :type, :string
    end
  end

  def down do
    alter table(:tbl_upload_file_errors) do
      remove :type
    end
  end
end
