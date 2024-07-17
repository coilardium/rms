defmodule Rms.MovementExceptions.MovementException do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]

  schema "tbl_mvt_exceptions" do
    field :axles, :decimal
    field :capture_date, :date
    field :derailment, :decimal
    field :empty_wagons, :decimal
    field :light_engines, :decimal
    field :status, :string, default: "D"
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(movement_exception, attrs) do
    movement_exception
    |> cast(attrs, [
      :capture_date,
      :derailment,
      :axles,
      :light_engines,
      :empty_wagons,
      :status,
      :maker_id,
      :checker_id
    ])
    |> validate_required([
      :capture_date,
      :derailment,
      :axles,
      :light_engines,
      :empty_wagons,
      :status
    ])
  end
end
