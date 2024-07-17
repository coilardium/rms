defmodule Rms.Repo.Migrations.AddStatusToMovementFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :status, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :status
    end
  end
end
