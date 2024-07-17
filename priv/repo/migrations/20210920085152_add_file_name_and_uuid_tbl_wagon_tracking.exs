defmodule Rms.Repo.Migrations.AddFileNameAndUuidTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      add :file_name, :string
      add :uuid, :string
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :file_name
      remove :uuid
    end
  end
end
