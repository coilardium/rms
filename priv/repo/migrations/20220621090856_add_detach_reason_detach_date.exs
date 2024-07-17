defmodule Rms.Repo.Migrations.AddDetachReasonDetachDate do
  use Ecto.Migration

  def up do
    alter table(:tbl_movement) do
      add :detach_reason, :string
      add :detach_date, :date
    end
  end

  def down do
    alter table(:tbl_movement) do
      remove :detach_reason
      remove :detach_date
    end
  end
end
