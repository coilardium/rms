defmodule Rms.Repo.Migrations.AddCatgoryTblTransportType do
  use Ecto.Migration

  def up do
    alter table(:tbl_transport_type) do
      add :catgory, :string
    end
  end

  def down do
    alter table(:tbl_transport_type) do
      remove :catgory
    end
  end
end
