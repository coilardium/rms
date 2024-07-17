defmodule Rms.Repo.Migrations.AddConsignerIdConsigneeTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      remove :consignee
      remove :consigner
      add :consignee_id, references(:tbl_clients, column: :id, on_delete: :nothing)
      add :consigner_id, references(:tbl_clients, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :consignee_id
      remove :consigner_id
      add :consignee, :string
      add :consigner, :string
    end
  end
end
