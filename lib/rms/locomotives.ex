defmodule Rms.Locomotives do
  @moduledoc """
  The Locomotives context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.Locomotives.Locomotive

  @doc """
  Returns the list of tbl_locomotive.
  
  ## Examples
  
      iex> list_tbl_locomotive()
      [%Locomotive{}, ...]
  
  """
  def list_tbl_locomotive do
    Locomotive
    |> preload([:maker, :checker, :model, :type, :owner])
    |> Repo.all()
  end

  def select_locomotive_no(search_term, start) do
    Locomotive
    |> where(
      [l],
      fragment("lower(?) like lower(?)", l.loco_number, ^search_term) and l.status == "A"
    )
    |> compose_select_locomotive_query(start)
    |> Repo.all()
  end

  def select_locomotive(search_term, start) do
    Locomotive
    |> where([l], fragment("lower(?) like lower(?)", l.loco_number, ^search_term))
    |> compose_select_locomotive_query(start)
    |> Repo.all()
  end

  defp compose_select_locomotive_query(query, start) do
    query
    |> order_by([l], l.id)
    |> group_by([l], [l.loco_number, l.id])
    |> limit(50)
    |> offset(^start)
    |> select([l], %{
      total_count: fragment("count(*) AS total_count"),
      id: l.id,
      text: l.loco_number
    })
  end

  def locomotive_capacty_lookup(locomotive_id) do
    Locomotive
    |> where([a], a.id == ^locomotive_id)
    |> join(:left, [a], b in Rms.SystemUtilities.Model, on: a.model_id == b.id)
    |> group_by([a, b], [a.description, a.loco_engine_capacity, b.model])
    |> select([a, b], %{
      description: a.description,
      loco_engine_capacity: a.loco_engine_capacity,
      type: b.model
    })
    |> Repo.all()
  end

  # def locomotive_capacty_lookup(locomotive_id) do
  #   Locomotive
  #   |> preload([:maker, :checker, :model, :type, :owner])
  #   |> where([a], a.id == ^locomotive_id)
  #   |> select([a],
  #     map(
  #       a,
  #       [
  #         :id,
  #         :loco_engine_capacity,
  #         :description,
  #         type: [:code]
  #       ]
  #     )
  #   )
  #   |> Repo.one()
  # end

  @doc """
  Gets a single locomotive.
  
  Raises `Ecto.NoResultsError` if the Locomotive does not exist.
  
  ## Examples
  
      iex> get_locomotive!(123)
      %Locomotive{}
  
      iex> get_locomotive!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_locomotive!(id), do: Repo.get!(Locomotive, id)

  @doc """
  Creates a locomotive.
  
  ## Examples
  
      iex> create_locomotive(%{field: value})
      {:ok, %Locomotive{}}
  
      iex> create_locomotive(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_locomotive(attrs \\ %{}) do
    %Locomotive{}
    |> Locomotive.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a locomotive.
  
  ## Examples
  
      iex> update_locomotive(locomotive, %{field: new_value})
      {:ok, %Locomotive{}}
  
      iex> update_locomotive(locomotive, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_locomotive(%Locomotive{} = locomotive, attrs) do
    locomotive
    |> Locomotive.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a locomotive.
  
  ## Examples
  
      iex> delete_locomotive(locomotive)
      {:ok, %Locomotive{}}
  
      iex> delete_locomotive(locomotive)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_locomotive(%Locomotive{} = locomotive) do
    Repo.delete(locomotive)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locomotive changes.
  
  ## Examples
  
      iex> change_locomotive(locomotive)
      %Ecto.Changeset{data: %Locomotive{}}
  
  """
  def change_locomotive(%Locomotive{} = locomotive, attrs \\ %{}) do
    Locomotive.changeset(locomotive, attrs)
  end

  def locomotives_lookup(ids) do
    Locomotive
    |> where([a], a.id in ^ids)
    |> select(
      [a],
      a.loco_number
    )
    |> Repo.all()
  end

  # alias Rms.Locomotives.LocoDriver

  # @doc """
  # Returns the list of tbl_loco_driver.

  # ## Examples

  #     iex> list_tbl_loco_driver()
  #     [%LocoDriver{}, ...]

  # """
  # def list_tbl_loco_driver do
  #   Repo.all(LocoDriver)
  # end

  # @doc """
  # Gets a single loco_driver.

  # Raises `Ecto.NoResultsError` if the Loco driver does not exist.

  # ## Examples

  #     iex> get_loco_driver!(123)
  #     %LocoDriver{}

  #     iex> get_loco_driver!(456)
  #     ** (Ecto.NoResultsError)

  # """
  # def get_loco_driver!(id), do: Repo.get!(LocoDriver, id)

  # @doc """
  # Creates a loco_driver.

  # ## Examples

  #     iex> create_loco_driver(%{field: value})
  #     {:ok, %LocoDriver{}}

  #     iex> create_loco_driver(%{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def create_loco_driver(attrs \\ %{}) do
  #   %LocoDriver{}
  #   |> LocoDriver.changeset(attrs)
  #   |> Repo.insert()
  # end

  # @doc """
  # Updates a loco_driver.

  # ## Examples

  #     iex> update_loco_driver(loco_driver, %{field: new_value})
  #     {:ok, %LocoDriver{}}

  #     iex> update_loco_driver(loco_driver, %{field: bad_value})
  #     {:error, %Ecto.Changeset{}}

  # """
  # def update_loco_driver(%LocoDriver{} = loco_driver, attrs) do
  #   loco_driver
  #   |> LocoDriver.changeset(attrs)
  #   |> Repo.update()
  # end

  # @doc """
  # Deletes a loco_driver.

  # ## Examples

  #     iex> delete_loco_driver(loco_driver)
  #     {:ok, %LocoDriver{}}

  #     iex> delete_loco_driver(loco_driver)
  #     {:error, %Ecto.Changeset{}}

  # """
  # def delete_loco_driver(%LocoDriver{} = loco_driver) do
  #   Repo.delete(loco_driver)
  # end

  # @doc """
  # Returns an `%Ecto.Changeset{}` for tracking loco_driver changes.

  # ## Examples

  #     iex> change_loco_driver(loco_driver)
  #     %Ecto.Changeset{data: %LocoDriver{}}

  # """
  # def change_loco_driver(%LocoDriver{} = loco_driver, attrs \\ %{}) do
  #   LocoDriver.changeset(loco_driver, attrs)
  # end

  alias Rms.Locomotives.LocomotiveType

  @doc """
  Returns the list of tbl_locomotive_type.
  
  ## Examples
  
      iex> list_tbl_locomotive_type()
      [%LocomotiveType{}, ...]
  
  """
  def list_tbl_locomotive_type do
    LocomotiveType
    |> preload([:maker, :checker])
    |> Repo.all()
  end

  @doc """
  Gets a single locomotive_type.
  
  Raises `Ecto.NoResultsError` if the Locomotive type does not exist.
  
  ## Examples
  
      iex> get_locomotive_type!(123)
      %LocomotiveType{}
  
      iex> get_locomotive_type!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_locomotive_type!(id), do: Repo.get!(LocomotiveType, id)

  @doc """
  Creates a locomotive_type.
  
  ## Examples
  
      iex> create_locomotive_type(%{field: value})
      {:ok, %LocomotiveType{}}
  
      iex> create_locomotive_type(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_locomotive_type(attrs \\ %{}) do
    %LocomotiveType{}
    |> LocomotiveType.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a locomotive_type.
  
  ## Examples
  
      iex> update_locomotive_type(locomotive_type, %{field: new_value})
      {:ok, %LocomotiveType{}}
  
      iex> update_locomotive_type(locomotive_type, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_locomotive_type(%LocomotiveType{} = locomotive_type, attrs) do
    locomotive_type
    |> LocomotiveType.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a locomotive_type.
  
  ## Examples
  
      iex> delete_locomotive_type(locomotive_type)
      {:ok, %LocomotiveType{}}
  
      iex> delete_locomotive_type(locomotive_type)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_locomotive_type(%LocomotiveType{} = locomotive_type) do
    Repo.delete(locomotive_type)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking locomotive_type changes.
  
  ## Examples
  
      iex> change_locomotive_type(locomotive_type)
      %Ecto.Changeset{data: %LocomotiveType{}}
  
  """
  def change_locomotive_type(%LocomotiveType{} = locomotive_type, attrs \\ %{}) do
    LocomotiveType.changeset(locomotive_type, attrs)
  end
end
