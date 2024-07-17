defmodule Rms.SystemUtilities.EquipmentRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_equipment_rates" do
    field :rate, :decimal
    field :status, :string
    field :start_date, :date
    # field :maker_id, :id
    # field :checker_id, :id
    # field :partner_id, :id
    # field :equipment_id, :id
    belongs_to :partner, Rms.Accounts.RailwayAdministrator, foreign_key: :partner_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :equipment, Rms.SystemUtilities.Equipment, foreign_key: :equipment_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(equipment_rate, attrs) do
    equipment_rate
    |> cast(attrs, [
      :rate,
      :start_date,
      :maker_id,
      :checker_id,
      :status,
      :currency_id,
      :partner_id,
      :equipment_id
    ])
    |> validate_required([
      :rate,
      :status,
      :start_date,
      :currency_id,
      :partner_id,
      :equipment_id
    ])
  end
end
