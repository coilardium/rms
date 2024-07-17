defmodule Rms.Repo.Migrations.RenameFieldsInTblWagonTracking do
  use Ecto.Migration

  def up do
    alter table(:tbl_wagon_tracking) do
      remove :hire
      add :on_hire, :string
    end
  end

  def down do
    alter table(:tbl_wagon_tracking) do
      remove :on_hire
    end
  end
end
