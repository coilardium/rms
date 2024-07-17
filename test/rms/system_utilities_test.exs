defmodule Rms.SystemUtilitiesTest do
  use Rms.DataCase

  alias Rms.SystemUtilities

  describe "tbl_commodity" do
    alias Rms.SystemUtilities.Commodity

    @valid_attrs %{code: "some code"}
    @update_attrs %{code: "some updated code"}
    @invalid_attrs %{code: nil}

    def commodity_fixture(attrs \\ %{}) do
      {:ok, commodity} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_commodity()

      commodity
    end

    test "list_tbl_commodity/0 returns all tbl_commodity" do
      commodity = commodity_fixture()
      assert SystemUtilities.list_tbl_commodity() == [commodity]
    end

    test "get_commodity!/1 returns the commodity with given id" do
      commodity = commodity_fixture()
      assert SystemUtilities.get_commodity!(commodity.id) == commodity
    end

    test "create_commodity/1 with valid data creates a commodity" do
      assert {:ok, %Commodity{} = commodity} = SystemUtilities.create_commodity(@valid_attrs)
      assert commodity.code == "some code"
    end

    test "create_commodity/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_commodity(@invalid_attrs)
    end

    test "update_commodity/2 with valid data updates the commodity" do
      commodity = commodity_fixture()

      assert {:ok, %Commodity{} = commodity} =
               SystemUtilities.update_commodity(commodity, @update_attrs)

      assert commodity.code == "some updated code"
    end

    test "update_commodity/2 with invalid data returns error changeset" do
      commodity = commodity_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_commodity(commodity, @invalid_attrs)

      assert commodity == SystemUtilities.get_commodity!(commodity.id)
    end

    test "delete_commodity/1 deletes the commodity" do
      commodity = commodity_fixture()
      assert {:ok, %Commodity{}} = SystemUtilities.delete_commodity(commodity)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_commodity!(commodity.id) end
    end

    test "change_commodity/1 returns a commodity changeset" do
      commodity = commodity_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_commodity(commodity)
    end
  end

  describe "tbl_spares" do
    alias Rms.SystemUtilities.Spare

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def spare_fixture(attrs \\ %{}) do
      {:ok, spare} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_spare()

      spare
    end

    test "list_tbl_spares/0 returns all tbl_spares" do
      spare = spare_fixture()
      assert SystemUtilities.list_tbl_spares() == [spare]
    end

    test "get_spare!/1 returns the spare with given id" do
      spare = spare_fixture()
      assert SystemUtilities.get_spare!(spare.id) == spare
    end

    test "create_spare/1 with valid data creates a spare" do
      assert {:ok, %Spare{} = spare} = SystemUtilities.create_spare(@valid_attrs)
      assert spare.code == "some code"
      assert spare.description == "some description"
    end

    test "create_spare/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_spare(@invalid_attrs)
    end

    test "update_spare/2 with valid data updates the spare" do
      spare = spare_fixture()
      assert {:ok, %Spare{} = spare} = SystemUtilities.update_spare(spare, @update_attrs)
      assert spare.code == "some updated code"
      assert spare.description == "some updated description"
    end

    test "update_spare/2 with invalid data returns error changeset" do
      spare = spare_fixture()
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.update_spare(spare, @invalid_attrs)
      assert spare == SystemUtilities.get_spare!(spare.id)
    end

    test "delete_spare/1 deletes the spare" do
      spare = spare_fixture()
      assert {:ok, %Spare{}} = SystemUtilities.delete_spare(spare)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_spare!(spare.id) end
    end

    test "change_spare/1 returns a spare changeset" do
      spare = spare_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_spare(spare)
    end
  end

  describe "tbl_spare_fees" do
    alias Rms.SystemUtilities.SpareFee

    @valid_attrs %{amount: "120.5", code: "some code", start_date: ~D[2010-04-17]}
    @update_attrs %{amount: "456.7", code: "some updated code", start_date: ~D[2011-05-18]}
    @invalid_attrs %{amount: nil, code: nil, start_date: nil}

    def spare_fee_fixture(attrs \\ %{}) do
      {:ok, spare_fee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_spare_fee()

      spare_fee
    end

    test "list_tbl_spare_fees/0 returns all tbl_spare_fees" do
      spare_fee = spare_fee_fixture()
      assert SystemUtilities.list_tbl_spare_fees() == [spare_fee]
    end

    test "get_spare_fee!/1 returns the spare_fee with given id" do
      spare_fee = spare_fee_fixture()
      assert SystemUtilities.get_spare_fee!(spare_fee.id) == spare_fee
    end

    test "create_spare_fee/1 with valid data creates a spare_fee" do
      assert {:ok, %SpareFee{} = spare_fee} = SystemUtilities.create_spare_fee(@valid_attrs)
      assert spare_fee.amount == Decimal.new("120.5")
      assert spare_fee.code == "some code"
      assert spare_fee.start_date == ~D[2010-04-17]
    end

    test "create_spare_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_spare_fee(@invalid_attrs)
    end

    test "update_spare_fee/2 with valid data updates the spare_fee" do
      spare_fee = spare_fee_fixture()

      assert {:ok, %SpareFee{} = spare_fee} =
               SystemUtilities.update_spare_fee(spare_fee, @update_attrs)

      assert spare_fee.amount == Decimal.new("456.7")
      assert spare_fee.code == "some updated code"
      assert spare_fee.start_date == ~D[2011-05-18]
    end

    test "update_spare_fee/2 with invalid data returns error changeset" do
      spare_fee = spare_fee_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_spare_fee(spare_fee, @invalid_attrs)

      assert spare_fee == SystemUtilities.get_spare_fee!(spare_fee.id)
    end

    test "delete_spare_fee/1 deletes the spare_fee" do
      spare_fee = spare_fee_fixture()
      assert {:ok, %SpareFee{}} = SystemUtilities.delete_spare_fee(spare_fee)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_spare_fee!(spare_fee.id) end
    end

    test "change_spare_fee/1 returns a spare_fee changeset" do
      spare_fee = spare_fee_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_spare_fee(spare_fee)
    end
  end

  describe "tbl_defects" do
    alias Rms.SystemUtilities.Defect

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def defect_fixture(attrs \\ %{}) do
      {:ok, defect} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_defect()

      defect
    end

    test "list_tbl_defects/0 returns all tbl_defects" do
      defect = defect_fixture()
      assert SystemUtilities.list_tbl_defects() == [defect]
    end

    test "get_defect!/1 returns the defect with given id" do
      defect = defect_fixture()
      assert SystemUtilities.get_defect!(defect.id) == defect
    end

    test "create_defect/1 with valid data creates a defect" do
      assert {:ok, %Defect{} = defect} = SystemUtilities.create_defect(@valid_attrs)
      assert defect.code == "some code"
      assert defect.description == "some description"
    end

    test "create_defect/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_defect(@invalid_attrs)
    end

    test "update_defect/2 with valid data updates the defect" do
      defect = defect_fixture()
      assert {:ok, %Defect{} = defect} = SystemUtilities.update_defect(defect, @update_attrs)
      assert defect.code == "some updated code"
      assert defect.description == "some updated description"
    end

    test "update_defect/2 with invalid data returns error changeset" do
      defect = defect_fixture()
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.update_defect(defect, @invalid_attrs)
      assert defect == SystemUtilities.get_defect!(defect.id)
    end

    test "delete_defect/1 deletes the defect" do
      defect = defect_fixture()
      assert {:ok, %Defect{}} = SystemUtilities.delete_defect(defect)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_defect!(defect.id) end
    end

    test "change_defect/1 returns a defect changeset" do
      defect = defect_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_defect(defect)
    end
  end

  describe "tbl_interchange_fees" do
    alias Rms.SystemUtilities.InterchangeFee

    @valid_attrs %{amount: "120.5", year: "some year"}
    @update_attrs %{amount: "456.7", year: "some updated year"}
    @invalid_attrs %{amount: nil, year: nil}

    def interchange_fee_fixture(attrs \\ %{}) do
      {:ok, interchange_fee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_interchange_fee()

      interchange_fee
    end

    test "list_tbl_interchange_fees/0 returns all tbl_interchange_fees" do
      interchange_fee = interchange_fee_fixture()
      assert SystemUtilities.list_tbl_interchange_fees() == [interchange_fee]
    end

    test "get_interchange_fee!/1 returns the interchange_fee with given id" do
      interchange_fee = interchange_fee_fixture()
      assert SystemUtilities.get_interchange_fee!(interchange_fee.id) == interchange_fee
    end

    test "create_interchange_fee/1 with valid data creates a interchange_fee" do
      assert {:ok, %InterchangeFee{} = interchange_fee} =
               SystemUtilities.create_interchange_fee(@valid_attrs)

      assert interchange_fee.amount == Decimal.new("120.5")
      assert interchange_fee.year == "some year"
    end

    test "create_interchange_fee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_interchange_fee(@invalid_attrs)
    end

    test "update_interchange_fee/2 with valid data updates the interchange_fee" do
      interchange_fee = interchange_fee_fixture()

      assert {:ok, %InterchangeFee{} = interchange_fee} =
               SystemUtilities.update_interchange_fee(interchange_fee, @update_attrs)

      assert interchange_fee.amount == Decimal.new("456.7")
      assert interchange_fee.year == "some updated year"
    end

    test "update_interchange_fee/2 with invalid data returns error changeset" do
      interchange_fee = interchange_fee_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_interchange_fee(interchange_fee, @invalid_attrs)

      assert interchange_fee == SystemUtilities.get_interchange_fee!(interchange_fee.id)
    end

    test "delete_interchange_fee/1 deletes the interchange_fee" do
      interchange_fee = interchange_fee_fixture()
      assert {:ok, %InterchangeFee{}} = SystemUtilities.delete_interchange_fee(interchange_fee)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_interchange_fee!(interchange_fee.id)
      end
    end

    test "change_interchange_fee/1 returns a interchange_fee changeset" do
      interchange_fee = interchange_fee_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_interchange_fee(interchange_fee)
    end
  end

  describe "tbl_company_info" do
    alias Rms.SystemUtilities.CompanyInfo

    @valid_attrs %{
      company_address: "some company_address",
      company_email: "some company_email",
      company_name: "some company_name",
      login_attempts: 42,
      password_expiry_days: 42,
      status: "some status",
      vat: "120.5"
    }
    @update_attrs %{
      company_address: "some updated company_address",
      company_email: "some updated company_email",
      company_name: "some updated company_name",
      login_attempts: 43,
      password_expiry_days: 43,
      status: "some updated status",
      vat: "456.7"
    }
    @invalid_attrs %{
      company_address: nil,
      company_email: nil,
      company_name: nil,
      login_attempts: nil,
      password_expiry_days: nil,
      status: nil,
      vat: nil
    }

    def company_info_fixture(attrs \\ %{}) do
      {:ok, company_info} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_company_info()

      company_info
    end

    test "list_tbl_company_info/0 returns all tbl_company_info" do
      company_info = company_info_fixture()
      assert SystemUtilities.list_tbl_company_info() == [company_info]
    end

    test "get_company_info!/1 returns the company_info with given id" do
      company_info = company_info_fixture()
      assert SystemUtilities.get_company_info!(company_info.id) == company_info
    end

    test "create_company_info/1 with valid data creates a company_info" do
      assert {:ok, %CompanyInfo{} = company_info} =
               SystemUtilities.create_company_info(@valid_attrs)

      assert company_info.company_address == "some company_address"
      assert company_info.company_email == "some company_email"
      assert company_info.company_name == "some company_name"
      assert company_info.login_attempts == 42
      assert company_info.password_expiry_days == 42
      assert company_info.status == "some status"
      assert company_info.vat == Decimal.new("120.5")
    end

    test "create_company_info/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_company_info(@invalid_attrs)
    end

    test "update_company_info/2 with valid data updates the company_info" do
      company_info = company_info_fixture()

      assert {:ok, %CompanyInfo{} = company_info} =
               SystemUtilities.update_company_info(company_info, @update_attrs)

      assert company_info.company_address == "some updated company_address"
      assert company_info.company_email == "some updated company_email"
      assert company_info.company_name == "some updated company_name"
      assert company_info.login_attempts == 43
      assert company_info.password_expiry_days == 43
      assert company_info.status == "some updated status"
      assert company_info.vat == Decimal.new("456.7")
    end

    test "update_company_info/2 with invalid data returns error changeset" do
      company_info = company_info_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_company_info(company_info, @invalid_attrs)

      assert company_info == SystemUtilities.get_company_info!(company_info.id)
    end

    test "delete_company_info/1 deletes the company_info" do
      company_info = company_info_fixture()
      assert {:ok, %CompanyInfo{}} = SystemUtilities.delete_company_info(company_info)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_company_info!(company_info.id)
      end
    end

    test "change_company_info/1 returns a company_info changeset" do
      company_info = company_info_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_company_info(company_info)
    end
  end

  describe "tbl_distance" do
    alias Rms.SystemUtilities.Distance

    @valid_attrs %{destin: "some destin", distance: "120.5", station_orig: "some station_orig"}
    @update_attrs %{
      destin: "some updated destin",
      distance: "456.7",
      station_orig: "some updated station_orig"
    }
    @invalid_attrs %{destin: nil, distance: nil, station_orig: nil}

    def distance_fixture(attrs \\ %{}) do
      {:ok, distance} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_distance()

      distance
    end

    test "list_tbl_distance/0 returns all tbl_distance" do
      distance = distance_fixture()
      assert SystemUtilities.list_tbl_distance() == [distance]
    end

    test "get_distance!/1 returns the distance with given id" do
      distance = distance_fixture()
      assert SystemUtilities.get_distance!(distance.id) == distance
    end

    test "create_distance/1 with valid data creates a distance" do
      assert {:ok, %Distance{} = distance} = SystemUtilities.create_distance(@valid_attrs)
      assert distance.destin == "some destin"
      assert distance.distance == Decimal.new("120.5")
      assert distance.station_orig == "some station_orig"
    end

    test "create_distance/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_distance(@invalid_attrs)
    end

    test "update_distance/2 with valid data updates the distance" do
      distance = distance_fixture()

      assert {:ok, %Distance{} = distance} =
               SystemUtilities.update_distance(distance, @update_attrs)

      assert distance.destin == "some updated destin"
      assert distance.distance == Decimal.new("456.7")
      assert distance.station_orig == "some updated station_orig"
    end

    test "update_distance/2 with invalid data returns error changeset" do
      distance = distance_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_distance(distance, @invalid_attrs)

      assert distance == SystemUtilities.get_distance!(distance.id)
    end

    test "delete_distance/1 deletes the distance" do
      distance = distance_fixture()
      assert {:ok, %Distance{}} = SystemUtilities.delete_distance(distance)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_distance!(distance.id) end
    end

    test "change_distance/1 returns a distance changeset" do
      distance = distance_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_distance(distance)
    end
  end

  describe "tbl_tariff_line_rates" do
    alias Rms.SystemUtilities.TariffLineRate

    @valid_attrs %{rate: "120.5"}
    @update_attrs %{rate: "456.7"}
    @invalid_attrs %{rate: nil}

    def tariff_line_rate_fixture(attrs \\ %{}) do
      {:ok, tariff_line_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_tariff_line_rate()

      tariff_line_rate
    end

    test "list_tbl_tariff_line_rates/0 returns all tbl_tariff_line_rates" do
      tariff_line_rate = tariff_line_rate_fixture()
      assert SystemUtilities.list_tbl_tariff_line_rates() == [tariff_line_rate]
    end

    test "get_tariff_line_rate!/1 returns the tariff_line_rate with given id" do
      tariff_line_rate = tariff_line_rate_fixture()
      assert SystemUtilities.get_tariff_line_rate!(tariff_line_rate.id) == tariff_line_rate
    end

    test "create_tariff_line_rate/1 with valid data creates a tariff_line_rate" do
      assert {:ok, %TariffLineRate{} = tariff_line_rate} =
               SystemUtilities.create_tariff_line_rate(@valid_attrs)

      assert tariff_line_rate.rate == Decimal.new("120.5")
    end

    test "create_tariff_line_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_tariff_line_rate(@invalid_attrs)
    end

    test "update_tariff_line_rate/2 with valid data updates the tariff_line_rate" do
      tariff_line_rate = tariff_line_rate_fixture()

      assert {:ok, %TariffLineRate{} = tariff_line_rate} =
               SystemUtilities.update_tariff_line_rate(tariff_line_rate, @update_attrs)

      assert tariff_line_rate.rate == Decimal.new("456.7")
    end

    test "update_tariff_line_rate/2 with invalid data returns error changeset" do
      tariff_line_rate = tariff_line_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_tariff_line_rate(tariff_line_rate, @invalid_attrs)

      assert tariff_line_rate == SystemUtilities.get_tariff_line_rate!(tariff_line_rate.id)
    end

    test "delete_tariff_line_rate/1 deletes the tariff_line_rate" do
      tariff_line_rate = tariff_line_rate_fixture()
      assert {:ok, %TariffLineRate{}} = SystemUtilities.delete_tariff_line_rate(tariff_line_rate)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_tariff_line_rate!(tariff_line_rate.id)
      end
    end

    test "change_tariff_line_rate/1 returns a tariff_line_rate changeset" do
      tariff_line_rate = tariff_line_rate_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_tariff_line_rate(tariff_line_rate)
    end
  end

  describe "tbl_condition_category" do
    alias Rms.SystemUtilities.ConditionCategory

    @valid_attrs %{code: "some code", description: "some description", status: "some status"}
    @update_attrs %{
      code: "some updated code",
      description: "some updated description",
      status: "some updated status"
    }
    @invalid_attrs %{code: nil, description: nil, status: nil}

    def condition_category_fixture(attrs \\ %{}) do
      {:ok, condition_category} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_condition_category()

      condition_category
    end

    test "list_tbl_condition_category/0 returns all tbl_condition_category" do
      condition_category = condition_category_fixture()
      assert SystemUtilities.list_tbl_condition_category() == [condition_category]
    end

    test "get_condition_category!/1 returns the condition_category with given id" do
      condition_category = condition_category_fixture()
      assert SystemUtilities.get_condition_category!(condition_category.id) == condition_category
    end

    test "create_condition_category/1 with valid data creates a condition_category" do
      assert {:ok, %ConditionCategory{} = condition_category} =
               SystemUtilities.create_condition_category(@valid_attrs)

      assert condition_category.code == "some code"
      assert condition_category.description == "some description"
      assert condition_category.status == "some status"
    end

    test "create_condition_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.create_condition_category(@invalid_attrs)
    end

    test "update_condition_category/2 with valid data updates the condition_category" do
      condition_category = condition_category_fixture()

      assert {:ok, %ConditionCategory{} = condition_category} =
               SystemUtilities.update_condition_category(condition_category, @update_attrs)

      assert condition_category.code == "some updated code"
      assert condition_category.description == "some updated description"
      assert condition_category.status == "some updated status"
    end

    test "update_condition_category/2 with invalid data returns error changeset" do
      condition_category = condition_category_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_condition_category(condition_category, @invalid_attrs)

      assert condition_category == SystemUtilities.get_condition_category!(condition_category.id)
    end

    test "delete_condition_category/1 deletes the condition_category" do
      condition_category = condition_category_fixture()

      assert {:ok, %ConditionCategory{}} =
               SystemUtilities.delete_condition_category(condition_category)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_condition_category!(condition_category.id)
      end
    end

    test "change_condition_category/1 returns a condition_category changeset" do
      condition_category = condition_category_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_condition_category(condition_category)
    end
  end

  describe "tbl_upload_file_errors" do
    alias Rms.SystemUtilities.FileUploadError

    @valid_attrs %{
      col_index: "some col_index",
      error_msg: "some error_msg",
      filename: "some filename"
    }
    @update_attrs %{
      col_index: "some updated col_index",
      error_msg: "some updated error_msg",
      filename: "some updated filename"
    }
    @invalid_attrs %{col_index: nil, error_msg: nil, filename: nil}

    def file_upload_error_fixture(attrs \\ %{}) do
      {:ok, file_upload_error} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_file_upload_error()

      file_upload_error
    end

    test "list_tbl_upload_file_errors/0 returns all tbl_upload_file_errors" do
      file_upload_error = file_upload_error_fixture()
      assert SystemUtilities.list_tbl_upload_file_errors() == [file_upload_error]
    end

    test "get_file_upload_error!/1 returns the file_upload_error with given id" do
      file_upload_error = file_upload_error_fixture()
      assert SystemUtilities.get_file_upload_error!(file_upload_error.id) == file_upload_error
    end

    test "create_file_upload_error/1 with valid data creates a file_upload_error" do
      assert {:ok, %FileUploadError{} = file_upload_error} =
               SystemUtilities.create_file_upload_error(@valid_attrs)

      assert file_upload_error.col_index == "some col_index"
      assert file_upload_error.error_msg == "some error_msg"
      assert file_upload_error.filename == "some filename"
    end

    test "create_file_upload_error/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.create_file_upload_error(@invalid_attrs)
    end

    test "update_file_upload_error/2 with valid data updates the file_upload_error" do
      file_upload_error = file_upload_error_fixture()

      assert {:ok, %FileUploadError{} = file_upload_error} =
               SystemUtilities.update_file_upload_error(file_upload_error, @update_attrs)

      assert file_upload_error.col_index == "some updated col_index"
      assert file_upload_error.error_msg == "some updated error_msg"
      assert file_upload_error.filename == "some updated filename"
    end

    test "update_file_upload_error/2 with invalid data returns error changeset" do
      file_upload_error = file_upload_error_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_file_upload_error(file_upload_error, @invalid_attrs)

      assert file_upload_error == SystemUtilities.get_file_upload_error!(file_upload_error.id)
    end

    test "delete_file_upload_error/1 deletes the file_upload_error" do
      file_upload_error = file_upload_error_fixture()

      assert {:ok, %FileUploadError{}} =
               SystemUtilities.delete_file_upload_error(file_upload_error)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_file_upload_error!(file_upload_error.id)
      end
    end

    test "change_file_upload_error/1 returns a file_upload_error changeset" do
      file_upload_error = file_upload_error_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_file_upload_error(file_upload_error)
    end
  end

  describe "tbl_defect_spares" do
    alias Rms.SystemUtilities.DefectSpare

    @valid_attrs %{}
    @update_attrs %{}
    @invalid_attrs %{}

    def defect_spare_fixture(attrs \\ %{}) do
      {:ok, defect_spare} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_defect_spare()

      defect_spare
    end

    test "list_tbl_defect_spares/0 returns all tbl_defect_spares" do
      defect_spare = defect_spare_fixture()
      assert SystemUtilities.list_tbl_defect_spares() == [defect_spare]
    end

    test "get_defect_spare!/1 returns the defect_spare with given id" do
      defect_spare = defect_spare_fixture()
      assert SystemUtilities.get_defect_spare!(defect_spare.id) == defect_spare
    end

    test "create_defect_spare/1 with valid data creates a defect_spare" do
      assert {:ok, %DefectSpare{} = defect_spare} =
               SystemUtilities.create_defect_spare(@valid_attrs)
    end

    test "create_defect_spare/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_defect_spare(@invalid_attrs)
    end

    test "update_defect_spare/2 with valid data updates the defect_spare" do
      defect_spare = defect_spare_fixture()

      assert {:ok, %DefectSpare{} = defect_spare} =
               SystemUtilities.update_defect_spare(defect_spare, @update_attrs)
    end

    test "update_defect_spare/2 with invalid data returns error changeset" do
      defect_spare = defect_spare_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_defect_spare(defect_spare, @invalid_attrs)

      assert defect_spare == SystemUtilities.get_defect_spare!(defect_spare.id)
    end

    test "delete_defect_spare/1 deletes the defect_spare" do
      defect_spare = defect_spare_fixture()
      assert {:ok, %DefectSpare{}} = SystemUtilities.delete_defect_spare(defect_spare)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_defect_spare!(defect_spare.id)
      end
    end

    test "change_defect_spare/1 returns a defect_spare changeset" do
      defect_spare = defect_spare_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_defect_spare(defect_spare)
    end
  end

  describe "tbl_collection_types" do
    alias Rms.SystemUtilities.CollectionType

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def collection_type_fixture(attrs \\ %{}) do
      {:ok, collection_type} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_collection_type()

      collection_type
    end

    test "list_tbl_collection_types/0 returns all tbl_collection_types" do
      collection_type = collection_type_fixture()
      assert SystemUtilities.list_tbl_collection_types() == [collection_type]
    end

    test "get_collection_type!/1 returns the collection_type with given id" do
      collection_type = collection_type_fixture()
      assert SystemUtilities.get_collection_type!(collection_type.id) == collection_type
    end

    test "create_collection_type/1 with valid data creates a collection_type" do
      assert {:ok, %CollectionType{} = collection_type} =
               SystemUtilities.create_collection_type(@valid_attrs)

      assert collection_type.code == "some code"
      assert collection_type.description == "some description"
    end

    test "create_collection_type/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_collection_type(@invalid_attrs)
    end

    test "update_collection_type/2 with valid data updates the collection_type" do
      collection_type = collection_type_fixture()

      assert {:ok, %CollectionType{} = collection_type} =
               SystemUtilities.update_collection_type(collection_type, @update_attrs)

      assert collection_type.code == "some updated code"
      assert collection_type.description == "some updated description"
    end

    test "update_collection_type/2 with invalid data returns error changeset" do
      collection_type = collection_type_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_collection_type(collection_type, @invalid_attrs)

      assert collection_type == SystemUtilities.get_collection_type!(collection_type.id)
    end

    test "delete_collection_type/1 deletes the collection_type" do
      collection_type = collection_type_fixture()
      assert {:ok, %CollectionType{}} = SystemUtilities.delete_collection_type(collection_type)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_collection_type!(collection_type.id)
      end
    end

    test "change_collection_type/1 returns a collection_type changeset" do
      collection_type = collection_type_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_collection_type(collection_type)
    end
  end

  describe "tbl_equipments" do
    alias Rms.SystemUtilities.Equipment

    @valid_attrs %{code: "some code", description: "some description"}
    @update_attrs %{code: "some updated code", description: "some updated description"}
    @invalid_attrs %{code: nil, description: nil}

    def equipment_fixture(attrs \\ %{}) do
      {:ok, equipment} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_equipment()

      equipment
    end

    test "list_tbl_equipments/0 returns all tbl_equipments" do
      equipment = equipment_fixture()
      assert SystemUtilities.list_tbl_equipments() == [equipment]
    end

    test "get_equipment!/1 returns the equipment with given id" do
      equipment = equipment_fixture()
      assert SystemUtilities.get_equipment!(equipment.id) == equipment
    end

    test "create_equipment/1 with valid data creates a equipment" do
      assert {:ok, %Equipment{} = equipment} = SystemUtilities.create_equipment(@valid_attrs)
      assert equipment.code == "some code"
      assert equipment.description == "some description"
    end

    test "create_equipment/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_equipment(@invalid_attrs)
    end

    test "update_equipment/2 with valid data updates the equipment" do
      equipment = equipment_fixture()

      assert {:ok, %Equipment{} = equipment} =
               SystemUtilities.update_equipment(equipment, @update_attrs)

      assert equipment.code == "some updated code"
      assert equipment.description == "some updated description"
    end

    test "update_equipment/2 with invalid data returns error changeset" do
      equipment = equipment_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_equipment(equipment, @invalid_attrs)

      assert equipment == SystemUtilities.get_equipment!(equipment.id)
    end

    test "delete_equipment/1 deletes the equipment" do
      equipment = equipment_fixture()
      assert {:ok, %Equipment{}} = SystemUtilities.delete_equipment(equipment)
      assert_raise Ecto.NoResultsError, fn -> SystemUtilities.get_equipment!(equipment.id) end
    end

    test "change_equipment/1 returns a equipment changeset" do
      equipment = equipment_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_equipment(equipment)
    end
  end

  describe "tbl_equipment_rates" do
    alias Rms.SystemUtilities.EquipmentRate

    @valid_attrs %{rate: "120.5", status: "some status", year: "some year"}
    @update_attrs %{rate: "456.7", status: "some updated status", year: "some updated year"}
    @invalid_attrs %{rate: nil, status: nil, year: nil}

    def equipment_rate_fixture(attrs \\ %{}) do
      {:ok, equipment_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_equipment_rate()

      equipment_rate
    end

    test "list_tbl_equipment_rates/0 returns all tbl_equipment_rates" do
      equipment_rate = equipment_rate_fixture()
      assert SystemUtilities.list_tbl_equipment_rates() == [equipment_rate]
    end

    test "get_equipment_rate!/1 returns the equipment_rate with given id" do
      equipment_rate = equipment_rate_fixture()
      assert SystemUtilities.get_equipment_rate!(equipment_rate.id) == equipment_rate
    end

    test "create_equipment_rate/1 with valid data creates a equipment_rate" do
      assert {:ok, %EquipmentRate{} = equipment_rate} =
               SystemUtilities.create_equipment_rate(@valid_attrs)

      assert equipment_rate.rate == Decimal.new("120.5")
      assert equipment_rate.status == "some status"
      assert equipment_rate.year == "some year"
    end

    test "create_equipment_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_equipment_rate(@invalid_attrs)
    end

    test "update_equipment_rate/2 with valid data updates the equipment_rate" do
      equipment_rate = equipment_rate_fixture()

      assert {:ok, %EquipmentRate{} = equipment_rate} =
               SystemUtilities.update_equipment_rate(equipment_rate, @update_attrs)

      assert equipment_rate.rate == Decimal.new("456.7")
      assert equipment_rate.status == "some updated status"
      assert equipment_rate.year == "some updated year"
    end

    test "update_equipment_rate/2 with invalid data returns error changeset" do
      equipment_rate = equipment_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_equipment_rate(equipment_rate, @invalid_attrs)

      assert equipment_rate == SystemUtilities.get_equipment_rate!(equipment_rate.id)
    end

    test "delete_equipment_rate/1 deletes the equipment_rate" do
      equipment_rate = equipment_rate_fixture()
      assert {:ok, %EquipmentRate{}} = SystemUtilities.delete_equipment_rate(equipment_rate)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_equipment_rate!(equipment_rate.id)
      end
    end

    test "change_equipment_rate/1 returns a equipment_rate changeset" do
      equipment_rate = equipment_rate_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_equipment_rate(equipment_rate)
    end
  end

  describe "tbl_loco_dentention_rates" do
    alias Rms.SystemUtilities.LocoDetentionRate

    @valid_attrs %{
      delay_charge: 42,
      rate: "120.5",
      start_date: ~D[2010-04-17],
      status: "some status"
    }
    @update_attrs %{
      delay_charge: 43,
      rate: "456.7",
      start_date: ~D[2011-05-18],
      status: "some updated status"
    }
    @invalid_attrs %{delay_charge: nil, rate: nil, start_date: nil, status: nil}

    def loco_detention_rate_fixture(attrs \\ %{}) do
      {:ok, loco_detention_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_loco_detention_rate()

      loco_detention_rate
    end

    test "list_tbl_loco_dentention_rates/0 returns all tbl_loco_dentention_rates" do
      loco_detention_rate = loco_detention_rate_fixture()
      assert SystemUtilities.list_tbl_loco_dentention_rates() == [loco_detention_rate]
    end

    test "get_loco_detention_rate!/1 returns the loco_detention_rate with given id" do
      loco_detention_rate = loco_detention_rate_fixture()

      assert SystemUtilities.get_loco_detention_rate!(loco_detention_rate.id) ==
               loco_detention_rate
    end

    test "create_loco_detention_rate/1 with valid data creates a loco_detention_rate" do
      assert {:ok, %LocoDetentionRate{} = loco_detention_rate} =
               SystemUtilities.create_loco_detention_rate(@valid_attrs)

      assert loco_detention_rate.delay_charge == 42
      assert loco_detention_rate.rate == Decimal.new("120.5")
      assert loco_detention_rate.start_date == ~D[2010-04-17]
      assert loco_detention_rate.status == "some status"
    end

    test "create_loco_detention_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.create_loco_detention_rate(@invalid_attrs)
    end

    test "update_loco_detention_rate/2 with valid data updates the loco_detention_rate" do
      loco_detention_rate = loco_detention_rate_fixture()

      assert {:ok, %LocoDetentionRate{} = loco_detention_rate} =
               SystemUtilities.update_loco_detention_rate(loco_detention_rate, @update_attrs)

      assert loco_detention_rate.delay_charge == 43
      assert loco_detention_rate.rate == Decimal.new("456.7")
      assert loco_detention_rate.start_date == ~D[2011-05-18]
      assert loco_detention_rate.status == "some updated status"
    end

    test "update_loco_detention_rate/2 with invalid data returns error changeset" do
      loco_detention_rate = loco_detention_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_loco_detention_rate(loco_detention_rate, @invalid_attrs)

      assert loco_detention_rate ==
               SystemUtilities.get_loco_detention_rate!(loco_detention_rate.id)
    end

    test "delete_loco_detention_rate/1 deletes the loco_detention_rate" do
      loco_detention_rate = loco_detention_rate_fixture()

      assert {:ok, %LocoDetentionRate{}} =
               SystemUtilities.delete_loco_detention_rate(loco_detention_rate)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_loco_detention_rate!(loco_detention_rate.id)
      end
    end

    test "change_loco_detention_rate/1 returns a loco_detention_rate changeset" do
      loco_detention_rate = loco_detention_rate_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_loco_detention_rate(loco_detention_rate)
    end
  end

  describe "tbl_haulage_rates" do
    alias Rms.SystemUtilities.HaulageRate

    @valid_attrs %{
      distance: "120.5",
      rate: "120.5",
      rate_type: "some rate_type",
      start_date: ~D[2010-04-17],
      status: "some status"
    }
    @update_attrs %{
      distance: "456.7",
      rate: "456.7",
      rate_type: "some updated rate_type",
      start_date: ~D[2011-05-18],
      status: "some updated status"
    }
    @invalid_attrs %{distance: nil, rate: nil, rate_type: nil, start_date: nil, status: nil}

    def haulage_rate_fixture(attrs \\ %{}) do
      {:ok, haulage_rate} =
        attrs
        |> Enum.into(@valid_attrs)
        |> SystemUtilities.create_haulage_rate()

      haulage_rate
    end

    test "list_tbl_haulage_rates/0 returns all tbl_haulage_rates" do
      haulage_rate = haulage_rate_fixture()
      assert SystemUtilities.list_tbl_haulage_rates() == [haulage_rate]
    end

    test "get_haulage_rate!/1 returns the haulage_rate with given id" do
      haulage_rate = haulage_rate_fixture()
      assert SystemUtilities.get_haulage_rate!(haulage_rate.id) == haulage_rate
    end

    test "create_haulage_rate/1 with valid data creates a haulage_rate" do
      assert {:ok, %HaulageRate{} = haulage_rate} =
               SystemUtilities.create_haulage_rate(@valid_attrs)

      assert haulage_rate.distance == Decimal.new("120.5")
      assert haulage_rate.rate == Decimal.new("120.5")
      assert haulage_rate.rate_type == "some rate_type"
      assert haulage_rate.start_date == ~D[2010-04-17]
      assert haulage_rate.status == "some status"
    end

    test "create_haulage_rate/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = SystemUtilities.create_haulage_rate(@invalid_attrs)
    end

    test "update_haulage_rate/2 with valid data updates the haulage_rate" do
      haulage_rate = haulage_rate_fixture()

      assert {:ok, %HaulageRate{} = haulage_rate} =
               SystemUtilities.update_haulage_rate(haulage_rate, @update_attrs)

      assert haulage_rate.distance == Decimal.new("456.7")
      assert haulage_rate.rate == Decimal.new("456.7")
      assert haulage_rate.rate_type == "some updated rate_type"
      assert haulage_rate.start_date == ~D[2011-05-18]
      assert haulage_rate.status == "some updated status"
    end

    test "update_haulage_rate/2 with invalid data returns error changeset" do
      haulage_rate = haulage_rate_fixture()

      assert {:error, %Ecto.Changeset{}} =
               SystemUtilities.update_haulage_rate(haulage_rate, @invalid_attrs)

      assert haulage_rate == SystemUtilities.get_haulage_rate!(haulage_rate.id)
    end

    test "delete_haulage_rate/1 deletes the haulage_rate" do
      haulage_rate = haulage_rate_fixture()
      assert {:ok, %HaulageRate{}} = SystemUtilities.delete_haulage_rate(haulage_rate)

      assert_raise Ecto.NoResultsError, fn ->
        SystemUtilities.get_haulage_rate!(haulage_rate.id)
      end
    end

    test "change_haulage_rate/1 returns a haulage_rate changeset" do
      haulage_rate = haulage_rate_fixture()
      assert %Ecto.Changeset{} = SystemUtilities.change_haulage_rate(haulage_rate)
    end
  end
end
