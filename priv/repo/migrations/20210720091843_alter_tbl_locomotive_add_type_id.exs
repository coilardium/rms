defmodule Rms.Repo.Migrations.AlterTblLocomotiveAddTypeId do
  use Ecto.Migration

  def up do
    alter table(:tbl_locomotive) do
      remove :type_id
      add :type_id, references(:tbl_locomotive_type, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_locomotive) do
      remove :type_id
      add :type_id, :string
    end
  end
end
