defmodule Rms.SystemUtilities.LocoDetentionRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_loco_dentention_rates" do
    field :delay_charge, :integer
    field :rate, :decimal
    field :start_date, :date
    field :status, :string
    # field :maker_id, :id
    # field :checker_id, :id
    # field :admin_id, :id
    belongs_to :admin, Rms.Accounts.RailwayAdministrator, foreign_key: :admin_id, type: :id
    belongs_to :currency, Rms.SystemUtilities.Currency, foreign_key: :currency_id, type: :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(loco_detention_rate, attrs) do
    loco_detention_rate
    |> cast(attrs, [
      :rate,
      :start_date,
      :status,
      :delay_charge,
      :admin_id,
      :currency_id,
      :maker_id,
      :checker_id
    ])
    |> validate_required([:rate, :start_date, :status, :delay_charge])
  end
end
