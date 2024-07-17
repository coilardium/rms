defmodule Rms.Activity.UserLog do
  use Ecto.Schema
  use Endon
  import Ecto.Changeset
  alias Rms.SystemUtilities.TariffLine

  @timestamps_opts [autogenerate: {TariffLine.Localtime, :autogenerate, []}]
  schema "tbl_user_activity" do
    field :activity, :string

    belongs_to :user, Rms.Accounts.User, foreign_key: :user_id, type: :id

    timestamps()
  end

  @doc false
  def changeset(user_log, attrs) do
    user_log
    |> cast(attrs, [:activity, :user_id])
    |> validate_required([:activity, :user_id])
  end
end
