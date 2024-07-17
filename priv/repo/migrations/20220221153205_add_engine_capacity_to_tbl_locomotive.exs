defmodule Rms.Repo.Migrations.AddEngineCapacityToTblLocomotive do
  use Ecto.Migration

  def up do
    alter table(:tbl_locomotive) do
      add :loco_engine_capacity, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_locomotive) do
      remove :loco_engine_capacity
    end
  end
end
