defmodule Rms.SystemUtilities.TariffLineRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_tariff_line_rates" do
    field :rate, :decimal
    # field :admin_id, :id
    # field :tariff_id, :id

    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :tariff, Rms.SystemUtilities.TariffLine, foreign_key: :tariff_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(tariff_line_rate, attrs) do
    tariff_line_rate
    |> cast(attrs, [:rate, :tariff_id, :admin_id])
    |> validate_required([:rate, :tariff_id, :admin_id])
  end
end
