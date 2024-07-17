jQuery.fn.dataTable.Api.register('sum()', function() {
    return this.flatten().reduce(function(a, b) {
        if (typeof a === 'string') {
            a = a.replace(/[^\d.-]/g, '') * 1;
        }
        if (typeof b === 'string') {
            b = b.replace(/[^\d.-]/g, '') * 1;
        }

        return a + b;
    }, 0);
});


function formartAmount(amt) {
    return Number(amt).toLocaleString(undefined, {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

function is_amount_key(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode != 46 && (charCode < 48 || charCode > 57)))
        return false;
    return true;
}

function isAmountKey(evt, obj) {
    var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode != 46 && (charCode < 48 || charCode > 57)))
        return false;
    // return obj.value.search(/^[0-9]{0,3}.?[0-9]{0,3}$/) == 0 ? true : false;
    return true;
}

function is_number_key(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;
    return true;
}


////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////
$(document).ready(function() {

    jQuery.fn.dataTable.Api.register('sum()', function() {
        return this.flatten().reduce(function(a, b) {
            if (typeof a === 'string') {
                a = a.replace(/[^\d.-]/g, '') * 1;
            }
            if (typeof b === 'string') {
                b = b.replace(/[^\d.-]/g, '') * 1;
            }

            return a + b;
        }, 0);
    });

    var spinner = $('#loader');

    var is_container;
    var data = [];
    var consgmt_wagon_num;
    var rate = {};
    var show_loco_number;
    var show_locomotive_type;
    var show_loco_driver;
    var show_train_origin_stn;
    var show_train_distin_stn;
    var show_train_type;
    var show_commercial_clark;
    var show_depo_stn;
    var data_row = [];
    var movement_wagon_num;
    var movement_origin_stn;
    var movement_destin_stn;
    var movement_commodity;
    var show_consigner;
    var show_consignee;
    var show_payer;
    var show_code;
    var status;
    var consign_smry_data = [
        { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 },
        { "header": "Total", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 }
    ];

    var dt_consignment = $('#dt-consignment').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        data: consign_smry_data,
        columns: [
            { data: "header" },
            { data: "rsz" },
            { data: "nlpi" },
            { data: "nll" },
            { data: "tfr" },
            { data: "tzr" },
            { data: "tzr_project" },
            { data: "additional_chg" }

        ]

    });


    //display of consignment order
    var dt_orders = $('#dt-orders').DataTable({
        scrollY: "50vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        'columnDefs': [{
                "targets": 0,
                "width": "50%",
                "className": "text-center"
            },
            {
                "targets": 0,
                "className": "text-center"

            }
        ],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "capacity_tonnes" },
            { data: "actual_tonnes" },
            { data: "tariff_tonnage" },
            { data: "container_no" },
            { data: "comment" },
            { data: "rsz" },
            { data: "nlpi" },
            { data: "nll_2005" },
            { data: "tfr" },
            { data: "tzr" },
            { data: "tzr_project" },
            { data: "additional_chg" },
            { data: "invoice_number" },
            //   { data: "train_number" },
            //   { data: "move_date" },
            { data: "total" },
            { data: "status" },
        ]
    });

    // locomotive type table

    var dt_loco_type = $('#dt_loco_type').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_loco_type tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_loco_type tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#view_modal').modal('show');
    });

    $('#dt_loco_type tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/locomotive/type/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_loco_type.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_loco_type tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/locomotive/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_loco_type.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Locomotive type deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_loco_driver').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    // Tarriff line table

    var dt_tariff_line = $('#dt_tariff_line').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 7,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 8,
                "width": "12",
                "className": "text-center"
            }
        ],
    });


    $('#dt_tariff_line tbody').on('click', '.edit', function() {
        var button = $(this);
        $('.field-clr').val('');
        $('#edit_start_dt').val(button.attr("data-start_dt"));
        $('#edit_additional_chg').val(button.attr("data-additional_chg"));
        $('#edit_tzr_project').val(button.attr("data-tzr_project"));
        $('#edit_orig_station_id').val(button.attr("data-orig_station_id"));
        $('#edit_tzr').val(button.attr("data-tzr"));
        $('#edit_tfr').val(button.attr("data-tfr"));
        $('#edit_tfr').val(button.attr("data-tfr"));
        $('#edit_nll_2005').val(button.attr("data-nll_2005"));
        $('#edit_nlpi').val(button.attr("data-nlpi"));
        $('#edit_rsz').val(button.attr("data-rsz"));
        $('#edit_surcharge_id').val(button.attr("data-surcharge_id"));
        $('#edit_currency_id').val(button.attr("data-currency_id"));
        $('#edit_pay_type_id').val(button.attr("data-pay_type_id"));
        $('#edit_commodity_id').val(button.attr("data-commodity_id"));
        $('#edit_client_id').val(button.attr("data-client_id"));
        $('#edit_destin_station_id').val(button.attr("data-destin_station_id"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_tariff_line tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_start_dt').val(button.attr("data-start_dt"));
        $('#vw_additional_chg').val(button.attr("data-additional_chg"));
        $('#vw_tzr_project').val(button.attr("data-tzr_project"));
        $('#vw_orig_station_id').val(button.attr("data-orig_station_id"));
        $('#vw_tzr').val(button.attr("data-tzr"));
        $('#vw_tfr').val(button.attr("data-tfr"));
        $('#vw_tfr').val(button.attr("data-tfr"));
        $('#vw_nll_2005').val(button.attr("data-nll_2005"));
        $('#vw_nlpi').val(button.attr("data-nlpi"));
        $('#vw_rsz').val(button.attr("data-rsz"));
        $('#vw_surcharge_id').val(button.attr("data-surcharge_id"));
        $('#vw_currency_id').val(button.attr("data-currency_id"));
        $('#vw_pay_type_id').val(button.attr("data-pay_type_id"));
        $('#vw_commodity_id').val(button.attr("data-commodity_id"));
        $('#vw_client_id').val(button.attr("data-client_id"));
        $('#vw_destin_station_id').val(button.attr("data-destin_station_id"));
        $('#vw_id').val(button.attr("data-id"));
        $('#view_modal').modal('show');
    });

    $('#dt_tariff_line tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/tariff/line/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_tariff_line.cell($tr, 7).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_tariff_line tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/tariff/line',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_tariff_line.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Tariff line deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // loco Model table

    var dt_loco_model = $('#dt_loco_model').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_loco_model tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_self_weight').val(button.attr("data-self_weight"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_loco_model tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/locomotive/model/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_loco_model.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_loco_model tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/locomotive/model',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_loco_model.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Locomotive model deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //  spare part table

    var dt_spares = $('#dt_spares').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_spares tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_spares tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#view_modal').modal('show');
    });

    $('#dt_spares tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/spare/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_spares.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_spares tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/spare',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_spares.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Spare Part deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // defects table

    var dt_defect = $('#dt_defect').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_defect tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_defect tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/defect/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_defect.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_defect tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/defect',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_defect.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Defect deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // interchange fee table

    var dt_interchange_fee = $('#dt_interchange_fee').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 6,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 5,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_interchange_fee tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_lease_lease_period').val(button.attr("data-lease_period"));
        $('#edit_year').val(button.attr("data-year"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency').val(button.attr("data-currency"));
        $('#edit_partner').val(button.attr("data-partner"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_interchange_fee tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/interchange/fee/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_interchange_fee.cell($tr, 5).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_interchange_fee tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/interchange/fee',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_interchange_fee.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Interchange fee deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // spare part fee table


    var dt_spare_fee = $('#dt_spare_fee').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_spare_fee tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_start_date').val(button.attr("data-start_date"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency_id').val(button.attr("data-currency"));
        $('#edit_spare_id').val(button.attr("data-spare"));
        // $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_spare_fee tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/spare/fee/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_spare_fee.cell($tr, 4).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_spare_fee tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/spare/fee',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_spare_fee.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Spare fee deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //surcharge Table

    var dt_surcharge = $('#dt_surcharge').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_surcharge tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_surcharge_percent').val(button.attr("data-surcharge_percent"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_surcharge tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/surcharge/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_surcharge.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_surcharge tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/surcharge',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_surcharge.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Surcharge deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });



    //commodity group

    var dt_commodity_group = $('#dt_commodity_group').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_commodity_group tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#description').val(button.attr("data-description"));
        $('#code').val(button.attr("data-code"));
        $('#id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_commodity_group tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#view_modal').modal('show');
    });

    $('#dt_commodity_group tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/commodity/group/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_commodity_group.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_commodity_group tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/commodity/group',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_commodity_group.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Locomotive deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //wgons table

    var dt_wgons = $('#dt_wgons').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 5,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_wgons tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_wagon_type').val(button.attr("data-type"));
        $('#edit_wagon_owner').val(button.attr("data-owner"));

        $('#edit_modal').modal('show');
    });

    $('#dt_wgons tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_wagon_type').val(button.attr("data-type"));
        $('#vw_wagon_owner').val(button.attr("data-owner"));

        $('#view_modal').modal('show');
    });

    $('#dt_wgons tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/wagon/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_wgons.cell($tr, 4).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_wgons tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/wagon',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_wgons.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Wagon deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //wgon Types table

    var dt_wagon_types = $('#dt_wagon_types').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 6,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 5,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_wagon_types tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_capacity').val(button.attr("data-capacity"));
        $('#edit_weight').val(button.attr("data-weight"));
        $('#edit_type').val(button.attr("data-type"));

        $('#edit_modal').modal('show');
    });

    $('#dt_wagon_types tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/wagon/type/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_wagon_types.cell($tr, 5).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_wagon_types tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/wagon/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_wagon_types.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Wagon type deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //commodity table
    var dt_commodity = $('#dt_commodity').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 3,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "12",
                "className": "text-center"
            }
        ],
    });


    $('#dt_commodity tbody').on('click', '.edit-commodity', function() {
        var button = $(this);
        $('#edit_com_group_id').val(button.attr("data-group-id"));
        $('#edit_is_container').val(button.attr("data-is-container"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_commodity tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_group').val(button.attr("data-group"));
        $('#vw_container').val(button.attr("data-is-container"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#view_modal').modal('show');
    });


    $('#dt_commodity tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/commodity/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_commodity.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_commodity tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/commodity',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_commodity.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Commodity deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //locomotives table

    var dt_locomotive = $('#dt_locomotive').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 6,
                "width": "14",
                "className": "text-center"
            }
        ],
    });


    $('#dt_locomotive tbody').on('click', '.edit-locomotive', function() {
        var button = $(this);
        $('#edit_type_id').val(button.attr("data-type_id"));
        $('#edit_loco_number').val(button.attr("data-loco_number"));
        $('#edit_weight').val(button.attr("data-weight"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_locomotive tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(button.attr("data-checker"));
        $('#maker').val(button.attr("data-maker"));
        $('#status').val(button.attr("data-status"));
        $('#vw_type_id').val(button.attr("data-type_id"));
        $('#vw_loco_number').val(button.attr("data-loco_number"));
        $('#vw_weight').val(button.attr("data-weight"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_model').val(button.attr("data-model"));
        $('#vw_id').val(button.attr("data-id"));
        $('#view_modal').modal('show');

    });


    $('#dt_locomotive tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/locomotive/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_locomotive.cell($tr, 5).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_locomotive tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/locomotive',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_locomotive.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Locomotive deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //stations table

    var dt_stations = $('#dt_stations').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "14",
                "className": "text-center"
            }
        ],
    });


    $('#dt_stations tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_acronym').val(button.attr("data-acronym"));
        $('#edit_station').val(button.attr("data-station"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_stations tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/station/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_stations.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_stations tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/station',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_stations.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Station deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // currency table

    var dt_currency = $('#dt_currency').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_currency tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_symbol').val(button.attr("data-symbol"));
        $('#edit_acronym').val(button.attr("data-acronym"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_currency tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/currency/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_currency.cell($tr, 4).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_currency tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/currency',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_currency.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Currency deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //counry table

    var dt_country = $('#dt_country').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_country tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_country tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/country/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_country.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_country tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/country',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_country.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Country deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //wagon condition table

    var dt_wagon_condition = $('#dt_wagon_condition').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });


    $('#dt_wagon_condition tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_status').val(button.attr("data-status"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_wagon_condition tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/wagon/condition/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_wagon_condition.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_wagon_condition tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/wagon/condition',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_wagon_condition.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Wagon status deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //clients table

    var dt_clients = $('#dt_clients').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 6,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_clients tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_email').val(button.attr("data-email"));
        $('#edit_address').val(button.attr("data-address"));
        $('#edit_phone_number').val(button.attr("data-phone_number"));
        $('#edit_client_account').val(button.attr("data-client_account"));
        $('#edit_client_name').val(button.attr("data-client_name"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_clients tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/client/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_clients.cell($tr, 5).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_clients tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/client',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_clients.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Client deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //exchange rate Table
    var dt_exchange_rate = $('#dt_exchange_rate').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_exchange_rate tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_exchange_rate').val(button.attr("data-exchange_rate"));
        $('#edit_start_date').val(button.attr("data-start_date"));
        $('#edit_first_currency').val(button.attr("data-first_currency"));
        $('#edit_second_currency').val(button.attr("data-second_currency"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_exchange_rate tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/exchange/rate/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_exchange_rate.cell($tr, 4).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_exchange_rate tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/exchange/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_exchange_rate.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Excahange rate deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // payment types table

    var dt_payment_type = $('#dt_payment_type').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_payment_type tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_payment_type tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/payment/type/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_payment_type.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_payment_type tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/payment/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_payment_type.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Payment type deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    // railway admins table

    var dt_railway_admin = $('#dt_railway_admin').DataTable({
        responsive: true,
    });

    $('#wagon-code').on('change', function() {
        var wagon_type = $(this).find(':selected').attr('data-wagon-type');
        var wagon_owner = $(this).find(':selected').attr('data-wagon-owner');
        $('#wagon-type').val(wagon_type);
        $('#wagon-owner').val(wagon_owner);

    });

    $('#dt_railway_admin tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_country').val(button.attr("data-country"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_railway_admin tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/railway/administrator/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_railway_admin.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_railway_admin tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/railway/administrator',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_railway_admin.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Railway administrator deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // fuel rate Table

    var dt_fuel_rate = $('#dt_fuel_rate').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12"
            },
            {
                "targets": 5,
                "width": "12"
            }
        ],
    });

    $('#dt_fuel_rate tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_refueling_depo').val(button.attr("data-refueling_depo"));
        $('#edit_month').val(button.attr("data-month"));
        $('#edit_fuel_rate').val(button.attr("data-fuel_rate"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_fuel_rate tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/fuel/rate/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_fuel_rate.cell($tr, 4).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_fuel_rate tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/fuel/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_fuel_rate.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Fuel rate deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //wagon status table

    var dt_wagon_status = $('#dt_wagon_status').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12"
            },
            {
                "targets": 3,
                "width": "12"
            }
        ],
    });

    $('#dt_wagon_status tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_status').val(button.attr("data-rec_status"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_wagon_status tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/wagon/stat',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_wagon_status.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_wagon_status tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/wagon/status',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_wagon_status.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Wagon status deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //dt_train route

    var dt_train_route = $('#dt_train_route').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 7,
                "width": "12"
            },
            {
                "targets": 8,
                "width": "12"
            }
        ],
    });

    $('#dt_train_route tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_origin_station').val(button.attr("data-origin_station"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_operator').val(button.attr("data-operator"));
        $('#edit_distance').val(button.attr("data-distance"));
        $('#edit_transport_type').val(button.attr("data-transport_type"));
        $('#edit_destination_station').val(button.attr("data-destination_station"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_train_route tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/route/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_train_route.cell($tr, 7).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_train_route tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/wagon/status',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_train_route.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Route deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // transport type table

    var dt_transport_type = $('#dt_transport_type').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12"
            },
            {
                "targets": 3,
                "width": "12"
            }
        ],
    });

    $('#dt_transport_type tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_type').val(button.attr("data-type"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_transport_type tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/transport/type/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_transport_type.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_transport_type tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/transport/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_transport_type.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Transport type deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // user roles

    if ($('#edit-role-form').length) {
        $("input[type='checkbox']").each(function() {
            var $this = this;
            if ($this.getAttribute("data-role-val") == 'Y')
                $this.checked = true;
        });
    }


    var dt_user_role = $('#dt_user_role').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "12"
            },
            {
                "targets": 3,
                "width": "12"
            }
        ],
    });

    $('#payer_name').on('change', function() {
        show_payer = $(this).find(':selected').attr('data-payer');
    });



    $('#dt_user_role tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/user/role/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_user_role.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_user_role tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/user/role',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_user_role.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'User role deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    // users table
    var dt_user = $('#dt_user').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12"
            },
            {
                "targets": 6,
                "width": "12"
            }
        ],
    });

    $('#dt_user tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#email').val(button.attr("data-email"));
        $('#mobile').val(button.attr("data-mobile"));
        $('#first_name').val(button.attr("data-first_name"));
        $('#last_name').val(button.attr("data-last_name"));
        $('#role').val(button.attr("data-role"));
        $('#id').val(button.attr("data-id"));
        $('#edit_user').modal('show');
    });

    $('#dt_user tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/user/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_user.cell($tr, 5).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('.tariff-lookup').on('change', function() {
        if ($('#origin_tariff').val().length < 1 || $('#destin_tariff').val().length < 1 || $('#client_id').val().length < 1) {
            return false;
        }
        $.ajax({
            url: '/tariff/line/lookup',
            type: 'post',
            data: {
                "client_id": $('#client_id').val(),
                "orign_station": $('#origin_tariff').val(),
                "destin_station": $('#destin_tariff').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    rate = { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 };
                } else {
                    rate = result.data[0];
                    var surcharge_percent = rate.surcharge ? (rate.surcharge.surcharge_percent / 100) : null;
                    $('#surcharge-percent').val(surcharge_percent);

                }
                var data = dt_consignment.rows().data();
                data[0].rsz = rate.rsz;
                data[0].nlpi = rate.nlpi;
                data[0].nll = rate.nll_2005 ? rate.nll_2005 : rate.nll;
                data[0].tfr = rate.tfr;
                data[0].tzr = rate.tzr;
                data[0].tzr_project = rate.tzr_project;
                data[0].additional_chg = rate.additional_chg ? rate.additional_chg : 0.00;
                dt_consignment.row(0).data(data[0]).draw();
            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

    $('#wagon-code').on('change', function() {
        var wagon_type = $(this).find(':selected').attr('data-wagon-type');
        var wagon_owner = $(this).find(':selected').attr('data-wagon-owner');
        consgmt_wagon_num = $(this).find(':selected').attr('data-wagon-code');
        $('#wagon-type').val(wagon_type);
        $('#wagon-owner').val(wagon_owner);

    });

    $('#edit-wagon-code').on('change', function() {
        var wagon_type = $(this).find(':selected').attr('data-wagon-type');
        var wagon_owner = $(this).find(':selected').attr('data-wagon-owner');
        $('#edit-wagon-type').val(wagon_type);
        $('#edit-wagon-owner').val(wagon_owner);

    });

    $('#close_add_order').on('click', function() {

        if (($('#client_id').val() == "") ||
            ($('#destin_tariff').val() == "") ||
            ($('#origin_tariff').val() == ""))

        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        $('#add_order').modal('show');
        $('.field-clr').val('');

        if (is_container == 'Yes') {
            $('.its_a_container').val('');

        } else {
            $('.not_a_container').val('');
        }

    });

    $('#commodity_type').on('change', function() {
        var commodity_type = $(this).find(':selected').attr('data-commodity-type');
        is_container = commodity_type;

        if (commodity_type == 'Yes') {

            $('#capacity-tonnes').attr('readonly', true);
            $('#capacity-tonnes').val('0');
            $('#actual-tonnes').attr('readonly', true);
            $('#actual-tonnes').val('0');
            $('#tariff-tonnage').attr('readonly', true);
            $('#tariff-tonnage').val('0');
            $('#total-containers').attr('readonly', false);


        } else {

            $('#total-containers').attr('readonly', true);
            $('#total-containers').val('0');
            $('#capacity-tonnes').attr('readonly', false);
            $('#actual-tonnes').attr('readonly', false);
            $('#tariff-tonnage').attr('readonly', false);
        }

    });

    $('#save-consignment').click(function() {

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_orders.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        var consignment_smry_data = [
            { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 },
            { "header": "Total", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 }
        ];
        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_orders.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_orders.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/save/consignment/order',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Consignment order saved successfully!',
                                'success'
                            )
                            dt_orders.clear().rows.add([]).draw();
                            dt_consignment.clear().rows.add(consignment_smry_data).draw();
                            $('.clear_form').val('');

                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('#submit-consignment').click(function() {

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_orders.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        var consignment_smry_data = [
            { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 },
            { "header": "Total", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 }
        ];
        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_orders.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_orders.rows().data()[index], details));
        }


        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            closeOnConfirm: false,
            closeOnCancel: false,
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/submit/consignment/order',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch: $('#batch_id').val(), client_id: $('#client_id').val(), sale_order: $('#sale_order').val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Consignment order submited successfully!',
                                'success'
                            )
                            dt_orders.clear().rows.add([]).draw();
                            dt_consignment.clear().rows.add(consignment_smry_data).draw();
                            $('.clear_form').val('');

                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('.verify-entries').click(function() {
        var button = $(this);
        if (dt_orders_report.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/verify/consignment/order/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch: $('#batch_id').val(), status: button.attr("data-status") },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            window.location.replace("/consignment/sales/order/verification/batch");

                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('.approve-consgmt-entries').click(function() {
        var button = $(this);

        if (dt_orders_report.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            closeOnConfirm: false,
            closeOnCancel: false,
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/approve/consignment/order/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch: $('#batch_id').val(), status: button.attr("data-status") },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            window.location.replace("/consignment/sales/order/approval/batch");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // $('#dt_movement').DataTable({
    //     responsive: true,
    //     bFilter: false,
    //     bInfo: false,

    //     'columnDefs': [{
    //             "targets": 2,
    //             "width": "12",
    //             "className": "text-center"
    //         },
    //         {
    //             "targets": 3,
    //             "width": "12",
    //             "className": "text-center"
    //         }
    //     ],
    // });


    $('#select-batch').change(function() {
        batch_id = $(this).find(':selected').attr('data-batch-id');
        $('#selected-batch-id').val(batch_id);
    });


    if ($('#client').length) {
        $.ajax({
            url: '/pending/consignment/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                _csrf_token: $("#csrf").val(),
                client_id: $('#client').val(),
                orign_station: $('#origin_tariff_id').val(),
                destin_station: $('#destin_tariff_id').val(),

            },
            success: function(result) {

                if (result.data.length < 1) {
                    rate = { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 };
                } else {
                    rate = result.data;

                    dt_orders.clear().rows.add(rate).draw();

                    if (result.rate && result.rate !== "null" && result.rate !== "undefined") {
                        var total_rsz = dt_orders.column(8).data().sum();
                        var total_nlpi = dt_orders.column(9).data().sum();
                        var total_nll = dt_orders.column(10).data().sum();
                        var total_tfr = dt_orders.column(11).data().sum();
                        var total_tzr = dt_orders.column(12).data().sum();
                        var total_tzr_project = dt_orders.column(13).data().sum();
                        var total_additional_chg = dt_orders.column(14).data().sum();

                        var newData = { "header": "Total", "rsz": total_rsz, "nlpi": total_nlpi, "nll": total_nll, "tfr": total_tfr, "tzr": total_tzr, "tzr_project": total_tzr_project, "additional_chg": total_additional_chg };

                        $('#wagon_count').val(dt_orders.rows().count());

                        $('#total_tonnage').val(dt_orders.column(5).data().sum());
                        var total_amount = total_rsz + total_nlpi + total_nll + total_tfr + total_tzr + total_tzr_project + total_additional_chg;
                        $('#total_amount').val(total_amount);


                        dt_consignment.row(1).data(newData).draw();

                        var surcharge_total = Number(((result.rate.surcharge.surcharge_percent / 100) * total_amount)).toFixed(2)
                        $('#surcharge_total').val(surcharge_total);
                        var vat_total = $("#vat-percentage").val() * total_amount;
                        $('#vat_total').val(vat_total);

                        // console.log(total_amount)
                        // console.log(surcharge_total)
                        // console.log(vat_total)
                        // var a = total_amount + vat_total + ((result.rate.surcharge.surcharge_percent / 100) * total_amount)
                        // console.log(a)

                        $('#overall_total').val(total_amount + ((result.rate.surcharge.surcharge_percent / 100) * total_amount) + vat_total);


                    }

                }


            },

            error: function(request, msg, error) {
                //  spinner.hide();
                //  console.log($('#client').val())
                //  swal({
                //      title: "Oops...",
                //      text: "Something went wrong!",
                //      confirmButtonColor: "#EF5350",
                //      type: "error"
                //  });
            }
        });
    }

    $('#dt-orders tbody').on('click', 'tr', function() {
        var values = dt_orders.row(this).data()
        $('#edit-wagon-owner').val(values.wagon_owner);
        $('#edit-wagon-type').val(values.wagon_type);
        $('#edit-capacity-tonnes').val(values.capacity_tonnes);
        $('#edit-actual-tonnes').val(values.actual_tonnes);
        $('#edit-tariff-tonnage').val(values.tariff_tonnage);
        $('#edit-total-containers').val(values.container_no);
        $('#edit-comment').val(values.comment);
        $('#edit-index').val(dt_orders.row(this).index());
        $('#edit_order').modal('show');
    });


    $('#edit-order-consign').on('click', function() {
        var wagon_number = $("#edit-wagon-code").val();
        var wagon_owner = $("#edit-wagon-owner").val();
        var wagon_type = $("#edit-wagon-type").val();
        var capacity_tonnes = $("#edit-capacity-tonnes").val();
        var actual_tonnes = $("#edit-actual-tonnes").val();
        var tariff_tonnage = $("#edit-tariff-tonnage").val();
        var container_no = $("#edit-total-containers").val();
        var comment = $("#edit-comment").val();
        var index = $("#edit-index").val();
        console.log(wagon_number)

        // validation and sweet alert to notify user to enter required fields
        if ((wagon_number == "") ||
            (wagon_owner == "") ||
            (wagon_type == "") ||
            (capacity_tonnes == "") ||
            (actual_tonnes == "") ||
            (tariff_tonnage == "") ||
            (container_no == ""))

        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }


        if (container_no == '0') {

            var rsz = rate.rsz * capacity_tonnes;
            var nlpi = rate.nlpi * capacity_tonnes;
            var nll_2005 = rate.nll_2005 * capacity_tonnes;
            var tfr = rate.tfr * capacity_tonnes;
            var tazar = rate.tzr * capacity_tonnes;
            var project = rate.tzr_project * capacity_tonnes;
            var additional_chg = rate.additional_chg * capacity_tonnes;


        } else {

            var rsz = rate.rsz * container_no;
            var nlpi = rate.nlpi * container_no;
            var nll_2005 = rate.nll_2005 * container_no;
            var tfr = rate.tfr * container_no;
            var tazar = rate.tzr * container_no;
            var project = rate.tzr_project * container_no;
            var additional_chg = rate.additional_chg * container_no;


        }

        var consign_smry_data = [{
                "wagon_id": 6,
                "wagon_owner": wagon_owner,
                "wagon_type": wagon_type,
                "capacity_tonnes": capacity_tonnes,
                "actual_tonnes": actual_tonnes,
                "tariff_tonnage": tariff_tonnage,
                "container_no": container_no,
                "comment": comment,
                "rsz": "00",
                "nlpi": nlpi,
                "nll_2005": nll_2005,
                "tfr": tfr,
                "tzr": tazar,
                "tzr_project": project,
                "additional_chg": additional_chg,
                "invoice_number": "",
                //  "train_number": "",
                //  "move_date": "",
                "total": "",
                "status": "PENDING"
            },

        ];


        // dt_orders.rows.add().draw(false);
        dt_orders.row(index).data(consign_smry_data).draw();
        var total_rsz = dt_orders.column(8).data().sum();
        var total_nlpi = dt_orders.column(9).data().sum();
        var total_nll = dt_orders.column(10).data().sum();
        var total_tfr = dt_orders.column(11).data().sum();
        var total_tzr = dt_orders.column(12).data().sum();
        var total_tzr_project = dt_orders.column(13).data().sum();
        var total_additional_chg = dt_orders.column(14).data().sum();


        var total_amount = total_rsz + total_nlpi + total_nll + total_tfr + total_tzr + total_tzr_project + total_additional_chg;
        $('#total_amount').val(total_amount);

        var get_surcharge = $("#surcharge-percent").val();

        var surcharge_total = get_surcharge * total_amount;
        $('#surcharge_total').val(surcharge_total);


        var get_vat = $("#vat-percentage").val();
        var vat_total = get_vat * total_amount;
        $('#vat_total').val(vat_total);

        var overall_total = total_amount + surcharge_total + vat_total;
        $('#overall_total').val(overall_total);

        $('#wagon_count').val(dt_orders.rows().count());
        $('#total_tonnage').val(dt_orders.column(5).data().sum());


        var newData = { "header": "Total", "rsz": total_rsz, "nlpi": total_nlpi, "nll": total_nll, "tfr": total_tfr, "tzr": total_tzr, "tzr_project": total_tzr_project, "additional_chg": total_additional_chg };

        dt_consignment.row(1).data(newData).draw();


    });


    if ($('#client_id').length) {
        var type = $('#client_id').attr('client_id_data');
        $('#client_id').val(type);
        $('#client_id').trigger('change');
    }

    if ($('#reporting_station_id').length) {
        var type = $('#reporting_station_id').attr('reporting_station_id_data');
        $('#reporting_station_id').val(type);
        $('#reporting_station_id').trigger('change');
    }

    if ($('#commodity_type').length) {
        var type = $('#commodity_type').attr('commodity_id_data');
        $('#commodity_type').val(type);
        $('#commodity_type').trigger('change');
    }

    if ($('#origin_station_id').length) {
        var type = $('#origin_station_id').attr('data_origin_station_id');
        $('#origin_station_id').val(type);
        $('#origin_station_id').trigger('change');
    }

    if ($('#origin_tariff').length) {
        var type = $('#origin_tariff').attr('data_origin_tariff');
        $('#origin_tariff').val(type);
        $('#origin_tariff').trigger('change');
    }

    if ($('#final_destination').length) {
        var type = $('#final_destination').attr('final_destination_data');
        $('#final_destination').val(type);
        $('#final_destination').trigger('change');
    }

    if ($('#destin_tariff').length) {
        var type = $('#destin_tariff').attr('tariff_destination_data');
        $('#destin_tariff').val(type);
        $('#destin_tariff').trigger('change');
    }

    if ($('#consigner').length) {
        var type = $('#consigner').attr('consigner_data');
        $('#consigner').val(type);
        $('#consigner').trigger('change');
    }

    if ($('#consignee').length) {
        var type = $('#consignee').attr('consignee_data');
        $('#consignee').val(type);
        $('#consignee').trigger('change');
    }

    if ($('#payer').length) {
        var type = $('#payer').attr('payer_data');
        $('#payer').val(type);
        $('#payer').trigger('change');
    }

    $('#create-usr-role').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                var data = $("form").serialize();
                spinner.show();
                $.ajax({
                    url: '/new/user/role',
                    type: 'POST',
                    data: data,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $("input[type='checkbox']").each(function() {
                                this.checked = false;
                            });
                            $('#role-desc').val('');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Oops...',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#update-usr-role').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                var data = $("form").serialize();
                spinner.show();
                $.ajax({
                    url: '/update/user/role',
                    type: 'POST',
                    data: data,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Oops...',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('#confirmpassword').keyup(function(e) {
        //get values 
        var pass = $('#password').val();
        var confpass = $(this).val();

        //check the strings
        if (pass == confpass) {
            //if both are same remove the error and allow to submit
            $('.error').text('');
            allowsubmit = true;
        } else {
            //if not matching show error and not allow to submit
            $('.error').text('Password not matching');
            allowsubmit = false;
        }
    });

    //jquery form submit
    $('.change-pass-form').submit(function() {

        var pass = $('#password').val();
        var confpass = $('#confirmpassword').val();

        //just to make sure once again during submit
        //if both are true then only allow submit
        if (pass == confpass) {
            allowsubmit = true;
        }
        if (allowsubmit) {
            $('.change-pass-form').find('button[type=submit]').prop('disabled', true);
            $(".change-pass-submit").html('please wait...');
            return true;
        } else {
            return false;
        }
    });



    //MOVEMENT JS

    // set consign wagon type and owner on movement form

    $('#wagon-number').on('change', function() {
        var wagon_type = $(this).find(':selected').attr('data-wagon-type');
        var wagon_owner = $(this).find(':selected').attr('data-wagon-owner');
        movement_wagon_num = $(this).find(':selected').attr('data-wagon-number');
        show_code = $(this).find(':selected').attr('data-wagon-number');

        $('#wagon-type').val(wagon_type);
        $('#wagon-owner').val(wagon_owner);
        var row = {
            "wagon_code": $('#wagon-number').val(),
            "wagon_owner": $('#wagon-owner').val(),
        };
        // dt_movement.row(0).data(data[0]).draw();
    });

    //display of movement order
    var dt_movement = $('#dt_movement').DataTable({
        scrollY: "50vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        'columnDefs': [{
                "targets": 0,
                "width": "50%",
                "className": "text-center"
            },
            {
                "targets": 0,
                "className": "text-center"

            }
        ],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "origin_name" },
            { data: "destination_name" },
            { data: "commodity_name" },
            { data: "consigner_name" },
            { data: "consignee_name" },
            { data: "container_no" },
            { data: "sales_order" },
            { data: "station_code" },
            { data: "consignment_date" },
            { data: "payer" },
            { data: "status" }
        ]
    });

    $('#origin_station').on('change', function() {
        movement_origin_stn = $(this).find(':selected').attr('data-orgin-station');
    });

    $('#final_destination').on('change', function() {
        movement_destin_stn = $(this).find(':selected').attr('data-destin-stn');
    });

    $('#commodity').on('change', function() {
        movement_commodity = $(this).find(':selected').attr('data-commodity');
    });

    $('#consigner').on('change', function() {
        show_consigner = $(this).find(':selected').attr('data-consigner');
    });

    $('#consignee').on('change', function() {
        show_consignee = $(this).find(':selected').attr('data-consignee');
    });

    $('#payer_name').on('change', function() {
        show_payer = $(this).find(':selected').attr('data-payer');
    });

    // display of movement 

    $('#save-movement').on('click', function() {
        var wagon_number = movement_wagon_num;
        var wagon_code = show_code;
        var wagon_owner = $("#wagon-owner").val();
        var wagon_type = $("#wagon-type").val();
        var origin = $("#origin").val();
        var origin_name = movement_origin_stn;
        var destination = $("#destination").val();
        var destination_name = movement_destin_stn;
        var commodity = $("#commodity").val();
        var commodity_name = movement_commodity;
        var consigner = $("#consigner").val();
        var consigner_name = show_consigner;
        var consignee = $("#consignee").val();
        var consignee_name = show_consignee;
        var container_no = $("#container-no").val();
        var sales_order = $("#sales-order").val();
        var station_code = $("#station-code").val();
        var consignment_date = $("#Consignment-date").val();
        var payer_name = $("#payer_name").val();


        // validation and sweet alert to notify user to enter required fields
        if ((wagon_number == "") ||
            (wagon_owner == "") ||
            (wagon_type == "") ||
            (consigner == "") ||
            (consignee == "") ||
            (container_no == "") ||
            (sales_order == "") ||
            (commodity == ""))

        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if ($('#wagon-number').length) {
            var type = $('#wagon-number').attr('data-wagon-number');

        }

        var movement_data = [{
            "wagon_id": $("#wagon-number").val(),
            "wagon_code": wagon_code,
            "wagon_owner": wagon_owner,
            "wagon_type": wagon_type,
            "origin_station_id": origin,
            "origin_name": origin_name,
            "destination": destination,
            "destin_station_id": destination,
            "destination_name": destination_name,
            "commodity_id": commodity,
            "commodity_name": commodity_name,
            "consigner": consigner,
            "consigner_name": consigner_name,
            "consignee": consignee,
            "consignee_name": consignee_name,
            "container_no": container_no,
            "origin": $("#origin").val(),
            "sales_order": sales_order,
            "station_code": station_code,
            "consignment_date": consignment_date,
            "payer": show_payer,
            "payer_id": payer_name,
            "status": "PENDING",

        }, ];
        dt_movement.rows.add(movement_data).draw(false);
        $('.add_movement').modal('hide');
    });

    //movement form display 
    if ($('#loco_id').length) {
        var type = $('#loco_id').attr('data_loco_no');
        $('#loco_id').val(type);
        $('#loco_id').trigger('change');
    }

    if ($('#dead_loco').length) {
        var type = $('#dead_loco').attr('data_dead_loco');
        $('#dead_loco').val(type);
        $('#dead_loco').trigger('change');

    }

    if ($('#origin').length) {
        var type = $('#origin').attr('data_origin_station');
        $('#origin').val(type);
        $('#origin').trigger('change');
    }

    if ($('#destination').length) {
        var type = $('#destination').attr('data_destin_station');
        $('#destination').val(type);
        $('#destination').trigger('change');
    }

    if ($('#reporting_station').length) {
        var type = $('#reporting_station').attr('data_reporting_station');
        $('#reporting_station').val(type);
        $('#reporting_station').trigger('change');

    }

    $('#close_add_movement').on('click', function() {
        $('#add_movement').modal('show');
        $('.field-clr').val('');

    });


    $('#submit-movement').click(function() {
        var a = dt_movement.rows().data()
        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_movement.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_movement.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_movement.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to save this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/create/movement/order',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order saved successfuly!',
                                'success'
                            )
                            window.location.replace("/new/movement/order");

                            $('.clear_form').val('');
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //submit movement for approval
    $('#movement-submit').click(function() {
        var a = dt_movement.rows().data()
        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_movement.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_movement.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_movement.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to submit this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/submit/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val() },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order submited for approval!',
                                'success'
                            )
                            window.location.replace("/new/movement/order");

                            $('.clear_form').val('');
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //display of movement details

    if ($('#train_no').length) {

        $.ajax({
            url: '/display/movement/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                console.log(result.data)
                dt_movement.rows.add(result.data).draw(false);


            },

            error: function(request, msg, error) {
                //  spinner.hide();
                //  console.log($('#client').val())
                //  swal({
                //      title: "Oops...",
                //      text: "Something went wrong!",
                //      confirmButtonColor: "#EF5350",
                //      type: "error"
                //  });
            }
        });
    }

    $('#approve-movement-entries').click(function() {
        var a = dt_movement.rows().data()
        var button = $(this);
        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_movement.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_movement.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_movement.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to approve this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/approve/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), status: button.attr("data-status") },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order approved successfully!',
                                'success'
                            )
                            window.location.replace("/movement/order/verification/batch");

                            $('.clear_form').val('');
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#reject-movement-entries').click(function() {
        var a = dt_movement.rows().data()
        var button = $(this);
        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_movement.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_movement.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_movement.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to reject this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/reject/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), status: button.attr("data-status") },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order has been rejected!',
                                'success'
                            )
                            window.location.replace("/movement/order/verification/batch");

                            $('.clear_form').val('');
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //fuel monitoring j.s


    $('#depo_refueled').on('change', function() {
        var fuel_rate = $(this).find(':selected').attr('data-depo-rate');
        $('#fuel_rate').val(fuel_rate);

    });

    $("#reading_after_refuel").on("input", function() {
        var after_refuel = $('#reading_after_refuel').val();
        var before_refuel = $('#balance_before_refuel').val();
        var total_refueled = after_refuel - before_refuel;
        var rate = $('#fuel_rate').val();
        var total_cost = rate * total_refueled;
        $('#summary_quantity_refueled').val(total_refueled);
    });

    $("#summary_quantity_refueled").on("input", function() {
        var refueled_qty = $('#summary_quantity_refueled').val();
        var refuel_authorized = $('#approved_refuel').val();
        var total_difference = refuel_authorized - refueled_qty;
        $('#deff_ctc_actual').val(total_difference);
        var before_refuel = $('#balance_before_refuel').val();
        var after_reading = parseFloat(refueled_qty) + parseFloat(before_refuel);
        $('#reading_after_refuel').val(after_reading);

    });

    $("#bp_meter_after").on("input", function() {
        var bp_metre_after = $('#bp_meter_after').val();
        var bp_metre_before = $('#bp_meter_before').val();
        var reading = bp_metre_after - bp_metre_before;
        $('#reading').val(reading);
        var meter_at_destin = $('#meter_at_destin').val();
        var consumed_fuel = reading - meter_at_destin;
        $('#fuel_consumed').val(consumed_fuel);

        var consumption = $('#km_to_destin').val();
        var reading = $('#reading').val();

        var consumpt_per_km = reading / consumption;
        $('#consumption_per_km').val(consumpt_per_km);

        var rate = $('#fuel_rate').val();
        var total_cost = reading * rate;
        $('#total_cost').val(total_cost);

    });

    // $("#summary_quantity_refueled").on("input", function(){
    //     var meter_at_destin = $('#meter_at_destin').val();
    //     var reading = $('#reading').val();
    //     var consumed_fuel = reading - meter_at_destin;
    //     $('#fuel_consumed').val(consumed_fuel);
    // });

    var dt_interchange_defect = $('#dt-interchange-defect').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 4,
            "width": "12",
            "className": "text-center"
        }, ],
        columns: [
            { data: "equipment" },
            { data: "code" },
            { data: "currency" },
            { data: "amount" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected_defect m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>" }
        ]
    });


    $('#spare_fee').on('change', function() {
        var spare = [{
            "equipment": $(this).find(':selected').attr('data-spare'),
            "code": $(this).find(':selected').attr('data-code'),
            "currency": $(this).find(':selected').attr('data-currency'),
            "spare_id": $(this).find(':selected').attr('data-id'),
            "amount": $(this).find(':selected').attr('data-amount'),
            "action": "<a href='#' class='remove_selected_defect m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>"
        }, ];

        dt_interchange_defect.rows.add(spare).draw(false);

        // var tempData = [];
        // for (let index = 0; index < dt_interchange_defect.rows().count(); index++) {
        //     // const element = array[index]; 
        //     tempData.push(dt_orders.rows().data()[index]);

        // }

        // ddddd = tempData;
        // console.log(ddddd)

    });


    $('#dt-interchange-defect tbody').on('click', '.remove_selected_defect', function() {
        var $tr = $(this).closest('tr');
        dt_interchange_defect.row($tr).remove().draw(false);
    });


    $('.add_inter_change').on('click', function() {
        console.log("tetststs 123");
        if (($('#direction').val() == "") ||
            ($('#interchange_point').val() == "") ||
            ($('#adminstrator_id').val() == "")
            // ($('#entry_date').val() == "") ||
            // ($('#exit_date').val() == "")

        )

        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        $('.wagon-field-clr').val('');
        $('.wagon-field-select').val([]);
        $('#add_interchange_wagon').show();
        $('#update_interchange_wagon').hide();
        dt_interchange_defect.clear().rows.add([]).draw();
        $('#add_inter_change_model').modal('show');
    });

    var dt_interchange = $('#dt-interchange').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,

        columns: [
            { data: "wagon_number" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "wagon_status" },
            { data: "adminstrator" },
            { data: "commodity" },
            { data: "comment" },
            { data: "action" }
        ]

    });


    $('#add_interchange_wagon').click(function() {

        if (($('#wagon-code').val() == "") ||
            ($('#wagon_status_id').val() == "") ||
            ($('#commodity_id').val() == "") ||
            ($('#comment').val() == "")
        ) {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if ($('#entry_date').val() == "") {

            var date = $('#exit_date').val();

        } else {

            var date = $('#entry_date').val()

        }

        spinner.show();
        $.ajax({
            url: '/interchange/fee/lookup',
            type: 'POST',
            data: {
                date: date,
                _csrf_token: $("#csrf").val(),
                adminstrator_id: $('#adminstrator_id').val(),

            },
            success: function(result) {
                console.log(result.data.length < 1)
                if (result.data.length < 1) {
                    spinner.hide();
                    $('#add_inter_change_model').modal('hide');
                    swal({
                        title: "Oops...",
                        text: "Interchange fee not found!",
                        confirmButtonColor: "#EF5350",
                        type: "error"
                    });

                } else {
                    spinner.hide();

                    var defects = [];
                    $.each(dt_interchange_defect.rows().data(), function(index, item) {
                        console.log(item, "test defect");
                        defects.push(item);
                    });

                    var wagon = [{
                        "defects": defects,
                        "wagon_number": $("#wagon-code option:selected").attr('data-wagon-code'),
                        "adminstrator": $("#adminstrator_id option:selected").attr('data-admin'),
                        "wagon_id": $('#wagon-code').val(),
                        "adminstrator_id": $('#adminstrator_id').val(),
                        "wagon_owner": $("#wagon-code option:selected").attr('data-wagon-owner'),
                        "interchange_fee": result.data[0].amount,
                        "interchange_fee_id": result.data[0].id,
                        "wagon_type": $("#wagon-code option:selected").attr('data-wagon-type'),
                        "wagon_status": $("#wagon_status_id option:selected").attr('data-wagon-status'),
                        "wagon_status_id": $('#wagon_status_id').val(),
                        "commodity": $("#commodity_id option:selected").attr('data-commodity'),
                        "commodity_id": $('#commodity_id').val(),
                        "comment": $('#comment').val(),
                        "action": "<a href='#' class='edit_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-edit'></i></a> <a href='#' class='remove_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>"
                    }];
                    console.log(wagon, "combined wagon");
                    dt_interchange.rows.add(wagon).draw(false);
                    $('#add_inter_change_model').modal('hide');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#dt-interchange tbody').on('click', '.remove_added_wagon', function() {
        var $tr = $(this).closest('tr');
        dt_interchange.row($tr).remove().draw(false);
    });


    var wagon_row;

    $('#dt-interchange tbody').on('click', '.edit_added_wagon', function() {
        var $tr = $(this).closest('tr');
        wagon_row = $tr;
        var wagon = dt_interchange.row($tr).data();
        $('#wagon_status_id').val(wagon.wagon_status_id);
        $('#commodity_id').val(wagon.commodity_id);
        $('#comment').val(wagon.comment);
        $('#wagon-code').val(wagon.wagon_id);
        $('#wagon-owner').val(wagon.wagon_owner);
        $('#wagon-type').val(wagon.wagon_type);
        $('#add_interchange_wagon').hide();
        $('#update_interchange_wagon').show();
        dt_interchange_defect.clear().rows.add([]).draw();
        dt_interchange_defect.rows.add(wagon.defects).draw(false);
        $('#add_inter_change_model').modal('show');
    });


    $('#update_interchange_wagon').click(function() {

        if (($('#wagon-code').val() == "") ||
            ($('#wagon_status_id').val() == "") ||
            ($('#commodity_id').val() == "") ||
            ($('#comment').val() == "")
        ) {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if ($('#entry_date').val() == "") {

            var date = $('#exit_date').val();

        } else {

            var date = $('#entry_date').val()

        }

        spinner.show();
        $.ajax({
            url: '/interchange/fee/lookup',
            type: 'POST',
            data: {
                date: date,
                _csrf_token: $("#csrf").val(),
                adminstrator_id: $('#adminstrator_id').val(),

            },
            success: function(result) {
                console.log(result.data.length < 1)
                if (result.data.length < 1) {
                    spinner.hide();
                    $('#add_inter_change_model').modal('hide');
                    swal({
                        title: "Oops...",
                        text: "Interchange fee not found!",
                        confirmButtonColor: "#EF5350",
                        type: "error"
                    });

                } else {
                    spinner.hide();

                    var defects = [];
                    $.each(dt_interchange_defect.rows().data(), function(index, item) {
                        console.log(item, "test defect");
                        defects.push(item);
                    });

                    var wagon = [{
                        "defects": defects,
                        "wagon_number": $("#wagon-code option:selected").attr('data-wagon-code'),
                        "adminstrator": $("#adminstrator_id option:selected").attr('data-admin'),
                        "wagon_id": $('#wagon-code').val(),
                        "adminstrator_id": $('#adminstrator_id').val(),
                        "wagon_owner": $("#wagon-code option:selected").attr('data-wagon-owner'),
                        "interchange_fee": result.data[0].amount,
                        "interchange_fee_id": result.data[0].id,
                        "wagon_type": $("#wagon-code option:selected").attr('data-wagon-type'),
                        "wagon_status": $("#wagon_status_id option:selected").attr('data-wagon-status'),
                        "wagon_status_id": $('#wagon_status_id').val(),
                        "commodity": $("#commodity_id option:selected").attr('data-commodity'),
                        "commodity_id": $('#commodity_id').val(),
                        "comment": $('#comment').val(),
                        "action": "<a href='#' class='edit_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-edit'></i></a> <a href='#' class='remove_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>"
                    }];

                    dt_interchange.row(wagon_row).remove().draw(false);
                    dt_interchange.rows.add(wagon).draw(false);
                    $('#add_inter_change_model').modal('hide');
                    $('.wagon-field-clr').val('');
                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });


    });

    $('#create-interchange').click(function() {

        var details = {};
        $.each($('.interchange_general_entries').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (dt_interchange.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < dt_interchange.rows().count(); index++) {
            // const element = array[index];
            data_row.push(Object.assign(dt_interchange.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/create/interchange',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Interchange created successfully!',
                                'success'
                            )
                            dt_interchange.clear().rows.add([]).draw();
                            dt_interchange_defect.clear().rows.add([]).draw();
                            $('.wagon-field-clr').val('');
                            $('.clear_selects').val([]);
                            $('.clear_form').val('');

                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('#dt_interchange_batch').DataTable({
        responsive: true,
        'columnDefs': [{
                "targets": [2],
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": [3, 4],
                "width": "70",
                "className": "text-center"
            }
        ],
    });


    $('#loco_no').on('change', function() {
        show_loco_number = $(this).find(':selected').attr('data-loco-number');
    });

    $('#loco_id').on('change', function() {
        show_locomotive_type = $(this).find(':selected').attr('data-loco-type');
    });

    $('#loco_driver').on('change', function() {
        show_loco_driver = $(this).find(':selected').attr('data-loco-driver');
    });

    $('#train_origin').on('change', function() {
        show_train_origin_stn = $(this).find(':selected').attr('data-train-origin');
    });

    $('#train_destination').on('change', function() {
        show_train_distin_stn = $(this).find(':selected').attr('data-train-destin');
    });

    $('#train_type').on('change', function() {
        show_train_type = $(this).find(':selected').attr('data-train-type');
    });

    $('#commercial_clerk').on('change', function() {
        show_commercial_clark = $(this).find(':selected').attr('data-clerk');
    });

    $('#depo_refueled').on('change', function() {
        show_depo_stn = $(this).find(':selected').attr('data-depo-station');
    });


    //display of fuel requests
    var dt_fuel_monitoring = $('#dt_fuel_monitoring').DataTable({
        scrollY: "50vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        'columnDefs': [{
                "targets": 0,
                "width": "50%",
                "className": "text-center"
            },
            {
                "targets": 0,
                "className": "text-center"

            }
        ],

    });


    $('#submit-fuel-request').click(function() {

        var data_row = [{
                "loco_no": $("#loco_no").val(),
                "loco_id": $("#loco_id").val(),
                "loco_driver_id": $("#loco_driver").val(),
                "train_number": $("#train_number").val(),
                "train_origin_id": $("#train_origin").val(),
                "train_destination_id": $("#train_destination").val(),
                "depo_refueled_id": $("#depo_refueled").val(),
                "train_type_id": $("#train_type").val(),
                "seal_number_at_arrival": $("#seal_number_at_arrival").val(),
                "seal_number_at_depture": $("#seal_number_at_depture").val(),
                "seal_color_at_arrival": $("#seal_color_at_arrival").val(),
                "seal_color_at_depture": $("#seal_color_at_depture").val(),
                "date": $("#date").val(),
                "time": $("#time").val(),
                "balance_before_refuel": $("#balance_before_refuel").val(),
                "approved_refuel": $("#approved_refuel").val(),
                "deff_ctc_actual": $("#deff_ctc_actual").val(),
                "reading_after_refuel": $("#reading_after_refuel").val(),
                "quantity_refueled": $("#summary_quantity_refueled").val(),
                "bp_meter_before": $("#bp_meter_before").val(),
                "bp_meter_after": $("#bp_meter_after").val(),
                "km_to_destin": $("#km_to_destin").val(),
                "fuel_consumed": $("#fuel_consumed").val(),
                "consumption_per_km": $("#consumption_per_km").val(),
                "reading": $("#reading").val(),
                "requisition_no": $("#requisition_no").val(),
                "fuel_rate": $("#fuel_rate").val(),
                "commercial_clerk_id": $("#commercial_clerk").val(),
                "section": $("#section").val(),
                "total_cost": $("#total_cost").val(),
                "comment": $("#comment").val(),
                "batch_id": $("#batch_id").val(),
                "status": "PENDING_CONTROL",
            },

        ];

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to submit this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/create/fuel/monitor',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val() },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                    'Success',
                                    'Fuel request submited for approval!',
                                    'success'
                                )
                                //  window.location.replace("/fuel/monitoring");

                            $('.field-clr').val([]);
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })

    });


    $('#dt-fuel-approvals').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt-fuel-back-office').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt-rejected-fuel-requisite').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });


    var dt_fuel_report_details = $('#dt-fuel-report').DataTable({
        "responsive": true,
        "processing": true,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/fuel/requisite/report/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "fuel_loco_number": $('#fuel_loco_number').val(),
                "fuel_section_name": $('#fuel_section_name').val(),
                "fuel_train_number": $('#fuel_train_number').val(),
                // "fuel_capture_date": $('#fuel_capture_date').val(),
                "fuel_depo_refueled": $('#fuel_depo_refueled').val(),
                "fuel_requisition_no": $('#fuel_requisition_no').val(),
                "from": $("#from").val(),
                "to": $("#to").val(),


            }
        },
        "columns": [
            { "data": "train_number" },
            { "data": "requisition_no" },
            { "data": "approved_refuel" },
            { "data": "quantity_refueled" },
            { "data": "balance_before_refuel" },
            { "data": "reading_after_refuel" },
            { "data": "section" },
            { "data": "total_cost" },
            { "data": "time" },
            { "data": "status" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" href="/view/fuel/report/entries/?id=' + data + '" aria-expanded="true"><i class="la la-eye" ></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            }
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [

            [1, 'asc']
        ],

        "columns": [
            { data: "train_number" },
            { data: "requisition_no" },
            { data: "approved_refuel" },
            { data: "quantity_refueled" },
            { data: "balance_before_refuel" },
            { data: "reading_after_refuel" },
            { data: "section" },
            { data: "total_cost" },
            { data: "time" },
            { data: "status" },

        ]
    });

    $('#fuel-requisite-filter').on('click', function() {

        $('#fuel_requisite_form_filter').modal('show');
    });

    $('#fuel-requisite-search').on('click', function() {
        dt_fuel_report_details.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.fuel_loco_number = $("#fuel_loco_number").val();
            data.fuel_section_name = $("#fuel_section_name").val();
            data.fuel_train_number = $('#fuel_train_number').val();
            // data.fuel_capture_date = $('#fuel_capture_date').val();
            data.fuel_depo_refueled = $('#fuel_depo_refueled').val();
            data.fuel_requisition_no = $('#fuel_requisition_no').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#fuel_requisite_form_filter').modal('hide');
        dt_fuel_report_details.draw();
    });


    if ($('#current_status').val() == "PENDING_CONTROL") {
        $("#approved_refuel").prop('disabled', false);
        $("#reading_after_refuel").prop('disabled', true);
        $("#seal_number_at_arrival").prop('disabled', true);
        $("#seal_number_at_depture").prop('disabled', true);
        $("#seal_color_at_arrival").prop('disabled', true);
        $("#seal_color_at_depture").prop('disabled', true);
        $("#date").prop('disabled', true);
        $("#time").prop('disabled', true);
        $("#balance_before_refuel").prop('disabled', true);
        $("#bp_meter_before").prop('disabled', true);
        $("#bp_meter_after").prop('disabled', true);
        $("#km_to_destin").prop('disabled', true);
        $("#fuel_consumed").prop('disabled', true);
        $("#consumption_per_km").prop('disabled', true);
        $("#reading").prop('disabled', true);
        $("#fuel_rate").prop('disabled', true);
        $("#commercial_clerk").prop('disabled', true);
        $("#comment").prop('disabled', true);
        $("#summary_quantity_refueled").prop('disabled', true);
        $("#total_cost").prop('disabled', true);
        $("#deff_ctc_actual").prop('disabled', true);
        $("#train_type").prop('disabled', true);
        $("#section").prop('disabled', true);
        $("#depo_refueled").prop('disabled', true);
        $("#train_destination").prop('disabled', true);
        $("#train_origin").prop('disabled', true);
        $("#loco_driver").prop('disabled', true);
        $("#train_number").prop('disabled', true);
        $("#loco_no").prop('disabled', true);
        $("#loco_type").prop('disabled', true);
        $("#requisition_no").prop('disabled', true);

    } else if ($('#current_status').val() == "PENDING_COMPLETION") {

        $("#approved_refuel").prop('disabled', true);
        $("#reading_after_refuel").prop('disabled', true);
        $("#seal_number_at_arrival").prop('disabled', true);
        $("#seal_number_at_depture").prop('disabled', false);
        $("#seal_color_at_arrival").prop('disabled', true);
        $("#seal_color_at_depture").prop('disabled', false);
        $("#date").prop('disabled', false);
        $("#time").prop('disabled', false);
        $("#balance_before_refuel").prop('disabled', true);
        $("#bp_meter_before").prop('disabled', true);
        $("#bp_meter_after").prop('disabled', false);
        $("#km_to_destin").prop('disabled', true);
        $("#fuel_consumed").prop('disabled', true);
        $("#consumption_per_km").prop('disabled', true);
        $("#reading").prop('disabled', true);
        $("#fuel_rate").prop('disabled', true);
        $("#commercial_clerk").prop('disabled', true);
        $("#comment").prop('disabled', true);
        $("#summary_quantity_refueled").prop('disabled', true);
        $("#total_cost").prop('disabled', true);
        $("#deff_ctc_actual").prop('disabled', true);
        $("#train_type").prop('disabled', true);
        $("#section").prop('disabled', true);
        $("#depo_refueled").prop('disabled', true);
        $("#train_destination").prop('disabled', true);
        $("#train_origin").prop('disabled', true);
        $("#loco_driver").prop('disabled', true);
        $("#train_number").prop('disabled', true);
        $("#loco_no").prop('disabled', true);
        $("#loco_type").prop('disabled', true);
        $("#requisition_no").prop('disabled', true);
        $("#summary_quantity_refueled").prop('disabled', false);

    } else if ($('#current_status').val() == "PENDING_APPROVAL") {
        $("#approved_refuel").prop('disabled', true);
        $("#reading_after_refuel").prop('disabled', true);
        $("#seal_number_at_arrival").prop('disabled', true);
        $("#seal_number_at_depture").prop('disabled', true);
        $("#seal_color_at_arrival").prop('disabled', true);
        $("#seal_color_at_depture").prop('disabled', true);
        $("#date").prop('disabled', true);
        $("#time").prop('disabled', true);
        $("#balance_before_refuel").prop('disabled', true);
        $("#bp_meter_before").prop('disabled', true);
        $("#bp_meter_after").prop('disabled', true);
        $("#km_to_destin").prop('disabled', true);
        $("#fuel_consumed").prop('disabled', true);
        $("#consumption_per_km").prop('disabled', true);
        $("#reading").prop('disabled', true);
        $("#fuel_rate").prop('disabled', true);
        $("#commercial_clerk").prop('disabled', true);
        $("#comment").prop('disabled', true);
        $("#summary_quantity_refueled").prop('disabled', true);
        $("#total_cost").prop('disabled', true);
        $("#deff_ctc_actual").prop('disabled', true);
        $("#train_type").prop('disabled', true);
        $("#section").prop('disabled', true);
        $("#depo_refueled").prop('disabled', true);
        $("#train_destination").prop('disabled', true);
        $("#train_origin").prop('disabled', true);
        $("#loco_driver").prop('disabled', true);
        $("#train_number").prop('disabled', true);
        $("#loco_no").prop('disabled', true);
        $("#loco_type").prop('disabled', true);
        $("#requisition_no").prop('disabled', true);

    }

    // $('#approved_refuel').on('click', function() {
    //     document.getElementById("approved_refuel").readOnly = true;
    // });

    // $('#reading_after_refuel').on('click', function() {
    //     document.getElementById("reading_after_refuel").readOnly = true;
    // });


    // function myFunction() {
    //     document.getElementById("approved_refuel").readOnly = true;
    //   }

    //display of fuel requisite details
    if ($('#requisition_no').length) {
        $.ajax({
            url: '/display/fuel/requisite/details',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                batch_id: $("#fuel_batch").val(),
                _csrf_token: $("#csrf").val(),
                requisition_no: $('#requisition_no').val(),
            },

            success: function(result) {

                if (result.data.length < 1) {
                    dt_fuel_monitoring.rows.add([]).draw(false);

                } else {
                    dt_fuel_monitoring.rows.add(result.data).draw(false);
                }
            },

            error: function(request, msg, error) {
                //  spinner.hide();
                //  console.log($('#client').val())
                //  swal({
                //      title: "Oops...",
                //      text: "Something went wrong!",
                //      confirmButtonColor: "#EF5350",
                //      type: "error"
                //  });
            }
        });
    }

    if ($('#commercial_clerk').length) {
        var type = $('#commercial_clerk').attr('data_commercial_clerk');
        $('#commercial_clerk').val(type);
        $('#commercial_clerk').trigger('change');
    }

    if ($('#loco_no').length) {
        var type = $('#loco_no').attr('data_number_loco');
        $('#loco_no').val(type);
        $('#loco_no').trigger('change');
    }

    if ($('#loco_driver').length) {
        var type = $('#loco_driver').attr('data_driver');
        $('#loco_driver').val(type);
        $('#loco_driver').trigger('change');
    }

    if ($('#train_origin').length) {
        var type = $('#train_origin').attr('data_loco_origin');
        $('#train_origin').val(type);
        $('#train_origin').trigger('change');
    }

    if ($('#loco_type').length) {
        var type = $('#loco_type').attr('data_loco_type');
        $('#loco_type').val(type);
        $('#loco_type').trigger('change');
    }

    if ($('#train_type').length) {
        var type = $('#train_type').attr('data_type_train');
        $('#train_type').val(type);
        $('#train_type').trigger('change');
    }
    if ($('#train_destination').length) {
        var type = $('#train_destination').attr('data_train_destination');
        $('#train_destination').val(type);
        $('#train_destination').trigger('change');
    }

    if ($('#depo_refueled').length) {
        var type = $('#depo_refueled').attr('data_depo_refuel_stn');
        $('#depo_refueled').val(type);
        $('#depo_refueled').trigger('change');
    }

    if ($('#loco_id').length) {
        var type = $('#loco_id').attr('data_locomotive_type');
        $('#loco_id').val(type);
        $('#loco_id').trigger('change');
    }


    if ($('#locomotive_id').length) {
        var type = $('#locomotive_id').attr('data_type_locomotive');
        $('#locomotive_id').val(type);
        $('#locomotive_id').trigger('change');
    }

    if ($('#locomotive_id').length) {
        var type = $('#locomotive_id').attr('data_type_locomotive');
        $('#locomotive_id').val(type);
        $('#locomotive_id').trigger('change');
    }

    if ($('#fuel_comp_loco_id').length) {
        var type = $('#fuel_comp_loco_id').attr('data_loco_type_comp');
        $('#fuel_comp_loco_id').val(type);
        $('#fuel_comp_loco_id').trigger('change');
    }


    ///////////////////////////////////////////disatnce maintenance js////////////////////////////////////////////////////////////////////////

    var dt_distance = $('#dt_distance').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "14",
                "className": "text-center"
            }
        ],
    });

    $('#dt_distance tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_station_orig').val(button.attr("data-station-orig"));
        $('#edit_destin').val(button.attr("data-distin"));
        $('#edit_distance').val(button.attr("data-distance"));
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_distance tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/distance/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_distance.cell($tr, 3).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_distance tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/distance',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_distance.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Record deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



    ///////////////resubmit for rejected fuel requisite entries////////////////////////////
    $('#re-submit-form-approval').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You want to submit this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/update/fuel/requisite',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        requisition_no: $("#requisition_no").val(),
                        status: "REJECTED",
                        current_status: $("#current_status").val(),
                        reading_after_refuel: $("#reading_after_refuel").val(),
                        balance_before_refuel: $("#balance_before_refuel").val(),
                        seal_color_at_depture: $("#seal_color_at_depture").val(),
                        seal_number_at_depture: $("#seal_number_at_depture").val(),
                        bp_meter_after: $("#bp_meter_after").val(),
                        date: $("#date").val(),
                        time: $("#time").val(),
                        total_cost: $("#total_cost").val(),
                        quantity_refueled: $("#summary_quantity_refueled").val(),
                        meter_at_destin: $("#meter_at_destin").val(),
                        reading: $("#reading").val(),
                        fuel_consumed: $("#fuel_consumed").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        km_to_destin: $("#km_to_destin").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        reading_after_refuel: $("#reading_after_refuel").val(),
                        loco_no: $("#loco_no").val(),
                        train_number: $("#train_number").val(),
                        seal_number_at_arrival: $("#seal_number_at_arrival").val(),
                        seal_color_at_arrival: $("#seal_color_at_arrival").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        bp_meter_before: $("#bp_meter_before").val(),
                        km_to_destin: $("#km_to_destin").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        section: $("#section").val(),
                        comment: $("#comment").val(),
                        loco_driver_id: $("#loco_driver").val(),
                        train_type_id: $("#train_type").val(),
                        commercial_clerk_id: $("#commercial_clerk").val(),
                        depo_refueled_id: $("#depo_refueled").val(),
                        train_destination_id: $("#train_origin").val(),


                    },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Fuel request submited for approval!',
                                'success'
                            )
                            window.location.replace("/view/rejected/fuel/requisites");

                            $('.field-clr').val([]);
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })

    });


    //////////////////////////// coilard //////////////////////////////////////////
    var dt_interchange_defect_approval = $('#dt-interchange-defect-approval').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        // 'columnDefs': [{
        //     "targets": 4,
        //     "width": "12",
        //     "className": "text-center"
        // }, ],
        columns: [
            { data: "equipment" },
            { data: "code" },
            { data: "currency" },
            { data: "amount" }
        ]
    });




    //approve js for fuel requisite

    $('#approve-fuel-requisite').click(function() {
        var a = dt_fuel_monitoring.rows().data()
        var button = $(this);
        var details = {};

        var data_row = [];
        console.log(data_row);
        for (let index = 0; index < dt_fuel_monitoring.rows().count(); index++) {
            data_row.push(Object.assign(dt_fuel_monitoring.rows().data()[index], details));
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You want to approve this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/approve/fuel/requisite/order',
                    type: 'post',
                    data: { requisition_no: $("#requisition_no").val(), _csrf_token: $("#csrf").val(), status: "COMPLETE" },
                    // data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), status: button.attr("data-status") },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Fuel request approved successfully!',
                                'success'
                            )
                            window.location.replace("/fuel/back/office/approval");

                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })

    });

    // $('#reject-fuel-requisite').click(function() {
    //     var a = dt_fuel_monitoring.rows().data()
    //     var button = $(this);
    //     var details = {};

    //     if (dt_fuel_monitoring.rows().count() <= 0) {
    //         Swal.fire(
    //             'Oops..!',
    //             'No fuel request found!',
    //             'error'
    //         )
    //         return false;
    //     }

    //     var data_row = [];
    //     console.log(data_row);
    //     for (let index = 0; index < dt_fuel_monitoring.rows().count(); index++) {
    //         data_row.push(Object.assign(dt_fuel_monitoring.rows().data()[index], details));
    //     }

    //     Swal.fire({
    //         title: 'Are you sure?',
    //         text: "You want to approve this order!",
    //         type: "warning",
    //         showCancelButton: true,
    //         confirmButtonColor: '#3085d6',
    //         cancelButtonColor: '#d33',
    //         confirmButtonText: 'Yes, continue!',
    //         showLoaderOnConfirm: true
    //     }).then((result) => {
    //         if (result.value) {
    //             // spinner.show();
    //             $.ajax({
    //                 url: '/reject/fuel/requisite/order',
    //                 type: 'post',
    //                 data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), status: button.attr("data-status") },
    //                 success: function(result) {
    //                     //   spinner.hide();
    //                     if (result.info) {
    //                         Swal.fire(
    //                                 'Success',
    //                                 'Fuel request rejected successfully!',
    //                                 'success'
    //                             )
    //                              window.location.replace("/fuel/back/office/approval");

    //                     } else {
    //                         Swal.fire(
    //                             'Oops..',
    //                             result.error,
    //                             'error'
    //                         )
    //                     }
    //                 },
    //                 error: function(request, msg, error) {
    //                     //   spinner.hide();
    //                     Swal.fire(
    //                         'Oops..',
    //                         'Something went wrong! try again',
    //                         'error'
    //                     )
    //                 }
    //             });
    //         } else {
    //             // spinner.hide();
    //             Swal.fire(
    //                 'Cancelled',
    //                 'Operation not performed :)',
    //                 'error'
    //             )
    //         }
    //     })

    // });


    $('#reject_fuel_requisite_modal').click(function() {

        $('#reject_requisite_model').modal('show');
        $('.wagon-field-clr').val('');
    });

    $('#reject-requisite').click(function() {

        if (($('#reason').val() == "")) {
            swal({
                title: "Opps",
                text: "Reject reason Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/reject/fuel/requisite/order',
                    type: 'post',
                    data: { requisition_no: $("#requisition_no").val(), _csrf_token: $("#csrf").val(), status: "REJECTED", reason: $("#reason").val() },
                    // data: { uuid: $("#entry_id").val(), _csrf_token: $("#csrf").val(), status: "REJECTED", reason: $("#reason").val() },
                    success: function(result) {
                        spinner.hide();
                        $('#reject_requisite_model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Requisite Rejected successfully!',
                                'success'
                            )
                            window.location.replace("/fuel/back/office/approval");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    //submit for control form for fuel requisite
    $('#control-submit-form').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You want to submit this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/update/fuel/requisite',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        requisition_no: $("#requisition_no").val(),
                        status: "PENDING_COMPLETION",
                        current_status: $("#current_status").val(),
                        approved_refuel: $("#approved_refuel").val()
                    },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Fuel request submited for Completion!',
                                'success'
                            )
                            window.location.replace("/fuel/control/view");

                            $('.field-clr').val([]);
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })

    });

    //submit for control form for fuel requisite
    $('#submit-form-approval').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You want to submit this order!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                // spinner.show();
                $.ajax({
                    url: '/update/fuel/requisite',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        requisition_no: $("#requisition_no").val(),
                        status: "PENDING_APPROVAL",
                        current_status: $("#current_status").val(),
                        reading_after_refuel: $("#reading_after_refuel").val(),
                        seal_color_at_depture: $("#seal_color_at_depture").val(),
                        seal_number_at_depture: $("#seal_number_at_depture").val(),
                        bp_meter_after: $("#bp_meter_after").val(),
                        date: $("#date").val(),
                        time: $("#time").val(),
                        total_cost: $("#total_cost").val(),
                        quantity_refueled: $("#summary_quantity_refueled").val(),

                    },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Fuel request submited for approval!',
                                'success'
                            )
                            window.location.replace("/view/fuel/entries");

                            $('.field-clr').val([]);
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        //   spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })

    });

    //////////////////////////// coilard //////////////////////////////////////////
    // var dt_interchange_defect_approval = $('#dt-interchange-defect-approval').DataTable({
    //     responsive: true,
    //     bLengthChange: false,
    //     bPaginate: false,
    //     bFilter: false,
    //     bInfo: false,
    //     // 'columnDefs': [{
    //     //     "targets": 4,
    //     //     "width": "12",
    //     //     "className": "text-center"
    //     // }, ],
    //     columns: [
    //         { data: "equipment" },
    //         { data: "code" },
    //         { data: "currency" },
    //         { data: "amount" }
    //     ]
    // });

    var dt_interchange_approval = $('#dt-interchange-approval').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No interchange found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/approve/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "id": $("#entry_id").val(),
                "status": 'PENDING_APPROVAL'
            }
        },
        "columns": [
            { "data": "wagon" },
            { "data": "wagon_owner" },
            { "data": "wagon_type" },
            { "data": "wagon_status" },
            { "data": "commodity" },
            { "data": "comment" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '  <a href= "#"  data-id = ' + data + ' data-wagon = ' + row["wagon"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + ' data-wagon_status = ' + row["wagon_status"] + ' data-commodity = ' + row["commodity"] + ' data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "12",
                "className": "text-center"
            },


        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#dt-interchange-approval tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    dt_interchange_defect_approval.clear().rows.add([]).draw();
                    $('#view_interchange_model').modal('show');

                } else {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    dt_interchange_defect_approval.clear().rows.add(result.data).draw();
                    $('#view_interchange_model').modal('show');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#approve-interchange').click(function() {

        if (dt_interchange_approval.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/approve/interchange',
                    type: 'post',
                    data: { uuid: $("#entry_id").val(), _csrf_token: $("#csrf").val(), status: "APPROVED" },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Interchange approved successfully!',
                                'success'
                            )
                            window.location.replace("/interchange/approvals");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#interchange_rejection_model').click(function() {

        $('#reject_interchange_model').modal('show');
        $('.wagon-field-clr').val('');
    });

    $('#reject-interchange').click(function() {

        if (($('#reject_reason').val() == "")) {
            swal({
                title: "Opps",
                text: "Reject reason Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (dt_interchange_approval.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/reject/interchange',
                    type: 'post',
                    data: { uuid: $("#entry_id").val(), _csrf_token: $("#csrf").val(), status: "REJECTED", reject_reason: $("#reject_reason").val() },
                    success: function(result) {
                        spinner.hide();
                        $('#reject_interchange_model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Interchange Rejected successfully!',
                                'success'
                            )
                            window.location.replace("/interchange/approvals");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    if ($('#invoice_currency').length) {

        var type = $('#invoice_currency').attr('data-currency');
        $('#invoice_currency').val(type);
        $('#invoice_currency').trigger('change');
    }

    if ($('#locomotive_id').length) {

        var type = $('#locomotive_id').attr('data-locomotive');
        $('#locomotive_id').val(type);
        $('#locomotive_id').trigger('change');
    }

    if ($('#adminstrator_id').length) {

        var type = $('#adminstrator_id').attr('data-adminstrator');
        $('#adminstrator_id').val(type);
        $('#adminstrator_id').trigger('change');
    }

    if ($('#interchange_point').length) {

        var type = $('#interchange_point').attr('data-interchange-point');
        $('#interchange_point').val(type);
        $('#interchange_point').trigger('change');
    }

    if ($('#direction').length) {
        var type = $('#direction').attr('data-direction');
        $('#direction').val(type);
        $('#direction').trigger('change');
    }

    var dt_rejected_interchange = $('#dt-rejected-interchange').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,

        columns: [
            { data: "wagon" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "wagon_status" },
            { data: "commodity" },
            { data: "comment" },
            { data: "action" }
        ]

    });


    if ($('#entry_id').length) {

        spinner.show();
        $.ajax({
            url: '/interchange/approve/batch/entries',
            type: 'POST',
            data: { id: $("#entry_id").val(), _csrf_token: $("#csrf").val(), status: 'REJECTED' },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    dt_rejected_interchange.clear().rows.add([]).draw();

                } else {

                    var new_data = [];
                    var actions = { 'action': "<a href='#' class='edit_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-edit'></i></a> <a href='#' class='remove_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>" };

                    for (let index = 0; index < result.data.length; index++) {
                        new_data.push(Object.assign(result.data[index], actions));
                    }

                    dt_rejected_interchange.clear().rows.add(result.data).draw();


                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    }

    $('#dt-rejected-interchange tbody').on('click', '.edit_added_wagon', function(e) {
        e.preventDefault()
        var $tr = $(this).closest('tr');
        row = $tr;
        var entry = dt_rejected_interchange.row($tr).data();
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: entry.id, _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    $('#wagon_status_id').val(entry.wagon_status_id);
                    $('#commodity_id').val(entry.commodity_id);
                    $('#comment').val(entry.comment);
                    $('#wagon-code').val(entry.wagon_id);
                    $('#wagon-owner').val(entry.wagon_owner);
                    $('#wagon-type').val(entry.wagon_type);
                    dt_interchange_defect.clear().rows.add([]).draw();
                    $('#edit_rejected_wagon_model').modal('show');

                } else {


                    $('#wagon_status_id').val(entry.wagon_status_id);
                    $('#commodity_id').val(entry.commodity_id);
                    $('#comment').val(entry.comment);
                    $('#wagon-code').val(entry.wagon_id);
                    $('#wagon-owner').val(entry.wagon_owner);
                    $('#wagon-type').val(entry.wagon_type);

                    var new_data = [];
                    var actions = { 'action': "<a href='#' class=' m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>" };

                    for (let index = 0; index < result.data.length; index++) {
                        new_data.push(Object.assign(result.data[index], actions));
                    }
                    dt_interchange_defect.clear().rows.add(result.data).draw();
                    $('#edit_rejected_wagon_model').modal('show');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });


    $('#direction').on('change', function() {

        if ($('#direction').val() == "OUTGOING") {
            $("#exit_date").prop('disabled', false);
            $("#entry_date").prop('disabled', true);

        } else {

            $("#entry_date").prop('disabled', false);
            $("#exit_date").prop('disabled', true);
        }

    });

    var dt_interchange_no_hire = $('#dt-interchange-on-hire').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No interchange found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/on/hire/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "uuid": $("#entry_id").val(),
                "auth_status": 'APPROVED',
                "direction": $("#interchange_direction").val()
            }
        },
        "columns": [
            { "data": "wagon" },
            { "data": "wagon_owner" },
            { "data": "wagon_type" },
            { "data": "wagon_status" },
            { "data": "administrator" },
            { "data": "commodity" },
            { "data": "comment" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#"  data-admin = ' + row["administrator"] + ' data-id = ' + data + ' data-wagon = ' + row["wagon"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + ' data-wagon_status = ' + row["wagon_status"] + ' data-commodity = ' + row["commodity"] + ' data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>' +
                        '<a href= "#" data-id = ' + data + ' data-wagon = ' + row["wagon"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + ' data-wagon_status = ' + row["wagon_status"] + ' data-commodity = ' + row["commodity"] + ' data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill set_single_interchange_entry_off_model" title= "Off Hire"><i class= "la la-check"></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },


        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#set-interchange-batch-off-hire-model').click(function() {
        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        if ($('#interchange_direction').val() == "INCOMING") {
            $('#set_batch_to_off_hire').show();
            $('#set_batch_to_off_hire_outgoing').hide();

        } else {
            $('#set_batch_to_off_hire').hide();
            $('#set_batch_to_off_hire_outgoing').show();
        }

        $('#batch_off_hire_model').modal('show');

    });


    $('#set_batch_to_off_hire').click(function() {

        if (($('#lease_period').val() == "") || ($('#off_hire_date').val() == "")) {
            swal({
                title: "Opps",
                text: "All fields Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/set/interchange/batch/off/hire',
                    type: 'post',
                    data: {
                        uuid: $("#entry_id").val(),
                        _csrf_token: $("#csrf").val(),
                        lease_period: $("#lease_period").val(),
                        off_hire_date: $("#off_hire_date").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#batch_off_hire_model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            window.location.replace("/interchange/approved/incoming/batch/entries");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('#set_batch_to_off_hire_outgoing').click(function() {

        if (($('#lease_period').val() == "") || ($('#off_hire_date').val() == "")) {
            swal({
                title: "Opps",
                text: "All fields Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/set/interchange/batch/off/hire',
                    type: 'post',
                    data: {
                        uuid: $("#entry_id").val(),
                        _csrf_token: $("#csrf").val(),
                        lease_period: $("#lease_period").val(),
                        off_hire_date: $("#off_hire_date").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#batch_off_hire_model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            window.location.replace("/interchange/approved/outgoing/batch/entries");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    $('#dt-interchange-on-hire tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    $('#admin').val(button.attr("data-admin"));
                    dt_interchange_defect_approval.clear().rows.add([]).draw();
                    $('#view_interchange_model').modal('show');

                } else {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    $('#admin').val(button.attr("data-admin"));
                    dt_interchange_defect_approval.clear().rows.add(result.data).draw();
                    $('#view_interchange_model').modal('show');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#dt-interchange-on-hire tbody').on('click', '.set_single_interchange_entry_off_model', function(e) {
        e.preventDefault()
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    $('.clear').val('');
                    dt_interchange_defect.clear().rows.add([]).draw();
                    $('#entry_id').val(button.attr("data-id"))
                    $('#single_off_hire_model').modal('show');


                } else {

                    $('.clear').val('');
                    dt_interchange_defect.clear().rows.add(result.data).draw();
                    $('#entry_id').val(button.attr("data-id"))
                    $('#single_off_hire_model').modal('show');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });


    $('#set_single_entry_to_off_hire').click(function() {

        var data_row = [];
        for (let index = 0; index < dt_interchange_defect.rows().count(); index++) {
            data_row.push(Object.assign(dt_interchange_defect.rows().data()[index], {}));
        }

        if (($('#single_lease_period').val() == "") || ($('#single_off_hire_date').val() == "")) {
            swal({
                title: "Opps",
                text: "All fields can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/set/single/interchange/off/hire',
                    type: 'post',
                    data: {
                        id: $("#entry_id").val(),
                        _csrf_token: $("#csrf").val(),
                        lease_period: $("#single_lease_period").val(),
                        off_hire_date: $("#single_off_hire_date").val(),
                        new_defects: data_row
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#view_interchange_model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                // spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    var dt_interchange_report_batch = $('#dt_interchange_report_batch').DataTable({
        "responsive": true,
        "processing": true,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/report/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "direction": $('#interchange_direction').val(),
                "exit_date": $('#interchange_exit_date').val(),
                "entry_date": $('#interchange_entry_date').val(),
                "administrator": $('#interchange_administrator').val(),
                "interchange_point": $('#interchange_interchange_point').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),

            }
        },
        "columns": [
            { "data": "interchange_pt" },
            { "data": "administrator" },
            { "data": "direction" },
            { "data": "exit_date" },
            { "data": "entry_date" },
            {
                "data": "uuid",
                "render": function(data, type, row) {
                    return '<a class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" href="/interchange/batch/report/entries?id=' + data + '" aria-expanded="true"><i class="la la-eye" ></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            }
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#interchange-report-filter').on('click', function() {

        if ($('#interchange_direction').val() == "incoimng") {
            $("#interchange_exit_date").prop('disabled', false);
            $("#interchange_entry_date").prop('disabled', true);

        } else {
            $("#interchange_entry_date").prop('disabled', false);
            $("#interchange_exit_date").prop('disabled', true);

        }

        $('#interchange_batch_report_filter_model').modal('show');
    });

    $('#interchange_batch_report_filter').on('click', function() {
        dt_interchange_report_batch.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.direction = $('#interchange_direction').val();
            data.exit_date = $('#interchange_exit_date').val();
            data.entry_date = $('#interchange_entry_date').val();
            data.administrator = $('#interchange_administrator').val();
            data.interchange_point = $('#interchange_interchange_point').val();
        });
        $('#interchange_batch_report_filter_model').modal('hide');
        dt_interchange_report_batch.draw();
    });

    var dt_interchange_report_batch_entries = $('#dt-interchange-report-batch-entries').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No interchange found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/on/hire/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "uuid": $("#entry_id").val(),
                "auth_status": 'COMPLETE',
                "direction": $("#interchange_direction").val()
            }
        },
        "columns": [
            { "data": "wagon" },
            { "data": "wagon_owner" },
            { "data": "wagon_type" },
            { "data": "wagon_status" },
            { "data": "commodity" },
            { "data": "comment" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#"  data-id = ' + data + ' data-lease_period = ' + row["lease_period"] + ' data-off_hire_date = ' + row["off_hire_date"] + ' data-accumulative_amount = ' + row["accumulative_amount"] + ' data-accumulative_days = ' + row["accumulative_days"] + ' data-wagon = ' + row["wagon"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + ' data-wagon_status = ' + row["wagon_status"] + ' data-commodity = ' + row["commodity"] + ' data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#dt-interchange-report-batch-entries tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#accumulative_amount').val(button.attr("data-accumulative_amount"));
                    $('#off_hire_date').val(button.attr("data-off_hire_date"));
                    $('#lease_period').val(button.attr("data-lease_period"));
                    dt_interchange_defect_approval.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view_interchange_report_model').modal('show');

                } else {

                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(button.attr("data-comment"));
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#accumulative_amount').val(button.attr("data-accumulative_amount"));
                    $('#off_hire_date').val(button.attr("data-off_hire_date"));
                    $('#lease_period').val(button.attr("data-lease_period"));
                    dt_interchange_defect_approval.clear().rows.add(result.data).draw();
                    var total = dt_interchange_defect_approval.column(3).data().sum();
                    $('#defects_total').text(total);

                    console.log(total);
                    $('#view_interchange_report_model').modal('show');

                }
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#consignment-report-filter').on('click', function() {
        $('#consignment_batch_report_filter_model').modal('show');
    });

    var dt_consignment_report_batch_entries = $('#dt-consignment-report-batch-entries').DataTable({
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No consignment found"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/consignment/order/report/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "consignment_customer": $("#consignment_customer").val(),
                "consignment_station_code": $("#consignment_station_code").val(),
                "consignment_sales_order": $("#consignment_sales_order").val(),
                "consignment_reporting_station": $("#consignment_reporting_station").val(),
                "consignment_capture_date": $("#consignment_capture_date").val(),
                "consignment_consignee": $("#consignment_consignee").val(),
                "consignment_payer": $("#consignment_payer").val(),
                "consignment_commodity": $("#consignment_commodity").val(),
                "to": $("#to").val(),
                "from": $("#from").val()
            }
        },

        "columns": [
            { "data": "customer" },
            { "data": "sale_order" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "batch_id",
                "render": function(data, type, row) {
                    return '<a href="/consignment/sales/order/report/entries?batch=' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#consignment_batch_report_filter').on('click', function() {
        dt_consignment_report_batch_entries.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.consignment_station_code = $("#consignment_station_code").val();
            data.consignment_customer = $("#consignment_customer").val();
            data.consignment_sales_order = $('#consignment_sales_order').val();
            data.consignment_reporting_station = $('#consignment_reporting_station').val();
            data.consignment_capture_date = $('#consignment_capture_date').val();
            data.consignment_consignee = $('#consignment_consignee').val();
            data.consignment_payer = $('#consignment_payer').val();
            data.consignment_commodity = $('#consignment_commodity').val();
            data.consignment_capture_date = $('#consignment_capture_date').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#consignment_batch_report_filter_model').modal('hide');
        dt_consignment_report_batch_entries.draw();
    });

    var dt_orders_report = $('#dt-orders-report').DataTable({
        scrollY: "50vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        'columnDefs': [{
                "targets": 0,
                "width": "50%",
                "className": "text-center"
            },
            {
                "targets": 0,
                "className": "text-center"

            }
        ],
        columns: [{
                data: "wagon_code",
                "width": "70",
                "className": "text-center"
            },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "capacity_tonnes" },
            { data: "actual_tonnes" },
            { data: "tariff_tonnage" },
            { data: "container_no" },
            { data: "comment" },
            { data: "rsz" },
            { data: "nlpi" },
            { data: "nll_2005" },
            { data: "tfr" },
            { data: "tzr" },
            { data: "tzr_project" },
            { data: "additional_chg" },
            { data: "invoice_number" },
            { data: "total" },
            // { data: "total" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '  <a href= "#"  data-id = ' + data + ' data-comment = ' + row["comment"] + ' data-container_no = ' + row["container_no"] + ' data-actual_tonnes = ' + row["actual_tonnes"] + ' data-tariff_tonnage = ' + row["tariff_tonnage"] + ' data-capacity_tonnes = ' + row["capacity_tonnes"] + ' data-wagon = ' + row["wagon_code"] + ' data-wagon-type = ' + row["wagon_type"] + ' data-wagon-owner = ' + row["wagon_owner"] + '  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_consignment_entry" title= "View "> <i class= "la la-eye "></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "12",
                "className": "text-center"
            },
        ]
    });

    if ($('#consignment-batch').length) {

        $.ajax({
            url: '/pending/consignment/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                _csrf_token: $("#csrf").val(),
                client_id: $('#consignment-batch').val(),
                orign_station: $('#origin_tariff_id').val(),
                destin_station: $('#destin_tariff_id').val(),

            },
            success: function(result) {
                $(".disable-fields").prop('disabled', true);
                if (result.data.length < 1) {
                    rate = { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 };
                } else {
                    rate = result.data;

                    dt_orders_report.clear().rows.add(rate).draw();

                    if (result.rate && result.rate !== "null" && result.rate !== "undefined") {
                        var total_rsz = dt_orders_report.column(8).data().sum();
                        var total_nlpi = dt_orders_report.column(9).data().sum();
                        var total_nll = dt_orders_report.column(10).data().sum();
                        var total_tfr = dt_orders_report.column(11).data().sum();
                        var total_tzr = dt_orders_report.column(12).data().sum();
                        var total_tzr_project = dt_orders_report.column(13).data().sum();
                        var total_additional_chg = dt_orders_report.column(14).data().sum();

                        var newData = { "header": "Total", "rsz": total_rsz, "nlpi": total_nlpi, "nll": total_nll, "tfr": total_tfr, "tzr": total_tzr, "tzr_project": total_tzr_project, "additional_chg": total_additional_chg };

                        $('#wagon_count').val(dt_orders_report.rows().count());

                        $('#total_tonnage').val(dt_orders_report.column(5).data().sum());
                        var total_amount = total_rsz + total_nlpi + total_nll + total_tfr + total_tzr + total_tzr_project + total_additional_chg;
                        $('#total_amount').val(total_amount);


                        dt_consignment.row(1).data(newData).draw();

                        var surcharge_total = Number(((result.rate.surcharge.surcharge_percent / 100) * total_amount)).toFixed(2)
                        $('#surcharge_total').val(surcharge_total);
                        var vat_total = $("#vat-percentage").val() * total_amount;
                        $('#vat_total').val(vat_total);

                        // console.log(total_amount)
                        // console.log(surcharge_total)
                        // console.log(vat_total)
                        // var a = total_amount + vat_total + ((result.rate.surcharge.surcharge_percent / 100) * total_amount)
                        // console.log(a)

                        $('#overall_total').val(total_amount + ((result.rate.surcharge.surcharge_percent / 100) * total_amount) + vat_total);


                    }

                }


            },

            error: function(request, msg, error) {
                //  spinner.hide();
                //  console.log($('#client').val())
                //  swal({
                //      title: "Oops...",
                //      text: "Something went wrong!",
                //      confirmButtonColor: "#EF5350",
                //      type: "error"
                //  });
            }
        });
    }

    $('#dt-orders-report tbody').on('click', '.view_consignment_entry', function(e) {

        var button = $(this);
        $('.clear_vw').val('');
        $('#vw_comment').val(button.attr("data-comment"));
        $('#vw_wagon').val(button.attr("data-wagon"));
        $('#vw_wagon_owner').val(button.attr("data-wagon-owner"));
        $('#vw_wagon_type').val(button.attr("data-wagon-type"));
        $('#vw_actual_tonnes').val(button.attr("data-actual_tonnes"));
        $('#vw_tariff_tonnage').val(button.attr("data-tariff_tonnage"));
        $('#vw_capacity_tonnes').val(button.attr("data-capacity_tonnes"));
        $('#vw_container_no').val(button.attr("data-container_no"));
        $('#view_order').modal('show');

    });


    ///////////////////////////consignment batch sales orders/////////////////////////
    $('#dt-consignment-verification-batch-entries').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No consignment found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/consignment/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "status": "PENDING_VERIFICATION"
            }
        },
        "columns": [
            { "data": "customer" },
            { "data": "sale_order" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "uuid",
                "render": function(data, type, row) {
                    return '<a href="/consignment/verification/entries?batch_id=' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#dt-consignment-approval-batch-entries').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No consignment found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/consignment/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "status": "PENDING_APPROVAL"
            }
        },
        "columns": [
            { "data": "customer" },
            { "data": "sale_order" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "uuid",
                "render": function(data, type, row) {
                    return '<a href="/consignment/approval/entries?batch_id=' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#dt-consignment-invoice-batch-entries').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No consignment found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/consignment/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "status": "PENDING_INVOICE"
            }
        },
        "columns": [
            { "data": "customer" },
            { "data": "sale_order" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "uuid",
                "render": function(data, type, row) {
                    return '<a href="/consignment/invoice/list/entries?batch_id=' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#consignment-invoice-model').on('click', function() {
        $('#add-invoice-model').modal('show');
    });

    $('#add_invoice_details').click(function() {

        if (($('#invoice_no').val() == "") ||
            ($('#nvoice_date').val() == "") ||
            ($('#invoice_amount').val() == "") ||
            ($('#invoice_currency').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }

        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/consignment/order/invoicing',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        batch: $('#batch_id').val(),
                        invoice_no: $('#invoice_no').val(),
                        invoice_date: $('#invoice_date').val(),
                        invoice_amount: $('#invoice_amount').val(),
                        invoice_currency_id: $('#invoice_currency').val(),
                        invoice_term: $('#invoice_term').val(),
                        status: "COMPLETE"
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            window.location.replace("/consignment/sales/order/invoice/batch");
                        } else {
                            Swal.fire(
                                'Oops..',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops..',
                            'Something went wrong! try again',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    ////////////////movement order//////////////////////////////////////////////

    $('#dt_movenment_batch').DataTable({
        responsive: true,
        'columnDefs': [{
                "targets": [2],
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#movement_report_filter').on('click', function() {
        $('#movenment_batch_report_filter_model').modal('show');
    });

    var dt_movement_report_batch_entries = $('#dt-movement-report-batch-entries').DataTable({
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No movement found"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/movement/order/report/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "sales_order": $("#movement_sales_order").val(),
                "movement_date": $("#movement_dt").val(),
                "movement_time": $("#movement_time").val(),
                "train_no": $("#movement_train_no").val(),
                "origin": $("#movement_origin").val(),
                "destination": $("#movement_destination").val(),
                "to": $("#to").val(),
                "from": $("#from").val()
            }
        },

        "columns": [
            { "data": "sales_order" },
            { "data": "train_no" },
            { "data": "movement_time" },
            { "data": "movement_date" },
            { "data": "origin_name" },
            { "data": "destination_name" },
            { "data": "reporting_stat" },
            {
                "data": "batch_id",
                "render": function(data, type, row) {
                    return '<a href="/movement/order/report/batch/entries?batch=' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#movement_batch_report_filter').on('click', function() {
        dt_movement_report_batch_entries.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.sales_order = $("#movement_sales_order").val();
            data.movement_date = $("#movement_dt").val();
            data.movement_time = $("#movement_time").val();
            data.train_no = $('#movement_train_no').val();
            data.origin = $('#movement_origin').val();
            data.destination = $('#movement_destination').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#movenment_batch_report_filter_model').modal('hide');
        dt_movement_report_batch_entries.draw();
    });

    $('#dt-movement-report-batch-list-entries').DataTable({
        "scrollX": false,
        "responsive": true,
        "processing": true,
        " bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No consignment found"
        },
        // "serverSide": true,
        // "oLanguage": {
        // },
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/movement/order/report/batch/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "batch_id": $("#batch_id").val(),
            }
        },
        "columns": [
            { "data": "wagon_code" },
            { "data": "wagon_owner" },
            { "data": "commodity_name" },
            { "data": "consigner_name" },
            { "data": "consignment_sales_order" },
            { "data": "station_code" },
            { "data": "payer" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href="#" data-id = ' + data + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_movement_entry" title= "View "> <i class= "la la-eye "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },

        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });


    $('#dt-movement-report-batch-list-entries tbody').on('click', '.view_movement_entry', function(e) {
        e.preventDefault()
        var button = $(this);;
        spinner.show();
        $.ajax({
            url: '/movement/report/entry/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                var movement = result.data;
                $('.wagon-field-clr').val('');
                $('#vw_payer').val(movement.payer);
                $('#vw_wagon_number').val(movement.wagon_code);
                $('#vw_wagon_owner').val(movement.wagon_owner);
                $('#vw_wagon_type').val(movement.wagon_type);
                $('#vw_from').val(movement.origin_name);
                $('#vw_to').val(movement.destination_name);
                $('#vw_commodity').val(movement.commodity_name);
                $('#vw_container_no').val(movement.container_no);
                $('#vw_consignment_date').val(movement.consignment_date);
                $('#vw_consigner').val(movement.consigner_name);
                $('#vw_consignee').val(movement.consignee_name);
                $('#vw_station_code').val(movement.station_code);
                $('#view_movement-model').modal('show');
            },
            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });


    if ($('#current_railway_admin').length) {
        var type = $('#current_railway_admin').attr('data-current_railway_admin');
        $('#current_railway_admin').val(type);
        $('#current_railway_admin').trigger('change');
    }

    if ($('#prefered_ccy_id').length) {
        var type = $('#prefered_ccy_id').attr('data-prefered_ccy_id');
        $('#prefered_ccy_id').val(type);
        $('#prefered_ccy_id').trigger('change');
    }

    $('#create-company-info').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                var data = $("form").serialize();
                spinner.show();
                $.ajax({
                    url: '/new/company/infomation',
                    type: 'POST',
                    data: data,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('#change-status-company-info').show('fast');
                            $('#create-company-info').hide('fast');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Oops...',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#change-status-company-info').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/company/infomation/status',
                    type: 'POST',
                    data: {
                        id: $("#id").val(),
                        _csrf_token: $("#csrf").val(),
                        status: "A"
                    },
                    success: function(result) {
                        if (result.info) {

                            $('#change-status-company-info').hide('fast');
                            $('#create-company-info').show('fast');

                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    // loco Model table

    var dt_email_alerts = $('#dt_email_alerts').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_email_alerts tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#type').val(button.attr("data-type"));
        $('#email ').val(button.attr("data-email"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_model').modal('show');
    });

    $('#dt_email_alerts tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/email/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_email_alerts.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_email_alerts tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/email',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_email_alerts.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Email deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    /////////////////////////// coilard///////////////////////////////////////////

    $('#submit-wagon-tracker').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You want to save this record!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                var data = $("form").serialize();
                spinner.show();
                $.ajax({
                    url: '/create/new/wagon/tracking',
                    type: 'POST',
                    data: data,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            $('.clear_form').val('');
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Oops...',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    //display of wagon tracker

    var wagon_tracker = $('#dt-wagon-tracker').DataTable({
        "responsive": true,
        "processing": true,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/tracking/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "customer_id": $('#customer_id').val(),
                "wagon_id": $('#wagon_id').val(),
                "current_location_id": $('#current_location_id').val(),
                "commodity_id": $('#commodity_id').val(),
                "origin_id": $('#origin_id').val(),
                "destination_id": $('#destination_id').val(),
                "yard_siding": $('#yard_siding').val(),
                "update_date": $('#update_date').val(),
                "train_no": $('#train_no').val(),
            }
        },
        "columns": [
            { "data": "client_name" },
            { "data": "wagon" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "current_location" },
            { "data": "dest_station" },
            { "data": "yard_siding" },
            { "data": "train_no" },
            { "data": "update_date" },


            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" href="/view/wagon/tracker?id=' + data + '" aria-expanded="true"><i class="la la-eye" ></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>"
            }
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#filter').on('click', function() {
        $('#filter_model').modal('show');
    });

    $('#report-filter').on('click', function() {
        wagon_tracker.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.wagon_id = $('#wagon_id').val();
            data.customer_id = $('#customer_id').val();
            data.current_location_id = $('#current_location_id').val();
            data.commodity_id = $('#commodity_id').val();
            data.origin_id = $('#origin_id').val();
            data.destination_id = $('#destination_id').val();
            data.yard_siding = $('#yard_siding').val();
            data.update_date = $('#update_date').val();
            data.train_no = $('#train_no').val();

        });
        $('#filter_model').modal('hide');
        wagon_tracker.draw();
    });

    ////////////////////////// russell///////////////////////////////////////////

    // not to allow required field to be empty

    $('#submit-wagon-tracker').click(function() {

        if (($('#update_date').val() == "") ||
            ($('#wagon_id').val() == "") ||
            ($('#customer_id').val() == "") ||
            ($('#train_no').val() == "") ||
            ($('#current_location_id').val() == "") ||
            ($('#yard_siding').val() == "") ||
            ($('#sub_category').val() == "") ||
            ($('#commodity_id').val() == "") ||
            ($('#origin_id').val() == "") ||
            ($('#destination_id').val() == "") ||
            ($('#bound').val() == "") ||
            ($('#condition_id').val() == "")

        ) {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
    });

    // domain table

    var dt_domain = $('#dt_domain').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_domain tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });


    $('#dt_domain tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/domain/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_domain.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#dt_domain tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/delete/domain',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_domain.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Domain deleted successfully!',
                            'success'
                        )
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Cancelled',
                            'Something went wrong',
                            'error'
                        )
                    }
                });
            } else {
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });


    // region table

    var dt_region = $('#dt_region').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 2,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "12",
                "className": "text-center"
            }
        ],
    });

    $('#dt_region tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_region tbody').on('click', '.change-status', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#3085d6',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes, continue!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                spinner.show();
                $.ajax({
                    url: '/change/region/status',
                    type: 'POST',
                    data: {
                        id: button.attr("data-id"),
                        status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_region.cell($tr, 2).data(stat).draw();
                            button.parent().children("a.status").each(function() {
                                var $a = $(this);
                                if ($a.css('display') == 'none')
                                    $a.show();
                                else
                                    $a.hide();
                            });
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            spinner.hide();
                            Swal.fire(
                                'Opps',
                                result.error,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        spinner.hide();
                        Swal.fire(
                            'Oops...',
                            'Something went wrong!',
                            'error'
                        )
                    }
                });
            } else {
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    // wagon position report

    var report_dt = $('#dt-wagon-position-report').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/position/tracker/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "wagon_symbol": $('#wagon_symbol').val(),
                "status": $('#status').val(),
                "domain": $('#domain').val(),
                "count": $('#count').val(),

            }
        },

        "columns": [
            { "data": "wagon_symbol" },
            { "data": "status" },
            { "data": "count" },
            { "data": "domain" },
            { "data": "grand_total" }

            // {
            // 	"data": "id",
            // 	"render": function ( data, type, row ) {
            //         return '<button class="btn btn-primary btn-xs" data-toggle="dropdown" style="margin-top:0px !important; padding-top: 0px !important;">Options</button>'+
            //         '<div class="dropdown-menu dropdown-menu-animated dropdown-menu-right position-absolute pos-top">'+
            //             '<a href="/ouwd/view/entry?id='+data+'" class="dropdown-item text-primary">View details</a>'+
            //             // '<a href="/proof/of/payment?id='+data+'" class="dropdown-item text-primary">Proof of Payment</a>'+
            //         '</div>';
            // 	},
            // 	"defaultContent": "<span class='text-danger'>No Actions</span>"
            // }
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ],
        "columnDefs": [{
                "visible": true,
                "targets": [0, 1, 2],
                "width": "20%",
                "targets": [1],
                //  "width": "10%", "targets": [2]
            },
            {
                "targets": 0,
                "className": "text-right fw-1000"
            },
            {
                "visible": false,
                "targets": [3, 4],
            }

        ],
        "rowGroup": {
            startRender: function(rows, group) {
                console.log(rows);
                return group
            },
            dataSrc: ['domain'],
            className: 'fw-500'
        }
    });

    // wagon allocation report

    var wagon_allocation_dt = $('#dt-wagon-allocation-position').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/allocation/tracker/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "region": $('#region').val(),
                "customer": $('#customer').val(),
                "count": $('#count').val(),


            }
        },

        "columns": [
            { "data": "region" },
            { "data": "customer" },
            { "data": "count" },
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ],
        "columnDefs": [{
                "visible": false,
                "targets": [0],
                "className": "fw-600"
                    //  "width": "20%", "targets": [1],
                    //  "width": "10%", "targets": [2]
            }

        ],
        "rowGroup": { dataSrc: ['region'], className: 'fw-600' }
    });

    // wagon yard position report

    var wagon_yard_position_dt = $('#dt-wagon-yard-position').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/yard/position/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "region": $('#region').val(),
                "customer": $('#customer').val(),
                "count": $('#count').val(),
            }
        },

        "columns": [
            { "data": "current_location" },
            { "data": "owner" },
            { "data": "commodity" },
            { "data": "wagon_symbol" },
            { "data": "count" },
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 2, 'asc']
        ],
        "columnDefs": [{
            "visible": false,
            "targets": [0],
            "className": "fw-600"
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
        }],
        "rowGroup": { dataSrc: ['current_location'], className: 'fw-600' }
    });

    // wagon daily position report

    var dt_daily_wagon_postion_dt = $('#dt_daily_wagon_postion').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/daily/position/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "Wagon": $('#Wagon').val(),
            }
        },

        "columns": [
            { data: "wagon" },
            { data: "wagon_status" },
            { data: "count_available" },
            { data: "count_available" },
            { data: "count" },
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 2, 'asc']
        ],
        "columnDefs": [{
            "visible": false,
            "targets": [0],
            "className": "fw-600"
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
        }],
        "rowGroup": { dataSrc: ['Wagon'], className: 'fw-600' }
    });
    // wagon condition report
    var dt_wagon_condition_report = $('#dt-wagon-condition-report').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/by/condition/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "Wagon": $('#Wagon').val(),
            }
        },

        "columns": [
            { data: "wagon" },
            { data: "condition" },
            { data: "count" },
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 2, 'asc']
        ],
        "columnDefs": [{
            "visible": false,
            "targets": [0],
            "className": "text-center fw-500"
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
        }],
        "rowGroup": { dataSrc: ['wagon'], className: 'fw-500' }
    });

    // delayed wagon delayed report
    var dt_delayed_wagon = $('#dt-delayed-wagon').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fal fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/delayed/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "Wagon": $('#Wagon').val(),
            }
        },

        "columns": [
            { "data": "days" },
            { "data": "wagon_status" },
            { "data": "count" },
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ],
        "columnDefs": [{
            "visible": false,
            "targets": [0],
            "className": "text-center fw-500"
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
        }],
        "rowGroup": { dataSrc: ['days'], className: 'fw-500' }
    });

    ////////////////////////// russell///////////////////////////////////////////

});