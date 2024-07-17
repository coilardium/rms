defmodule Rms.Repo.Migrations.AddLocoNo do
  use Ecto.Migration

  def up do
    alter table(:tbl_loco_detention) do
      add :loco_no, :string
    end
  end

  def down do
    alter table(:tbl_loco_detention) do
      remove :loco_no
    end
  end
end
