defmodule Rms.Repo.Migrations.AddInvoiceNoToTblMovement do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :invoice_no, :string
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :invoice_no
    end
  end
end
