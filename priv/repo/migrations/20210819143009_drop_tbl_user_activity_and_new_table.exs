defmodule Rms.Repo.Migrations.DropTblUserActivityAndNewTable do
  use Ecto.Migration

  def up do
    drop table(:tbl_user_log)
  end

  def down do
  end
end
