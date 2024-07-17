defmodule Rms.Repo.Migrations.AddSurchargeIdTblDefects do
  use Ecto.Migration

  def up do
    alter table(:tbl_defects) do
      add :surcharge_id, references(:tbl_surcharge, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_defects) do
      remove :surcharge_id
    end
  end
end
