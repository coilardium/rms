defmodule Rms.Repo.Migrations.AddLoadStatusToCommodity do
  use Ecto.Migration

  def up do
    alter table(:tbl_commodity) do
      add :load_status, :string
    end
  end

  def down do
    alter table(:tbl_commodity) do
      remove :load_status
    end
  end
end
