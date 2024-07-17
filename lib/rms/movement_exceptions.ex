defmodule Rms.MovementExceptions do
  @moduledoc """
  The MovementExceptions context.
  """

  import Ecto.Query, warn: false
  alias Rms.Repo

  alias Rms.MovementExceptions.MovementException

  @doc """
  Returns the list of tbl_mvt_exceptions.
  
  ## Examples
  
      iex> list_tbl_mvt_exceptions()
      [%MovementException{}, ...]
  
  """
  def list_tbl_mvt_exceptions do
    Repo.all(MovementException)
  end

  @doc """
  Gets a single movement_exception.
  
  Raises `Ecto.NoResultsError` if the Movement exception does not exist.
  
  ## Examples
  
      iex> get_movement_exception!(123)
      %MovementException{}
  
      iex> get_movement_exception!(456)
      ** (Ecto.NoResultsError)
  
  """
  def get_movement_exception!(id), do: Repo.get!(MovementException, id)

  @doc """
  Creates a movement_exception.
  
  ## Examples
  
      iex> create_movement_exception(%{field: value})
      {:ok, %MovementException{}}
  
      iex> create_movement_exception(%{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def create_movement_exception(attrs \\ %{}) do
    %MovementException{}
    |> MovementException.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a movement_exception.
  
  ## Examples
  
      iex> update_movement_exception(movement_exception, %{field: new_value})
      {:ok, %MovementException{}}
  
      iex> update_movement_exception(movement_exception, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  
  """
  def update_movement_exception(%MovementException{} = movement_exception, attrs) do
    movement_exception
    |> MovementException.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a movement_exception.
  
  ## Examples
  
      iex> delete_movement_exception(movement_exception)
      {:ok, %MovementException{}}
  
      iex> delete_movement_exception(movement_exception)
      {:error, %Ecto.Changeset{}}
  
  """
  def delete_movement_exception(%MovementException{} = movement_exception) do
    Repo.delete(movement_exception)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking movement_exception changes.
  
  ## Examples
  
      iex> change_movement_exception(movement_exception)
      %Ecto.Changeset{data: %MovementException{}}
  
  """
  def change_movement_exception(%MovementException{} = movement_exception, attrs \\ %{}) do
    MovementException.changeset(movement_exception, attrs)
  end
end
