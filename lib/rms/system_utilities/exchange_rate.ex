defmodule Rms.SystemUtilities.ExchangeRate do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_exchange_rate" do
    # field :first_currency, :decimal
    # field :second_currency, :decimal
    field :status, :string, default: "D"
    field :exchange_rate, :decimal
    field :start_date, :string
    field :symbol, :string
    # field :maker_id, :id
    # field :checker_id, :id

    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id
    belongs_to :first_ccy, Rms.SystemUtilities.Currency, foreign_key: :first_currency, type: :id
    belongs_to :second_ccy, Rms.SystemUtilities.Currency, foreign_key: :second_currency, type: :id

    timestamps()
  end

  @doc false
  def changeset(exchange_rate, attrs) do
    exchange_rate
    |> cast(attrs, [
      :symbol,
      :first_currency,
      :status,
      :second_currency,
      :start_date,
      :exchange_rate,
      :maker_id,
      :checker_id
    ])
    |> validate_required([:first_currency, :second_currency, :start_date, :exchange_rate])
    |> unique_constraint(:exchange_rate,
      name: :unique_exchange_rate_index,
      message: "already exists"
    )
  end
end
