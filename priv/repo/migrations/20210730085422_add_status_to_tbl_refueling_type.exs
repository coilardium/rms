defmodule Rms.Repo.Migrations.AddStatusToTblRefuelingType do
  use Ecto.Migration

  def up do
    alter table(:tbl_refueling_type) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_refueling_type) do
      remove :status
    end
  end
end
