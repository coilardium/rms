defmodule Rms.Repo.Migrations.AddStatusToTblDistance do
  use Ecto.Migration

  def up do
    alter table(:tbl_distance) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_distance) do
      remove :status
    end
  end
end
