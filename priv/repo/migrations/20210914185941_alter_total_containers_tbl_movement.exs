defmodule Rms.Repo.Migrations.AlterTotalContainersTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      remove :total_containers
      add :total_containers, :string
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :total_containers
      add :total_containers, :decimal, precision: 18, scale: 2
    end
  end
end
