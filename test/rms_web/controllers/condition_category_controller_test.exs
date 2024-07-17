defmodule RmsWeb.ConditionCategoryControllerTest do
  use RmsWeb.ConnCase

  alias Rms.SystemUtilities

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:condition_category) do
    {:ok, condition_category} = SystemUtilities.create_condition_category(@create_attrs)
    condition_category
  end

  describe "index" do
    test "lists all tbl_condition_category", %{conn: conn} do
      conn = get(conn, Routes.condition_category_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl condition category"
    end
  end

  describe "new condition_category" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.condition_category_path(conn, :new))
      assert html_response(conn, 200) =~ "New Condition category"
    end
  end

  describe "create condition_category" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.condition_category_path(conn, :create),
          condition_category: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.condition_category_path(conn, :show, id)

      conn = get(conn, Routes.condition_category_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Condition category"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.condition_category_path(conn, :create),
          condition_category: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Condition category"
    end
  end

  describe "edit condition_category" do
    setup [:create_condition_category]

    test "renders form for editing chosen condition_category", %{
      conn: conn,
      condition_category: condition_category
    } do
      conn = get(conn, Routes.condition_category_path(conn, :edit, condition_category))
      assert html_response(conn, 200) =~ "Edit Condition category"
    end
  end

  describe "update condition_category" do
    setup [:create_condition_category]

    test "redirects when data is valid", %{conn: conn, condition_category: condition_category} do
      conn =
        put(conn, Routes.condition_category_path(conn, :update, condition_category),
          condition_category: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.condition_category_path(conn, :show, condition_category)

      conn = get(conn, Routes.condition_category_path(conn, :show, condition_category))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      condition_category: condition_category
    } do
      conn =
        put(conn, Routes.condition_category_path(conn, :update, condition_category),
          condition_category: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Condition category"
    end
  end

  describe "delete condition_category" do
    setup [:create_condition_category]

    test "deletes chosen condition_category", %{
      conn: conn,
      condition_category: condition_category
    } do
      conn = delete(conn, Routes.condition_category_path(conn, :delete, condition_category))
      assert redirected_to(conn) == Routes.condition_category_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.condition_category_path(conn, :show, condition_category))
      end
    end
  end

  defp create_condition_category(_) do
    condition_category = fixture(:condition_category)
    %{condition_category: condition_category}
  end
end
