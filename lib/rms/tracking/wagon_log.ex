defmodule Rms.Tracking.WagonLog do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]

  schema "tbl_wagon_status_daily_log" do
    field :commulative_loaded, :decimal
    field :count_active, :decimal
    field :curr_loaded, :decimal
    field :date, :string
    field :non_act_count, :decimal
    field :total_wagons, :decimal
    field :conditon_id, :id

    timestamps()
  end

  @doc false
  def changeset(wagon_log, attrs) do
    wagon_log
    |> cast(attrs, [
      :count_active,
      :non_act_count,
      :curr_loaded,
      :commulative_loaded,
      :total_wagons,
      :date,
      :conditon_id
    ])

    # |> validate_required([:count_active, :non_act_count, :curr_loaded, :commulative_loaded, :total_wagons, :date])
  end
end
