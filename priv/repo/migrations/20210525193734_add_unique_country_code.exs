defmodule Rms.Repo.Migrations.AddUniqueCountryCode do
  use Ecto.Migration

  def up do
    create unique_index(:tbl_country, [:code], name: :unique_country_code)
  end

  def down do
    drop index(:tbl_country, [:code], name: :unique_country_code)
  end
end
