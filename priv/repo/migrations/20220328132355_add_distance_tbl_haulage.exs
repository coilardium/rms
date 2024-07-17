defmodule Rms.Repo.Migrations.AddDistanceTblHaulage do
  use Ecto.Migration

  def up do
    alter table(:tbl_haulage) do
      add :distance, :decimal, precision: 18, scale: 2
    end
  end

  def down do
    alter table(:tbl_haulage) do
      remove :distance
    end
  end
end
