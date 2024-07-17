defmodule RmsWeb.UserRegionControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Accounts

  @create_attrs %{code: "some code", description: "some description"}
  @update_attrs %{code: "some updated code", description: "some updated description"}
  @invalid_attrs %{code: nil, description: nil}

  def fixture(:user_region) do
    {:ok, user_region} = Accounts.create_user_region(@create_attrs)
    user_region
  end

  describe "index" do
    test "lists all tbl_user_region", %{conn: conn} do
      conn = get(conn, Routes.user_region_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl user region"
    end
  end

  describe "new user_region" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.user_region_path(conn, :new))
      assert html_response(conn, 200) =~ "New User region"
    end
  end

  describe "create user_region" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.user_region_path(conn, :create), user_region: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.user_region_path(conn, :show, id)

      conn = get(conn, Routes.user_region_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show User region"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.user_region_path(conn, :create), user_region: @invalid_attrs)
      assert html_response(conn, 200) =~ "New User region"
    end
  end

  describe "edit user_region" do
    setup [:create_user_region]

    test "renders form for editing chosen user_region", %{conn: conn, user_region: user_region} do
      conn = get(conn, Routes.user_region_path(conn, :edit, user_region))
      assert html_response(conn, 200) =~ "Edit User region"
    end
  end

  describe "update user_region" do
    setup [:create_user_region]

    test "redirects when data is valid", %{conn: conn, user_region: user_region} do
      conn =
        put(conn, Routes.user_region_path(conn, :update, user_region), user_region: @update_attrs)

      assert redirected_to(conn) == Routes.user_region_path(conn, :show, user_region)

      conn = get(conn, Routes.user_region_path(conn, :show, user_region))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, user_region: user_region} do
      conn =
        put(conn, Routes.user_region_path(conn, :update, user_region), user_region: @invalid_attrs)

      assert html_response(conn, 200) =~ "Edit User region"
    end
  end

  describe "delete user_region" do
    setup [:create_user_region]

    test "deletes chosen user_region", %{conn: conn, user_region: user_region} do
      conn = delete(conn, Routes.user_region_path(conn, :delete, user_region))
      assert redirected_to(conn) == Routes.user_region_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_region_path(conn, :show, user_region))
      end
    end
  end

  defp create_user_region(_) do
    user_region = fixture(:user_region)
    %{user_region: user_region}
  end
end
