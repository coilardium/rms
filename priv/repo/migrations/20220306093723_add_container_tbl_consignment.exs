defmodule Rms.Repo.Migrations.AddContainerTblConsignment do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :container_no, :string
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :container_no
    end
  end
end
