defmodule Rms.Tracking.Demurrage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_demurrage_master" do
    field :arrival_dt, :date
    field :total_days, :integer
    field :total_charge, :decimal
    field :charge_rate, :decimal
    field :comment, :string
    field :date_cleared, :date
    field :date_loaded, :date
    field :date_offloaded, :date
    field :date_placed, :date
    field :dt_placed_over_weekend, :date
    field :sidings, :integer
    field :total, :integer
    field :yard, :integer
    field :commodity_in_id, :id
    field :commodity_out_id, :id
    field :wagon_id, :id
    field :maker_id, :id
    field :currency_id, :id

    timestamps()
  end

  @doc false
  def changeset(demurrage, attrs) do
    demurrage
    |> cast(attrs, [
      :yard,
      :sidings,
      :total_days,
      :total_charge,
      :charge_rate,
      :comment,
      :arrival_dt,
      :date_placed,
      :dt_placed_over_weekend,
      :date_offloaded,
      :date_loaded,
      :date_cleared,
      :commodity_in_id,
      :commodity_out_id,
      :wagon_id,
      :maker_id,
      :currency_id
    ])
    |> validate_required([
      :yard,
      :sidings,
      :total_days,
      :total_charge,
      :charge_rate,
      :arrival_dt,
      :date_placed,
      :dt_placed_over_weekend,
      :date_offloaded,
      :date_cleared,
      :date_cleared,
      :commodity_in_id,
      :commodity_out_id,
      :wagon_id,
      :maker_id,
      :currency_id
    ])
  end
end
