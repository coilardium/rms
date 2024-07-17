defmodule RmsWeb.Router do
  use RmsWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug(RmsWeb.Plugs.SetUser)
    plug(RmsWeb.Plugs.SessionTimeout, timeout_after_seconds: 10_000)
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :session do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:put_secure_browser_headers)
  end

  pipeline :app do
    plug(:put_layout, {RmsWeb.LayoutView, :app})
  end

  pipeline :no_layout do
    plug :put_layout, false
  end

  scope "/", RmsWeb do
    pipe_through :browser

    get "/create/user", UserController, :new
    post "/create/user", UserController, :create
    get("/system/users", UserController, :index)
    get("/update/user", UserController, :edit)
    post("/update/user", UserController, :update)
    get("/change/user/password", UserController, :new_password)
    post("/change/user/password", UserController, :change_password)
    get("/user/activity/logs", UserController, :user_logs)
    post("/change/user/status", UserController, :change_user_status)
    get("/view/user/activities", UserController, :user_logs)
    get("/repair/users", UserController, :repair_users)
    get("/dashboard", UserController, :dashboard)
    post("/show/user", UserController, :show)
    post("/show/user/signture", UserController, :view_signture)
    post("/admin/assign/loco/driver", LocoDriverController, :create)
    get("/admin/assign/loco/driver", LocoDriverController, :create)
    get("/view/loco/drivers", LocoDriverController, :index)
    post("/change/loco/driver/status", LocoDriverController, :change_status)
    delete("/delete/loco/driver", LocoDriverController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:session])
    get("/forgort/password", UserController, :forgot_password)
    post("/confirmation/token", UserController, :token)
    get("/reset/password", UserController, :reset_password)
    post("/reset/password", UserController, :reset_password)
    get("/token/verification", SessionController, :entrust_token)
    post("/token/verification", SessionController, :confirm_token)
    get("/", SessionController, :new)
    post("/", SessionController, :create)
  end

  scope "/", RmsWeb do
    pipe_through([:browser])
    get("/signout", SessionController, :signout)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])
    get("/movement", MovementController, :movement)
    post("/movement", MovementController, :movement)
    get("/new/movement/order", MovementController, :movement_draft)
    get("/movement/order/verification/batch", MovementController, :movement_verification_batch)
    get("/train/intransit", MovementController, :movement_intransit_batch)
    get("/detached/wagons", MovementController, :movement_detached_batch)
    post("/attach/wagons", MovementController, :attach_detected_wagons)
    post("/mark/train/arrived", MovementController, :mark_train_arrived)
    get("/verify/movement/order", MovementController, :verify_movement)
    post("/verify/movement/order", MovementController, :verify_movement)
    post("/submit/movement/entries", MovementController, :submit_movement)
    get("/submit/movement/entries", MovementController, :submit_movement)
    get("/approve/movement/entries", MovementController, :approve_movement)
    post("/approve/movement/entries", MovementController, :approve_movement)
    post("/create/movement/order", MovementController, :create_movement)
    get("/create/movement/order", MovementController, :create_movement)
    post("/reject/movement/entries", MovementController, :reject_movement)
    get("/reject/movement/entries", MovementController, :rejected_movement)
    post("/discard/movement/entries", MovementController, :discard_movement)
    get("/new/movement", MovementController, :create_movement_batch)
    get("/movement/draft/:batch_id/entries", MovementController, :movement_draft_entries)
    get("/movement/batch/entries", MovementController, :movement_batch_entries)

    get(
      "/movement/batch/:batch_id/verification/entries",
      MovementController,
      :movement_verification_entries
    )

    get(
      "/intransit/:batch_id/train",
      MovementController,
      :movement_intransit_entries
    )

    get(
      "/detached/:batch_id/wagons",
      MovementController,
      :movement_detached_entries
    )

    get(
      "/intransit/:train_no/train/attachment",
      MovementController,
      :intransit_train_attachment
    )

    get(
      "/movement/:batch_id/pending/entries",
      MovementController,
      :movement_pending_entries
    )

    post(
      "/add/wagons/instransit/train",
      MovementController,
      :train_attachment
    )

    post("/movement/batch/entries/lookup", MovementController, :movement_batch_entries_lookup)
    get("/display/movement/entries", MovementController, :display_movement_details)
    get("/movenment/verification", MovementController, :consignment_verification)
    get("/movement/report/batch", MovementController, :movement_report_batch)
    get("/movement/movement/haulage/report", MovementController, :movement_haulage_report)

    get(
      "/movement/movement/customer/based/report",
      MovementController,
      :movement_customer_based_report
    )

    post("/movement/order/report/entries", MovementController, :movement_report_lookup)
    post("/movement/order/report/batch/entries", MovementController, :report_batch_entries_lookup)
    post("/movement/report/entry/lookup", MovementController, :movement_report_entry_lookup)
    get("/movement/order/report/batch/entries", MovementController, :report_batch_entries)
    get("/download/movement/batch/report/excel", MovementController, :excel_exp)
    post("/movement/monthly/income/summary/report", MovementController, :monthly_income_summary)
    get("/movement/monthly/income/summary/report", MovementController, :monthly_income_summary)

    post(
      "/create/movement/order/without/consignment",
      MovementController,
      :movement_without_consignment
    )

    get(
      "/create/movement/order/without/consignment",
      MovementController,
      :movement_without_consignment
    )

    get(
      "/movement/order/without/consignment/entries",
      MovementController,
      :movement_without_congnmt_batch
    )

    get("/modify/movement/batch/entries", MovementController, :edit_movement_entries)
    get("/modify/movement/:batch/batch/entries", MovementController, :edit_movement_entries)
    post("/movement/item/lookup", MovementController, :movement_item_lookup)
    post("/update/movement/batch/item", MovementController, :update_movement_item)
    post("/update/movement/entries", MovementController, :update_movement)
    get("/movement/pending/approval/entries", MovementController, :movement_pending_approval)
    get("/movement/search/locono", MovementController, :search_loco_number)
    get("/movement/search/station", MovementController, :search_station)
    get("/movement/station/owner", MovementController, :lookup_stn_owner)
    post("/movement/station/owner", MovementController, :lookup_stn_owner)
    get("/movement/reconciliation/report", MovementController, :mvt_recon_report)
    get("/movement/wagon/querry/report", MovementController, :mvt_wagon_querry_report)
    get("/new/works/order", MovementController, :works_order)
    post("/new/works/order", MovementController, :create_works_order)
    get("/works/order/report", MovementController, :works_order_report)
    post("/works/order/item/lookup", MovementController, :works_order_lookup)
    post("/detach/train/wagon", MovementController, :detach_wagon)
    get("/works/order/:id/file", MovementController, :works_order_pdf)
    post("/find/invoice/no", MovementController, :invoice_lookup)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])
    get("/new/wagon/tracking", WagonTrackingController, :index)
    post("/create/new/wagon/tracking", WagonTrackingController, :create)
    get("/create//new/wagon/tracking", WagonTrackingController, :create)
    post("/wagon/tracking/entries", WagonTrackingController, :view_wagon_tracker_entries)
    get("/view/wagon/tracking", WagonTrackingController, :view_wagon_tracker)
    get("/view/wagon/tracker", WagonTrackingController, :view_wagon_tracker_by_id)
    get("/wagon/position/report", WagonTrackingController, :view_wagon_position_report)
    post("/wagon/position/tracker/entries", WagonTrackingController, :view_wagon_position_entries)
    get("/wagon/position/tracker/entries", WagonTrackingController, :view_wagon_position_entries)
    get("/wagon/allocation/report", WagonTrackingController, :wagon_allocation_report)
    get("/wagon/summary/report", WagonTrackingController, :wagon_summary_report)

    post(
      "/wagon/allocation/tracker/entries",
      WagonTrackingController,
      :view_wagon_allocation_entries
    )

    get(
      "/wagon/allocation/tracker/entries",
      WagonTrackingController,
      :view_wagon_allocation_entries
    )

    get("/wagon/yard/position/report", WagonTrackingController, :view_wagon_yard_position_report)

    post(
      "/wagon/yard/position/entries",
      WagonTrackingController,
      :view_wagon_yard_position_entries
    )

    get(
      "/wagon/daily/position/report",
      WagonTrackingController,
      :view_wagon_daily_position_report
    )

    get("/wagon/delayed/report", WagonTrackingController, :view_wagon_delayed_report)

    post(
      "/wagon/daily/position/entries",
      WagonTrackingController,
      :view_wagon_daily_position_entries
    )

    post("/wagon/delayed/entries", WagonTrackingController, :view_wagon_delayed_entries)
    get("/wagon/condition/report", WagonTrackingController, :view_wagon_by_condition_report)
    post("/wagon/by/condition/entries", WagonTrackingController, :view_wagon_by_condition_entries)
    get("/daily/wagon/position", WagonTrackingController, :wagon_position)
    get("/delayed/wagon", WagonTrackingController, :list_wagon_delayed)
    post("/delayed/wagon", WagonTrackingController, :list_wagon_delayed)
    post("/wagon/bad/order/average/report", WagonTrackingController, :bad_order_average_lookup)
    get("/wagon/bad/order/average/report", WagonTrackingController, :bad_order_average_lookup)

    get(
      "/delayed/wagon/summary/report/pdf",
      WagonTrackingController,
      :delayed_wagons_generate_pdf
    )

    get("/wagon/summary/report/pdf", WagonTrackingController, :generate_wagon_summary_pdf)

    get(
      "/export/delayed/wagon/summary/report/pdf",
      WagonTrackingController,
      :delayed_wagons_generate_copy_pdf
    )

    get("/edit/wagon/tracker/details", WagonTrackingController, :edit_wagon_tracker_by_id)
    post("/wagon/bad/order/entries", WagonTrackingController, :bad_order_average_entries)
    get("/wagon/bad/order/entries", WagonTrackingController, :bad_order_average_entries)
    get("/bulk/wagon/tracking", WagonTrackingController, :bulk_tracking)
    post("/bulk/wagon/tracking", WagonTrackingController, :handle_bulk_upload)
    get("/bulk/wagon/tracking/upload/errors", WagonTrackingController, :file_upload_errors)
    get("/download/wagon/tracking/report/excel", WagonTrackingController, :wagon_tracking_exp)
    post("/movement/train/lookup", WagonTrackingController, :mvt_train_lookup)
    post("/save/new/wagon/tracker", WagonTrackingController, :save_tracker)
    get("/station/search", WagonTrackingController, :wagon_stn_search)
    get("/spare/search", WagonTrackingController, :wagon_spare_search)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get "/view/user/roles", UserRoleController, :index
    get "/new/user/role", UserRoleController, :new
    post "/new/user/role", UserRoleController, :create
    get "/update/user/:id/role", UserRoleController, :edit
    post "/update/user/role", UserRoleController, :update
    delete "/delete/user/role", UserRoleController, :delete
    post "/change/user/role/status", UserRoleController, :change_status
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get "/view/user/regions", UserRegionController, :index
    get "/new/user/region", UserRegionController, :new
    post "/new/user/region", UserRegionController, :create
    get "/update/user/:id/region", UserRegionController, :edit
    post "/update/user/region", UserRegionController, :update
    # get "/system/user/region", UserRegionController, :index
    delete "/delete/user/region", UserRegionController, :delete
    post "/change/user/region/status", UserRegionController, :change_status
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/cond/category", ConditionCategoryController, :index)
    post("/new/cond/category", ConditionCategoryController, :create)
    get("/ne/new/cond/category", ConditionCategoryController, :create)
    post("/change/user/cond/category/status", ConditionCategoryController, :change_status)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/consignment", ConsignmentController, :consignment)
    post("/save/consignment/order", ConsignmentController, :save_consignment)
    post("/submit/consignment/order", ConsignmentController, :submit_consignment)
    post("/verify/consignment/order/entries", ConsignmentController, :verification_consignment)
    post("/approve/consignment/order/entries", ConsignmentController, :approval_consignment)
    post("/discard/consignment/order/entries", ConsignmentController, :discard_consignment)
    get("/consignment/order/report/entries", ConsignmentController, :consignment_batch_report)

    post(
      "/consignment/order/report/entries",
      ConsignmentController,
      :consignment_report_batch_lookup
    )

    get(
      "/consignment/sales/order/report/entries",
      ConsignmentController,
      :consignment_batch_entries
    )

    get(
      "/consignment/sales/order/verification/batch",
      ConsignmentController,
      :consignment_verifcation_batches
    )

    post("/consignment/batch/entries", ConsignmentController, :consignment_batch_lookup)

    get(
      "/consignment/sales/order/approval/batch",
      ConsignmentController,
      :consignment_approval_batches
    )

    get(
      "/consignment/sales/order/invoice/batch",
      ConsignmentController,
      :consignment_invoice_batches
    )

    get("/consignment/verification/entries", ConsignmentController, :verify_consignment_entries)
    get("/consignment/approval/entries", ConsignmentController, :approve_consignment_entries)
    get("/consignment/invoice/list/entries", ConsignmentController, :invoice_consignment_entries)
    post("/consignment/order/invoicing", ConsignmentController, :consignment_invoicing)

    post(
      "/consignment/monthly/income/summary/report",
      ConsignmentController,
      :monthly_income_summary
    )

    get(
      "/consignment/monthly/income/summary/report",
      ConsignmentController,
      :monthly_income_summary
    )

    post("/consignment/haulage/invoice/report", ConsignmentController, :haulage_invoice)
    get("/consignment/haulage/invoice/report", ConsignmentController, :haulage_invoice)

    get(
      "/consignment/haulage/invoice/report/pdf",
      ConsignmentController,
      :haulage_invoice_generate_pdf
    )

    get(
      "/consignment/monthly/income/summary/report/pdf",
      ConsignmentController,
      :monthly_income_generate_pdf
    )

    get("/consignment/order/draft", ConsignmentController, :consignment_draft)
    get("/new/consignment/order", ConsignmentController, :new_consignment)
    get("/consignment/:batch_id/order/draft", ConsignmentController, :draft)
    get("/edit/consignment/batch/order", ConsignmentController, :modify_consignment)
    get("/rejected/consignments/batch", ConsignmentController, :rejected_consignment)
    post("/consignment/sales/order/lookup", ConsignmentController, :search_for_consignment)
    post("/find/consignment/sales/order", ConsignmentController, :lookup_consignment)
    post("/find/consignment/details", ConsignmentController, :mvt_search_for_consignment)

    post(
      "/consignment/sales/order/batch/entries",
      ConsignmentController,
      :consignment_sales_orders_batch_entries
    )

    get("/batch/entries", ConsignmentController, :batch_entries)
    get("/consignment/approval", ConsignmentController, :consignment_approval)
    post("/consignment/unmatched/aging/report", ConsignmentController, :unmatched_aging)
    get("/consignment/unmatched/aging/report", ConsignmentController, :unmatched_aging)

    get(
      "/consignment/unmatched/aging/report/pdf",
      ConsignmentController,
      :unmatched_aging_generate_pdf
    )

    get("/download/consignment/batch/report/excel", ConsignmentController, :excel_exp)
    get("/movement/consignment/manual/matching/report", ConsignmentController, :manual_matching)

    post(
      "/movement/consignment/manual/matching/report",
      ConsignmentController,
      :manual_matching_report_lookup
    )

    get(
      "/download/consignment/manual/matching/excel",
      ConsignmentController,
      :manual_matching_excel_exp
    )

    post("/umatched/movement/lookup", ConsignmentController, :unmatched_movement_lookup)
    post("/match/consignment/movement/entries", ConsignmentController, :manual_match_entries)
    post("/update/consignment/batch/item", ConsignmentController, :update_movement_item)
    post("/update/consignment/order/entries", ConsignmentController, :update_movement_entries)

    get(
      "/customer/based/consignment/list",
      ConsignmentController,
      :customer_based_consignment_list
    )

    get("/haulage/based/consignment/list", ConsignmentController, :haulage_export)
    get("/consignment/pending/approval", ConsignmentController, :consignment_pending_approval)

    get(
      "/consignment/pending/approval/entries",
      ConsignmentController,
      :consignment_pending_approval_entries
    )

    get("/ajax/search/client", ConsignmentController, :search_client_name)
    get("/ajax/search/consign/station", ConsignmentController, :search_station_name)
    get("/ajax/search/consign/commodity", ConsignmentController, :search_commodity)
    get("/consignment/reconciliation/report", ConsignmentController, :con_recon_report)
    get("/consignment/wagon/querry/report", ConsignmentController, :con_wagon_querry_report)
    get("/consignment/:id/delivery/note", ConsignmentController, :consign_delivery_note)
    post("/station/code/lookup", ConsignmentController, :station_code_lookup)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/locomotives", LocomotiveController, :index)
    get("/new/locomotive", LocomotiveController, :new)
    post("/new/locomotive", LocomotiveController, :create)
    get("/update/locomotive", LocomotiveController, :edit)
    post("/update/locomotive", LocomotiveController, :update)
    post("/change/locomotive/status", LocomotiveController, :change_status)
    delete("/delete/locomotive", LocomotiveController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/locomotive/types", LocomotiveTypeController, :index)
    get("/new/locomotive/type", LocomotiveTypeController, :new)
    post("/new/locomotive/type", LocomotiveTypeController, :create)
    get("/update/locomotive/type", LocomotiveTypeController, :edit)
    post("/update/locomotive/type", LocomotiveTypeController, :update)
    post("/change/locomotive/type/status", LocomotiveTypeController, :change_status)
    delete("/delete/locomotive/type", LocomotiveTypeController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/commodities", CommodityController, :index)
    get("/new/commodity", CommodityController, :new)
    post("/new/commodity", CommodityController, :create)
    get("/update/commodity", CommodityController, :edit)
    post("/update/commodity", CommodityController, :update)
    post("/change/commodity/status", CommodityController, :change_status)
    delete("/delete/commodity", CommodityController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/commodity/groups", CommodityGroupController, :index)
    get("/new/commodity/group", CommodityGroupController, :new)
    post("/new/commodity/group", CommodityGroupController, :create)
    get("/update/commodity/group", CommodityGroupController, :edit)
    post("/update/commodity/group", CommodityGroupController, :update)
    post("/change/commodity/group/status", CommodityGroupController, :change_status)
    delete("/delete/commodity/group", CommodityGroupController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/wagons", WagonController, :index)
    get("/new/wagon", WagonController, :new)
    post("/new/wagon", WagonController, :create)
    get("/update/wagon", WagonController, :edit)
    post("/update/wagon", WagonController, :update)
    post("/change/wagon/status", WagonController, :change_status)
    delete("/delete/wagon", WagonController, :delete)
    post("/wagon/lookup", WagonController, :wagon_lookup)
    post("/allocate/wagon", WagonController, :allocate_wagon)
    post("/view/wagons", WagonController, :wagon_fleet_lookup)
    get("/down/load/wagon/fleet/excel", WagonController, :wagon_fleet_excel)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/:type/wagon/types", WagonTypeController, :index)
    get("/new/wagon/type", WagonTypeController, :new)
    post("/new/wagon/type", WagonTypeController, :create)
    get("/update/wagon/type", WagonTypeController, :edit)
    post("/update/wagon/type", WagonTypeController, :update)
    post("/change/wagon/type/status", WagonTypeController, :change_status)
    delete("/delete/wagon/type", WagonTypeController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/stations", StationsController, :index)
    get("/new/station", StationsController, :new)
    post("/new/station", StationsController, :create)
    get("/update/station", StationsController, :edit)
    post("/update/station", StationsController, :update)
    post("/change/station/status", StationsController, :change_status)
    delete("/delete/station", StationsController, :delete)
    post("/station/lookup", StationsController, :station_lookup)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/fuel/rates", RatesController, :index)
    get("/new/fuel/rate", RatesController, :new)
    post("/new/fuel/rate", RatesController, :create)
    get("/update/fuel/rate", RatesController, :edit)
    post("/update/fuel/rate", RatesController, :update)
    post("/change/fuel/rate/status", RatesController, :change_status)
    delete("/delete/fuel/rate", RatesController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/routes", TrainRouteController, :index)
    get("/new/route", TrainRouteController, :new)
    post("/new/route", TrainRouteController, :create)
    get("/update/route", TrainRouteController, :edit)
    post("/update/route", TrainRouteController, :update)
    post("/change/route/status", TrainRouteController, :change_status)
    delete("/delete/route", TrainRouteController, :delete)
    post("/view/routes", TrainRouteController, :train_route_lookup)
    get("/download/train/route/excel", TrainRouteController, :train_route_excel)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/wagon/statuses", WagonStatusController, :index)
    get("/new/wagon/status", WagonStatusController, :new)
    post("/new/wagon/status", WagonStatusController, :create)
    get("/update/wagon/status", WagonStatusController, :edit)
    post("/update/wagon/status", WagonStatusController, :update)
    post("/change/wagon/stat", WagonStatusController, :change_status)
    delete("/delete/wagon/status", WagonStatusController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/wagon/conditions", WagonConditionController, :index)
    get("/new/wagon/condition", WagonConditionController, :new)
    post("/new/wagon/condition", WagonConditionController, :create)
    get("/update/wagon/condition", WagonConditionController, :edit)
    post("/update/wagon/condition", WagonConditionController, :update)
    post("/change/wagon/condition/status", WagonConditionController, :change_status)
    delete("/delete/wagon/condition", WagonConditionController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/railway/administrators", RailwayAdministratorController, :index)
    get("/new/railway/administrator", RailwayAdministratorController, :new)
    post("/new/railway/administrator", RailwayAdministratorController, :create)
    get("/update/railway/administrator", RailwayAdministratorController, :edit)
    post("/update/railway/administrator", RailwayAdministratorController, :update)
    post("/change/railway/administrator/status", RailwayAdministratorController, :change_status)
    delete("/delete/railway/administrator", RailwayAdministratorController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/contries", CountryController, :index)
    get("/new/country", CountryController, :new)
    post("/new/country", CountryController, :create)
    get("/update/country", CountryController, :edit)
    post("/update/country", CountryController, :update)
    post("/change/country/status", CountryController, :change_status)
    delete("/delete/country", CountryController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/regions", RegionController, :index)
    get("/new/region", RegionController, :new)
    post("/new/region", RegionController, :create)
    get("/update/region", RegionController, :edit)
    post("/update/region", RegionController, :update)
    post("/change/region/status", RegionController, :change_status)
    delete("/delete/region", RegionController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/domains", DomainController, :index)
    get("/new/domain", DomainController, :new)
    post("/new/domain", DomainController, :create)
    get("/update/domain", DomainController, :edit)
    post("/update/domain", DomainController, :update)
    post("/change/domain/status", DomainController, :change_status)
    delete("/delete/domain", DomainController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/transport/types", TransportTypeController, :index)
    get("/new/transport/type", TransportTypeController, :new)
    post("/new/transport/type", TransportTypeController, :create)
    get("/update/transport/type", TransportTypeController, :edit)
    post("/update/transport/type", TransportTypeController, :update)
    post("/change/transport/type/status", TransportTypeController, :change_status)
    delete("/delete/transport/type", TransportTypeController, :delete)
    get("/search/transport/type", TransportTypeController, :search_transport_type)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/currencies", CurrencyController, :index)
    get("/new/currency", CurrencyController, :new)
    post("/new/currency", CurrencyController, :create)
    get("/update/currency", CurrencyController, :edit)
    post("/update/currency", CurrencyController, :update)
    post("/change/currency/status", CurrencyController, :change_status)
    delete("/delete/currency", CurrencyController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/payment/types", PaymentTypeController, :index)
    get("/new/payment/type", PaymentTypeController, :new)
    post("/new/payment/type", PaymentTypeController, :create)
    get("/update/payment/type", PaymentTypeController, :edit)
    post("/update/payment/type", PaymentTypeController, :update)
    post("/change/payment/type/status", PaymentTypeController, :change_status)
    delete("/delete/payment/type", PaymentTypeController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/clients", ClientsController, :index)
    get("/new/client", ClientsController, :new)
    post("/new/client", ClientsController, :create)
    get("/update/client", ClientsController, :edit)
    post("/update/client", ClientsController, :update)
    post("/change/client/status", ClientsController, :change_status)
    delete("/delete/client", ClientsController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/exchange/rates", ExchangeRateController, :index)
    get("/new/exchange/rate", ExchangeRateController, :new)
    post("/new/exchange/rate", ExchangeRateController, :create)
    get("/update/exchange/rate", ExchangeRateController, :edit)
    post("/update/exchange/rate", ExchangeRateController, :update)
    post("/change/exchange/rate/status", ExchangeRateController, :change_status)
    delete("/delete/exchange/rate", ExchangeRateController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/locomotive/models", LocomotiveModelController, :index)
    get("/new/locomotive/model", LocomotiveModelController, :new)
    post("/new/locomotive/model", LocomotiveModelController, :create)
    get("/update/locomotive/model", LocomotiveModelController, :edit)
    post("/update/locomotive/model", LocomotiveModelController, :update)
    post("/change/locomotive/model/status", LocomotiveModelController, :change_status)
    delete("/delete/locomotive/model", LocomotiveModelController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/surcharges", SurchageController, :index)
    get("/new/surcharge", SurchageController, :new)
    post("/new/surcharge", SurchageController, :create)
    get("/update/surcharge", SurchageController, :edit)
    post("/update/surcharge", SurchageController, :update)
    post("/change/surcharge/status", SurchageController, :change_status)
    delete("/delete/surcharge", SurchageController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/tariff/line", TariffLineController, :index)
    post("/view/tariff/line", TariffLineController, :customer_tarriffline_lookup)
    get("/new/tariff/line", TariffLineController, :new)
    post("/new/tariff/line", TariffLineController, :create)
    get("/update/tariff/line", TariffLineController, :edit)
    post("/update/tariff/line", TariffLineController, :update)
    post("/change/tariff/line/status", TariffLineController, :change_status)
    delete("/delete/tariff/line", TariffLineController, :delete)
    post("/tariff/line/lookup", TariffLineController, :tariff_lookup)
    post("/tarriff/line/rate/lookup", TariffLineController, :tariff_rate_lookup)
    delete("/delete/tarriff/line/rate", TariffLineController, :delete_tariff_rate)
    get("/download/tariff/line/rates/excel", TariffLineController, :tarriffline_excel)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/:type/defects", DefectController, :index)
    get("/new/defect", DefectController, :new)
    post("/new/defect", DefectController, :create)
    get("/update/defect", DefectController, :edit)
    post("/update/defect", DefectController, :update)
    post("/change/defect/status", DefectController, :change_status)
    delete("/delete/defect", DefectController, :delete)
    post("/wagon/tracking/defects/lookup", DefectController, :defects_lookup)
    post("/defect/spares/lookup", DefectController, :defect_spare_lookup)
    delete("/delete/defect/spare", DefectController, :delete_spare)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/spares", SpareController, :index)
    get("/new/spare", SpareController, :new)
    post("/new/spare", SpareController, :create)
    get("/update/spare", SpareController, :edit)
    post("/update/spare", SpareController, :update)
    post("/change/spare/status", SpareController, :change_status)
    delete("/delete/spare", SpareController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/spare/fees", SpareFeeController, :index)
    get("/new/spare/fee", SpareFeeController, :new)
    post("/new/spare/fee", SpareFeeController, :create)
    get("/update/spare/fee", SpareFeeController, :edit)
    post("/update/spare/fee", SpareFeeController, :update)
    post("/change/spare/fee/status", SpareFeeController, :change_status)
    delete("/delete/spare/fee", SpareFeeController, :delete)
    post("/admin/defect/spare/rates/lookup", SpareFeeController, :admin_defect_spare_lookup)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/interchange/wagon/rates", InterchangeFeeController, :index)
    get("/new/interchange/fee", InterchangeFeeController, :new)
    post("/new/interchange/fee", InterchangeFeeController, :create)
    get("/update/interchange/fee", InterchangeFeeController, :edit)
    post("/update/interchange/fee", InterchangeFeeController, :update)
    post("/change/interchange/fee/status", InterchangeFeeController, :change_status)
    delete("/delete/interchange/fee", InterchangeFeeController, :delete)
    post("/interchange/fee/lookup", InterchangeFeeController, :interchange_fee_lookup)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])
    get("/new/interchange", InterchangeController, :index)
    post("/create/interchange", InterchangeController, :create)
    get("/interchange/approvals", InterchangeController, :interchange_approval)

    get(
      "/interchange/approve/batch/:id/entries",
      InterchangeController,
      :interchange_batch_entries
    )

    post(
      "/interchange/approve/batch/entries",
      InterchangeController,
      :interchange_batch_entries_lookup
    )

    post("/interchange/defect/lookup", InterchangeController, :interchange_defect_lookup)

    post(
      "/interchange/onhire/spare/lookup",
      InterchangeController,
      :interchange_defect_spare_lookup
    )

    post("/close/interchange", InterchangeController, :close_interchange)
    post("/reject/interchange", InterchangeController, :reject_interchange)
    get("/rejected/interchange", InterchangeController, :interchange_rejected_batch)

    get(
      "/interchange/rejected/batch/:id/entries",
      InterchangeController,
      :interchange_rejected_batch_entries
    )

    get(
      "/interchange/approved/outgoing/batch/entries",
      InterchangeController,
      :interchange_on_hire_outgoing_batch
    )

    get(
      "/interchange/approved/incoming/batch/entries",
      InterchangeController,
      :interchange_on_hire_incoming_batch
    )

    get(
      "/interchange/on/hire/batch/:id/entries",
      InterchangeController,
      :interchange_on_hire_batch_entries
    )

    post(
      "/interchange/on/hire/batch/entries",
      InterchangeController,
      :on_hire_interchange_entries_lookup
    )

    post(
      "/set/interchange/batch/off/hire",
      InterchangeController,
      :set_interchange_batch_off_hire
    )

    post(
      "/set/single/interchange/off/hire",
      InterchangeController,
      :set_single_interchange_off_hire
    )

    get("/interchange/:type/report", InterchangeController, :interchange_report)
    post("/interchange/report/lookup", InterchangeController, :interchange_report_lookup)

    post(
      "/interchange/report/incoming/outgoing/lookup",
      InterchangeController,
      :interchange_report_lookup
    )

    post(
      "/interchange/report/hired/wagons/lookup",
      InterchangeController,
      :interchange_report_lookup
    )

    post("/interchange/train/lookup", InterchangeController, :train_no_lookup)

    get(
      "/interchange/batch/report/entries",
      InterchangeController,
      :interchange_batch_report_entries
    )

    get("/interchange/list/report/entries", InterchangeController, :interchange_list_report)

    get(
      "/download/interchange/onhire/report/excel",
      InterchangeController,
      :interchange_excel_exp
    )

    post("/set/wagon/hire/status", InterchangeController, :set_hire)
    get("/incoming/wagons/off/hire", InterchangeController, :incoming_wagons_off_hire)
    get("/incoming/wagons/on/hire", InterchangeController, :incoming_wagons_on_hire)
    get("/outgoing/wagons/off/hire", InterchangeController, :outgoing_wagons_off_hire)
    get("/outgoing/wagons/on/hire", InterchangeController, :outgoing_wagons_on_hire)
    get("/new/interchange/materials", InterchangeController, :materials)
    post("/new/interchange/materials", InterchangeController, :track_material)
    get("/incoming/interchange/materials", InterchangeController, :incoming_materials)
    get("/outgoing/interchange/materials", InterchangeController, :outgoing_materials)
    post("/interchange/material/lookup", InterchangeController, :interchange_report_lookup)
    get("/new/auxiliary/hire", InterchangeController, :auxiliary_hire)
    post("/new/auxiliary/hire", InterchangeController, :create_auxiliary_hire)
    get("/incoming/auxiliary/hire", InterchangeController, :incoming_auxiliary_hire)
    get("/outgoing/auxiliary/hire", InterchangeController, :outgoing_auxiliary_hire)
    post("/auxiliary/lookup", InterchangeController, :interchange_report_lookup)
    post("/auxiliary/daily/summary/lookup", InterchangeController, :interchange_report_lookup)
    post("/set/auxiliary/off/hire", InterchangeController, :off_hire_auxiliary)
    get("/incoming/auxiliary/report", InterchangeController, :incoming_auxiliary_report)
    get("/outgoing/auxiliary/report", InterchangeController, :outgoing_auxiliary_report)
    post("/auxiliary/item/lookup", InterchangeController, :auxiliary_lookup)
    get("/interchange/wagon/tracking", InterchangeController, :wagon_tracking)
    post("/track/wagon", InterchangeController, :track_wagon)
    post("/archive/hire/auxiliary", InterchangeController, :archive_hire_auxiliary)
    get("/auxiliary/tracking", InterchangeController, :auxiliary_tracking)
    post("/auxiliary/tracking/lookup", InterchangeController, :auxiliary_tracking_lookup)
    post("/auxiliary/tracking", InterchangeController, :track_auxiliary)
    post("/locomotive/detention", InterchangeController, :create_loco_detention)
    get("/locomotive/detention", InterchangeController, :loco_detention)
    get("/incoming/locomotive", InterchangeController, :incoming_locomotive)
    get("/outgoing/locomotive", InterchangeController, :outgoing_locomotive)
    get("/incoming/locomotive/report", InterchangeController, :incoming_locomotive_report)
    get("/outgoing/locomotive/report", InterchangeController, :outgoing_locomotive_report)
    post("/locomotive/detention/lookup", InterchangeController, :interchange_report_lookup)
    post("/haulage/report/lookup", InterchangeController, :interchange_report_lookup)

    post(
      "/locomotive/detention/summary/lookup",
      InterchangeController,
      :interchange_report_lookup
    )

    post("/archive/locomotive/detention", InterchangeController, :archive_loco_detention)
    post("/locomotive/item/lookup", InterchangeController, :loco_item_lookup)
    post("/haulage/item/lookup", InterchangeController, :haulage_item_lookup)
    get("/locomotive/detention/summary/report", InterchangeController, :locomotive_summary_report)
    get("/auxiliary/daily/summary/report", InterchangeController, :auxiliary_daily_summary_report)
    get("/interchange/haulage", InterchangeController, :new_haulage)
    get("/interchange/incoming/haulage/report", InterchangeController, :incoming_haulage_report)
    get("/interchange/outgoing/haulage/report", InterchangeController, :outgoing_haulage_report)
    post("/interchange/haulage", InterchangeController, :create_haulage)
    post("/foreign/wagon/tracking", InterchangeController, :handle_bulk_upload)
    get("/foreign/wagon/tracking", InterchangeController, :foreign_wagon_tracking)
    get("/foreign/wagon/tracking/exceptions", InterchangeController, :foreign_tracking_exceptions)
    post("/interchange/exceptions", InterchangeController, :interchange_report_lookup)
    get("/download/exception/file", InterchangeController, :download_exception_file)
    get("/mechanical/bills/report", InterchangeController, :mechanical_bills_report)
    get("/new/demurrage", InterchangeController, :demurrage)
    post("/new/demurrage", InterchangeController, :create_demurrage)
    get("/demurrage/report", InterchangeController, :demurrage_report)
    post("/demurrage/report", InterchangeController, :interchange_report_lookup)
    post("/demurrage/item/lookup", InterchangeController, :demurrage_lookup)
    get("/bulk/auxiliary/tracking", InterchangeController, :bulk_auxiliary_tracking)
    post("/bulk/auxiliary/tracking", InterchangeController, :auxiliary_bulk_tracker)
    get("/current/account/report", InterchangeController, :current_acc_report)
    post("/current/account/report", InterchangeController, :current_acc_report)
    get("/modify/wagon/:id/hire", InterchangeController, :modify_wagon_hire)
    get("/modify/auxililary/:id/hire", InterchangeController, :modify_auxiliary_hire)
    post("/modify/auxililary/hire", InterchangeController, :update_auxiliary)
    get("/modify/:id/haulage", InterchangeController, :modify_haulage)
    post("/modify/haulage", InterchangeController, :update_haulage)
    get("/modify/:id/locomotive", InterchangeController, :modify_locomotive)
    post("/modify/locomotive", InterchangeController, :update_loco_detention)
    get("/modify/:id/material", InterchangeController, :modify_material)
    post("/modify/material", InterchangeController, :update_material)
    post("/delete/defects", InterchangeController, :delete_defects)
    post("/update/wagon/hire", InterchangeController, :update_wagon_hire)
    post("/interchange/wagon/turn/around", InterchangeController, :wagon_turn_around)
    get("/interchange/wagon/turn/around", InterchangeController, :wagon_turn_around)
    post("/works/order/report", InterchangeController, :interchange_report_lookup)
    get("/interchange/account/summary/report", InterchangeController, :account_summary_report)
    post("/interchange/account/summary/report", InterchangeController, :account_summary_report)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])
    get("/fuel/monitoring", FuelMonitoringController, :fuel_monitoring)
    post("/create/fuel/monitor", FuelMonitoringController, :submit_fuel_request)
    get("/create/fuel/monitor", FuelMonitoringController, :submit_fuel_request)
    get("/view/fuel/monitor", FuelMonitoringController, :fuel_monitor)
    get("/new/fuel/monitor", FuelMonitoringController, :fuel_order)
    get("/fuel/control/view", FuelMonitoringController, :control_fuel_verification)
    get("/fuel/back/office/approval", FuelMonitoringController, :back_office_fuel_approval)

    get(
      "/view/pending/completion/fuel/entries",
      FuelMonitoringController,
      :pending_completion_entries
    )

    get("/approve/view/:id/requisite", FuelMonitoringController, :approver_view_fuel_form)
    post("/approve/view/:id/requisite", FuelMonitoringController, :approver_view_fuel_form)
    get("/initiator/view/:id/requisite", FuelMonitoringController, :pending_completion_entries)
    post("/initiator/view/:id/requisite", FuelMonitoringController, :pending_completion_entries)
    get("/form/completion/:id/requisite", FuelMonitoringController, :view_completion_form)
    post("/form/completion/:id/requisite", FuelMonitoringController, :view_completion_form)
    post("/display/fuel/requisite/details", FuelMonitoringController, :display_requisiste_details)
    get("/display/fuel/requisite/details", FuelMonitoringController, :display_requisiste_details)
    post("/verify/fuel/entries", FuelMonitoringController, :fuel_verification_entries)
    get("/verify/fuel/entries", FuelMonitoringController, :fuel_verification_entries)
    post("/control/submit/fuel/form", FuelMonitoringController, :control_submit_fuel_request)
    get("/control/submit/fuel/form", FuelMonitoringController, :control_submit_fuel_request)
    post("/submit/form/approval", FuelMonitoringController, :submit_form_approval)
    get("/submit/form/approval", FuelMonitoringController, :submit_form_approval)

    post(
      "/backoffice/submit/form/:id/requisite",
      FuelMonitoringController,
      :back_office_form_details
    )

    get(
      "/backoffice/submit/form/:id/requisite",
      FuelMonitoringController,
      :back_office_form_details
    )
    post("/backoffice/edit/fuel/:id/requiste", FuelMonitoringController, :backoffice_edit_requiste)
    get("/backoffice/edit/fuel/:id/requiste", FuelMonitoringController, :backoffice_edit_requiste)


    post("/approve/fuel/requisite/order", FuelMonitoringController, :approve_fuel_requisite)
    get("/approve/fuel/requisite/order", FuelMonitoringController, :approve_fuel_requisite)
    post("/reject/fuel/requisite/order", FuelMonitoringController, :reject_fuel_requisite)
    get("/reject/fuel/requisite/order", FuelMonitoringController, :reject_fuel_requisite)
    post("/update/fuel/requisite", FuelMonitoringController, :update_fuel_request)
    get("/view/rejected/fuel/requisites", FuelMonitoringController, :rejected_requisite_table)

    post(
      "/fuel/rejected/form/:id/requisite",
      FuelMonitoringController,
      :rejected_requisite_details
    )

    get(
      "/fuel/rejected/form/:id/requisite",
      FuelMonitoringController,
      :rejected_requisite_details
    )

    get(
      "/view/rejected/fuel/requisites/:id/requisite",
      FuelMonitoringController,
      :rejected_requisite_table
    )

    post(
      "/view/rejected/fuel/requisites/:id/requisite",
      FuelMonitoringController,
      :rejected_requisite_table
    )

    get("/view/complete/requisites", FuelMonitoringController, :fuel_requisite_table)
    get("/view/fuel/report/entries", FuelMonitoringController, :fuel_report_entries)

    post(
      "/view/fuel/report/entries/:id/requisite",
      FuelMonitoringController,
      :fuel_report_entries
    )

    get("/view/fuel/report/entries/:id/requisite", FuelMonitoringController, :fuel_report_entries)
    post("/fuel/requisite/report/lookup", FuelMonitoringController, :fuel_requisite_report_lookup)
    get("/view/exco/report", FuelMonitoringController, :fuel_exco_report)
    post("/view/exco/report", FuelMonitoringController, :fuel_exco_report)
    post("/view/depo/summary/report", FuelMonitoringController, :depo_summary_report)
    get("/view/depo/summary/report", FuelMonitoringController, :depo_summary_report)
    post("/section/summary/report", FuelMonitoringController, :section_summary_report)
    get("/section/summary/report", FuelMonitoringController, :section_summary_report)

    get(
      "/fuel/section//summary/report/pdf",
      FuelMonitoringController,
      :section_summary_generate_pdf
    )

    get(
      "/download/fuel/requisite/batch/report/excel",
      FuelMonitoringController,
      :fuel_req_excel_exp
    )

    get("/fuel/depo/summary/report/pdf", FuelMonitoringController, :depo_summary_generate_pdf)
    post("/lookup/fuel/rate", FuelMonitoringController, :lookup_fuel_rate)
    post("/weekly/summary/report", FuelMonitoringController, :weekly_fuel_report)
    get("/weekly/summary/report", FuelMonitoringController, :weekly_fuel_report)
    get("/depo/period/report", FuelMonitoringController, :depo_period_report)
    post("/depo/period/report", FuelMonitoringController, :depo_period_report)
    get("/weekly/fuel/smry/report/pdf", FuelMonitoringController, :weekly_fuel_smry_report_pdf)


    get(
      "/initiator/view/pending/approval/list",
      FuelMonitoringController,
      :requisite_pending_approval_list
    )

    get(
      "/initiator/pending/approval/form/:id/requisite",
      FuelMonitoringController,
      :pending_req_form
    )

    post("/lookup/loco/capacity", FuelMonitoringController, :lookup_loco_type)
    get("/monthly/report", FuelMonitoringController, :monthly_report)
    post("/monthly/report", FuelMonitoringController, :monthly_report)
    post("/load/depo/summry/rept", FuelMonitoringController, :load_depo_report)
    get("/ajax/select/locomotive", FuelMonitoringController, :lookup_loco_number)
    post("/loco/capacity/lookup", FuelMonitoringController, :loco_capacty_lookup)
    get("/ajax/search/station", FuelMonitoringController, :search_station_name)
    get("/ajax/search/user", FuelMonitoringController, :search_user_name)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/maintain/train/type", TrainTypeController, :index)
    post("/maintain/train/type", TrainTypeController, :create)
    get("/create/train/type", TrainTypeController, :create)
    post("/update/train/type", TrainTypeController, :update)
    post("/change/train/type/status", TrainTypeController, :change_status)
    delete("/delete/train/type", TrainTypeController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/company/infomation", CompanyInfoController, :index)
    get("/new/company/infomation", CompanyInfoController, :new)
    post("/new/company/infomation", CompanyInfoController, :create)
    get("/update/company/infomation", CompanyInfoController, :edit)
    post("/update/company/infomation", CompanyInfoController, :update)
    post("/change/company/infomation/status", CompanyInfoController, :change_status)
    delete("/delete/company/infomation", CompanyInfoController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    post("/maintain/distance", DistanceController, :index)
    get("/maintain/distance", DistanceController, :index)
    post("/create/new/distance", DistanceController, :create)
    get("/create/new/distance", DistanceController, :create)
    get("/update/distance", DistanceController, :edit)
    post("/update/distance", DistanceController, :update)
    post("/change/distance/status", DistanceController, :change_status)
    delete("/delete/distance", DistanceController, :delete)
    post("/distance/km/lookup", DistanceController, :distnace_km_lookup)
    post("/view/distance", DistanceController, :filter_distance_lookup)
    get("/view/distance", DistanceController, :filter_distance_lookup)
    get("/distance/excel", DistanceController, :distance_excel)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/email/list", NotificationController, :index)
    post("/new/email", NotificationController, :create)
    get("/update/:id/email", NotificationController, :edit)
    post("/update/email", NotificationController, :update)
    delete("/delete/email", NotificationController, :delete)
    post("/change/email/status", NotificationController, :change_status)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/refueling/type", RefuelingTypeController, :index)
    get("/create/refueling/type", RefuelingTypeController, :create)
    post("/create/refueling/type", RefuelingTypeController, :create)
    get("/update/refueling/type", RefuelingTypeController, :update)
    post("/update/refueling/type", RefuelingTypeController, :update)
    post("/change/refuel/type/status", RefuelingTypeController, :change_status)
    delete("/refuel/type", RefuelingTypeController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/new/section", SectionController, :index)
    get("/create/section", SectionController, :create)
    post("/create/section", SectionController, :create)
    get("/update/section", SectionController, :update)
    post("/update/section", SectionController, :update)
    post("/change/section/status", SectionController, :change_status)
    delete("/delete/section", SectionController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])
    get("/new/mvt/exception", MovementExceptionController, :index)
    get("/create/mvt/exception", MovementExceptionController, :create)
    post("/create/mvt/exception", MovementExceptionController, :create)
    get("/update/mvt/exception", MovementExceptionController, :update)
    post("/update/mvt/exception", MovementExceptionController, :update)
    post("/change/mvt/exception/status", MovementExceptionController, :change_status)
    delete("/delete/mvt/exception", MovementExceptionController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/equipments", EquipmentController, :index)
    get("/new/equipment", EquipmentController, :new)
    post("/new/equipment", EquipmentController, :create)
    get("/update/equipment", EquipmentController, :edit)
    post("/update/equipment", EquipmentController, :update)
    post("/change/equipment/status", EquipmentController, :change_status)
    delete("/delete/equipment", EquipmentController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/equipment/rates", EquipmentRateController, :index)
    get("/new/equipment/rate", EquipmentRateController, :new)
    post("/new/equipment/rate", EquipmentRateController, :create)
    get("/update/equipment/rate", EquipmentRateController, :edit)
    post("/update/equipment/rate", EquipmentRateController, :update)
    post("/change/equipment/rate/status", EquipmentRateController, :change_status)
    delete("/delete/equipment/rate", EquipmentRateController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/locomotive/detention/rates", LocoDetentionRateController, :index)
    get("/new/locomotive/detention/rate", LocoDetentionRateController, :new)
    post("/new/locomotive/detention/rate", LocoDetentionRateController, :create)
    get("/update/locomotive/detention/rate", LocoDetentionRateController, :edit)
    post("/update/locomotive/detention/rate", LocoDetentionRateController, :update)
    post("/change/locomotive/detention/rate/status", LocoDetentionRateController, :change_status)
    delete("/delete/locomotive/detention/rate", LocoDetentionRateController, :delete)
  end

  scope "/", RmsWeb do
    pipe_through([:browser, :app])

    get("/view/haulage/rates", HaulageRateController, :index)
    get("/new/haulage/rate", HaulageRateController, :new)
    post("/new/haulage/rate", HaulageRateController, :create)
    get("/update/haulage/rate", HaulageRateController, :edit)
    post("/update/haulage/rate", HaulageRateController, :update)
    post("/change/haulage/rate/status", HaulageRateController, :change_status)
    delete("/delete/haulage/rate", HaulageRateController, :delete)
  end

  # Other scopes may use custom stacks.
  # scope "/api", RmsWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should puts
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboarddd", metrics: RmsWeb.Telemetry
    end
  end
end
