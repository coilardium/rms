defmodule Rms.SystemUtilities.InterchangeFee do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange_fees" do
    field :amount, :decimal
    field :year, :string
    field :status, :string, default: "D"
    field :lease_period, :integer
    field :escalated_period, :integer
    field :effective_date, :date

    belongs_to :partner, Rms.Accounts.RailwayAdministrator, foreign_key: :partner_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :wagon_type, Rms.SystemUtilities.WagonType, foreign_key: :wagon_type_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(interchange_fee, attrs) do
    interchange_fee
    |> cast(attrs, [
      :amount,
      :year,
      :maker_id,
      :checker_id,
      :status,
      :currency_id,
      :partner_id,
      :wagon_type_id,
      :lease_period,
      :effective_date,
      :escalated_period
    ])
    # |> validate_required([:amount, :effective_date, :lease_period])
    |> unique_constraint(:Administrator, name: :unique_interchange_fee, message: " has an existing rate ")
    |> handle_escalated_period
  end

  defp handle_escalated_period(%Ecto.Changeset{valid?: true} = changeset) do

    escalated_period = get_field(changeset, :escalated_period)
    partner_id = get_field(changeset, :partner_id)
    effective_date = get_field(changeset, :effective_date)
    wagon_type_id = get_field(changeset, :wagon_type_id)
    rate = Rms.SystemUtilities.wagon_rate_lookup(effective_date, partner_id, wagon_type_id)

    case rate do
      nil -> changeset

      _ ->
        case Decimal.cmp(escalated_period, (rate.escalated_period || 0)) do
          :gt  -> changeset

          :eq  -> changeset

          _ -> add_error(changeset, :escalated_period,"should be more than #{escalated_period} days")
        end
    end
  end

  defp handle_escalated_period(changeset), do: changeset

end
