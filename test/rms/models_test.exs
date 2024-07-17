defmodule Rms.ModelsTest do
  use Rms.DataCase

  alias Rms.Models

  describe "tbl_locomotive_models" do
    alias Rms.Models.Model

    @valid_attrs %{model: "some model", self_weight: "some self_weight", status: "some status"}
    @update_attrs %{
      model: "some updated model",
      self_weight: "some updated self_weight",
      status: "some updated status"
    }
    @invalid_attrs %{model: nil, self_weight: nil, status: nil}

    def model_fixture(attrs \\ %{}) do
      {:ok, model} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Models.create_model()

      model
    end

    test "list_tbl_locomotive_models/0 returns all tbl_locomotive_models" do
      model = model_fixture()
      assert Models.list_tbl_locomotive_models() == [model]
    end

    test "get_model!/1 returns the model with given id" do
      model = model_fixture()
      assert Models.get_model!(model.id) == model
    end

    test "create_model/1 with valid data creates a model" do
      assert {:ok, %Model{} = model} = Models.create_model(@valid_attrs)
      assert model.model == "some model"
      assert model.self_weight == "some self_weight"
      assert model.status == "some status"
    end

    test "create_model/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Models.create_model(@invalid_attrs)
    end

    test "update_model/2 with valid data updates the model" do
      model = model_fixture()
      assert {:ok, %Model{} = model} = Models.update_model(model, @update_attrs)
      assert model.model == "some updated model"
      assert model.self_weight == "some updated self_weight"
      assert model.status == "some updated status"
    end

    test "update_model/2 with invalid data returns error changeset" do
      model = model_fixture()
      assert {:error, %Ecto.Changeset{}} = Models.update_model(model, @invalid_attrs)
      assert model == Models.get_model!(model.id)
    end

    test "delete_model/1 deletes the model" do
      model = model_fixture()
      assert {:ok, %Model{}} = Models.delete_model(model)
      assert_raise Ecto.NoResultsError, fn -> Models.get_model!(model.id) end
    end

    test "change_model/1 returns a model changeset" do
      model = model_fixture()
      assert %Ecto.Changeset{} = Models.change_model(model)
    end
  end
end
