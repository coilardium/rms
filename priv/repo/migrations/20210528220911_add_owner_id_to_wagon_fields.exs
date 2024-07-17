defmodule Rms.Repo.Migrations.AddOwnerIdToWagonFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon) do
      add :owner_id, references(:tbl_railway_administrator, column: :id, on_delete: :nilify_all)
    end
  end

  def down do
    alter table(:tbl_wagon) do
      remove :owner_id
    end
  end
end
