defmodule Rms.Repo.Migrations.CreateTblTariffLine do
  use Ecto.Migration

  def change do
    create table(:tbl_tariff_line) do
      add :origin, :string
      add :destination, :string
      add :client, :string
      add :commodity, :string
      add :payment_type, :string
      add :currency, :string
      add :active_from, :string
      add :surcharge, :string
      add :rsz, :decimal
      add :nlpi, :decimal
      add :nll_2005, :decimal
      add :tfr, :decimal
      add :tzr, :decimal
      add :tzr_project, :decimal
      add :others, :decimal
      add :total, :float
      add :maker_id, references(:tbl_users, on_delete: :nothing)
      add :checker_id, references(:tbl_users, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_tariff_line, [:maker_id])
    create index(:tbl_tariff_line, [:checker_id])
  end
end
