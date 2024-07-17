defmodule Rms.Repo.Migrations.AddAuthStatusToTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :auth_status, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :auth_status
    end
  end
end
