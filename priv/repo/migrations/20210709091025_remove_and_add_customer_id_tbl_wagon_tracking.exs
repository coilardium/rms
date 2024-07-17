defmodule Rms.Repo.Migrations.RemoveAndAddCustomerIdTblWagonTracking do
  use Ecto.Migration

  def up do
    drop table(:tbl_wagon_tracking)
  end

  def down do
  end
end
