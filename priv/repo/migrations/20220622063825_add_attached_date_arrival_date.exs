defmodule Rms.Repo.Migrations.AddAttachedDateArrivalDate do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :attached_date, :date
      add :arrival_date, :date
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :attached_date
      remove :arrival_date
    end
  end
end
