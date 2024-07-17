defmodule Rms.Vats do
  @moduledoc """
  The Vats context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Vats.Vat

  @doc """
  Returns the list of tbl_vat.
  
  ## Examples
  
      iex> list_tbl_vat()
      [%Vat{}, ...]
  
  """
  def list_tbl_vat do
    Repo.all(Vat)
  end

  def get_maintained_vat() do
    Vat
    |> where(status: "A")
    |> limit(1)
    |> Repo.one()
  end

  @doc """
  Gets a single vat.
  
  Raises `Ecto.NoResultsError` if the Vat does not exist.
  
  ## Examples
  
      iex> get_vat!(123)
      %Vat{}
  
      iex> get_vat!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_vat!(id), do: Repo.get!(Vat, id)

  @doc """
  Creates a vat.
  
  ## Examples
  
      iex> create_vat(%{field: value})
      {:ok, %Vat{}}
  
      iex> create_vat(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_vat(attrs \\ %{}) do
    %Vat{}
    |> Vat.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a vat.
  
  ## Examples
  
      iex> update_vat(vat, %{field: new_value})
      {:ok, %Vat{}}
  
      iex> update_vat(vat, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_vat(%Vat{} = vat, attrs) do
    vat
    |> Vat.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a vat.
  
  ## Examples
  
      iex> delete_vat(vat)
      {:ok, %Vat{}}
  
      iex> delete_vat(vat)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_vat(%Vat{} = vat) do
    Repo.delete(vat)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vat changes.
  
  ## Examples
  
      iex> change_vat(vat)
      %Ecto.Changeset{data: %Vat{}}
  
  """
  def change_vat(%Vat{} = vat, attrs \\ %{}) do
    Vat.changeset(vat, attrs)
  end
end
