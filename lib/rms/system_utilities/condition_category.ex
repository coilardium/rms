defmodule Rms.SystemUtilities.ConditionCategory do
  use Ecto.Schema
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_condition_category" do
    field :code, :string
    field :description, :string
    field :status, :string
    # field :maker_id, :id
    # field :checker_id, :id
    belongs_to :maker, Rms.Accounts.User, foreign_key: :maker_id, type: :id
    belongs_to :checker, Rms.Accounts.User, foreign_key: :checker_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(condition_category, attrs) do
    condition_category
    |> cast(attrs, [:code, :description, :status, :maker_id, :checker_id])
    |> validate_required([:code, :description, :status])
  end
end
