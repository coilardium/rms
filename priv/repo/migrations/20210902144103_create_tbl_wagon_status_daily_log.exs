defmodule Rms.Repo.Migrations.CreateTblWagonStatusDailyLog do
  use Ecto.Migration

  def change do
    create table(:tbl_wagon_status_daily_log) do
      add :count_active, :decimal
      add :non_act_count, :decimal
      add :curr_loaded, :decimal
      add :commulative_loaded, :decimal
      add :total_wagons, :decimal
      add :date, :string
      add :conditon_id, references(:tbl_condition, on_delete: :nothing)

      timestamps()
    end

    create index(:tbl_wagon_status_daily_log, [:conditon_id])
  end
end
