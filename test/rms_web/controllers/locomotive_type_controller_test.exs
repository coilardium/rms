defmodule RmsWeb.LocomotiveTypeControllerTest do
  use RmsWeb.ConnCase

  alias Rms.Locomotives

  @create_attrs %{code: "some code", description: "some description", status: "some status"}
  @update_attrs %{
    code: "some updated code",
    description: "some updated description",
    status: "some updated status"
  }
  @invalid_attrs %{code: nil, description: nil, status: nil}

  def fixture(:locomotive_type) do
    {:ok, locomotive_type} = Locomotives.create_locomotive_type(@create_attrs)
    locomotive_type
  end

  describe "index" do
    test "lists all tbl_locomotive_type", %{conn: conn} do
      conn = get(conn, Routes.locomotive_type_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Tbl locomotive type"
    end
  end

  describe "new locomotive_type" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.locomotive_type_path(conn, :new))
      assert html_response(conn, 200) =~ "New Locomotive type"
    end
  end

  describe "create locomotive_type" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn =
        post(conn, Routes.locomotive_type_path(conn, :create), locomotive_type: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.locomotive_type_path(conn, :show, id)

      conn = get(conn, Routes.locomotive_type_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Locomotive type"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn =
        post(conn, Routes.locomotive_type_path(conn, :create), locomotive_type: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Locomotive type"
    end
  end

  describe "edit locomotive_type" do
    setup [:create_locomotive_type]

    test "renders form for editing chosen locomotive_type", %{
      conn: conn,
      locomotive_type: locomotive_type
    } do
      conn = get(conn, Routes.locomotive_type_path(conn, :edit, locomotive_type))
      assert html_response(conn, 200) =~ "Edit Locomotive type"
    end
  end

  describe "update locomotive_type" do
    setup [:create_locomotive_type]

    test "redirects when data is valid", %{conn: conn, locomotive_type: locomotive_type} do
      conn =
        put(conn, Routes.locomotive_type_path(conn, :update, locomotive_type),
          locomotive_type: @update_attrs
        )

      assert redirected_to(conn) == Routes.locomotive_type_path(conn, :show, locomotive_type)

      conn = get(conn, Routes.locomotive_type_path(conn, :show, locomotive_type))
      assert html_response(conn, 200) =~ "some updated code"
    end

    test "renders errors when data is invalid", %{conn: conn, locomotive_type: locomotive_type} do
      conn =
        put(conn, Routes.locomotive_type_path(conn, :update, locomotive_type),
          locomotive_type: @invalid_attrs
        )

      assert html_response(conn, 200) =~ "Edit Locomotive type"
    end
  end

  describe "delete locomotive_type" do
    setup [:create_locomotive_type]

    test "deletes chosen locomotive_type", %{conn: conn, locomotive_type: locomotive_type} do
      conn = delete(conn, Routes.locomotive_type_path(conn, :delete, locomotive_type))
      assert redirected_to(conn) == Routes.locomotive_type_path(conn, :index)

      assert_error_sent 404, fn ->
        get(conn, Routes.locomotive_type_path(conn, :show, locomotive_type))
      end
    end
  end

  defp create_locomotive_type(_) do
    locomotive_type = fixture(:locomotive_type)
    %{locomotive_type: locomotive_type}
  end
end
