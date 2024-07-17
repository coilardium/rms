defmodule Rms.Repo.Migrations.AddInvoiceAmountCurrencyInvoiceDateTerm do
  use Ecto.Migration

  def up do
    alter table(:tbl_consignments) do
      add :invoice_date, :date
      add :invoice_amount, :decimal, precision: 18, scale: 2
      add :invoice_term, :string
      add :invoice_currency_id, references(:tbl_currency, column: :id, on_delete: :nothing)
    end
  end

  def down do
    alter table(:tbl_consignments) do
      remove :invoice_date
      remove :invoice_amount
      remove :invoice_currency_id
      remove :invoice_term
    end
  end
end
