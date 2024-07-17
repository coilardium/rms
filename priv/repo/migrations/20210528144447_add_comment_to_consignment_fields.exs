defmodule Rms.Repo.Migrations.AddCommentToConsignmentFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :wagon_id, references(:tbl_wagon, column: :id)
      add :comment, :text
      add :capacity_tonnes, :decimal, precision: 18, scale: 2
      add :actual_tonnes, :decimal, precision: 18, scale: 2
      add :tariff_tonnage, :decimal, precision: 18, scale: 2
      add :total_containers, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove_if_exists(:wagon_id, references(:tbl_wagon, column: :id))
      remove_if_exists(:comment, :text)
      remove_if_exists(:capacity_tonnes, :decimal)
      remove_if_exists(:actual_tonnes, :decimal)
      remove_if_exists(:tariff_tonnage, :decimal)
      remove_if_exists(:total_containers, :decimal)
    end
  end
end
