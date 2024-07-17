defmodule Rms.Repo.Migrations.AddStatusToTblUserRegion do
  use Ecto.Migration

  def up do
    alter table(:tbl_user_region) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_user_region) do
      remove :status
    end
  end
end
