defmodule Rms.Repo.Migrations.AddUnqiueCodeConstraintsTblPaymentType do
  use Ecto.Migration

  def up do
    create(unique_index(:tbl_transport_type, [:code], name: :unique_code))
  end

  def down do
    drop(index(:tbl_transport_type, [:code], name: :unique_code))
  end
end
