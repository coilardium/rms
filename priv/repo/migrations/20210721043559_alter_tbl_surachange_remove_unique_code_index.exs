defmodule Rms.Repo.Migrations.AlterTblSurachangeRemoveUniqueCodeIndex do
  use Ecto.Migration

  def up do
    drop(index(:tbl_surcharge, [:code], name: :unique_code))
    create(unique_index(:tbl_surcharge, [:code], name: :unique_code, where: "code is not null"))
    create(unique_index(:tbl_surcharge, [:description], name: :unique_description))
  end

  def down do
    drop(index(:tbl_surcharge, [:code], name: :unique_code))
    create(unique_index(:tbl_surcharge, [:code], name: :unique_code))
    drop(unique_index(:tbl_surcharge, [:description], name: :unique_description))
  end
end
