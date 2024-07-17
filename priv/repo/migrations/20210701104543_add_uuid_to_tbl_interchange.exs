defmodule Rms.Repo.Migrations.AddUuidToTblInterchange do
  use Ecto.Migration

  def up do
    alter table(:tbl_interchange) do
      add :uuid, :string
    end
  end

  def down do
    alter table(:tbl_interchange) do
      remove :uuid
    end
  end
end
