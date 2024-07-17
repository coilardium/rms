defmodule Rms.Tracking.Haulage do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_haulage" do
    field :amount, :decimal
    field :date, :date
    field :loco_no, :string
    field :status, :string
    field :rate, :decimal
    field :distance, :decimal
    field :direction, :string
    field :total_wagons, :integer
    field :train_no, :string
    field :wagon_grand_total, :integer
    field :comment, :string
    field :observation, :string
    field :wagon_ratio, :string
    field :rate_type, :string
    field :modification_reason, :string
    # field :admin_id, :id
    # field :rate_id, :id
    belongs_to :payee_admin, Rms.Accounts.RailwayAdministrator, foreign_key: :payee_admin_id, type: :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :haulage_rate, Rms.SystemUtilities.HaulageRate, foreign_key: :rate_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(haulage, attrs) do
    haulage
    |> cast(attrs, [
      :date,
      :train_no,
      :loco_no,
      :total_wagons,
      :wagon_grand_total,
      :amount,
      :direction,
      :rate,
      :admin_id,
      :currency_id,
      :maker_id,
      :checker_id,
      :wagon_ratio,
      :comment,
      :observation,
      :rate_id,
      :payee_admin_id,
      :modification_reason,
      :distance
    ])
    |> validate_required([
      :date,
      :train_no,
      :loco_no,
      :direction,
      :total_wagons,
      :admin_id,
      :wagon_grand_total
    ])
    |> does_haulage_fee_exist?()
  end

  defp does_haulage_fee_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    admin = get_field(changeset, :admin_id)
    date = to_string(get_field(changeset, :date))
    direction = get_field(changeset, :direction)

    case Rms.SystemUtilities.haulage_fee_lookup(admin, direction, date) do
      nil ->
        add_error(
          changeset,
          :Hauladge,
          "rate not maintained for Administrator"
        )

      fee ->
        haulage_rate_type(changeset, fee)
    end
  end

  defp does_haulage_fee_exist?(changeset), do: changeset

  defp haulage_rate_type(changeset, %{rate_type: "RATIO"} = fee) do
    wagon_grand_total = get_field(changeset, :wagon_grand_total)
    total_wagons = to_string(get_field(changeset, :total_wagons))
    ratio = Decimal.div(total_wagons, wagon_grand_total)
    amount = Decimal.mult(ratio, fee.rate)
    wagon_ratio = "#{total_wagons}/#{wagon_grand_total}"

    change(changeset,
      rate_id: fee.id,
      rate: fee.rate,
      amount: amount,
      currency_id: fee.currency_id,
      rate_type: fee.rate_type,
      wagon_ratio: wagon_ratio
    )
  end

  defp haulage_rate_type(changeset, fee) do
    amount = Decimal.mult(fee.distance, fee.rate)

    change(changeset,
      rate_id: fee.id,
      rate: fee.rate,
      amount: amount,
      currency_id: fee.currency_id,
      rate_type: fee.rate_type,
      wagon_ratio: "1",
      distance: fee.distance
    )
  end
end
