defmodule Rms.Repo.Migrations.AlterTblLomocotivesAddOwnerId do
  use Ecto.Migration

  def up do
    alter table(:tbl_locomotive) do
      add :owner_id, references(:tbl_railway_administrator, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_locomotive) do
      remove :owner_id
    end
  end
end
