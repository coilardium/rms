defmodule Rms.Repo.Migrations.ModifyTarrifLineFields do
  use Ecto.Migration

  def up do
    alter table(:tbl_tariff_line) do
      modify :rsz, :decimal
      modify :nlpi, :decimal
      modify :nll_2005, :decimal
      modify :tfr, :decimal
      modify :tzr, :decimal
      modify :tzr_project, :decimal
      modify :others, :decimal
    end
  end

  def down do
    alter table(:tbl_tariff_line) do
      modify :rsz, :decimal
      modify :nlpi, :decimal
      modify :nll_2005, :decimal
      modify :tfr, :decimal
      modify :tzr, :decimal
      modify :tzr_project, :decimal
      modify :others, :decimal
    end
  end
end
