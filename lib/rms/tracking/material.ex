defmodule Rms.Tracking.Material do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_interchange_material" do
    field :date_received, :date
    field :date_sent, :date
    field :direction, :string
    field :status, :string
    field :fin_year, :string
    field :comment, :string
    field :amount, :decimal
    # field :equipment_id, :id
    # field :admin_id, :id
    # field :maker_id, :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :equipment, Rms.SystemUtilities.Equipment, foreign_key: :equipment_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id

    belongs_to :equipment_rate, Rms.SystemUtilities.EquipmentRate,
      foreign_key: :equipment_rate_id,
      type: :id

    belongs_to :spare, Rms.SystemUtilities.Spare, foreign_key: :spare_id, type: :id
    belongs_to :spare_rate, Rms.SystemUtilities.SpareFee, foreign_key: :spare_rate_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(material, attrs) do
    material
    |> cast(attrs, [
      :direction,
      :date_sent,
      :date_received,
      :status,
      :admin_id,
      :equipment_id,
      :maker_id,
      :equipment_rate_id,
      :currency_id,
      :amount,
      :fin_year,
      :spare_id,
      :comment,
      :spare_rate_id
    ])
    |> validate_required([:direction, :admin_id, :spare_id, :maker_id])
    |> does_material_fee_exist?()
  end

  defp does_material_fee_exist?(%Ecto.Changeset{valid?: true} = changeset) do
    admin = get_field(changeset, :admin_id)
    spare = get_field(changeset, :spare_id)

    date =
      (get_field(changeset, :date_received) || get_field(changeset, :date_sent)) |> to_string()

    year = String.slice(date, 0..-7)

    case Rms.SystemUtilities.spare_fee_lookup(date, admin, spare) do
      nil ->
        add_error(
          changeset,
          :Rate,
          " not maintained for Administrator"
        )

      fee ->
        change(changeset,
          spare_rate_id: fee.id,
          amount: fee.amount,
          fin_year: year,
          currency_id: fee.currency_id
        )
    end
  end

  defp does_material_fee_exist?(changeset), do: changeset
end
