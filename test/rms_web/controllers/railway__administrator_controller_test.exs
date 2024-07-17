defmodule RmsWeb.Railway_AdministratorControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Railway_Administrators

  @create_attrs %{
    code: "some code",
    country: "some country",
    description: "some description",
    status: "some status"
  }
  @update_attrs %{
    code: "some updated code",
    country: "some updated country",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, country: nil, description: nil, status: nil}

  def fixture(:railway__administrator) do
    {:ok, railway__administrator} =
      Railway_Administrators.create_railway__administrator(@create_attrs)

    railway__administrator
  end

  describe "index" do
    test "lists all tbl_railway_administrator", %{conn: conn} do
      conn = get(conn, Routes.railway__administrator_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl railway administrator"
    end
  end

  describe "new railway__administrator" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.railway__administrator_path(conn, :new))
      assert html_response(conn, 200) =~ "New Railway  administrator"
    end
  end

  describe "create railway__administrator" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.railway__administrator_path(conn, :create),
          railway__administrator: @create_attrs
        )

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.railway__administrator_path(conn, :show, id)

      conn = get(conn, Routes.railway__administrator_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Railway  administrator"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.railway__administrator_path(conn, :create),
          railway__administrator: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "New Railway  administrator"
    end
  end

  describe "edit railway__administrator" do
    setup [:create_railway__administrator]

    test "renders form for editing chosen railway__administrator", %{
      conn: conn,
      railway__administrator: railway__administrator
    } do
      conn = get(conn, Routes.railway__administrator_path(conn, :edit, railway__administrator))
      assert html_response(conn, 200) =~ "Edit Railway  administrator"
    end
  end

  describe "update railway__administrator" do
    setup [:create_railway__administrator]

    test "redirects when data is valid", %{
      conn: conn,
      railway__administrator: railway__administrator
    } do
      conn =
        put(conn, Routes.railway__administrator_path(conn, :update, railway__administrator),
          railway__administrator: @update_attrs
        )

      assert redirected_to(conn) ==
               Routes.railway__administrator_path(conn, :show, railway__administrator)

      conn = get(conn, Routes.railway__administrator_path(conn, :show, railway__administrator))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{
      conn: conn,
      railway__administrator: railway__administrator
    } do
      conn =
        put(conn, Routes.railway__administrator_path(conn, :update, railway__administrator),
          railway__administrator: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Railway  administrator"
    end
  end

  describe "delete railway__administrator" do
    setup [:create_railway__administrator]

    test "deletes chosen railway__administrator", %{
      conn: conn,
      railway__administrator: railway__administrator
    } do
      conn =
        delete(conn, Routes.railway__administrator_path(conn, :delete, railway__administrator))

      assert redirected_to(conn) == Routes.railway__administrator_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.railway__administrator_path(conn, :show, railway__administrator))
      end
    end
  end

  defp create_railway__administrator(_) do
    railway__administrator = fixture(:railway__administrator)
    %{railway__administrator: railway__administrator}
  end
end
