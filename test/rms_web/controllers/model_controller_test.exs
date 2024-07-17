defmodule RmsWeb.ModelControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Models

  @create_attrs %{model: "some model", self_weight: "some self_weight", status: "some status"}
  @update_attrs %{
    model: "some updated model",
    self_weight: "some updated self_weight",
    status: "some updated status"
  }
  @invalid_attrs %{model: nil, self_weight: nil, status: nil}

  def fixture(:model) do
    {:ok, model} = Models.create_model(@create_attrs)
    model
  end

  describe "index" do
    test "lists all tbl_locomotive_models", %{conn: conn} do
      conn = get(conn, Routes.model_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl locomotive models"
    end
  end

  describe "new model" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.model_path(conn, :new))
      assert html_response(conn, 200) =~ "New Model"
    end
  end

  describe "create model" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.model_path(conn, :create), model: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.model_path(conn, :show, id)

      conn = get(conn, Routes.model_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Model"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.model_path(conn, :create), model: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Model"
    end
  end

  describe "edit model" do
    setup [:create_model]

    test "renders form for editing chosen model", %{conn: conn, model: model} do
      conn = get(conn, Routes.model_path(conn, :edit, model))
      assert html_response(conn, 200) =~ "Edit Model"
    end
  end

  describe "update model" do
    setup [:create_model]

    test "redirects when data is valid", %{conn: conn, model: model} do
      conn = put(conn, Routes.model_path(conn, :update, model), model: @update_attrs)
      assert redirected_to(conn) == Routes.model_path(conn, :show, model)

      conn = get(conn, Routes.model_path(conn, :show, model))
      assert html_response(conn, 200) =~ "some updated model"
    end

    test "renders errors when data is invalid", %{conn: conn, model: model} do
      conn = put(conn, Routes.model_path(conn, :update, model), model: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Model"
    end
  end

  describe "delete model" do
    setup [:create_model]

    test "deletes chosen model", %{conn: conn, model: model} do
      conn = delete(conn, Routes.model_path(conn, :delete, model))
      assert redirected_to(conn) == Routes.model_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.model_path(conn, :show, model))
      end
    end
  end

  defp create_model(_) do
    model = fixture(:model)
    %{model: model}
  end
end
