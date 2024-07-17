defmodule Rms.SystemUtilities.CollectionType do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tbl_collection_types" do
    field :code, :string
    field :description, :string

    timestamps()
  end

  @doc false
  def changeset(collection_type, attrs) do
    collection_type
    |> cast(attrs, [:description, :code])
    |> validate_required([:description, :code])
    |> unique_constraint(:description)
  end
end
