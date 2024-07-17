defmodule Rms.Tracking.LocoDetention do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_loco_detention" do
    field :actual_delay, :integer
    field :amount, :decimal
    field :arrival_date, :date
    field :arrival_time, :string
    field :chargeable_delay, :integer
    field :comment, :string
    field :departure_date, :date
    field :departure_time, :string
    field :direction, :string
    field :grace_period, :integer
    field :interchange_date, :date
    field :status, :string
    field :train_no, :string
    field :rate, :decimal
    field :modification_reason, :string
    field :loco_no, :string
    # field :maker_id, :id
    # field :checker_id, :id
    # field :admin_id, :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :locomotive, Rms.Locomotives.Locomotive, foreign_key: :locomotive_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id

    belongs_to :dentention_rate, Rms.SystemUtilities.LocoDetentionRate,
      foreign_key: :dentention_rate_id,
      type: :id

    timestamps()
  end

  @doc false
  def changeset(loco_detention, attrs) do
    loco_detention
    |> cast(attrs, [
      :status,
      :comment,
      :interchange_date,
      :arrival_date,
      :arrival_time,
      :departure_date,
      :departure_time,
      :train_no,
      :direction,
      :chargeable_delay,
      :actual_delay,
      :grace_period,
      :amount,
      :admin_id,
      :maker_id,
      :checker_id,
      :modification_reason,
      :locomotive_id,
      :loco_no,
      :currency_id
    ])
    |> validate_required([
      :status,
      :interchange_date,
      :arrival_date,
      :arrival_time,
      :train_no,
      :loco_no,
      :direction
    ])
    |> does_loco_detention_rate_exist?()
  end

  defp does_loco_detention_rate_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    admin = get_field(changeset, :admin_id)
    date = get_field(changeset, :interchange_date)

    case Rms.SystemUtilities.loco_detention_rate_lookup(date, admin) do
      nil ->
        add_error(
          changeset,
          :Rate,
          " not maintained for Administrator"
        )

      fee ->
        change(changeset,
          dentention_rate_id: fee.id,
          rate: fee.rate,
          currency_id: fee.currency_id,
          grace_period: fee.delay_charge
        )
    end
  end

  defp does_loco_detention_rate_exist?(changeset), do: changeset
end
