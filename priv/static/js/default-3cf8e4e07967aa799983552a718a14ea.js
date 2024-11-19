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
    return true;
}

function is_number_key(evt) {
    var charCode = (evt.which) ? evt.which : event.keyCode
    if (charCode > 31 && (charCode < 48 || charCode > 57))
        return false;
    return true;
}

function capitalize(str) {
    var splitStr = str.toLowerCase().split(' ');
    for (var i = 0; i < splitStr.length; i++) {
        // You do not need to check if i is larger than splitStr length, as your for does that for you
        // Assign it back to the array
        splitStr[i] = splitStr[i].charAt(0).toUpperCase() + splitStr[i].substring(1);     
    }
    // Directly return the joined string
    return splitStr.join(' '); 
 }

 function get_day(date) {
    const d = new Date(date);
    let day = d.getDay();
    return day;
}


var a = ['','one ','two ','three ','four ', 'five ','six ','seven ','eight ','nine ','ten ','eleven ','twelve ','thirteen ','fourteen ','fifteen ','sixteen ','seventeen ','eighteen ','nineteen '];
var b = ['', '', 'twenty','thirty','forty','fifty', 'sixty','seventy','eighty','ninety'];

function inWords (num) {
    if ((num = num.toString()).length > 9) return 'overflow';
    n = ('000000000' + num).substr(-9).match(/^(\d{2})(\d{2})(\d{2})(\d{1})(\d{2})$/);
    if (!n) return; var str = '';
    str += (n[1] != 0) ? (a[Number(n[1])] || b[n[1][0]] + ' ' + a[n[1][1]]) + 'million ' : '';
    str += (n[2] != 0) ? (a[Number(n[2])] || b[n[2][0]] + ' ' + a[n[2][1]]) + 'hundred ' : '';
    str += (n[3] != 0) ? (a[Number(n[3])] || b[n[3][0]] + ' ' + a[n[3][1]]) + 'thousand ' : '';
    str += (n[4] != 0) ? (a[Number(n[4])] || b[n[4][0]] + ' ' + a[n[4][1]]) + 'hundred ' : '';
    str += (n[5] != 0) ? ((str != '') ? 'and ' : '') + (a[Number(n[5])] || b[n[5][0]] + ' ' + a[n[5][1]]) + 'only ' : '';
    return str;
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
    var surcharge_rate = 0;
    var consgmt_wagon_num;
    var rate = {};
    var WagonID;
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
    var selected_rows = [];
    var tracker_row;
    var status;
    var consign_smry_data = [
        { "header": "Rate", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 },
        { "header": "Total", "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "additional_chg": 0.00 }
    ];
    var consign = [
        { "comment": "", "invoice_number": "", "total": 0.00, "rsz": 0.00, "nlpi": 0.00, "nll": 0.00, "tfr": 0.00, "tzr": 0.00, "tzr_project": 0.00, "wagon_code": "", "wagon_owner": "", "wagon_type": "", "capacity_tonnes": 0.00, "actual_tonnes": 0.00, "tariff_tonnage": 0.00, "container_no": " ", "additional_chg": 0.00, edited: false }
    ];

    var editRow = 0;

    $('#create-tariff-line').click(function() {

        var tarriff = {};
        $.each($('.tariff_lines').serializeArray(), function(i, field) {
            tarriff[field.name] = field.value;
        });
        var domRates = document.querySelectorAll("div[data-repeater-item]");
        var rates = [];
        domRates.forEach(function(rate) {
            var rate_entry = {
                admin_id: rate.querySelector('.rail-admin').value,
                rate: rate.querySelector('.rate').value
            }
            rates.push(rate_entry);
        });
        tarriff.rates = rates;
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
                    url: '/new/tariff/line',
                    type: 'POST',
                    data: tarriff,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            window.location.replace("/view/tariff/line");
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Loco Type",
                filename: "Loco Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Loco Type",
                filename: "Loco Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Loco Type",
                filename: "Loco Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
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
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
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

    // Loco driver table
    var dt_loco_driver = $('#dt_loco_driver').DataTable({
        responsive: true,
        // "bFilter": false,

        'columnDefs': [{
            "targets": 4,
            "width": "12",
            "className": "text-center"
        }, ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });


    $('#dt_loco_driver tbody').on('click', '.change-status', function() {
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
                    url: '/change/loco/driver/status',
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

                            dt_loco_driver.cell($tr, 3).data(stat).draw();
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


    $('#dt_loco_driver tbody').on('click', '.delete', function() {
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
                    url: '/delete/loco/driver',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_loco_driver.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Operation successful!',
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



    // Tarriff line table

    var dt_tariff_line = $('#dt_tariff_line').DataTable({
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
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No Tarriff found !"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/view/tariff/line',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "client_id": $("#rpt_client_id").val(),
                "surcharge_id": $("#rpt_surcharge_id").val(),
                "start_dt": $("#rpt_start_dt").val(),
                "orig_station_id": $("#rpt_orig_station_id").val(),
                "destin_station_id": $("#rpt_destin_station_id").val(),
                "commodity_id": $("#rpt_commodity_id").val(),
                "pay_type_id": $("#rpt_pay_type_id").val(),
                "currency_id": $("#rpt_currency_id").val(),
                "category": $("#category").val()
            }
        },
        "columns": [
            { "data": "client_name" },
            { "data": "origin_station" },
            { "data": "destin_station" },
            { "data": "commodity"},
            { "data": "payment_type"},
            { "data": "currency"},
            { "data": "surcharge"},
            { "data": "category"},
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'A'){
                        return "<span class='m-badge m-badge--success m-badge--wide'>Active</span>"
                    } else {
                        return "<span class='m-badge m-badge--danger m-badge--wide'>Disabled</span>"
                    }
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>" 
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    var opt = row["status"]  == 'A' ? "display: block;" : "display: none;";
                    var opt_2 = row["status"]  == 'D' ? "display: block;" : "display: none;";

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                        '<a class="dropdown-item view" href="#" data-id= "' + data + '" ><i class="la la-eye"></i> View</a>' +
                                        '<a class="dropdown-item edit" href="#" data-id= "' + data + '"><i class="la la-edit"></i> Edit</a>' +
                                        '<a class="status dropdown-item  text-success change-status" href="#" data-id= "' + data + '" data-status="A" style="'+ opt_2 +'" ><i class="la la-check"></i>Activate</a>' +
                                        '<a class="status dropdown-item  text-warning change-status" href="#" data-id= "' + data + '" data-status="D" style="'+ opt +'"><i class="la la-close"></i>Disable</a>' +
                                        '<a class="dropdown-item delete text-danger" href="#" data-id= "' + data + '" ><i class="flaticon-delete" aria-hidden="true"></i> Delete</a>' +
                                ' </div>' +
                            '</span>'


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

    $('#filter-tariff-line').on('click', function() {
        dt_tariff_line.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.client_id = $("#rpt_client_id").val();
            data.start_dt = $("#rpt_start_dt").val();
            data.surcharge_id = $('#rpt_surcharge_id').val();
            data.orig_station_id = $('#rpt_orig_station_id').val();
            data.destin_station_id = $('#rpt_destin_station_id').val();
            data.commodity_id = $('#rpt_commodity_id').val();
            data.pay_type_id = $('#rpt_pay_type_id').val();
            data.currency_id = $('#rpt_currency_id').val();
            data.category = $('#category').val();
        });
        $('#filter_modal').modal('hide');
        dt_tariff_line.draw();
    });

    $('#tarrif_line_reset_report_filter').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        dt_tariff_line.draw();
    });

    $('#download-tarriff-rates-excel').click(function() {
        $('#tarriffSearchForm').attr('action', '/download/tariff/line/rates/excel');
        $('#tarriffSearchForm').attr('method', 'GET');
        $("#tarriffSearchForm").submit();
    })

    var view_tariff_line = $('#view-tariff-line').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        data: [],
        columns: [
            { data: "admin" },
            { data: "rate" },
        ]

    });

    var edit_tariff_line = $('#edit-tariff-line').DataTable({
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 2,
            "width": "7",
            "className": "text-center"
        }],
        data: [],
        columns: [
            { data: "admin" },
            { data: "rate" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '<a href="#" class="remove_selected_rate  m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-id = ' + data + ' title="Delete"><i class="la la-trash"></i></a>'
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "12",
                "className": "text-center"
            },
        ]

    });

    $('#edit-tariff-line tbody').on('click', '.remove_selected_rate', function() {
        var row = $(this).parents('tr')[0];
        var button = $(this);
        var $tr = $(this).closest('tr');


        if (edit_tariff_line.row(row).data().id == "") {
            edit_tariff_line.row($tr).remove().draw(false);
            Swal.fire(
                'Success',
                'Tariff line rate deleted successfully!',
                'success'
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
                    url: '/delete/tarriff/line/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        edit_tariff_line.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Tariff line rate deleted successfully!',
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


    $('#update-tariff-line').click(function() {

        if (edit_tariff_line.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Adminstrator Rate has been Added!',
                'error'
            )
            return false;
        }

        var tarriff = {};
        $.each($('.edit_tariff_lines').serializeArray(), function(i, field) {
            tarriff[field.name] = field.value;
        });

        var rates = [];
        edit_tariff_line.rows().every(function() {
            rates.push(this.data());

        });

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
                    url: '/update/tariff/line',
                    type: 'POST',
                    data: { entry: tarriff, rates: rates, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            window.location.replace("/view/tariff/line");
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


    $('#add_tarriff_rate').on('click', function() {

        if (($("#new_admin").val() == "") ||
            ($("#new_rate").val() == ""))

        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        var rate_data = [{
            "admin": $('#new_admin option:selected').data('admin'),
            "rate": $("#new_rate").val(),
            "id": "",
            "admin_id": $("#new_admin").val()

        }, ];

        edit_tariff_line.rows.add(rate_data).draw(false);
        $('.rate-clear').val('');
    });


    $('#dt_tariff_line tbody').on('click', '.edit', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/tarriff/line/rate/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),

            },
            success: function(result) {

                $('#edit_start_dt').val(result.tariff.start_dt);
                $('#edit_surcharge_id').val(result.tariff.surcharge_id);
                $('#edit_currency_id').val(result.tariff.currency_id);
                $('#edit_pay_type_id').val(result.tariff.pay_type_id);
                $('#edit_commodity_id').val(result.tariff.commodity_id);
                $('#edit_client_id').val(result.tariff.client_id);
                $('#edit_destin_station_id').val(result.tariff.destin_station_id);
                $('#edit_orig_station_id').val(result.tariff.orig_station_id);
                $('#edit_category').val(result.tariff.category);
                $('#edit_id').val(button.attr("data-id"));

                if (result.data.length < 1) {
                    spinner.hide();
                    $('#edit_modal').modal('show');
                    edit_tariff_line.clear().rows.add([]).draw();

                } else {
                    spinner.hide();
                    $('#edit_modal').modal('show');
                    edit_tariff_line.clear().rows.add(result.data).draw();

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

    $('#dt_tariff_line tbody').on('click', '.view', function() {
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/tarriff/line/rate/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),

            },
            success: function(result) {


                var checker = result.tariff.checker ? result.tariff.checker.first_name + ' ' + result.tariff.checker.last_name : null;
                var maker = result.tariff.maker ? result.tariff.maker.first_name + ' ' + result.tariff.maker.last_name : null;
                var origin = result.tariff.orig_station ? result.tariff.orig_station.description : null;
                var destin = result.tariff.destin_station ? result.tariff.destin_station.description : null;
                var commodity = result.tariff.commodity ? result.tariff.commodity.description : null;
                var currency = result.tariff.currency ? result.tariff.currency.description : null;
                var client = result.tariff.client ? result.tariff.client.client_name : null;
                var surcharge = result.tariff.surcharge ? result.tariff.surcharge.description : null;
                var pay_type = result.tariff.pay_type ? result.tariff.pay_type.description : null;
                var created = (new Date( result.tariff.inserted_at).toLocaleString())
                var modified = (new Date(result.tariff.updated_at).toLocaleString())

                $('#created').val(created);
                $('#modified').val(modified);
                $('#checker').val(maker);
                $('#maker').val(maker);
                $('#vw_start_dt').val(result.tariff.start_dt);
                $('#vw_surcharge_id').val(surcharge);
                $('#vw_currency_id').val(currency);
                $('#vw_pay_type_id').val(pay_type);
                $('#vw_commodity_id').val(commodity);
                $('#vw_client_id').val(client);
                $('#vw_destin_station_id').val(destin);
                $('#vw_orig_station_id').val(origin);
                
                if (result.data.length < 1) {
                    spinner.hide();
                    $('#view_modal').modal('show');
                    view_tariff_line.clear().rows.add([]).draw();

                } else {
                    spinner.hide();
                    $('#view_modal').modal('show');
                    view_tariff_line.clear().rows.add(result.data).draw();

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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Loco Model",
                filename: "Loco Model List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Loco Model",
                filename: "Loco Model List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Loco Model",
                filename: "Loco Model List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
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

    $('#dt_loco_model tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_model').val(button.attr("data-model"));
        $('#vw_self_weight').val(button.attr("data-self_weight"));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#vw_status').val(button.attr("data-status"));
        $('#created_dt').val(button.attr("data-created"));
        $('#modified_dt').val(button.attr("data-modified"));
        $('#view_modal').modal('show');
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
                    url: '/delete/loco/driver',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_loco_model.row($tr).remove().draw(false);
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Spares",
                filename: "Spare List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Spares",
                filename: "Spare List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Spares",
                filename: "Spare List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
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
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Defects",
                filename: "Defect List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Defects",
                filename: "Defect List",
                exportOptions: {
                    columns: [  0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Defects",
                filename: "Defect List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            }
        ],
    });

    var dt_defect_spares = $('#dt-defect-spares').DataTable({
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 2,
            "width": "7",
            "className": "text-center"
        }],
        data: [],
        columns: [
            { data: "spare" },
            { data: "code" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '<a href="#" class="remove_selected_spare  m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-id = ' + data + ' title="Delete"><i class="la la-trash"></i></a>'
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "6",
                "className": "text-center"
            },
        ]

    });

    var dt_defect_spares_edit = $('#dt-defect-spare-edit').DataTable({
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 2,
            "width": "7",
            "className": "text-center"
        }],
        data: [],
        columns: [
            { data: "spare" },
            { data: "code" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '<a href="#" class="remove_selected_spare  m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-id = ' + data + ' title="Delete"><i class="la la-trash"></i></a>'
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "6",
                "className": "text-center"
            },
        ]

    });

    var dt_defect_spares_view = $('#dt-defect-spare-view').DataTable({
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 1,
            "width": "7",
            "className": "text-center"
        }],
        data: [],
        columns: [
            { data: "spare" },
            { data: "code" }
        ]

    });

    $('#dt_defect tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_currency').val(button.attr("data-currency"));
        $('#edit_surcharge').val(button.attr("data-surcharge"));
        $('#edit_man_hours').val(button.attr("data-currency"));
        $('#edit_cost').val(button.attr("data-cost"));
        $('#edit_modal').modal('show');
    });

    $('#dt_defect tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_surcharge').val(button.attr("data-surcharge"));
        $('#vw_man_hours').val(button.attr("data-currency"));
        $('#vw_cost').val(button.attr("data-cost"));
        $('#view_modal').modal('show');
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

    $('#add_defects').click(function() {

        // if (dt_defect_spares.rows().count() <= 0) {
        //     Swal.fire(
        //         'Oops..!',
        //         'No Defect spare has been Added!',
        //         'error'
        //     )
        //     return false;
        // }

        // var spare = [];
        // dt_defect_spares.rows().every(function() {
        //     spare.push(this.data());

        // });

          
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
                    url: '/new/defect',
                    type: 'POST',
                    data: { description: $("#new_description").val(), 
                            code: $("#new_code").val(), 
                            // spares: spare,
                            _csrf_token: $("#csrf").val(),
                            currency_id: $("#new_currency").val(),
                            surcharge_id: $("#new_surcharge").val(), 
                            man_hours: $("#new_man_hours").val(),
                            cost: $("#new_cost").val(),
                            type: $("#type").val()
                        },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            window.location.reload();
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

    $('#dt-defect-spares tbody').on('click', '.remove_selected_spare', function() {
        var row = $(this).parents('tr')[0];
        var button = $(this);
        var $tr = $(this).closest('tr');
        dt_defect_spares.row($tr).remove().draw(false)
        $(".select2_form option:selected").remove();


        // if (edit_tariff_line.row(row).data().id == "") {
        //     edit_tariff_line.row($tr).remove().draw(false);
        //     Swal.fire(
        //         'Success',
        //         'Tariff line rate deleted successfully!',
        //         'success'
        //     )
        //     return false;
        // }


        // Swal.fire({
        //     title: 'Are you sure?',
        //     text: "You won't be able to revert this!",
        //     type: "warning",
        //     showCancelButton: true,
        //     confirmButtonColor: '#3085d6',
        //     cancelButtonColor: '#d33',
        //     confirmButtonText: 'Yes, continue!',
        //     showLoaderOnConfirm: true
        // }).then((result) => {
        //     if (result.value) {
        //         spinner.show();
        //         $.ajax({
        //             url: '/delete/tarriff/line/rate',
        //             type: 'DELETE',
        //             data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
        //             success: function(result) {
        //                 spinner.hide();
        //                 edit_tariff_line.row($tr).remove().draw(false);
        //                 Swal.fire(
        //                     'Success',
        //                     'Tariff line rate deleted successfully!',
        //                     'success'
        //                 )
        //             },
        //             error: function(request, msg, error) {
        //                 spinner.hide();
        //                 Swal.fire(
        //                     'Cancelled',
        //                     'Something went wrong',
        //                     'error'
        //                 )
        //             }
        //         });
        //     } else {
        //         spinner.hide();
        //         Swal.fire(
        //             'Cancelled',
        //             'Operation not performed :)',
        //             'error'
        //         )
        //     }
        // })
    });

    $('#defect_spare').on('change', function() {
        
        var spare = [{
            "spare": $('#defect_spare option:selected').data('spare'),
            "code": $('#defect_spare option:selected').data('code'),
            "spare_id": $("#defect_spare").val()

        }, ];

        dt_defect_spares.rows.add(spare).draw(false);
        $('.rate-clear').val('');
    });

    $('#defect_spare_edt').on('change', function() {
        
        var spare = [{
            "spare": $('#defect_spare_edt option:selected').data('spare'),
            "code": $('#defect_spare_edt option:selected').data('code'),
            "spare_id": $("#defect_spare_edt").val(),
            "id": ""

        }, ];

        dt_defect_spares_edit.rows.add(spare).draw(false);
      
    });

    $('#dt-defect-spare-edit tbody').on('click', '.remove_selected_spare', function() {
        var row = $(this).parents('tr')[0];
        var button = $(this);
        var $tr = $(this).closest('tr');
    

        if (dt_defect_spares_edit.row(row).data().id == "") {
            dt_defect_spares_edit.row($tr).remove().draw(false);
            Swal.fire(
                'Success',
                'Spare deleted successfully!',
                'success'
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
                    url: '/delete/defect/spare',
                    type: 'DELETE',
                    data: { id: dt_defect_spares_edit.row(row).data().id, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_defect_spares_edit.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Spare deleted successfully!',
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

    $('#update_defects').click(function() {

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
                    url: '/update/defect',
                    type: 'POST',
                    data: {
                        id: $("#edit_id").val(), status: "D", 
                        description: $("#edit_description").val(),
                        code: $("#edit_code").val(), 
                        // spares: spare,
                        _csrf_token: $("#csrf").val(),
                        currency_id: $("#edit_currency").val(),
                        surcharge_id: $("#edit_surcharge").val(), 
                        man_hours: $("#edit_man_hours").val(),
                        cost: $("#edit_cost").val(),
                        type: $("#type").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            window.location.reload();
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

    // interchange fee table

    var dt_interchange_fee = $('#dt_interchange_fee').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 6,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Wagon Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Wagon Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Rates",
                filename: "Wagon Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
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
        $('#edit_wagon_type').val(button.attr("data-wagon-type"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_interchange_fee tbody').on('click', '.view', function() {
        var button = $(this);

        $('#vw_lease_period').val(button.attr("data-lease_period"));
        $('#vw_year').val(button.attr("data-year"));
        $('#vw_amount').val(button.attr("data-amount"));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_partner').val(button.attr("data-partner"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
      
        $('#view_modal').modal('show');
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

                            dt_interchange_fee.cell($tr, 6).data(stat).draw();
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
                "targets": 6,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Price Catalog",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Price Catalog",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Rates",
                filename: "Price Catalog",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            }
        ],
    });

    $('#dt_spare_fee tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_start_date').val(button.attr("data-start_date"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency_id').val(button.attr("data-currency"));
        $('#edit_spare_id').val(button.attr("data-spare"));
        $('#edit_admin').val(button.attr("data-admin"));
        $('#edit_cataloge').val(button.attr("data-cataloge"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_spare_fee tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_start_date').val(button.attr("data-start_date"));
        $('#vw_amount').val(button.attr("data-amount"));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_cataloge').val(button.attr("data-cataloge"));
        $('#vw_spare').val(button.attr("data-spare"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#vw_admin').val(button.attr("data-admin"));
        $('#vw_status').val(button.attr("data-status"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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

                            dt_spare_fee.cell($tr, 6).data(stat).draw();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Surcharge",
                filename: "Surcharge List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Surcharge",
                filename: "Surcharge List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Surcharge",
                filename: "Surcharge List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
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

    $('#dt_surcharge tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_surcharge_percent').val(button.attr("data-surcharge_percent"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Commodiy Groups",
                filename: "Commodiy Groups",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Commodiy Groups",
                filename: "Commodiy Groups",
                exportOptions: {
                    columns: [  0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Commodiy Groups",
                filename: "Commodiy Groups",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ]
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
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
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
                            'Commodity group deleted successfully!',
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
        'columnDefs': [{
            "targets": 4,
            "width": "80",
                    "className": "text-center"
                },
                {
                    "targets": 5,
                    "width": "12",
                    "className": "text-center"
                }
            ],
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No Wagon found !"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/view/wagons',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "wagon_symbol": $("#rpt_wagon_symbol").val(),
                "wagon_owner": $("#rpt_wagon_owner").val(),
                "wagon_type": $("#rpt_wagon_type").val(),
                "wagon_sub_type": $("#rpt_wagon_sub_type").val(),
                "code": $("#rpt_code").val(),
                "description": $("#rpt_description").val(),
                "current_station": $("#rpt_current_station").val(),
                "wagon_condition": $("#rpt_wagon_condition").val()

            }
        },
        "columns": [
            { "data": "wagon_code" },
            { "data": "description" },
            { "data": "wagon_type" },
            { "data": "owner"},
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'A'){
                        return "<span class='m-badge m-badge--success m-badge--wide'>Active</span>"
                    } else {
                        return "<span class='m-badge m-badge--danger m-badge--wide'>Disabled</span>"
                    }
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>" 
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    // return '<a href= "#" data-admin-id = ' + row["admin_id"] + '  data-id = ' + data + ' data-lease_period = ' + row["lease_period"] + ' data-off_hire_date = ' + row["off_hire_date"] + ' data-accumulative_amount = ' + row["accumulative_amount"] + ' data-accumulative_days = ' + row["accumulative_days"] + ' data-wagon = ' + row["wagon_code"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + '  data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'
                    var load_status = row["load_status"]  == 'L' ? "Loaded" : "Empty";
                    var status = row["status"]  == 'A' ? "Active" : "Disabled";
                    var mvt_status = row["mvt_status"]  == 'A' ? "Active" : "Not Active";
                    var assigned = row["assigned"] == 'YES' ? row["client_name"] : "Not-Allocated";
                    var created = (new Date( row["inserted_at"]).toLocaleString())
                    var modified = (new Date( row["updated_at"]).toLocaleString())
                    var opt = row["status"]  == 'A' ? "display: block;" : "display: none;";
                    var opt_2 = row["status"]  == 'D' ? "display: block;" : "display: none;";
                    var checker = row["checker_ft_name"] ? row["checker_ft_name"] + ' ' + row["checker_lt_name"] : "";
                    var maker = row["maker_ft_name"]? row["maker_ft_name"] + ' ' + row["maker_lt_name"] : "";
                    var description = row["description"] ? row["description"] : "";
                    var station = row["station"] ? row["station"] : "";
                    var condition = row["condition"] ? row["condition"] : "";

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                        '<a class="dropdown-item view" href="#" data-station="'+ station +'"  data-condition="'+ condition +'" data-modified="'+ modified +'" data-created = "'+ created +'" data-symbol="'+  row["wagon_symbol"] + '" data-maker ="' + maker + '"  data-description="' + description + '" data-checker ="' + checker + '" data-load-status ="' + load_status + '" data-movement-status="' + mvt_status + '" data-assigned ="'+ assigned +'" data-status ="' + status + '" data-code="'+ row["wagon_code"] +'" data-owner ="'+ row["owner"] +'" data-type ="'+ row["wagon_type"]  +'"><i class="la la-eye"></i> View</a>' +
                                    
                                        '<a class="dropdown-item assign text-info" href="#"  data-customer= "' + row["allocated_cust_id"] + '" data-assigned= "' + row["assigned"] + '" data-id= "' + row["id"] + '"><i class="flaticon-user-add" aria-hidden="true"></i>Allocate</a>' +
                                
                                        '<a class="dropdown-item edit" href="#" data-id= "' + row["id"] + '" data-code="' + row["wagon_code"] + '"  data-owner ="' + row["owner_id"] + '" data-type ="' + row["wagon_type_id"] + '" data-description="' + description + '" data-symbol="' + row["wagon_symbol"] + '"><i class="la la-edit"></i> Edit</a>' +
                
                                        '<a class="status dropdown-item  text-success change-status" href="#" data-id= "' + row["id"] + '" data-status="A" style="'+ opt_2 +'" ><i class="la la-check"></i>Activate</a>' +
                                        '<a class="status dropdown-item  text-warning change-status" href="#" data-id= "' + row["id"] + '"  data-status="D" style="'+ opt +'"><i class="la la-close"></i>Disable</a>' +
                                    
                                        '<a class="dropdown-item delete text-danger" href="#"  data-id= "' + row["id"] + '"><i class="flaticon-delete" aria-hidden="true"></i> Delete</a>' +
                                ' </div>' +
                            '</span>'


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

    $('#filter-wagons').on('click', function() {
        dt_wgons.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.wagon_symbol = $('#rpt_wagon_symbol').val();
            data.wagon_owner = $('#rpt_wagon_owner').val();
            data.wagon_type = $('#rpt_wagon_type').val();
            data.wagon_sub_type = $('#rpt_wagon_sub_type').val();
            data.code = $('#rpt_code').val();
            data.description = $('#rpt_description').val();
            data.current_station = $("#rpt_current_station").val();
            data.wagon_condition = $("#rpt_wagon_condition").val();

        });
        $('#filter_modal').modal('hide');
        dt_wgons.draw();
    });

    $('#wagon_filter_reset').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        dt_wgons.draw();
    });

    $('#download-wagon-fleet-excel').click(function() {
        $('#wagon-report-form').attr('action', '/down/load/wagon/fleet/excel');
        $('#wagon-report-form').attr('method', 'GET');
        $("#wagon-report-form").submit();
    })

    $('#dt_wgons tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_wagon_type').val(button.attr("data-type"));
        $('#edit_wagon_owner').val(button.attr("data-owner"));
        $('#edit_wagon_symbol').val(button.attr("data-symbol"));

        $('#edit_modal').modal('show');
    });

    $('#dt_wgons tbody').on('click', '.view', function() {
        var button = $(this);
        $('.clear_wagon').val('');
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_wagon_type').val(button.attr("data-type"));
        $('#vw_wagon_owner').val(button.attr("data-owner"));
        $('#vw_wagon_symbol').val(button.attr("data-symbol"));
        $('#vw_assigned').val(button.attr("data-assigned"));
        $('#vw_wagon_condition').val(button.attr("data-condition"));
        $('#vw_wagon_status').val(button.attr("data-movement-status"));
        $('#vw_wagon_load').val(button.attr("data-load-status"));
        $('#vw_wagon_position').val(button.attr("data-station"));

        $('#view_modal').modal('show');
    });


    $('#dt_wgons tbody').on('click', '.assign', function() {
        var button = $(this); 
        // $(".m-select2 option:selected").remove();
        $("input:radio").removeAttr("checked");

         if(button.attr("data-assigned") == "YES"){
            
            $("#assign-yes").attr('checked', 'checked');
         }
         else{
            $("#assign-no").attr('checked', 'checked');

         }
        
        $('#wagon_id').val(button.attr("data-id"));
        $('#client_id').val(button.attr("data-customer"));
        $('#assign_wagon_model').modal('show');
    });

    $('#allocate_wagon').click(function(){
        
        if ($("#client_id").val() == null)
        {
            swal({
                title: "Opps",
                text: "Select a customer!",
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
                $('#assign_wagon_model').modal('hide');
                spinner.show();
                $.ajax({
                    url: '/allocate/wagon',
                    type: 'POST',
                    data: {
                        id: $("#wagon_id").val(),
                        allocated_cust_id: $("#client_id").val(),
                        status: "D",
                        assigned: $("input[type=radio][name=assign]:checked").val(),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
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
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Types",
                filename: "Wagon Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Types",
                filename: "Wagon Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Types",
                filename: "Wagon Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
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

    $('#dt_wagon_types tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_id').val(button.attr("data-id"));
        $('#vw_capacity').val(button.attr("data-capacity"));
        $('#vw_weight').val(button.attr("data-weight"));
        $('#vw_type').val(button.attr("data-type"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#vw_status').val(button.attr("data-status"));

        $('#view_modal').modal('show');
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

                            dt_wagon_types.cell($tr, 3).data(stat).draw();
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
        paging: true,

        'columnDefs': [{
                "targets": 6,
                "width": "14",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Commodiy List",
                filename: "Commodiy List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Commodiy List",
                filename: "Commodiy List",
                exportOptions: {
                    columns: [  0, 1, 2, 3, 4, 5, 6]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Commodiy List",
                filename: "Commodiy List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6]
                }
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
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
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
                                stat = "<span class='m-badge m-badge--success m-badge--wide'>Active</span>"
                            else
                                stat = "<span class='m-badge m-badge--danger m-badge--wide'>Disabled</span>"

                            dt_commodity.cell($tr, 6).data(stat).draw();
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
                "targets": 8,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "14",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Locomotives",
                filename: "Locomotive List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Locomotives",
                filename: "Locomotive List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Locomotives",
                filename: "Locomotive List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            }
        ],
    });


    $('#dt_locomotive tbody').on('click', '.edit-locomotive', function() {
        var button = $(this);
        $('#edit_owner').val(button.attr("data-owner"));
        $('#edit_type_id').val(button.attr("data-type_id"));
        $('#edit_loco_number').val(button.attr("data-loco_number"));
        $('#edit_weight').val(button.attr("data-weight"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_loco_engine_capacity').val(button.attr("data-loco-engine-cap"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_locomotive tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_owner').val(button.attr("data-owner"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#status').val(button.attr("data-status"));
        $('#vw_type_id').val(button.attr("data-type_id"));
        $('#vw_loco_number').val(button.attr("data-loco_number"));
        $('#vw_weight').val(button.attr("data-weight"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_model').val(button.attr("data-model"));
        $('#vw_loco_engine_capacity').val(button.attr("data-loco-engine-cap"));
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

                            dt_locomotive.cell($tr, 7).data(stat).draw();
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

    ///////////////////////////////// movement exception table//////////////////////
    var dt_mvt_exceptions = $('#dt_mvt_exceptions').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 4,
                // "width": "14",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });

    $('#dt_mvt_exceptions tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_date_captured').val(button.attr("data-date-captured"));
        $('#edit_derailed').val(button.attr("data-derailment"));
        $('#edit_axles').val(button.attr("data-axles"));
        // $('#edit_model').val(button.attr("data-model"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_light_engines').val(button.attr("data-light-engines"));
        $('#edit_empty_wagons').val(button.attr("data-empty-wagons"));
        $('#edit_modal').modal('show');

    });

    $('#dt_mvt_exceptions tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_date_captured').val(button.attr("data-date-captured"));
        $('#vw_derailed').val(button.attr("data-derailment"));
        $('#vw_axles').val(button.attr("data-axles"));
        $('#vw_id').val(button.attr("data-id"));
        $('#vw_light_engines').val(button.attr("data-light-engines"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#vw_empty_wagons').val(capitalize(button.attr("data-empty-wagons")));
        $('#view_modal').modal('show');
    });

    $('#dt_mvt_exceptions tbody').on('click', '.change-status', function() {
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
                    url: '/change/mvt/exception/status',
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

                            dt_mvt_exceptions.cell($tr, 5).data(stat).draw();
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

    $('#dt_mvt_exceptions tbody').on('click', '.delete', function() {
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
                    url: '/delete/mvt/exception',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_mvt_exceptions.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'exception deleted successfully!',
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
                "targets": 5,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 8,
                "width": "14",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Stations",
                filename: "Station List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Stations",
                filename: "Station List",
                exportOptions: {
                    columns: [  0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Stations",
                filename: "Station List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            }
        ],
    });


    $('#dt_stations tbody').on('click', '.edit', function() {
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/station/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                var entry = result.data;
                console.log(entry)
                $('.field-clr').val('');
                $('#edit_acronym').val(entry.acronym);
                $('#edit_station').val(entry.station_id);
                $('#edit_description').val(entry.description);
                $('#edit_id').val(button.attr("data-id"));
                $('#edit_owner').val(entry.owner_id);
                $('#edit_domain').val(entry.domain_id);
                $('#edit_region').val(entry.region_id);
                $('#edit_interchange_point').val(entry.interchange_point);
                $('#edit_modal').modal('show');
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

    $('#dt_stations tbody').on('click', '.view', function() {
        var button = $(this);
        $.ajax({
            url: '/station/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
            success: function(result) {
                spinner.hide();
                var entry = result.data;
                console.log(entry)
                $('.field-clr').val('');
                var maker = result.data.maker ? entry.maker.first_name + ' ' + entry.maker.last_name : null;
                var checker = result.data.checker ? entry.checker.first_name + ' ' + entry.checker.last_name : null;
                var owner = result.data.owner ? entry.owner.code : null;
                var domain = result.data.domain ? entry.domain.description : null;
                var region = result.data.region ? entry.region.description : null;
                var status = entry.status == "A" ? "Active" : "Disabled";
                $('#vw_acronym').val(entry.acronym);
                $('#vw_station').val(entry.station_id);
                $('#vw_description').val(entry.description);
                $('#vw_owner').val(owner);
                $('#vw_domain').val(domain);
                $('#vw_region').val(region);
                $('#vw_interchange_point').val(entry.interchange_point);
                $('#created').val(entry.inserted_at);
                $('#modified').val(entry.updated_at);
                $('#vw_status').val(status);
                $('#checker').val(checker);
                $('#maker').val(maker);
                $('#view_modal').modal('show');
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

                            dt_stations.cell($tr, 7).data(stat).draw();
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
                "targets": 6,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Currencies",
                filename: "Currency List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Currencies",
                filename: "Currency List",
                exportOptions: {
                    columns: [  0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Currencies",
                filename: "Currency List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            }
        ],
    });

    $('#dt_currency tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_symbol').val(button.attr("data-symbol"));
        $('#edit_type').val(button.attr("data-type"));
        $('#edit_acronym').val(button.attr("data-acronym"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_currency tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_symbol').val(button.attr("data-symbol"));
        $('#vw_type').val(button.attr("data-type"));
        $('#vw_acronym').val(button.attr("data-acronym"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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

                            dt_currency.cell($tr, 5).data(stat).draw();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Countries",
                filename: "Countries",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Countries",
                filename: "Countries",
                exportOptions: {
                    columns: [  0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Countries",
                filename: "Countries",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#dt_country tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        // $('#region_id').val(button.attr("data-region"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_country tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        // $('#vw_region').val(button.attr("data-region"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Conditions",
                filename: "Wagon Condition List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Conditions",
                filename: "Wagon Condition List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Conditions",
                filename: "Wagon Condition List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            }
        ],
    });


    $('#dt_wagon_condition tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_status').val(button.attr("data-status"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_category_id').val(button.attr("data-category"));

        if(button.attr("data-usable")=='Y'){
            $("#is_usable_no").prop("checked", false);
            $("#is_usable_yes").prop("checked", true);

        }else if(button.attr("data-usable")=='N'){
            $("#is_usable_yes").prop("checked", false);
            $("#is_usable_no").prop("checked", true);
        }else{
            $("#is_usable_yes").prop("checked", false);
            $("#is_usable_no").prop("checked", false);
        }

        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_wagon_condition tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_category_id').val(button.attr("data-category"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        if(button.attr("data-usable")=='Y'){
            $("#vw_is_usable_no").prop("checked", false);
            $("#vw_is_usable_yes").prop("checked", true);

        }else if(button.attr("data-usable")=='N'){
            $("#vw_is_usable_yes").prop("checked", false);
            $("#vw_is_usable_no").prop("checked", true);
        }else{
            $("#vw_is_usable_yes").prop("checked", false);
            $("#vw_is_usable_no").prop("checked", false);
        }

        $('#view_modal').modal('show');

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

                            dt_wagon_condition.cell($tr, 4).data(stat).draw();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Customers",
                filename: "Customers List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Customers",
                filename: "Customers List",
                exportOptions: {
                    columns: [  0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Customers",
                filename: "Customers List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            }
        ]
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

    
    $('#dt_clients tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_email').val(button.attr("data-email"));
        $('#vw_status').val(button.attr("data-status"));
        $('#vw_address').val(button.attr("data-address"));
        $('#vw_phone_number').val(button.attr("data-phone_number"));
        $('#vw_client_account').val(button.attr("data-client_account"));
        $('#vw_client_name').val(button.attr("data-client_name"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
      
        $('#view_modal').modal('show');
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

                            dt_clients.cell($tr, 4).data(stat).draw();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Exchange Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Exchange Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Rates",
                filename: "Exchange Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
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

    $('#dt_exchange_rate tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_exchange_rate').val(button.attr("data-exchange_rate"));
        $('#vw_start_date').val(button.attr("data-start_date"));
        $('#vw_first_currency').val(button.attr("data-first_currency"));
        $('#vw_second_currency').val(button.attr("data-second_currency"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Payment Types",
                filename: "Payment Types",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Payment Types",
                filename: "Payment Types",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Payment Types",
                filename: "Payment Types",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
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

    $('#dt_payment_type tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Railway Administrators",
                filename: "Railway Administrators",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Railway Administrators",
                filename: "Railway Administrators",
                exportOptions: {
                    columns: [  0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Railway Administrators",
                filename: "Railway Administrators",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            }
        ]
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

    $('#dt_railway_admin tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_status').val(button.attr("data-status"));
        $('#vw_conutry').val(button.attr("data-country"));
        $('#vw_description').val(button.attr("data-description"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        $('#view_modal').modal('show');

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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Fuel Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Fuel Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Rates",
                filename: "Fuel Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
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

    $('#dt_fuel_rate tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_refueling_depo').val(button.attr("data-refueling_depo"));
        $('#vw_month').val(button.attr("data-month"));
        $('#vw_fuel_rate').val(button.attr("data-fuel_rate"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');

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
                "targets": 5,
                "width": "12"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Status",
                filename: "Wagon Status List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Status",
                filename: "Wagon Status List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Status",
                filename: "Wagon Status List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            }
        ],
    });

    $('#dt_wagon_status tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_status').val(button.attr("data-rec_status"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_pur_code').val(button.attr("data-pur-code"));
        $('#edit_modal').modal('show');

    });

    $('#dt_wagon_status tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_rec_status').val(button.attr("data-pur-code"));
        $('#vw_status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');

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
                        rec_status: button.attr("data-status"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            var stat = null;
                            if (button.attr("data-status") == "A")
                                stat = ' <span class="m-badge m-badge--success m-badge--wide">Active</span> '
                            else
                                stat = ' <span class="m-badge m-badge--danger m-badge--wide">Disabled</span> '

                            dt_wagon_status.cell($tr, 4).data(stat).draw();
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
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No Train Route found !"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/view/routes',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "description": $("#train_route_dscription").val(),
                "code": $("#train_route_code").val(),
                "route_org_station": $("#route_org_station").val(),
                "route_dest_station": $("#route_dest_station").val(),
                "route_transport_type": $("#route_transport_type").val(),
                "route_operator": $("#route_operator").val()

            }
        },
        "columns": [
            { "data": "description" },
            { "data": "code" },
            { "data": "route_org_station" },
            { "data": "route_dest_station"},
            { "data": "route_transport_type"},
            { "data": "distance"},
            { "data": "route_operator"},
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'A'){
                        return "<span class='m-badge m-badge--success m-badge--wide'>Active</span>"
                    } else {
                        return "<span class='m-badge m-badge--danger m-badge--wide'>Disabled</span>"
                    }
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>" 
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    // return '<a href= "#" data-admin-id = ' + row["admin_id"] + '  data-id = ' + data + ' data-lease_period = ' + row["lease_period"] + ' data-off_hire_date = ' + row["off_hire_date"] + ' data-accumulative_amount = ' + row["accumulative_amount"] + ' data-accumulative_days = ' + row["accumulative_days"] + ' data-wagon = ' + row["wagon_code"] + '  data-wagon_owner = ' + row["wagon_owner"] + ' data-wagon_type = ' + row["wagon_type"] + '  data-comment = ' + row["comment"] + ' class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'
                    var route_dest_station = row["route_dest_station"] ? row["route_dest_station"] : "";
                    var status = row["status"]  == 'A' ? "Active" : "Disabled";
                    var route_transport_type = row["route_transport_type"] ?  row["route_transport_type"] : "";
                    var route_operator = row["route_operator"] ? row["route_operator"] : "";
                    var created = (new Date( row["inserted_at"]).toLocaleString())
                    var modified = (new Date( row["updated_at"]).toLocaleString())
                    var opt = row["status"]  == 'A' ? "display: block;" : "display: none;";
                    var opt_2 = row["status"]  == 'D' ? "display: block;" : "display: none;";
                    var checker = row["checker_frt_name"] ? row["checker_frt_name"] + ' ' + row["checker_lst_name"] : "";
                    var maker = row["maker_frt_name"]? row["maker_frt_name"] + ' ' + row["maker_lst_name"] : "";
                    var description = row["description"] ? row["description"] : "";
                    var route_org_station = row["route_org_station"] ? row["route_org_station"] : "";

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                        '<a class="dropdown-item view" href="#" data-route-description="'+ description +'" data-modified="'+ modified +'" data-created = "'+ created +'" data-org-station="'+ route_org_station + '" data-maker ="' + maker + '" data-checker ="' + checker + '"  data-dst-station="' + route_dest_station + '" data-transport-type ="'+ route_transport_type +'" data-operator="' + route_operator + '" data-status ="' + status + '" data-code="'+ row["code"] +'" data-distance="' + row["distance"] + '"><i class="la la-eye"></i> View</a>' +
                                
                                        '<a class="dropdown-item edit" href="#" data-id= "' + row["id"] + '" data-code="' + row["code"] + '"  data-route-description="' + row["description"] + '" data-org-station ="' + row["origin_station"] + '" data-dst-station="' + row["destination_station"] + '" data-transport-type="' + row["transport_type"] + '" data-operator="' + row["operator"] + '" data-distance="' + row["distance"] + '"><i class="la la-edit"></i> Edit</a>' +
                
                                        '<a class="status dropdown-item  text-success change-status" href="#" data-id= "' + row["id"] + '" data-status="A" style="'+ opt_2 +'" ><i class="la la-check"></i>Activate</a>' +
                                        '<a class="status dropdown-item  text-warning change-status" href="#" data-id= "' + row["id"] + '"  data-status="D" style="'+ opt +'"><i class="la la-close"></i>Disable</a>' +
                                    
                                        '<a class="dropdown-item delete text-danger" href="#"  data-id= "' + row["id"] + '"><i class="flaticon-delete" aria-hidden="true"></i> Delete</a>' +
                                ' </div>' +
                            '</span>'


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

    $('#filter_trainroute').on('click', function() {
        dt_train_route.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.description = $('#train_route_dscription').val();
            data.code = $('#train_route_code').val();
            data.route_org_station = $('#route_org_station').val();
            data.route_dest_station = $('#route_dest_station').val();
            data.route_transport_type = $('#route_transport_type').val();
            data.route_operator = $('#route_operator').val();
        });
        $('#filter_modal').modal('hide');
        dt_train_route.draw();
    });

    $('#download-train-route-excel').click(function() {
        $('#train-route-report-form').attr('action', '/download/train/route/excel');
        $('#train-route-report-form').attr('method', 'GET');
        $("#train-route-report-form").submit();
    })

    $('#dt_train_route tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-route-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_origin_station').val(button.attr("data-org-station"));
        $('#edit_destination_station').val(button.attr("data-dst-station"));
        $('#edit_transport_type').val(button.attr("data-transport-type"));
        $('#edit_distance').val(button.attr("data-distance"));
        $('#edit_operator').val(button.attr("data-operator"));

        $('#edit_modal').modal('show');
    });

    $('#dt_train_route tbody').on('click', '.view', function() {
        var button = $(this);
        $('.clear_wagon').val('');
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#vw_description').val(button.attr("data-route-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_origin_station').val(button.attr("data-org-station"));
        $('#vw_destination_station').val(button.attr("data-dst-station"));
        $('#vw_transport_type').val(button.attr("data-transport-type"));
        $('#vw_distance').val(button.attr("data-distance"));
        $('#vw_operator').val(button.attr("data-operator"));
        $('#vw_satus').val(button.attr("data-status"));

        $('#view_modal').modal('show');
    });

    $('#routes_filter_reset').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        dt_train_route.draw();
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
                "targets": 5,
                "width": "12"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Transport Types",
                filename: "Transport Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Transport Types",
                filename: "Transport Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Transport Types",
                filename: "Transport Type List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4]
                }
            }
        ],
    });

    $('#dt_transport_type tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_catgory').val(button.attr("data-catgory"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_type').val(button.attr("data-type"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_transport_type tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_catgory').val(button.attr("data-catgory"));
        $('#vw_type').val(button.attr("data-type"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
    
        $('#view_modal').modal('show');
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

                            dt_transport_type.cell($tr, 4).data(stat).draw();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "User Roles",
                filename: "System User Roles",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "User Roles",
                filename: "System User Roles",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "User Roles",
                filename: "System User Roles",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
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

    $('#dt_user_activity').DataTable({
        responsive: true,

        'columnDefs': [{
            "targets": 4,
            "width": "50"
        }, ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });


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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Users",
                filename: "System Users",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Users",
                filename: "System Users",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Users",
                filename: "System Users",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            }
        ],
    });

    $('#dt_user tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#email').val(button.attr("data-email"));
        $('#user_region_id').val(button.attr("data-user_region_id"));
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

    $('#dt_user tbody').on('click', '.reset-password', function() {
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
                    url: '/reset/password',
                    type: 'POST',
                    data: {
                        user_token: button.attr("data-id"),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success',
                                'Password Reset Successful!',
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

    $('#dt_user tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_email').val(button.attr("data-email"));
        $('#vw_region').val(button.attr("data-user_region"));
        $('#vw_mobile').val(button.attr("data-mobile"));
        $('#vw_first_name').val(button.attr("data-first_name"));
        $('#vw_last_name').val(button.attr("data-last_name"));
        $('#vw_role').val(button.attr("data-role"));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#vw_status').val(button.attr("data-status"));
        $('#created_dt').val(button.attr("data-created"));
        $('#modified_dt').val(button.attr("data-modified"));
        $('#view_user').modal('show');
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

        if (edit_dt_orders.rows().count()  < 2) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < (edit_dt_orders.rows().count()); index++) {
            // const element = array[index];
            data_row.push(Object.assign(edit_dt_orders.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/save/consignment/order',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val()},
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Consignment order saved successfully!',
                                'success'
                            )
                            dt_tariff_lines_rates.clear().rows.add([]).draw();
                            edit_dt_orders.clear().rows.add([]).draw();
                            $(".select2_form option:selected").remove();
                            $('.clear_form').val('');
                            $(".clear_form").prop("disabled", true);
                            $(".select2_form").prop("disabled", true);
                            window.location.replace("/new/consignment/order");

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
        if (edit_dt_orders.rows().count() < 2) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < (edit_dt_orders.rows().count()); index++) {
            // const element = array[index];
            data_row.push(Object.assign(edit_dt_orders.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/submit/consignment/order',
                    type: 'post',                                               
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $('#batch_id').val(), client_id: $('#client_id').val(), sale_order: $('#sale_order').val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Consignment order submited successfully!',
                                'success'
                            )
                           
                            window.location.replace("/dashboard");

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
        if (dt_order_batch_entries.rows().count() <= 0) {
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

        if (dt_order_batch_entries.rows().count() <= 0) {
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
                $('#consignment_rejection_model').modal('hide');
                $.ajax({
                    url: '/approve/consignment/order/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch: $('#batch_id').val(),reason: $('#reason').val() , status: button.attr("data-status") },
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

    $('#reject-consgmt').click(function() {
        $('#consignment_rejection_model').modal('show');
    });

    $('#discard-consgmt-entries').click(function() {
        var button = $(this);

        if (edit_dt_orders.rows().count() <= 0) {
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
                    url: '/discard/consignment/order/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch: $('#batch_id').val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            dt_tariff_lines_rates.clear().rows.add([]).draw();
                            edit_dt_orders.clear().rows.add([]).draw();
                            $(".select2_form option:selected").remove();
                            $('.clear_form').val(''); 
                            window.location.replace("/consignment/order/draft");
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

    $('#select-batch').change(function() {
        batch_id = $(this).find(':selected').attr('data-batch-id');
        $('#selected-batch-id').val(batch_id);
    });

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

    if ($('#verification_client_id').length) {
        var type = $('#verification_client_id').attr('client_id_data');
        $('#verification_client_id').val(type);
        $('#verification_client_id').trigger('change');
    }

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

        if ($("#aces_lvl").val() == "")
        {
            swal({
                title: "Opps",
                text: "Select Access level!",
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

        if ($("#aces_lvl").val() == "")
        {
            swal({
                title: "Opps",
                text: "Select Access level !",
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
  
    //movement form display 

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


    $('#save-movement').click(function() {

        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (editable_movement_dt.rows().count()  < 2) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < (editable_movement_dt.rows().count()); index++) {
            // const element = array[index];
            data_row.push(Object.assign(editable_movement_dt.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/create/movement/order',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), loco_no: $("#loco_id").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order saved successfuly!',
                                'success'
                            )
                            $(".select2_form option:selected").remove();
                            $('.m-select2').val(null).trigger("change")
                            $('.clear_form').val('');
                            $("#total_wagon_count").text("0");
                            editable_movement_dt.clear().rows.add([]).draw();
                            window.location.replace("/movement/batch/entries");
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

    //submit movement for approval
    $('#movement-submit').click(function() {

        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (editable_movement_dt.rows().count()  < 2) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        //  row_count=dt_orders.rows().count()
        for (let index = 0; index < (editable_movement_dt.rows().count()); index++) {
            // const element = array[index];
            data_row.push(Object.assign(editable_movement_dt.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/submit/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), loco_no: $("#loco_id").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order submited for approval!',
                                'success'
                            )
                            $(".select2_form option:selected").remove();
                            $('.m-select2').val(null).trigger("change")
                            $('.clear_form').val('');
                            $("#total_wagon_count").text("0");
                            editable_movement_dt.clear().rows.add([]).draw();
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

    //display of movement details

    if ($('#movement_batch_entries').length) {

        spinner.show();
        $.ajax({
            url: '/movement/batch/entries/lookup',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                status: $("#entries_type").val(),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                // dt_movement.rows.add(result.data).draw(false);
                editable_movement_dt.clear().rows.add(result.data).draw();
                editable_movement_dt.row.add($(rowmovent)).draw();
                var wagon = count= editable_movement_dt.rows().count() - 1
                $("#total_wagon_count").text(wagon);
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

    $('#approve-movement-entries').click(function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        if (verification_movement_dt.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
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
                spinner.show();
                $.ajax({
                    url: '/approve/movement/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), status: button.attr("data-status") },
                    success: function(result) {
                        spinner.hide();
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

    $('#discared-movement-entries').click(function() {
   
        if (editable_movement_dt.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
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
                spinner.show();
                $.ajax({
                    url: '/discard/movement/entries',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order discarded successfully!',
                                'success'
                            )
                

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

    $('#reject-mvt').click(function() {
        $('#mvt_rejection_model').modal('show');
    });

    $('#reject-movement-entries').click(function() {

        if ($("#reason").val() == '') {
            Swal.fire(
                'Oops..!',
                'Reject reason Can not be blank!',
                'error'
            )
            return false;
        }

        if (verification_movement_dt.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
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
                $('#mvt_rejection_model').modal('hide');
                spinner.show();
                $.ajax({
                    url: '/reject/movement/entries',
                    type: 'post',
                    data: {_csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), reason: $("#reason").val() },
                    success: function(result) {
                        spinner.hide();
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

    var verification_movement_dt = $('#verification_movement_dt').DataTable({
        scrollY: "500vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bFilter: false,
        select: {
            "style": 'multi'
        },
        columnDefs: [
            { "width": "20px", "targets": '_all' },
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
            { data: "consignment_date" },
            { data: "invoice_no"}
        ]
    });

    if ($('#movement_verification_entries').length) {

        spinner.show();
        $.ajax({
            url: '/movement/batch/entries/lookup',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                status: $("#entries_type").val(),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                $(".disable-fields").prop('disabled', true);
                verification_movement_dt.clear().rows.add(result.data).draw();
                var wagon = count= verification_movement_dt.rows().count()
                $("#total_wagon_count").text(wagon);
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


    //fuel monitoring j.s


    $('#depo_refueled').on('change', function() {
        var fuel_rate = $(this).find(':selected').attr('data-depo-rate');
        $('#fuel_rate').val(fuel_rate);

    });
   
    $('#locomotive_id').on('change', function() {
        var loco_cap =  $('#locomotive_id option:selected').data('loco-engine-capacity')
        $('#loco_engine_capacity').val(loco_cap);
    });

    // $("#reading_after_refuel").on("input", function() {
    //     var after_refuel = $('#reading_after_refuel').val();
    //     var before_refuel = $('#balance_before_refuel').val();
    //     var total_refueled = after_refuel - before_refuel;
    //     var rate = $('#fuel_rate').val();
    //     var total_cost = rate * total_refueled;
    //     $('#summary_quantity_refueled').val(total_refueled);
    // });

   
    $("#bp_meter_after").on("input", function() {
        var bp_metre_after = $('#bp_meter_after').val();
        var bp_metre_before = $('#bp_meter_before').val();
        var reading = bp_metre_after - bp_metre_before;
        $('#reading').val(parseFloat(reading));

        var meter_at_dest = $('#meter_at_destin').val();
        var fuel_consumed = reading - meter_at_dest;
        $('#fuel_consumed').val(fuel_consumed);
        // var meter_at_destin = $('#meter_at_destin').val();
        // var consumed_fuel = reading - meter_at_destin;
        // $('#fuel_consumed').val(consumed_fuel);
        var consumption = $('#km_to_destin').val();

        var consumpt_per_km = reading / consumption;
        $('#consumption_per_km').val(Number(consumpt_per_km).toFixed(2));

        
        // var format_currency = new Intl.NumberFormat('en-US', {
        //     // style: 'currency',
        //     // // currency: 'ZMW',
        //     minimumFractionDigits: 2,
        //     maximumFractionDigits: 2
        //   }); 

        var rate = $('#fuel_rate').val();
        var total_cost = reading * rate;
        $('#total_cost').val(Number(total_cost).toFixed(2));
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

    $("#balance_before_refuel").on("input", function(){
        var blc_words = $('#balance_before_refuel').val();
        converted = inWords(blc_words)
        $('#fuel_blc_words').val(converted)  
    });

    $("#ctc_approved_refuel").on("input", function(){
        var ct_blc_words = $('#ctc_approved_refuel').val();
        ctc_converted = inWords(ct_blc_words)
        $('#litres_in_words').val(ctc_converted)  
    });
    
    $("#meter_at_destin").on("input", function() {
        var reading = $('#reading').val();
        var meter_at_dest = $('#meter_at_destin').val();
        var fuel_consumed = reading - meter_at_dest;
        $('#fuel_consumed').val(fuel_consumed);
    });

    $("#ctc_approved_refuel").on("input", function() {
        var approved_refuel = $('#ctc_approved_refuel').val();
        $('#approved_refuel').val(approved_refuel);
        $('.disable-feild-fuel-form').prop('disabled', false);
    });

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
            { data: "count" },
            { data: "amount" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected_defect m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'>\n <i class='la la-trash'></i></a> <a href='#' class='view_selected_defect m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-eye'></i></a>" }
        ],
    });

    var spare_loading = false;
    $('#spare_fee').on('change', function() {
        if(spare_loading) {
            return false;
        }
        spare_loading = true;
        date = $('#entry_date').val() == "" ? $('#exit_date').val() : $('#entry_date').val() 
        
        var defect = {
            "equipment": $(this).find(':selected').attr('data-description'),
            "code": $(this).find(':selected').attr('data-code'),
            "admin_id": $("#adminstrator_id").val(),
            "defect_id": $(this).find(':selected').attr('data-id'),
        }

        spinner.show();
        $.ajax({
            url: '/admin/defect/spare/rates/lookup',
            type: 'POST',
            data: {
                date: date,
                admin_id: $("#adminstrator_id").val(),
                defect_id:  $(this).find(':selected').attr('data-id'),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                
               if(result.data.length > 0){
                  
                    var data_row = [];
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    
                    dt_interchange_defect.rows.add(data_row).draw(false);
               }else{

                swal({
                    title: "Oops...",
                    text: "Spare rate not maintained for defect!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });

               }
                
                spare_loading = false;
            },

            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                spare_loading = false;
            }
        });
    });


    $('#dt-interchange-defect tbody').on('click', '.remove_selected_defect', function() {
        var $tr = $(this).closest('tr');
        dt_interchange_defect.row($tr).remove().draw(false);
    });


    $('.add_inter_change').on('click', function() {
       
        date = $('#entry_date').val() == "" ? $('#exit_date').val() : $('#entry_date').val() 

        if (($('#direction').val() == "") ||
            ($('#interchange_point').val() == "") ||
            ($('#adminstrator_id').val() == "") ||
            (date == "") 

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

    var dt_interchange_defect_spares = $('#dt-interchange-defect-spares').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 2,
            "width": "12",
            "className": "text-center"
        }, ],
        columns: [
            { data: "spare" },
            { data: "code" },
            { data: "amount" },
        ],
    });
    
    $('#dt-interchange-defect tbody').on('click', '.view_selected_defect', function() {
        var $tr = $(this).closest('tr');
        var defect = dt_interchange_defect.row($tr).data();

        $.ajax({
            url: '/admin/defect/spare/rates/lookup',
            type: 'POST',
            data: {
                admin_id: defect.admin_id,
                defect_id: defect.defect_id,
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                total = 0.0;
                data = result.data
                for (let index = 0; index < (data.length); index++) {
                    total = total + parseFloat(data[index].amount)
                    data[index].amount = data[index].currency.concat(data[index].amount)
                }
                 $("#defect_spare_total").val(total)
                 dt_interchange_defect_spares.clear().rows.add(data).draw();
                $('#view_defect_spares_model').modal('show');  
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

    var dt_interchange = $('#dt-interchange').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        select: {
            "style": 'multi'
        },    
        columnDefs: [{
            "targets": [6],
            "width": "14",
            "className": "text-center"
            },
        ],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_type" },
            { data: "wagon_owner" },
            { data: "origin_name" },
            { data: "destination_name" },
            { data: "commodity_name" },
            { data: "action",
                "defaultContent": 
                "<a href='#' class='add_wagon_defects m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-edit'></i></a>"  
            }
        ]

    });

    $('#interchange-select-all').on( 'click', function () {
		dt_interchange.rows().select();
        dt_interchange.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#interchange-unselect-all').on( 'click', function () {
        dt_interchange.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		dt_interchange.rows().deselect();
    });
    

    $('#new-interchange-list').click(function() {
        date = $('#entry_date').val() == "" ? $('#exit_date').val() : $('#entry_date').val() 
        if(
            (date == "") ||
             $('#on_hire_date').val() == "" ||
             $('#interchange_point').val() == ""  ||
             $('#adminstrator_id').val() == "" || 
             $('#direction').val() == ""
        ){
            Swal.fire(
                'Oops..!',
                'Feilds cannot be blank!',
                'error'
            )
            return false;
        }

        if (dt_interchange.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        row = dt_interchange.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }
        $('#bulk_current_status_id').val(null).trigger("change");
        $('#condition_tracker_modal').modal('show');
    });


    $("#intchge_train_no").on("input", function() {
        spinner.show();
        $.ajax({
            url: '/interchange/train/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                train_no: $("#intchge_train_no").val()
            },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {
                     
                    dt_interchange.clear().rows.add(result.data).draw();

                } else {
                    dt_interchange.clear().rows.add(result.data).draw();
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



    $('#add_interchange_wagon').click(function() {

        if (($('#wagon-code').val() == "")
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
                        "wagon_status_id": $('#wagon_status_id').val(),
                        "commodity": $("#commodity_id option:selected").attr('data-commodity'),
                        "commodity_id": $('#commodity_id').val(),
                        "comment": $('#comment').val(),
                        "action": "<a href='#' class='edit_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-edit'></i></a> <a href='#' class='remove_added_wagon m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-trash'></i></a>"
                    }];
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

    $('#dt-interchange tbody').on('click', '.add_wagon_defects', function() {
        if (($('#intchge_train_no').val() == "") ||
                ($('#wagon_status_id').val() == "") ||
                ($('#interchange_point').val() == "") ||
                ($('#direction').val() == "") ||
                ($('#on_hire_date').val() == "") ||
                ($('#adminstrator_id').val() == "")
            ) {
                swal({
                    title: "Opps",
                    text: "ensure all required fields are filled!",
                    confirmButtonColor: "#2196F3",
                    type: "error"
                });
                return false;
            }
        var $tr = $(this).closest('tr');          
        wagon_row = $tr;
        var row = dt_interchange.row($tr).data();

        $('#comment').val(row.comment);
        $('#spare_fee').val(null);
        defects  = Array.isArray(row.defects) == false ? [] : row.defects;
        dt_interchange_defect.clear().rows.add([]).draw();
        dt_interchange_defect.rows.add(defects).draw(false);

        $('#add_inter_change_model').modal('show');
    });


    $('#update_interchange_wagon').click(function() {
        var defects = [];
        $.each(dt_interchange_defect.rows().data(), function(index, item) {
            defects.push(item);
        });
        
        var rowData = dt_interchange.row(wagon_row).data();
        rowData.comment = $('#comment').val();
        rowData.defects = defects
        dt_interchange.row(wagon_row).data(rowData).draw();
        $('#add_inter_change_model').modal('hide');
        $('.wagon-field-clr').val('');

    });

    $('#create-interchange').click(function() {
        if (($('#bulk_current_status_id').val() == "")
            ) {
            Swal.fire(
                'Oops..!',
                'Wagon Status cannot be blank!',
                'error'
            )
            return false;
        }

        if (dt_interchange.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        row = dt_interchange.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.interchange_general_entries').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];
        dt_interchange.rows( { selected: true } ).every(function(rowIdx) {
            data_row.push(Object.assign(dt_interchange.rows().data()[rowIdx], details));
        })

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
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), wagon_status_id: $('#bulk_current_status_id').val()},
                    success: function(result) {
                         $(window).scrollTop(0);
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Interchange created successfully!',
                                'success'
                            )
                            // dt_interchange.clear().rows.add([]).draw();
                            // dt_interchange_defect.clear().rows.add([]).draw();
                            // $('.wagon-field-clr').val('');
                            // $('.clear_selects').val([]);
                            // $('.clear_form').val('');
                            // window.location.reload();
                            $('#condition_tracker_modal').modal('hide');

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

    $('#dt_interchange_batch').DataTable({
        responsive: true,
        'columnDefs': [{
                "targets": [6],
                "width": "14",
                "className": "text-center"
            },
        ],
    });


    $('#locomotive_id').on('change', function() {
        show_loco_number = $(this).find(':selected').attr('data-loco-number');
    });

    $('#locomotive_type').on('change', function() {
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
                "locomotive_type": $("#locomotive_type").val(),
                "locomotive_driver_id": $("#locomotive_driver_id").val(),
                "train_number": $("#train_number").val(),
                "train_origin_id": $("#train_origin").val(),
                "train_destination_id": $("#train_destination").val(),
                "depo_refueled_id": $("#depo_refueled").val(),
                "depo_stn": $("#depo_station").val(),
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
                "commercial_clerk_id": $("#commercial_clerk_id").val(),
                "section": $("#section").val(),
                "total_cost": $("#total_cost").val(),
                "comment": $("#comment").val(),
                "batch_id": $("#batch_id").val(),
                "asset_protection_officers_name": $("#asset_protection_officers_name").val(),
                "oil_rep_name": $("#oil_rep_name").val(),
                "yard_master_id": $("#yard_master_id").val(),
                "other_refuel": $("#other_instrument").val(),
                "other_refuel_no": $("#instrument_number").val(),
                "refuel_type": $("#refuel_type").val(),
                "section_id": $("#Section_type").val(),
                "locomotive_id": $("#locomotive_id").val(),
                "loco_engine_capacity": $("#loco_engine_capacity").val(),
                "shunt":$("#fuel_shunt").val(),
                "driver_name":$("#driver_name").val(),
                "commercial_clk_name":$("#commercial_clk_name").val(),
                "yard_master_name":$("#yard_master_name").val(),
                "controllers_name":$("#controllers_name").val(),
                "ctc_datestamp":$("#ctc_datestamp").val(),
                "ctc_time":$("#ctc_time").val(),
                "fuel_blc_figures":$("#fuel_blc_figures").val(),
                "fuel_blc_words":$("#fuel_blc_words").val(),
                "litres_in_words":$("#litres_in_words").val(),
                "controllers_name":$("#controllers_name").val(),
                "status": "PENDING_APPROVAL",
            },

        ];
        if (($('#depo_station').val() == "")) {
            swal({
                title: "Opps",
                text: "Refueling Depo cannot be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
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
                    url: '/create/fuel/monitor',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val() },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                    'Success',
                                    'Fuel request submited successfully!',
                                    'success'
                                )
                                window.location.reload();

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
        autoWidth: true,


    });

    $('#dt-fuel-back-office').DataTable({
        responsive: true,
        autoWidth: true,


    });

    $('#dt-req-pending-approval-list').DataTable({
        responsive: true,
        autoWidth: true,


    });

    $('#dt-rejected-fuel-requisite').DataTable({
        responsive: true,
        autoWidth: true,


    });


    var dt_fuel_report_details = $('#dt-fuel-report').DataTable({
        "responsive": true,
        "processing": true,
        "autoWidth": true,
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
                "filter_refuel_type": $("#filter_refuel_type").val()


            }
        },
        "columns": [
            { "data": "train_number" },
            { "data": "requisition_no" },
            { "data": "approved_refuel" },
            { "data": "quantity_refueled" },
            { "data": "balance_before_refuel" },
            { "data": "reading_after_refuel" },
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
        ]

    });

    $('#fuel-requisite-filter').on('click', function() {
        $('#fuel_requisite_form_filter').modal('show');
    });

      //excel
    $('#download_fuel_requisite_report_excel').click(function() {
        $('#fuel_requisite_batch_report_form').attr('action', '/download/fuel/requisite/batch/report/excel');
        $('#fuel_requisite_batch_report_form').attr('method', 'GET');
        $("#fuel_requisite_batch_report_form").submit();
    })


    $('#download_interchange_report_excel').click(function() {
        $('#interchange_batch_report_form').attr('action', '/download/interchange/onhire/report/excel');
        $('#interchange_batch_report_form').attr('method', 'GET');
        $("#interchange_batch_report_form").submit();
    })

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
            data.filter_refuel_type = $('#filter_refuel_type').val();
        });
        $('#fuel_requisite_form_filter').modal('hide');
        dt_fuel_report_details.draw();
    });

    $('#fuel_report_reset_filter').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        dt_fuel_report_details.draw();
    });

    $('.disable-feild-fuel-form').prop('disabled', true);
      
    // $('#refuel_type').on('change', function() {
    //     var loco_no = $(this).find(':selected').attr('data-refuel-type-fm');
       
    //     if ($('#refuel_type').val() == loco_no) {
    //         $("#other_instrument").prop('disabled', false);
    //         $("#instrument_number").prop('disabled', false);
    //     } 
    //     else {
    //         alert("am not selected")
    //         $("#other_instrument").prop('disabled', true);
    //         $("#instrument_number").prop('disabled', true);
    //     }
    // });

    $("#other_instrument").on("input", function() {
        $("#locomotive_id").prop('disabled', true);
        $("#locomotive_type").prop('disabled', true);
    });

    $('.load_fuel_report').on('click', function() {
        // let csrf = document.getElementById('csrf').value
        let end_date = document.getElementById('end_date').value
        let start_date = document.getElementById('start_date').value
        $.ajax({
            url: '/view/depo/summary/report',
            type: 'post',
            data: {_csrf_token: $("#csrf").val(), 
                    // start_date: $("#start_date").val(), 
                    // end_date: $("#end_date").val(), 
                },
            success: function(result) {
                $('.load_report').modal('show'); 
            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
        
    });

      $( "#depo_filter" ).click(function() {
        $( "#first_filter" ).hide(); 
        $( "#second_filter" ).show();
        $( "#third_filter" ).hide();
      });
      $( "#sec_filter" ).click(function() {
        $( "#third_filter" ).show();
        $( "#second_filter" ).hide(); 
        $( "#first_filter" ).hide();  
      });
      $( "#exco_filter" ).click(function() {
        $( "#third_filter" ).hide();
        $( "#second_filter" ).hide(); 
        $( "#first_filter" ).show();  
      });
     
    /////////distance lookup ajax call/////////////////////////////////////////////////////////
    $('.distance-lookup').on('change', function() {
        if ($('#depo_station').val() == "" || $('#train_destination').val() == "") {
            return false;
        }
        $.ajax({
            url: '/distance/km/lookup',
            type: 'post',
            data: {
                "station_orig": $('#depo_station').val(),
                "destin": $('#train_destination').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    Swal.fire(
                        'Oops..!',
                        'This Route does not exist! select a different route',
                        'error'
                    )
                    return false
                } else {
                    dist = result.data[0];
                    var distance = dist.distance;
                    $('#km_to_destin').val(distance);
                }
            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

    $('.loco-capacity-lookup').on('change', function() {
        if ($('#locomotive_id').val() == "") {
            return false;
        }
        $.ajax({
            url: '/loco/capacity/lookup',
            type: 'post',
            data: {
                "locomotive_id": $('#locomotive_id').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    Swal.fire(
                        'Oops..!',
                        'No capacity maintained for this loco selected',
                        'error'
                    )
                    return false
                } else {
                    capa = result.data[0];
                    var capacity = capa.loco_engine_capacity;
                    var type = capa.type;
                    $('#loco_engine_capacity').val(capacity);
                    $('#locomotive_type').val(type);
                }
            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

    $('.station-owner-lookup').on('change', function() {
        if ($('#reporting_station').val() == "") {
            return false;
        }
        $.ajax({
            url: '/movement/station/owner',
            type: 'post',
            data: {
                "movement_reporting_station_id": $('#reporting_station').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    Swal.fire(
                        'Oops..!',
                        'No owner for this station',
                        'error'
                    )
                    return false
                } else {
                    stn = result.data[0];
                    var owner = stn.owner;
                    $('#station_owner').val(owner);
                }
            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

     /////////fuel rate lookup ajax call/////////////////////////////////////////////////////////
     $('.fuel-rate-lkup').on('change', function() {
        if ($('#depo_station').val() == "" ) {
            return false;
        }
        $.ajax({
            url: '/lookup/fuel/rate',
            type: 'post',
            data: {
                "station_id": $('#depo_station').val(),
                 "month": $('#date').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    // console.log(data)
                    Swal.fire(
                        'Oops..!',
                        'The depo station selected has no rate maintained',
                        'error'
                    )
                    return false
                } else {
                    rate = result.data[0];
                    var rate = rate.fuel_rate;
                    $('#depo_refueled').val(result.data[0].id);
                    $('#fuel_rate').val(rate);
                }

            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

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
                //  swal({
                //      title: "Oops...",
                //      text: "Something went wrong!",
                //      confirmButtonColor: "#EF5350",
                //      type: "error"
                //  });
            }
        });
    }

    if ($('#rejctd_commercial_clerk').length) {
        var type = $('#rejctd_commercial_clerk').attr('data_rejctd_commercial_clerk');
        $('#rejctd_commercial_clerk').val(type);
        $('#rejctd_commercial_clerk').trigger('change');
    }

    if ($('#comp_master_name').length) {
        var type = $('#comp_master_name').attr('data_yard_master_comp');
        $('#comp_master_name').val(type);
        $('#comp_master_name').trigger('change');
    }

    if ($('#rejctd_master_name').length) {
        var type = $('#rejctd_master_name').attr('data_yard_master_rejctd');
        $('#rejctd_master_name').val(type);
        $('#rejctd_master_name').trigger('change');
    }

    if ($('#rpt_yard_master_name').length) {
        var type = $('#rpt_yard_master_name').attr('data_yard_master_reprt');
        $('#rpt_yard_master_name').val(type);
        $('#rpt_yard_master_name').trigger('change');
    }

    if ($('#pend_yard_master').length) {
        var type = $('#pend_yard_master').attr('data_yard_master_pend');
        $('#pend_yard_master').val(type);
        $('#pend_yard_master').trigger('change');
    }

    if ($('#complete_driver_name').length) {
        var type = $('#complete_driver_name').attr('data_number_loco');
        $('#complete_driver_name').val(type);
        $('#complete_driver_name').trigger('change');
    }

    if ($('#rejt_loco_no').length) {
        var type = $('#rejt_loco_no').attr('data_rejctd_number_loco');
        $('#rejt_loco_no').val(type);
        $('#rejt_loco_no').trigger('change');
    }

    if ($('#ctrl_loco_no').length) {
        var type = $('#ctrl_loco_no').attr('data_ctrl_number_loco');
        $('#ctrl_loco_no').val(type);
        $('#ctrl_loco_no').trigger('change');
    }

    if ($('#ctc_shunt').length) {
        var type = $('#ctc_shunt').attr('data_ctc_shunt');
        $('#ctc_shunt').val(type);
        $('#ctc_shunt').trigger('change');
    }

    if ($('#bkoff_master_name').length) {
        var type = $('#bkoff_master_name').attr('data_yard_master_bkoff');
        $('#bkoff_master_name').val(type);
        $('#bkoff_master_name').trigger('change');
    }

    if ($('#pend_loco_no').length) {
        var type = $('#pend_loco_no').attr('data_loco_no_bkoff');
        $('#pend_loco_no').val(type);
        $('#pend_loco_no').trigger('change');
    }

    if ($('#commercial_clerk_bkoff').length) {
        var type = $('#commercial_clerk_bkoff').attr('data_commercial_clerk_bkoff');
        $('#commercial_clerk_bkoff').val(type);
        $('#commercial_clerk_bkoff').trigger('change');
    }

    if ($('#commercial_clerk_pending').length) {
        var type = $('#commercial_clerk_pending').attr('data_commercial_clerk_pding_fm');
        $('#commercial_clerk_pending').val(type);
        $('#commercial_clerk_pending').trigger('change');
    }

    if ($('#comp_loco_no').length) {
        var type = $('#comp_loco_no').attr('data_compl_number_loco');
        $('#comp_loco_no').val(type);
        $('#comp_loco_no').trigger('change');
    }

    if ($('#bkoff_driver_name').length) {
        var type = $('#bkoff_driver_name').attr('data_driver');
        $('#bkoff_driver_name').val(type);
        $('#bkoff_driver_name').trigger('change');
    }

    if ($('#pend_driver_name').length) {
        var type = $('#pend_driver_name').attr('data_pend_driver_name');
        $('#pend_driver_name').val(type);
        $('#pend_driver_name').trigger('change');
    }

    if ($('#train_origin').length) {
        var type = $('#train_origin').attr('data_loco_origin');
        $('#train_origin').val(type);
        $('#train_origin').trigger('change');
    }

    if ($('#bkoffce_loco_no').length) {
        var type = $('#bkoffce_loco_no').attr('data_bkoff_loco_no');
        $('#bkoffce_loco_no').val(type);
        $('#bkoffce_loco_no').trigger('change');
    }

    if ($('#loco_type').length) {
        var type = $('#loco_type').attr('data_loco_type');
        $('#loco_type').val(type);
        $('#loco_type').trigger('change');
    }

    if ($('#train_typpe').length) {
        var type = $('#train_typpe').attr('data_type_train');
        $('#train_typpe').val(type);
        $('#train_typpe').trigger('change');
    }

    if ($('#rejcted_train_typpe').length) {
        var type = $('#rejcted_train_typpe').attr('data_rejcted_type_train');
        $('#rejcted_train_typpe').val(type);
        $('#rejcted_train_typpe').trigger('change');
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

    if ($('#rejctd_depo_refueled').length) {
        var type = $('#rejctd_depo_refueled').attr('data_rejcted_depo_stn');
        $('#rejctd_depo_refueled').val(type);
        $('#rejctd_depo_refueled').trigger('change');
    }

    if ($('#depo_rept_refueled').length) {
        var type = $('#depo_rept_refueled').attr('data_depo_stn_rept');
        $('#depo_rept_refueled').val(type);
        $('#depo_rept_refueled').trigger('change');
    }

    if ($('#comp_depo_refueled').length) {
        var type = $('#depo_refueled').attr('data_depo_station');
        $('#depo_refueled').val(type);
        $('#depo_refueled').trigger('change');
    }

    if ($('#locomotive_type').length) {
        var type = $('#locomotive_type').attr('data_locomotive_type');
        $('#locomotive_type').val(type);
        $('#locomotive_type').trigger('change');
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

    if ($('#contr_loco_type').length) {
        var type = $('#contr_loco_type').attr('data_type_loco');
        $('#contr_loco_type').val(type);
        $('#contr_loco_type').trigger('change');
    }

    if ($('#contr_loco_type').length) {
        var type = $('#contr_loco_type').attr('data_type_loco');
        $('#contr_loco_type').val(type);
        $('#contr_loco_type').trigger('change');
    }

    if ($('#Section_type').length) {
        var type = $('#Section_type').attr('data_section_type');
        $('#Section_type').val(type);
        $('#Section_type').trigger('change');
    }

    if ($('#fuel_bkoffice_loco_id').length) {
        var type = $('#fuel_bkoffice_loco_id').attr('data_loco_type_bkoff');
        $('#fuel_bkoffice_loco_id').val(type);
        $('#fuel_bkoffice_loco_id').trigger('change');
    }

    if ($('#drivers_name').length) {
        var type = $('#drivers_name').attr('data_drivers_name');
        $('#drivers_name').val(type);
        $('#drivers_name').trigger('change');
    }
    
    if ($('#rejctd_drivers_name').length) {
        var type = $('#rejctd_drivers_name').attr('data_rejctd_drivers_name');
        $('#rejctd_drivers_name').val(type);
        $('#rejctd_drivers_name').trigger('change');
    }

    if ($('#loco_driver_name').length) {
        var type = $('#loco_driver_name').attr('data_driver_loco');
        $('#loco_driver_name').val(type);
        $('#loco_driver_name').trigger('change');
    }

    if ($('#type_section').length) {
        var type = $('#type_section').attr('data_type_section');
        $('#type_section').val(type);
        $('#type_section').trigger('change');
    }

    if ($('#typpe_section').length) {
        var type = $('#typpe_section').attr('data_typpe_section');
        $('#typpe_section').val(type);
        $('#typpe_section').trigger('change');
    }

    if ($('#clerks_name').length) {
        var type = $('#clerks_name').attr('data_clerk_name');
        $('#clerks_name').val(type);
        $('#clerks_name').trigger('change');
    }

    if ($('#locomo_driver').length) {
        var type = $('#locomo_driver').attr('data_driver_locomo');
        $('#locomo_driver').val(type);
        $('#locomo_driver').trigger('change');
    }

    if ($('#section_type').length) {
        var type = $('#section_type').attr('data_section_type');
        $('#section_type').val(type);
        $('#section_type').trigger('change');
    }

    if ($('#train_make').length) {
        var type = $('#train_make').attr('data_train_make');
        $('#train_make').val(type);
        $('#train_make').trigger('change');
    }

    if ($('#refuel_type').length) {
        var type = $('#refuel_type').attr('data_refuel_type');
        $('#refuel_type').val(type);
        $('#refuel_type').trigger('change');
    }

    if ($('#type_refuel').length) {
        var type = $('#type_refuel').attr('data_type_refuel');
        $('#type_refuel').val(type);
        $('#type_refuel').trigger('change');
    }

    if ($('#report_refuel_type').length) {
        var type = $('#report_refuel_type').attr('data_refuel_type_report');
        $('#report_refuel_type').val(type);
        $('#report_refuel_type').trigger('change');
    }

    if ($('#train_type_comp').length) {
        var type = $('#train_type_comp').attr('data_train_type_comp');
        $('#train_type_comp').val(type);
        $('#train_type_comp').trigger('change');
    }

    if ($('#train_type_bkoff').length) {
        var type = $('#train_type_bkoff').attr('data_train_type_bkoffice');
        $('#train_type_bkoff').val(type);
        $('#train_type_bkoff').trigger('change');
    }

    if ($('#bkoffice_refuel_type').length) {
        var type = $('#bkoffice_refuel_type').attr('data_refuel_type_bkoff');
        $('#bkoffice_refuel_type').val(type);
        $('#bkoffice_refuel_type').trigger('change');
    }

    if ($('#rejtd_refuel_type').length) {
        var type = $('#rejtd_refuel_type').attr('data_refuel_type_rejtd');
        $('#rejtd_refuel_type').val(type);
        $('#rejtd_refuel_type').trigger('change');
    }

    //////////////////////////////////////////////train type maintenance js /////////////////////////////////////////////////////////////////
    var dt_train_type = $('#dt_train_type').DataTable({
        responsive: true,
        'columnDefs': [{
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 2,
                "width": "14",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Train Types",
                filename: "Train Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Train Types",
                filename: "Train Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Train Types",
                filename: "Train Type List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#dt_train_type tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_train_code').val(button.attr("data-train-code"));
        $('#edit_train_description').val(button.attr("data-train-description"));
        $('#edit_model').val(button.attr("data-model"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_train_type tbody').on('click', '.view', function() {
        var button = $(this);

        $('#vw_train_code').val(button.attr("data-train-code"));
        $('#vw_train_description').val(button.attr("data-train-description"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        $('#view_modal').modal('show');
    });

    $('#dt_train_type tbody').on('click', '.change-status', function() {
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
                    url: '/change/train/type/status',
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

                            dt_train_type.cell($tr, 2).data(stat).draw();
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

    $('#dt_train_type tbody').on('click', '.delete', function() {
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
                    url: '/delete/train/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_train_type.row($tr).remove().draw(false);
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

    /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    ///////////////////////////////////////////disatnce maintenance js////////////////////////////////////////////////////////////////////////

    var dt_distance = $('#dt_distance').DataTable({
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
        "responsive": true,
        "processing": true,
        "bInfo": false,
        'language': {
            'loadingRecords': '&nbsp;',
                processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
                "sEmptyTable": "No Distance found !"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/view/distance',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "station_origin_name": $("#station_origin_name").val(),
                "station_destin_name": $("#station_destin_name").val()
            }
        },
        "columns": [
            { "data": "station_origin_name" },
            { "data": "station_destin_name" },
            { "data": "distance" },
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'A'){
                        return "<span class='m-badge m-badge--success m-badge--wide'>Active</span>"
                    } else {
                        return "<span class='m-badge m-badge--danger m-badge--wide'>Disabled</span>"
                    }
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>" 
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    var dist_station = row["station_destin_name"] ? row["station_destin_name"] : "";
                    var origin_statn = row["station_origin_name"] ? row["station_origin_name"] : "";
                    var status = row["status"]  == 'A' ? "Active" : "Disabled";
                    var vw_distance = row["distance"] ? row["distance"] : "";
                    var date_created = (new Date( row["inserted_at"]).toLocaleString())
                    var date_modified = (new Date( row["updated_at"]).toLocaleString())
                    var maker = row["maker_first_name"] ? row["maker_first_name"] + ' ' + row["maker_lastname"] : "";
                    var checker = row["checker_first_name"] ? row["checker_first_name"] + ' ' + row["checker_lastname"] : "";
                    var opt_1 = row["status"]  == 'A' ? "display: block;" : "display: none;";
                    var opt_2 = row["status"]  == 'D' ? "display: block;" : "display: none;";

                    return '<span class="dropdown">' +
                            '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                            '<i class="la la-ellipsis-h"></i>' +
                            '</a>'+
                            '<div class="dropdown-menu dropdown-menu-right">' +
                                    '<a class="dropdown-item view" href="#" data-origin-station="' + origin_statn + '" data-distation-station="'+ dist_station +'" data-distance="' + vw_distance + '" data-status="' + status + '" data-maker="' + maker + '" data-checker="' + checker + '" data-date-modified="' + date_modified + '" data-date-created="'+ date_created + '"><i class="la la-eye"></i> View</a>' +
                                    '<a class="dropdown-item edit" href="#" data-id= "' + row["id"] + '" data-kilometers="' + row["distance"] +'" data-start_statn="' + row["station_orig"] +'" data-end-station="' + row["destin"] + '"><i class="la la-edit"></i> Edit</a>' +
                                    '<a class="status dropdown-item  text-success change-status" href="#" data-id= "' + row["id"] + '" data-status="A" style="'+ opt_2 +'" ><i class="la la-check"></i>Activate</a>' +
                                    '<a class="status dropdown-item  text-warning change-status" href="#" data-id= "' + row["id"] + '" data-status="D" style="'+ opt_1 +'"><i class="la la-close"></i>Disable</a>' +
                                    '<a class="dropdown-item delete text-danger" href="#" data-id= "' + row["id"] + '" ><i class="flaticon-delete" aria-hidden="true"></i> Delete</a>' +
                            ' </div>' +
                        '</span>'
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

    $('#filter_distance').on('click', function() {
        $('#filter_distance_modal').modal('show');
    });

    $('#filter-distance').on('click', function() {
        dt_distance.on('preXhr.dt', function(e, settings, data) {
        data._csrf_token = $("#csrf").val(),
		data.station_origin_name = $("#station_origin_name").val(),
		data.station_destin_name = $("#station_destin_name").val();
        });
        $('#filter_distance_modal').modal('hide');
        dt_distance.draw();
    });

    $('#reset-distance-filter').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        dt_distance.draw();
    });

    $('#download-distance-excel').click(function() {
        $('#distance-report-form').attr('action', '/distance/excel');
        $('#distance-report-form').attr('method', 'GET');
        $("#distance-report-form").submit();
    })

    $('#dt_distance tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_station_orig').val(button.attr("data-start_statn"));
        $('#edit_destin').val(button.attr("data-end-station"));
        $('#edit_distance').val(button.attr("data-kilometers"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_distance tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_station_orig').val(button.attr("data-origin-station"));
        $('#vw_destin').val(button.attr("data-distation-station"));
        $('#vw_distance').val(button.attr("data-distance"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-date-created"));
        $('#modified').val(button.attr("data-date-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        $('#view_modal').modal('show');
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


    /////////////////////////////////////////////////////////////////refuel type///////////////////////////////////////////////////////////////////

    var dt_refuel_type = $('#dt_refuel_type').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 4,
                "width": "8",
                "className": "text-center"
            },
            {
                "targets": 3,
                "width": "16",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Refuel Types",
                filename: "Refuel Types",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Refuel Types",
                filename: "Refuel Types",
                exportOptions: {
                    columns: [  0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Refuel Types",
                filename: "Refuel Types",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            }
        ]
    });

    $('#dt_refuel_type tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#code_edit').val(button.attr("data-code"));
        $('#description_edit').val(button.attr("data-description"));
        $('#edit_category').val(button.attr("data-category"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');

    });

    $('#dt_refuel_type tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_category').val(button.attr("data-category"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
       
        $('#view_modal').modal('show');

    });
        
    $('#dt_refuel_type tbody').on('click', '.change-status', function() {
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
                    url: '/change/refuel/type/status',
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

                            dt_refuel_type.cell($tr, 3).data(stat).draw();
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

    $('#dt_refuel_type tbody').on('click', '.delete', function() {
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
                    url: '/refuel/type',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_refuel_type.row($tr).remove().draw(false);
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
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

    //////////////////////////section maintenance /////////////////////////////////////////
    var dt_section = $('#dt_sections').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Sections",
                filename: "Section List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Sections",
                filename: "Section List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Sections",
                filename: "Section List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#dt_sections tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#sect_edit_code').val(button.attr("data-code"));
        $('#sec_edit_description').val(button.attr("data-description"));
        $('#edit_category').val(button.attr("data-category"));
        $('#edit_id').val(button.attr("data-id"));

        $('#edit_modal').modal('show');
    });

    $('#dt_sections tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_category').val(button.attr("data-category"));
        $('#vw_status').val(button.attr("data-id"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        $('#view_modal').modal('show');
    });

 

    $('#dt_sections tbody').on('click', '.change-status', function() {
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
                    url: '/change/section/status',
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

                            dt_section.cell($tr, 2).data(stat).draw();
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

    $('#dt_sections tbody').on('click', '.delete', function() {
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
                    url: '/delete/section',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_refuel_type.row($tr).remove().draw(false);
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


    ////////////////////////////////////////////////////////////////////////////////////////


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
                        locomotive_id: $("#rejt_loco_no").val(),
                        train_number: $("#train_number").val(),
                        seal_number_at_arrival: $("#seal_number_at_arrival").val(),
                        seal_color_at_arrival: $("#seal_color_at_arrival").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        bp_meter_before: $("#bp_meter_before").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        section: $("#section").val(),
                        comment: $("#rejctd_comment").val(),
                        rejctd_drivers_name: $("#rejctd_drivers_name").val(),
                        train_type_id: $("#rejcted_train_typpe").val(),
                        commercial_clk_name: $("#rejctd_commercial_clerk").val(),
                        rejctd_depo_refueled: $("#rejctd_depo_refueled").val(),
                        depo_stn: $("#depo_station").val(),
                        train_destination_id: $("#train_origin").val(),
                        yard_master_id: $("#rejctd_master_name").val(),
                        oil_rep_name: $("#oil_rep_name").val(),
                        asset_protection_officers_name: $("#asset_protection_officers_name").val(),
                        other_refuel: $("#other_instrument").val(),
                        other_refuel_no: $("#instrument_number").val(),
                        refuel_type: $("#refuel_type").val(),
                        section_id: $("#Section_type").val(),
                        shunt: $("#resub_fuel_shunt").val(),
                        driver_name: $("#driver_name").val(),
                        commercial_clk_name: $("#commercial_clk_name").val(),
                        yard_master_name: $("#yard_master_name").val()


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

     ///////////////Submit modified fuel request entries////////////////////////////
     $('#submit-modified-requesite').click(function() {
        Swal.fire({
            title: 'Are you sure?',
            text: "You want to save the changes this order!",
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
                        status: "COMPLETE",
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
                        locomotive_id: $("#rejt_loco_no").val(),
                        train_number: $("#train_number").val(),
                        seal_number_at_arrival: $("#seal_number_at_arrival").val(),
                        seal_color_at_arrival: $("#seal_color_at_arrival").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        bp_meter_before: $("#bp_meter_before").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        section: $("#section").val(),
                        comment: $("#rejctd_comment").val(),
                        driver_name: $("#rejctd_drivers_name").val(),
                        train_type_id: $("#rejcted_train_typpe").val(),
                        commercial_clerk_id: $("#rejctd_commercial_clerk").val(),
                        rejctd_depo_refueled: $("#rejctd_depo_refueled").val(),
                        depo_stn: $("#depo_station").val(),
                        train_destination_id: $("#train_origin").val(),
                        yard_master_id: $("#rejctd_master_name").val(),
                        oil_rep_name: $("#oil_rep_name").val(),
                        asset_protection_officers_name: $("#asset_protection_officers_name").val(),
                        other_refuel: $("#other_instrument").val(),
                        other_refuel_no: $("#instrument_number").val(),
                        refuel_type: $("#refuel_type").val(),
                        section_id: $("#Section_type").val(),
                        shunt: $("#resub_fuel_shunt").val()


                    },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'requisite updated successfully!',
                                'success'
                            )
                            window.location.replace("/fuel/back/office/approval");

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
        'columnDefs': [{
            "targets": 4,
            "width": "5",
            "className": "text-center"
        }, ],
        columns: [
            { data: "equipment" },
            { data: "code" },
            { data: "count" },
            { data: "amount" },
            { data: "action", "defaultContent": "<a href='#' class='view-spare m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'><i class='la la-eye'></i></a>" }
        ]
    });

    //approve js for fuel requisite

    $('#approve-fuel-requisite').click(function() {
        var a = dt_fuel_monitoring.rows().data()
        var button = $(this);
        var details = {};

        var data_row = [];
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

    $('#ctc_input_form_modal').click(function() {
        $('#ctc_display_input_modal').modal('show');
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
                    approved_refuel: $("#approved_refuel").val(),
                    fuel_blc_figures: $("#fuel_blc_figures").val(),
                    ctc_datestamp: $("#ctc_datestamp").val(),
                    ctc_time: $("#ctc_time").val(),
                    fuel_blc_words: $("#fuel_blc_words").val(),
                    comment: $("#comment").val(),
                    litres_in_words: $("#litres_in_words").val() 
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

    // //submit for control form for fuel requisite
    // $('#control-submit-form').click(function() {
    //     var details = {};
    //     $.each($('.data_entry').serializeArray(), function(i, field) {
    //         details[field.name] = field.value;
    //     });
    //     Swal.fire({
    //         title: 'Are you sure?',
    //         text: "You want to submit this order!",
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
    //                 url: '/update/fuel/requisite',
    //                 type: 'post',
    //                 data: { _csrf_token: $("#csrf").val(), entries: details, 
    //                     requisition_no: $("#requisition_no").val(),
    //                     status: "PENDING_COMPLETION",
    //                     current_status: $("#current_status").val()
    //                     // fuel_blc_figures: $("#fuel_blc_figures").val(),
    //                     // ctc_datestamp: $("#ctc_datestamp").val(),
    //                     // ctc_time: $("#ctc_time").val(),
    //                     // fuel_blc_words: $("#fuel_blc_words").val(),
    //                     // comment: $("#comment").val()
    //                 },
    //                 success: function(result) {
    //                     spinner.hide();
    //                     $('#reject_requisite_model').modal('hide');
    //                     if (result.info) {
    //                         Swal.fire(
    //                             'Success',
    //                             'Fuel request submited for Completion!',
    //                             'success'
    //                         )
    //                         window.location.replace("/fuel/control/view");

    //                         $('.field-clr').val([]);
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
                        quantity_refueled: $("#summary_quantity_refueled").val(),
                        meter_at_destin: $("#meter_at_destin").val(),
                        reading: $("#reading").val(),
                        fuel_consumed: $("#fuel_consumed").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        km_to_destin: $("#km_to_destin").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        deff_ctc_actual: $("#deff_ctc_actual").val(),
                        consumption_per_km: $("#consumption_per_km").val(),
                        total_cost: $("#total_cost").val(),
                        refuel_type: $("#type_refuel").val(),
                        Section_id: $("#Section_type").val(),


                    },
                    success: function(result) {
                        //   spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Fuel request submited for approval!',
                                'success'
                            )
                            window.location.replace("/view/pending/completion/fuel/entries");

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

    $('#direction').on('change', function() {
        $('#entry_date').val('');
        $('#exit_date').val('');
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
        "select": {
            "style": 'multi'
        },
       'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> ',
            "sEmptyTable": "No interchange found !"
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/report/hired/wagons/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "interchange_on_hire_date_to": $('#interchange_on_hire_date_to').val(),
                "interchange_on_hire_date_from": $('#interchange_on_hire_date_from').val(),
                "interchange_administrator": $('#interchange_administrator').val(),
                "interchange_wagon_no": $('#interchange_wagon_no').val(),
                "interchange_commdity": $('#interchange_commdity').val(),
                "interchange_point": $('#interchange_point').val(),
                "interchange_direction": $('#interchange_direction').val(),
                "interchange_origin": $('#interchange_origin').val(),
                "interchange_destin": $('#interchange_destin').val(),
                "interchange_train_no": $('#interchange_train_no').val(),
                "interchange_status": $('#interchange_status').val(),
                "interchange_update_dt_from": $('#interchange_update_dt_from').val(),
                "interchange_update_dt_to": $('#interchange_update_dt_to').val(),
                "interchange_region": $('#interchange_region').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "wagon_code"},
            { "data": "wagon_owner"},
            { "data": "origin"},
            { "data": "destination"},
            { "data": "commodity"},
            { "data": "train_no"},
            { "data": "interchange_pt"},
            { "data": "administrator"},
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-admin-id = "' + row["admin_id"] + '"  data-id = "' + data + '"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'
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
     
    $('#interchange-incoming-on-hire-report-filter').on('click', function() {
        dt_interchange_no_hire.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.interchange_direction = $('#interchange_direction').val();
            data.interchange_exit_date_from = $('#interchange_exit_date_from').val();
            data.interchange_exit_date_to = $('#interchange_exit_date_to').val();
            data.interchange_entry_date_from = $('#interchange_entry_date_from').val();
            data.interchange_entry_date_to = $('#interchange_entry_date_to').val();
            data.interchange_on_hire_date_from = $('#interchange_on_hire_date_from').val();
            data.interchange_on_hire_date_to = $('#interchange_on_hire_date_to').val();
            data.interchange_train_no = $('#interchange_train_no').val();
            data.interchange_status = $('#interchange_status').val();
            data.interchange_wagon_no =  $('#interchange_wagon_no').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.interchange_administrator = $('#interchange_administrator').val();
            data.interchange_origin = $('#interchange_origin').val();
            data.interchange_destin =  $('#interchange_destin').val();
            data.interchange_commdity = $('#interchange_commdity').val();
            data.interchange_point = $('#interchange_point').val();
            data.interchange_update_dt_from = $('#interchange_update_dt_from').val(),
            data.interchange_update_dt_to = $('#interchange_update_dt_to').val(),
            data.interchange_region = $('#interchange_region').val()
        });
        // $('#interchange_batch_report_filter_model').modal('hide');
        dt_interchange_no_hire.draw();
    });

    $('#interchange-incoming-on-hire-reset_filter').on('click', function() {
        $('#interchange_administrator').val(null).trigger("change")
        $('#interchange_point').val(null).trigger("change")
        $('#interchange_origin').val(null).trigger("change")
        $('#interchange_destin').val(null).trigger("change")
        $('#interchange_commdity').val(null).trigger("change")
        $('#interchange_direction').val(null).trigger("change")
        $('.clear_form').val('');
        dt_interchange_no_hire.draw();
    });


    $('#intechange-hire-select-all').on( 'click', function () {
		dt_interchange_no_hire.rows().select();
        dt_interchange_no_hire.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#intechange-hire-unselect-all').on( 'click', function () {
        dt_interchange_no_hire.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		dt_interchange_no_hire.rows().deselect();
    });

    $('#dt-interchange-on-hire tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                var wagon = result.wagon
                $('#vw-comment').val(wagon.comment);
                $('#vw-wagon').val(wagon.wagon_code);
                $('#vw-wagon-owner').val(wagon.wagon_owner);
                $('#vw-accumulative-days').val(wagon.accumulative_days);
                $('#vw-accumulative-amount').val(wagon.accumulative_amount);
                $('#vw-on-hire-date').val(wagon.on_hire_date);
                $('#vw-off-hire-date').val(wagon.off_hire_date);
                $('#vw-origin').val(wagon.origin);
                $('#vw-destination').val(wagon.destination);
                $('#vw-train-number').val(wagon.train_no);
                $('#vw-commodity').val(wagon.commodity);
                $('#vw-total-accum-days').val(wagon.total_accum_days);
                $('#vw-wagon-status').val(wagon.wagon_status);
                $('#vw-region').val(wagon.region);
                $('#vw-current-station').val(wagon.current_station);
                $('#vw-wagon-condition').val(wagon.wagon_condition);
                
                if (result.data.length < 1) {

                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view-hired-wagon-model').modal('show');

                } else {
                    
                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();

                    $('#view-hired-wagon-model').modal('show');

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

    $('#set-interchange-batch-off-hire-model').click(function() {

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
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

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var data_row = [];
        for (let index = 0; index < dt_interchange_no_hire.rows().count(); index++) {
            data_row.push(Object.assign(dt_interchange_no_hire.rows().data()[index], {}));
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
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        lease_period: $("#lease_period").val(),
                        off_hire_date: $("#off_hire_date").val(),
                        on_hire_date: ""
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

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var data_row = [];
        for (let index = 0; index < dt_interchange_no_hire.rows().count(); index++) {
            data_row.push(Object.assign(dt_interchange_no_hire.rows().data()[index], {}));
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
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        lease_period: $("#lease_period").val(),
                        off_hire_date: $("#off_hire_date").val(),
                        on_hire_date: ""
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

    var dt_interchange_view_defect = $('#dt-interchange-view-defect').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        'columnDefs': [{
            "targets": 4,
            "width": "5",
            "className": "text-center"
        }, ],
        columns: [
            { data: "equipment" },
            { data: "code" },
            { data: "count" },
            { data: "amount" },
            { data: "action", "defaultContent": "<a href='#' class='view-spare m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'><i class='la la-eye'></i></a>" }
        ]
    });

    $('#select_defect').on('change', function() {
        if(spare_loading) {
            return false;
        }
        spare_loading = true;
       
        var defect = {
            "equipment": $(this).find(':selected').attr('data-description'),
            "code": $(this).find(':selected').attr('data-code'),
            "admin_id": $("#new-admin-id").val(),
            "defect_id": $(this).find(':selected').attr('data-id'),
            "interchange_id": $("#entry_id").val()
        }

        spinner.show();
        $.ajax({
            url: '/admin/defect/spare/rates/lookup',
            type: 'POST',
            data: {
                date: $("#new-on-hire-dt").val(),
                admin_id: $("#new-admin-id").val(),
                defect_id:  $(this).find(':selected').attr('data-id'),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                
               if(result.data.length > 0){
                  
                    var data_row = [];
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    
                    dt_interchange_defect_approval.rows.add(data_row).draw(false);
               }else{

                swal({
                    title: "Oops...",
                    text: "Spare rate not maintained for defect!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });

               }
                
                spare_loading = false;
            },

            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                spare_loading = false;
            }
        });
    });

    $('#dt-interchange-on-hire tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                if (result.data.length < 1) {
            
                    var comment = button.attr("data-comment");
                    if (comment == "null" || comment== "undefined") {
                        comment = ""
                       }
                    else{
                        comment = comment
                    }

                    $('.wagon-field-clr').val('');
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(comment);
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#admin').val(button.attr("data-admin"));
                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#view_interchange_model').modal('show');

                } else {

                    var comment = button.attr("data-comment");
                    if (comment == "null" || comment== "undefined") {
                        comment = ""
                       }
                    else{
                        comment = comment
                    }
                    $('.wagon-field-clr').val('');
                    $('#wagon_status').val(button.attr("data-wagon_status"));
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#commodity').val(button.attr("data-commodity"));
                    $('#comment').val(comment);
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#wagon_type').val(button.attr("data-wagon_type"));
                    $('#admin').val(button.attr("data-admin"));
                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();
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

    $('#dt-interchange-view-defect tbody').on('click', '.view-spare', function() {
        var $tr = $(this).closest('tr');
        var defect = dt_interchange_view_defect.row($tr).data();

        $.ajax({
            url: '/interchange/onhire/spare/lookup',
            type: 'POST',
            data: {
                admin_id: defect.admin_id,
                id: defect.interchange_id,
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                total = 0.0;
                data = result.data
                for (let index = 0; index < (data.length); index++) {
                    total = total + parseFloat(data[index].amount)
                    data[index].amount = data[index].currency.concat(data[index].amount)
                }
                 $("#defect_spare_total").val(total)
                 dt_interchange_defect_spares.clear().rows.add(data).draw();
                $('#view_defect_spares_model').modal('show');  
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
        var admin =  button.attr("data-admin-id")
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(),  admin: admin },
            success: function(result) {
                spinner.hide();
                var wagon = result.wagon;
                $('.clear').val('');
                // $('#new-comment').val(wagon.comment);
                $('#new-wagon').val(wagon.wagon_code);
                $('#new-wagon-owner').val(wagon.wagon_owner);
                $('#vw-on-hire-date').val(wagon.on_hire_date);
                $('#new-entry-id').val(wagon.id);
                $('#new-admin-id').val(admin);
                $('#new-on-hire-dt').val(wagon.on_hire_date);
                $('#new-wagon-condition').val(wagon.wagon_condition_id);
           
                if (result.data.length < 1) {

                    dt_interchange_defect_approval.clear().rows.add([]).draw();
                    $('#single_off_hire_model').modal('show');

                } else {

                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_defect_approval.clear().rows.add(data_row).draw();
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

    $('#intechange-set-off-hire').click(function() {
        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }
        $("#off_hire_dt").val('');
        $("#bulk_comment").val('');
        $('#set-off-hire-model').modal('show');
    });

    $('#set-to-off-hire').click(function() {

        if (($('#off_hire_dt').val() == "")) {
            swal({
                title: "Opps",
                text: "All fields Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        dt_interchange_no_hire.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );
      
        off_hire_date = $("#interchange_status").val() == 'ON_HIRE' ? $("#off_hire_dt").val() : "";
        on_hire_date = $("#interchange_status").val() == 'ON_HIRE' ?  "" : $("#off_hire_dt").val();

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
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        status: "OFF_HIRE",
                        on_hire_date: on_hire_date,
                        off_hire_date: off_hire_date,
                        comment: $("#bulk_comment").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#set-off-hire-model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            dt_interchange_no_hire.draw();
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

    
    $('#set-to-on-hire').click(function() {

        if (($('#off_hire_dt').val() == "")) {
            swal({
                title: "Opps",
                text: "All fields Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        dt_interchange_no_hire.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );

        off_hire_date = $("#interchange_status").val() == 'ON_HIRE' ? $("#off_hire_dt").val() : "";
        on_hire_date = $("#interchange_status").val() == 'ON_HIRE' ?  "" : $("#off_hire_dt").val();

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
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        status: "ON_HIRE",
                        on_hire_date: on_hire_date,
                        off_hire_date: off_hire_date,
                        comment: $("#bulk_comment").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#set-off-hire-model').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            dt_interchange_no_hire.draw();
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

    $('#set_single_entry_to_off_hire').click(function() {

        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        for (let index = 0; index < dt_interchange_defect_approval.rows().count(); index++) {
            data_row.push(Object.assign(dt_interchange_defect_approval.rows().data()[index], {}));
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

        off_hire_date = $("#interchange_status").val() == 'ON_HIRE' ? $("#single_off_hire_date").val() : "";
        on_hire_date = $("#interchange_status").val() == 'ON_HIRE' ?  "" : $("#single_off_hire_date").val();

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
                        id: $("#new-entry-id").val(),
                        _csrf_token: $("#csrf").val(),
                        // lease_period: $("#single_lease_period").val(),
                        off_hire_date: off_hire_date,
                        on_hire_date: on_hire_date,
                        comment: $('#new-comment').val(),
                        status: $('#new-hire-status').val(), 
                        new_defects: data_row
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            $('#single_off_hire_model').modal('hide');
                            dt_interchange_no_hire.draw();
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

    $('#set_single_entry_to_on_hire').click(function() {

        if (dt_interchange_no_hire.rows().count() <= 0) {
            Swal.fire(
                'Oops..!',
                'No Interchange found!',
                'error'
            )
            return false;
        }
        var data_row = [];
        for (let index = 0; index < dt_interchange_defect_approval.rows().count(); index++) {
            data_row.push(Object.assign(dt_interchange_defect_approval.rows().data()[index], {}));
        }

        if (($('#single_lease_period').val() == "") ||
           ($('#single_off_hire_date').val() == "") ||
           ($('#new-wagon-condition').val() == "")
           ) {
            swal({
                title: "Opps",
                text: "All fields can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        off_hire_date = $("#interchange_status").val() == 'ON_HIRE' ? $("#single_off_hire_date").val() : "";
        on_hire_date = $("#interchange_status").val() == 'ON_HIRE' ?  "" : $("#single_off_hire_date").val();
     
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
                        id: $("#new-entry-id").val(),
                        _csrf_token: $("#csrf").val(),
                        off_hire_date: off_hire_date,
                        on_hire_date: on_hire_date,
                        comment: $('#new-comment').val(),
                        status: $('#new-hire-status').val(), 
                        wagon_condition_id: $('#new-wagon-condition').val(), 
                        new_defects: data_row
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            $('#single_off_hire_model').modal('hide');
                            dt_interchange_no_hire.draw();
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
                "interchange_direction": $('#interchange_direction').val(),
                "interchange_exit_date_from": $('#interchange_exit_date_from').val(),
                "interchange_exit_date_to": $('#interchange_exit_date_to').val(),
                "interchange_on_hire_date_to": $('#interchange_on_hire_date_to').val(),
                "interchange_on_hire_date_from": $('#interchange_on_hire_date_from').val(),
                "interchange_administrator": $('#interchange_administrator').val(),
                "interchange_interchange_point": $('#interchange_interchange_point').val(),
                "interchange_entry_date_from": $('#interchange_entry_date_from').val(),
                "interchange_entry_date_to": $('#interchange_entry_date_to').val(),
                "interchange_train_no": $('#interchange_train_no').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "wagon_code"},
            { "data": "wagon_owner"},
            { "data": "origin"},
            { "data": "destination"},
            { "data": "commodity"},
            { "data": "train_no"},
            { "data": "interchange_pt"},
            { "data": "administrator"},
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'ON_HIRE'){
						return "<span class='text-warning'>On Hire</span>"
					} else if (data == 'OFF_HIRE') {
						return "<span class='text-success'>Off HIRE</span>"
					} else {
                        return "<span>"+data+"</span>"
                    }
				},
				"defaultContent": "<span class='text-danger'>No Actions</span>"
            },
            {   
                "data": "status",
                "render": function(data, type, row) {
                hire_date = data == 'ON_HIRE' ? row["on_hire_date"]   :  row["off_hire_date"];
                    return hire_date;
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "className": "text-center"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-admin-id = "' + row["adminstrator_id"] + '"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>' +
                       '<a href= "/modify/wagon/' + data + '/hire" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"><i class= "la la-edit"></i></a>';
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

        // if ($('#interchange_direction').val() == "incoimng") {
        //     $("#interchange_exit_date").prop('disabled', false);
        //     $("#interchange_entry_date").prop('disabled', true);

        // } else {
        //     $("#interchange_entry_date").prop('disabled', false);
        //     $("#interchange_exit_date").prop('disabled', true);

        // }

        $('#interchange_batch_report_filter_model').modal('show');
    });

    $('#interchange_batch_report_filter').on('click', function() {
        dt_interchange_report_batch.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.interchange_direction = $('#interchange_direction').val();
            data.interchange_exit_date_from = $('#interchange_exit_date_from').val();
            data.interchange_exit_date_to = $('#interchange_exit_date_to').val();
            data.interchange_entry_date_from = $('#interchange_entry_date_from').val();
            data.interchange_entry_date_to = $('#interchange_entry_date_to').val();
            data.interchange_on_hire_date_from = $('#interchange_on_hire_date_from').val();
            data.interchange_on_hire_date_to = $('#interchange_on_hire_date_to').val();
            data.interchange_train_no = $('#interchange_train_no').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.interchange_administrator = $('#interchange_administrator').val();
            data.interchange_interchange_point = $('#interchange_interchange_point').val();
        });
        $('#interchange_batch_report_filter_model').modal('hide');
        dt_interchange_report_batch.draw();
    });

    $('#interchange_report_reset_filter').on('click', function() {
        $('#interchange_administrator').val(null).trigger("change")
        $('#interchange_interchange_point').val(null).trigger("change")
        $('.clear_form').val('');
        dt_interchange_report_batch.draw();
    });

    $('#dt_interchange_report_batch tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                spinner.hide();
                $('.wagon-field-clr').val('');
                var wagon = result.wagon
                $('#comment').val(wagon.comment);
                $('#wagon').val(wagon.wagon_code);
                $('#wagon_owner').val(wagon.wagon_owner);
                $('#accumulative_days').val(wagon.accumulative_days);
                $('#origin').val(wagon.origin);
                $('#destination').val(wagon.destination);
                $('#on-hire-date').val(wagon.on_hire_date);
                $('#off_hire_date').val(wagon.off_hire_date);
                $('#train-number').val(wagon.train_no);
                $('#off-hire-date').val(wagon.off_hire_date);
                $('#commodity').val(wagon.commodity);
                $('#vw-total-accum-days').val(wagon.total_accum_days);
                if (result.data.length < 1) {
                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view_interchange_report_model').modal('show');

                } else {
    
                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();

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

    $('#close-interchange').click(function() {

        row = dt_interchange_no_hire.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        dt_interchange_no_hire.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );

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
                    url: '/close/interchange',
                    type: 'post',
                    data: { _csrf_token: $("#csrf").val(), entries: data_row },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Interchange Closed successfully!',
                                'success'
                            )
                            dt_interchange_no_hire.draw();
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
            { "data": "wagon_code" },
            { "data": "wagon_type" },
            { "data": "wagon_owner" },
            { "data": "origin_name" },
            { "data": "destination_name" },
            { "data": "commodity_name" },
            { "data": "comment" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-admin-id = "' + row["admin_id"] + '"  data-id = "' + data + '" data-lease_period = "' + row["lease_period"] + '" data-off_hire_date = "' + row["off_hire_date"] + '" data-accumulative_amount = "' + row["accumulative_amount"] + '" data-accumulative_days = "' + row["accumulative_days"] + '" data-wagon = "' + row["wagon_code"] + '"  data-wagon_owner = "' + row["wagon_owner"] + '"  data-comment = "' + row["comment"] + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View "> <i class= "la la-eye "></i></a>'

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
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    var comment = button.attr("data-comment");
                    if (comment == "null" || comment== "undefined") {
                        comment = ""
                       }
                    else{
                        comment = comment
                    }
                    $('.wagon-field-clr').val('');
                    $('#comment').val(comment);
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#accumulative_amount').val(button.attr("data-accumulative_amount"));
                    $('#off_hire_date').val(button.attr("data-off_hire_date"));
                    $('#lease_period').val(button.attr("data-lease_period"));
                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view_interchange_report_model').modal('show');

                } else {
                    var comment = button.attr("data-comment");
                    if (comment == "null" || comment== "undefined") {
                        comment = ""
                       }
                    else{
                        comment = comment
                    }
                    $('.wagon-field-clr').val('');
                    $('#comment').val(comment);
                    $('#wagon').val(button.attr("data-wagon"));
                    $('#wagon_owner').val(button.attr("data-wagon_owner"));
                    $('#accumulative_days').val(button.attr("data-accumulative_days"));
                    $('#accumulative_amount').val(button.attr("data-accumulative_amount"));
                    $('#off_hire_date').val(button.attr("data-off_hire_date"));
                    $('#lease_period').val(button.attr("data-lease_period"));
                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();

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

    $('#dt-interchange-defect-approval tbody').on('click', '.view-spare', function() {
        var $tr = $(this).closest('tr');
        var defect = dt_interchange_defect_approval.row($tr).data();

        $.ajax({
            url: '/interchange/onhire/spare/lookup',
            type: 'POST',
            data: {
                admin_id: defect.admin_id,
                id: defect.interchange_id,
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                total = 0.0;
                data = result.data
                for (let index = 0; index < (data.length); index++) {
                    total = total + parseFloat(data[index].amount)
                    data[index].amount = data[index].currency.concat(data[index].amount)
                }
                 $("#defect_spare_total").val(total)
                 dt_interchange_defect_spares.clear().rows.add(data).draw();
                $('#view_defect_spares_model').modal('show');  
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

    $('#download_interchange_report_excel').click(function() {
        $('#interchange_batch_report_form').attr('action', '/download/interchange/onhire/report/excel');
        $('#interchange_batch_report_form').attr('method', 'GET');
        $("#interchange_batch_report_form").submit();
    })

    var interchange_list_report_dt = $('#interchange-list-report-dt').DataTable({
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
            "url": '/interchange/report/incoming/outgoing/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "interchange_on_hire_date_to": $('#interchange_on_hire_date_to').val(),
                "interchange_on_hire_date_from": $('#interchange_on_hire_date_from').val(),
                "interchange_administrator": $('#interchange_administrator').val(),
                "interchange_wagon_no": $('#interchange_wagon_no').val(),
                "interchange_commdity": $('#interchange_commdity').val(),
                "interchange_point": $('#interchange_point').val(),
                "interchange_direction": $('#interchange_direction').val(),
                "interchange_origin": $('#interchange_origin').val(),
                "interchange_destin": $('#interchange_destin').val(),
                "interchange_update_dt_from": $('#interchange_update_dt_from').val(),
                "interchange_update_dt_to": $('#interchange_update_dt_to').val(),
                "interchange_region": $('#interchange_region').val(),
                "interchange_train_no": $('#interchange_train_no').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "wagon_code"},
            { "data": "wagon_owner"},
            { "data": "origin"},
            { "data": "destination"},
            { "data": "commodity"},
            { "data": "train_no"},
            { "data": "interchange_pt"},
            { "data": "update_date"},
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'ON_HIRE'){
						return "<span class='text-warning'>On Hire</span>"
					} else if (data == 'OFF_HIRE') {
						return "<span class='text-success'>Off HIRE</span>"
					} else {
                        return "<span>"+data+"</span>"
                    }
				},
				"defaultContent": "<span class='text-danger'>No Actions</span>"
            },
            {   
                "data": "status",
                "render": function(data, type, row) {
                hire_date = data == 'ON_HIRE' ? row["on_hire_date"]   :  row["off_hire_date"];
                    return hire_date;
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "className": "text-center"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-admin-id = "' + row["admin_id"] + '"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View"> <i class= "la la-eye "></i></a>' +
                        '<a href= "/modify/wagon/' + data + '/hire"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"><i class= "la la-edit"></i></a>';
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

    $('#interchange_list_report_filter').on('click', function() {
        interchange_list_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.interchange_direction = $('#interchange_direction').val();
            data.interchange_exit_date_from = $('#interchange_exit_date_from').val();
            data.interchange_exit_date_to = $('#interchange_exit_date_to').val();
            data.interchange_entry_date_from = $('#interchange_entry_date_from').val();
            data.interchange_entry_date_to = $('#interchange_entry_date_to').val();
            data.interchange_on_hire_date_from = $('#interchange_on_hire_date_from').val();
            data.interchange_on_hire_date_to = $('#interchange_on_hire_date_to').val();
            data.interchange_train_no = $('#interchange_train_no').val();
            data.interchange_wagon_no =  $('#interchange_wagon_no').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.interchange_administrator = $('#interchange_administrator').val();
            data.interchange_origin = $('#interchange_origin').val();
            data.interchange_destin =  $('#interchange_destin').val();
            data.interchange_commdity = $('#interchange_commdity').val();
            data.interchange_point = $('#interchange_point').val();
            data.interchange_update_dt_from = $('#interchange_update_dt_from').val(),
            data.interchange_update_dt_to = $('#interchange_update_dt_to').val(),
            data.interchange_region = $('#interchange_region').val()
        });
        $('#interchange_batch_report_filter_model').modal('hide');
        interchange_list_report_dt.draw();
    });

    $('#interchange_list_report_reset_filter').on('click', function() {
        $('#interchange_administrator').val(null).trigger("change")
        $('#interchange_point').val(null).trigger("change")
        $('#interchange_origin').val(null).trigger("change")
        $('#interchange_destin').val(null).trigger("change")
        $('#interchange_commdity').val(null).trigger("change")
        $('#interchange_direction').val(null).trigger("change")
        $('.clear_form').val('');
        interchange_list_report_dt.draw();
    });

    $('#interchange-list-report-dt tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        var $tr = $(this).closest('tr');
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                spinner.hide();
                $('.wagon-field-clr').val('');
                var wagon = result.wagon
                $('#comment').val(wagon.comment);
                $('#wagon').val(wagon.wagon_code);
                $('#wagon_owner').val(wagon.wagon_owner);
                $('#accumulative_days').val(wagon.accumulative_days);
                $('#origin').val(wagon.origin);
                $('#destination').val(wagon.destination);
                $('#on-hire-date').val(wagon.on_hire_date);
                $('#off_hire_date').val(wagon.off_hire_date);
                $('#train-number').val(wagon.train_no);
                $('#off-hire-date').val(wagon.off_hire_date);
                $('#commodity').val(wagon.commodity);
                $('#vw-total-accum-days').val(wagon.total_accum_days);
                if (result.data.length < 1) {
                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view_interchange_report_model').modal('show');

                } else {
    
                    var data_row = [];

                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {

                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();

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

/// consignment\\\\\\\\\\\\\\\\\\\\\\\\

    $('#dt-consignment-pending-aproval').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 8,
                "width": "8",
                "className": "text-center"
            }
        ],
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
            { "data": "station_code" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "batch_id",
                "render": function(data, type, row) {
                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                    '<a class="dropdown-item view_interchange_entry"href="/consignment/sales/order/report/entries?batch=' + data + '" ><i class="la la-eye"></i> View</a>' +
                                    '<a class="dropdown-item edit"href="/edit/consignment/batch/order?batch_id='+ row["uuid"] +'" ><i class="la la-edit"></i> Edit</a>' +
                                ' </div>' +
                            '</span>'

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
            [0, 'desc']
        ]
    });

    // dt_consignment_report_batch_entries.order( [ 0, 'asc' ] ).draw();

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

    $('#consignment_reset_report_filter').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        dt_consignment_report_batch_entries.draw();
    });

    $('#download_consignment_report_excel').click(function() {
        $('#consignment_batch_report_form').attr('action', '/download/consignment/batch/report/excel');
        $('#consignment_batch_report_form').attr('method', 'GET');
        $("#consignment_batch_report_form").submit();
    })

    $('#download_consignment_invoice_report_excel').click(function() {
        $('#ConsignReportSearchForm').attr('action', '/download/consignment/batch/report/excel');
        $('#ConsignReportSearchForm').attr('method', 'GET');
        $("#ConsignReportSearchForm").submit();
    })

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
            { "data": "station_code" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "uuid",
                "render": function(data, type, row) {

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                    '<a class="dropdown-item" href="/consignment/approval/entries?batch_id=' + data + '" ><i class="la la-eye"></i> View</a>' +
                                    '<a class="dropdown-item edit" href="/edit/consignment/batch/order?batch_id=' + data + '" ><i class="la la-edit"></i> Edit</a>' +
                                ' </div>' +
                            '</span>'

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
            { "data": "station_code" },
            { "data": "capture_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "tariff_origin" },
            {
                "data": "uuid",
                "render": function(data, type, row) {

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                    '<a class="dropdown-item view_interchange_entry" href="/consignment/invoice/list/entries?batch_id=' + data + '" ><i class="la la-eye"></i> View</a>' +
                                    '<a class="dropdown-item edit"href="/edit/consignment/batch/order?batch_id=' + data + '" ><i class="la la-edit"></i> Edit</a>' +
                                ' </div>' +
                            '</span>'

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
                $(window).scrollTop(0);
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
                "train_list_no": $("#train_list_no").val(),
                "movement_date": $("#movement_date").val(),
                "movement_time": $("#movement_time").val(),
                "train_no": $("#train_no").val(),
                "origin": $("#origin").val(),
                "destination": $("#destination").val(),
                "to": $("#to").val(),
                "from": $("#from").val(),
                "movement_from":  $("#movement_from").val(),
                "movement_to":  $("#movement_to").val(),
                "consignee": $("#mvt_consignee").val(),
                "customer": $("#mvt_customer").val(),
                "commodity": $("#mvt_commodity").val(),
                "movement_wagon_code": $("#movement_wagon_code").val(),

                   
            }  
        },

        "columns": [
            { "data": "train_list_no" },
            { "data": "train_no" },
            { "data": "movement_time" },
            { "data": "movement_date" },
            { "data": "origin_name" },
            { "data": "destination_name" },
            { "data": "reporting_stat" },
            {
                "data": "batch_id",
                "render": function(data, type, row) {

                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                        '<a class="dropdown-item view_interchange_entry" href="/movement/order/report/batch/entries?batch=' + data + '" ><i class="la la-eye"></i> View</a>' +
                                        '<a class="dropdown-item edit"href="/modify/movement/batch/entries?batch_id=' + data + '" ><i class="la la-edit"></i> Edit</a>' +
                                ' </div>' +
                            '</span>'

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

    $('#movement_report_table_filter').on('click', function() {
        dt_movement_report_batch_entries.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.train_list_no = $("#train_list_no").val();
            data.movement_date = $("#movement_date").val();
            data.movement_time = $("#movement_time").val();
            data.train_no = $('#train_no').val();
            data.origin = $('#origin').val();
            data.destination = $('#destination').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.movement_from = $("#movement_from").val(),
            data.movement_to = $("#movement_to").val(),
            data.movement_wagon_code = $("#movement_wagon_code").val(),
            data.consignee = $("#mvt_consignee").val(),
            data.customer = $("#mvt_customer").val(),
            data.commodity = $("#mvt_commodity").val()
        });
        dt_movement_report_batch_entries.draw();
    });

    $('#movement_report_reset_filter').on('click', function() {
        $('#destination').val(null).trigger("change")
        $('#origin').val(null).trigger("change")
        $('.clear_form').val('');

        dt_movement_report_batch_entries.draw();
    });

    //excel
    $('#download_movement_report_excel').click(function() {
        $('#movenment_batch_report_form').attr('action', '/download/movement/batch/report/excel');
        $('#movenment_batch_report_form').attr('method', 'GET');
        $("#movenment_batch_report_form").submit();
    })


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
        var button = $(this);
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

    if ($('#log_admin_id').length) {
        var type = $('#log_admin_id').attr('data-log_admin_id');
        $('#log_admin_id').val(type);
        $('#log_admin_id').trigger('change');
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });

    $('#dt_email_alerts tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#type').val(button.attr("data-type"));
        $('#email ').val(button.attr("data-email"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_model').modal('show');
    });

    $('#dt_email_alerts tbody').on('click', '.view', function() {
        var button = $(this);
    
        $('#vw_type').val(button.attr("data-type"));
        $('#vw_email ').val(button.attr("data-email"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));

        $('#view_model').modal('show');
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
        // bFilter: false,
        // dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        // buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
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
                "update_date_to": $('#update_date_to').val(),
                "update_date_from": $('#update_date_from').val(),
                "train_no": $('#train_no').val(),
            }
        },
        "columns": [
            { "data": "wagon" },
            { "data": "train_no" },
            { "data": "client_name" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "current_location" },
            { "data": "dest_station" },
            { "data": "yard_siding" },
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
            data.update_date_to = $('#update_date_to').val();
            data.update_date_from = $('#update_date_from').val();
            data.train_no = $('#train_no').val();

        });
        $('#filter_model').modal('hide');
        wagon_tracker.draw();
    });

    $('#reset_wagon_tracking_report_filter').on('click', function() {
        $('.clear_select').val(null).trigger("change")
        $('.clear_form').val('');
        wagon_tracker.draw();
    });

    $('#download_tracking_report_excel').click(function() {
        $('#wagon_tracking_report_form').attr('action', '/download/wagon/tracking/report/excel');
        $('#wagon_tracking_report_form').attr('method', 'GET');
        $("#wagon_tracking_report_form").submit();
    })

    // not to allow required field to be empty

    $('#submit-wagon-tracker').click(function() {

        if (($('#update_date').val() == "") ||
            ($('#customer_id').val() == "")

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

    var wagon_tracking_bulk_dt = $('#wagon-tracking-bulk-dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        select: {
            "style": 'multi'
        },
        bInfo: false,
        orderable: !0,
        bSort: false,
        columns: [
            { data: "wagon_code"},
            { data: "wagon_owner"},
            { data: "train_no"},
            { data: "customer_name" },
            { data: "commodity_name" },
            { data: "origin_name" },
            { data: "destination_name"},
            {
                "data": "current_location",
                "render": function ( data, type, row ) {
                    if ((row["wagon_curent_stat_pur_code"]  == 'ARRIVAL')){
                        return "<span style='color:#02f52f'>"+data+"</span>"
                    } else {
                        var location
                        if (data === null || data === undefined) {
                            location = ""
                           }
                        else{
                            location = data
                        }

                        return "<span>"+location+"</span>"
                    }
                },
                "defaultContent": "<span></span>"
            },
            {
                data: "wagon_code",
                "render": function(data, type, row) {
                    return '<a href= "#" data-wagon_code = "' + data + '" data-origin_name = "' + row["origin_name"] + '" data-destination_id = "' + row["destination_id"] + '" data-origin_id = "' + row["origin_id"] + '"  data-customer_id = "' + row["customer_id"] + '" data-commodity_id = "' + row["commodity_id"] + '" data-condition_id = "' + row["condition_id"] + '"  data-current_location_id = "' + row["current_location_id"] + '" data-destination_name = "' + row["destination_name"] + '" data-wagon_owner = "' + row["wagon_owner"] +'" data-train_no = "'+ row["train_no"] +'" data-customer_name = "'+ row["customer_name"] +'" data-commodity_name ="'+ row["commodity_name"] +'" data-wagon = "'+ row["wagon_code"] +'" data-wagon-owner = "'+ row["wagon_owner"] +'" data-wagon-id = "'+ row["wagon_id"] +'"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill edit" title= "Edit "> <i class= "la la-edit "></i></a>'  
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "8",
                "className": "text-center"
            },
        ]
    });

    $('#tracker-select-all').on( 'click', function () {
		wagon_tracking_bulk_dt.rows().select();
        wagon_tracking_bulk_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#tracker-unselect-all').on( 'click', function () {
        wagon_tracking_bulk_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		wagon_tracking_bulk_dt.rows().deselect();
    });

    $('#wagon-tracking-bulk-dt tbody').on('click', '.edit', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        tracker_row =  $(this).closest('tr');
        var rowData = wagon_tracking_bulk_dt.row($tr).data()
        $('.multi_select2_modal').val(null).trigger("change");
        $('.select2_modal').val(null).trigger("change");
        $('.spare_id').val(null).trigger("change");
        $('.field-clr').val('');
        $('#wagon_code').val(button.attr("data-wagon"));
        $('#wagon_owner').val(button.attr("data-wagon-owner"));
        $('#commodity').val(button.attr("data-commodity_name"));
        $('#origin_station').val(button.attr("data-origin_name"));
        // $('#comment').val(comment);
        $('#destin_station').val(button.attr("data-destination_name"));
        $('#customer').val(button.attr("data-customer_name"));
        $('#train_no').val(button.attr("data-train_no")); 
        $('#current_status_id').val(rowData.departure);
        $('#yard_siding').val(rowData.yard_siding);
        $('#sub_category').val(rowData.sub_category);
        $('#condition_id').val(rowData.condition_id);
        $('#defect_ids').val(rowData.defect_ids);
        $('#bound').val(rowData.bound);
        $('#domain_id').val(rowData.domain_id);
        $('#comment').val(rowData.comment);
        $('#edit_tracking').modal('show');
    });

    $('#add_new_tracker').click(function() {
        if (($('#mvt_train_no').val() == "") ||
            ($('#current_location_id').val() == "") ||
            ($('#update_date').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }
        $('#new_train_no').val($('#mvt_train_no').val());
        $('#add_new_tracker_modal').modal('show');
    });

    $('#update-tracker-list').click(function() {
        if (($('#mvt_train_no').val() == "") ||
            ($('#current_location_id').val() == "") ||
            ($('#update_date').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }
        $('#crnt_stat_id').val('');
        $('#bulk_current_status_id').val(null).trigger("change");
        $('#condition_tracker_modal').modal('show');
    });

    $('#add_new_tracker_to_dt').click(function() {
         
        if(($('#mvt_wagon_code').val() == "") ||
            ($('#new_wagon_owner').val() == "") ||
            ($('#new_origin_station').val() == "") ||
            ($('#new_destin_station').val() == "") ||
            ($('#new_current_status_id').val() == "") ||
            ($('#new_domain_id').val() == "") ||
            ($('#new_customer').val() == "") ||
            ($('#new_commodity').val() == "")
        ) {
                Swal.fire(
                    'Oops..!',
                    'Fields cannot be blank!',
                    'error'
                )
                return false;
            }
        
            var domSpares = document.querySelectorAll("div[data-repeater-add]");
            var spares = [];
            domSpares.forEach(function(spare) {
                var spare_entry = {
                    spare_id: spare.querySelector('.add_spare_id').value,
                    quantity: spare.querySelector('.add_count').value
                }
                spares.push(spare_entry);
            });
         
        var row = [{ 
            "comment": "", 
            "spares": spares, 
             "wagon_code":  $('#mvt_wagon_code').val(),
             "wagon_owner": $('#new_wagon_owner').val(),
             "train_no": $('#new_train_no').val(),
             "customer_name": $("#new_customer option:selected").attr('data-customer'),
             "commodity_name": $("#new_commodity_id option:selected").attr('data-commodity'),
             "origin_name": $("#new_origin_station option:selected").attr('data-origin'),
             "destination_name" :$("#new_destin_station option:selected").attr('data-destin'),
             "departure": $('#new_current_status_id').val(),
             "yard_siding": $('#new_yard_siding').val(),
             "sub_category": $('#new_sub_category').val(),
             "condition_id": $('#new_condition_id').val(),
             "current_location_id": $('#current_location_id').val(),
             "current_location": $("#current_location_id option:selected").attr('data-current-location'),
             "wagon_curent_stat_pur_code": "",
             "bound": $('#new_bound').val(),
             "defect_ids": $('#new_defect_ids').val(),
             "domain_id": $('#new_domain_id').val(),
             "comment": $('#new_comment').val(),
             "wagon_id": $('#wagon_id').val(),
             "commodity_id": $('#new_commodity_id').val(),
             "customer_id" : $('#new_customer').val(),
             "origin_id": $('#new_origin_station').val(),
             "destination_id": $('#new_destin_station').val()
          }
        ];
        
        wagon_tracking_bulk_dt.rows.add(row).draw(false);
        // $('#add_new_tracker_modal').modal('hide');
        $('.multi_select2_modal').val(null).trigger("change");
        $('.select2_modal').val(null).trigger("change");
        $('.field-clr').val('');
    });

    $('#save-tracked-wagons').click(function() {
         $('#crnt_stat_id').val($('#bulk_current_status_id').val());

        if (($('#crnt_stat_id').val() == "")){
            Swal.fire(
                'Oops..!',
                'Wagon condition cannot be blank!',
                'error'
            )
            return false;
        }

        if (($('#mvt_train_no').val() == "") ||
            ($('#current_location_id').val() == "") ||
            ($('#update_date').val() == "") ||
            ($('#bound').val() == "") ||
            ($('#domain_id').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }

        if (wagon_tracking_bulk_dt.rows().count()  < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        row = wagon_tracking_bulk_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];
      
        wagon_tracking_bulk_dt.rows( { selected: true } ).every(function(rowIdx) {
            data_row.push(Object.assign(wagon_tracking_bulk_dt.rows().data()[rowIdx], details));
        })

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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/save/new/wagon/tracker',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Entries saved successfully!',
                                'success'
                            )
                            $.each(wagon_tracking_bulk_dt.rows( { selected: true } ).indexes(), function(index, item) {

                                var rowData = wagon_tracking_bulk_dt.row(item).data()
                                rowData.current_location =  $("#current_location_id option:selected").attr('data-current-location');
                                rowData.current_location_id =  $("#current_location_id").val();
                                rowData.wagon_curent_stat_pur_code =  $("#bulk_current_status_id option:selected").attr('data-pur-code');
                                rowData.departure =  $("#bulk_current_status_id").val();
                                wagon_tracking_bulk_dt.row(item).data(rowData).draw();
                            });
                            $('#condition_tracker_modal').modal('hide');

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
    
    $('#update_tracker').click(function() {
            
        var rowData = wagon_tracking_bulk_dt.row(tracker_row).data();
        rowData.departure = $('#current_status_id').val();
        rowData.yard_siding = $('#yard_siding').val();
        rowData.sub_category = $('#sub_category').val();
        rowData.condition_id = $('#condition_id').val();
        rowData.defect_ids = $('#defect_ids').val();
        rowData.bound  = $('#bound').val();
        rowData.domain_id = $('#domain_id').val();
        rowData.comment = $('#comment').val();
        var domSpares = document.querySelectorAll("div[data-repeater-spare]");
        var spares = [];
        domSpares.forEach(function(spare) {
            var spare_entry = {
                spare_id: spare.querySelector('.spare_id').value,
                quantity: spare.querySelector('.count').value
            }
            spares.push(spare_entry);
        });
        rowData.spares = spares;
      
        if($('#defect_ids').val().length > 0){
            domSpares.forEach(function(spare) {
                if (( spare.querySelector('.spare_id').value == "") ||
                    ( spare.querySelector('.count').value == "")
                ) {
                    Swal.fire(
                        'Oops..!',
                        'Spares cannot be blank!',
                        'error'
                    )
                    return false;
                }else{
                    wagon_tracking_bulk_dt.row(tracker_row).data(rowData).draw();
                    $('#edit_tracking').modal('hide');
                }
            })
          
        }else{
            wagon_tracking_bulk_dt.row(tracker_row).data(rowData).draw();
            $('#edit_tracking').modal('hide');
        }
        
    });
    
    $("#mvt_train_no").on("input", function() {
        spinner.show();
        $.ajax({
            url: '/movement/train/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                train_no: $("#mvt_train_no").val()
            },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {
                     
                    wagon_tracking_bulk_dt.clear().rows.add(result.data).draw();

                } else {
                    wagon_tracking_bulk_dt.clear().rows.add(result.data).draw();
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

    $('#create-single-tracker').click(function() {
            
        if(($('#mvt_wagon_code').val() == "") ||
            ($('#wagon_id').val() == "") ||
            ($('#bound').val() == "") ||
            ($('#domain_id').val() == "") ||
            ($('#departure').val() == "") ||
            ($('#current_location_id').val() == "") ||
            ($('#train_no').val() == "") ||
            ($('#update_date').val() == "")
        ) {
                Swal.fire(
                    'Oops..!',
                    'Required Fields can not be blank!',
                    'error'
                )
                return false;
            }
        
        var domSpares = document.querySelectorAll("div[data-repeater-add]");
        var spares = [];
        domSpares.forEach(function(spare) {
            var spare_entry = {
                spare_id: spare.querySelector('.add_spare_id').value,
                quantity: spare.querySelector('.add_count').value
            }
            spares.push(spare_entry);
        });

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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/create/new/wagon/tracking',
                    type: 'post',
                    data: {
                        spares: spares, 
                        _csrf_token: $("#csrf").val(),
                        wagon_id: $('#wagon_id').val(),
                        bound: $('#bound').val(),
                        domain_id: $('#domain_id').val(),
                        departure: $('#departure').val(),
                        current_location_id: $('#current_location_id').val(),
                        train_no: $('#train_no').val(),
                        update_date: $('#update_date').val(),
                        tracking_type: $('#tracking_type').val(),
                        yard_siding: $('#yard_siding').val(),
                        defect_ids : $('#defect_ids').val(), 
                        comment : $('#comment').val(),
                        net_ton : $('#net_ton').val(), 
                        sub_category : $('#sub_category').val(),  
                        condition_id : $('#condition_id').val()
                     },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Submited successfully!',
                                'success'
                            )
                            location.reload();
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Domains",
                filename: "Domain List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Domains",
                filename: "Domain List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Domains",
                filename: "Domain List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
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

    $('#dt_domain tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_id').val(button.attr("data-id"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
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

    var dt_region = $('#dt_regions').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Regions",
                filename: "Region List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Regions",
                filename: "Region List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "Regions",
                filename: "Region List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#dt_regions tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_regions tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        
        $('#view_modal').modal('show');
    });

    $('#dt_regions tbody').on('click', '.change-status', function() {
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

    $('#dt_regions tbody').on('click', '.delete', function() {
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
                    url: '/delete/region',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_region.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Region deleted successfully!',
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



    // wagon position report

    var wagon_position_report_dt = $('#dt-wagon-position-report').DataTable({
        "responsive": true,
        "processing": true,
        "bFilter": false,
        "select": {
            "style": 'multi'
        },
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
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
                "domain_ids": $('#domain_ids').val(),
                "wagon_status_ids": $('#wagon_status_ids').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),
            }
        },

        "columns": [
            { "data": "wagon_symbol" },
            { "data": "status" },
            { "data": "count" },
            { "data": "grand_total" }
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
                "targets": [3],
            },
            {
                "targets": 2,
                "className": "text-right",
                "width": "20%"
            },

        ],
        "rowGroup": {
            startRender: function(rows, group) {
                return group
            },
            dataSrc: ['domain'],
            "font-weight": 800
        }
    });


    // wagon position filter
    $('#wagon_position__filter').click(function() {

        $('#wagon_position_filter_model').modal('show');
    });

    $('#wagon-position-report-filter').on('click', function() {
        wagon_position_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.domain_ids = $('#domain_ids').val();
            data.wagon_status_ids = $('#wagon_status_ids').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#wagon_position_filter_model').modal('hide');
        wagon_position_report_dt.draw();
    });


    // wagon allocation report

    var wagon_allocation_dt = $('#dt-wagon-allocation-position').DataTable({
        "responsive": true,
        "processing": true,
        // "bFilter": false,
        "select": {
            "style": 'multi'
        },
        // dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        // buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/allocation/tracker/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "customer_ids": $('#customer_ids').val(),
                "domain_ids": $('#domain_ids').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),

            }
        },
        "columns": [
            { "data": "region" },
            { "data": "customer" },
            { "data": "count" }
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
                "width": "40%",
                "className": "text-right fw-1000",
                "targets": [0],
                // "className": "fw-600"
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
            },

            {
                "targets": 1,
                "className": "text-right",
                "fw": "600",
                "width": "50%"
            },
            {
                "targets": 2,
                "className": "text-right",
                "fw": "600",
                "width": "65%"
            },

        ],
        "rowGroup": { dataSrc: ['region'], "font-weight": 800 }
    });

    // wagon allocation filter
    $('#allocation_filter').click(function() {

        $('#allocation_filter_model').modal('show');
    });

    $('#allocation-report-filter').on('click', function() {
        wagon_allocation_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.customer_ids = $('#customer_ids').val();
            data.domain_ids = $('#domain_ids').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#allocation_filter_model').modal('hide');
        wagon_allocation_dt.draw();
    });



    // wagon yard position report

    var wagon_yard_position_dt = $('#dt-wagon-yard-position').DataTable({
        "responsive": true,
        "processing": true,
        "bFilter": false,
        "select": {
            "style": 'multi'
        },
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/yard/position/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "current_location_ids": $('#current_location_ids').val(),
                "wagon_owner_ids": $('#wagon_owner_ids').val(),
                "commodity_ids": $('#commodity_ids').val(),
                // "wagon_symbol_ids": $('#wagon_symbol_ids').val(),
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
                "className": "fw-600",
                "className": "text-right",
                //  "width": "20%", "targets": [1],
                //  "width": "10%", "targets": [2]
            },
            {
                "targets": [1],
                "className": "text-right"
            },
            {
                "targets": [4],
                "className": "text-right"
            },

        ],
        "rowGroup": { dataSrc: ['current_location'], "font-weight": 800 }
    });


    // wagon yard filter
    $('#wagon_yard_filter').click(function() {

        $('#wagon_yard_filter_model').modal('show');
    });

    $('#wagon-yard-report-filter').on('click', function() {
        wagon_yard_position_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.current_location_ids = $('#current_location_ids').val();
            data.wagon_owner_ids = $('#wagon_owner_ids').val();
            data.commodity_ids = $('#commodity_ids').val();
            // data.wagon_symbol_ids = $('#wagon_symbol_ids').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#wagon_yard_filter_model').modal('hide');
        wagon_yard_position_dt.draw();
    });


    // wagon daily position report

    var dt_daily_wagon_postion_dt = $('#dt_daily_wagon_postion').DataTable({
        "responsive": true,
        "processing": true,
        "select": {
            "style": 'multi'
        },
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
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
    var dt_wagon_by_condition_report = $('#dt-wagon-condition-report').DataTable({
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
            "url": '/wagon/by/condition/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "domain_id": $('#domain_id').val(),
                "wagon_condition_id": $('#wagon_condition_id').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),
            }
        },
        "columns": [
            { data: "domain" },
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
            },
            {
                "targets": 1,
                "className": "text-right",
                "width": "70%"
            },
            {
                "targets": 2,
                "className": "text-right",
                "width": "20%"
            },
        ],
        "rowGroup": { dataSrc: ['domain'], "font-weight": 800 }
    });

    // wagon grouped by condition filter
    $('#wagon_by_conditon_filter').click(function() {

        $('#wagon_by_condtion_filter_model').modal('show');
    });

    $('#wagon-by-condtion-report-filter').on('click', function() {
        dt_wagon_by_condition_report.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.wagon_condition_id = $('#wagon_condition_id').val();
            data.domain_id = $('#domain_id').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#wagon_by_condtion_filter_model').modal('hide');
        dt_wagon_by_condition_report.draw();
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
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
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


    //////////////////////////// coilard //////////////////////////////////////////


    $('.addrate').click(function() {
        var lastRepeatingGroup = $('.repeatingSection').last();
        lastRepeatingGroup.clone().insertAfter(lastRepeatingGroup);
        return false;
    });

    $('.deleterate').on('click', function() {
        $(this).parent('div.addrate').remove();
    });

    var dt_tariff_lines_rates = $('#dt-tariff-lines-rates').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        columnDefs: [{
                "targets": 0,
                "width": "70",
                "className": "text-center"
            },
            {
                "targets": 4,
                "className": "text-center"

            }
        ],
        columns: [
            { data: "rate" },
            { data: "admin" },
            { data: "country" },
            { data: "date" },
            { data: "total", "defaultContent": 0.00 }
        ],


    });

    $('.tariff-lookup').on('change', function() {
        if ($('#origin_tariff').val().length < 1 || $('#destin_tariff').val().length < 1 || $('#client_id').val().length < 1 || $('#commodity_type').val().length < 1 || $('#document_date').val().length < 1 ) {
            return false;
        }

        $.ajax({
            url: '/tariff/line/lookup',
            type: 'post',
            data: {
                "client_id": $('#client_id').val(),
                "orign_station": $('#origin_tariff').val(),
                "destin_station": $('#destin_tariff').val(),
                "commodity": $('#commodity_type').val(),
                "date": $('#document_date').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {

                if (result.data.length < 1) {

                    dt_tariff_lines_rates.clear().rows.add([]).draw();
                    $('#surcharge-percent').val('');
                    $('#tarrif_id').val('');
                    surcharge_rate = 0

                } else {

                    var surcharge_percent = result.data[0].surcharge > 0 == true ? (result.data[0].surcharge / 100) : 0;
                    var tarriff_id = result.data[0].id > 0 == true ? (result.data[0].id) : ""
                    $('#tarrif_id').val(tarriff_id);

                    surcharge_rate = Number(surcharge_percent).toFixed(2)
                    $('#surcharge-percent').val(Number(surcharge_percent).toFixed(2));
                    dt_tariff_lines_rates.clear().rows.add(result.data).draw();
                





              


                    if (edit_dt_orders.rows().count() < 2) {
                        dt_tariff_lines_rates.clear().rows.add(result.data).draw();
                   } else {
           
                    $.each(edit_dt_orders.rows().data(), function(index, wagon) {
                        var total_amt = 0;
                        var order_sum = !isNaN(wagon["tariff_tonnage"]) && (Number(wagon["tariff_tonnage"]) > 0) ? wagon["tariff_tonnage"] :  wagon["actual_tonnes"];
                        $.each(dt_tariff_lines_rates.rows().data(), function(index_rate, item) {
                            total_amt = (item["rate"] * order_sum) + total_amt
                            item.total = item.total + (item["rate"] * order_sum)
                            item.total = Number(item.total.toFixed(2));
                            dt_tariff_lines_rates.row(index_rate).data(item).draw();
                          
                        });
                        wagon.total = total_amt
                        wagon.total =  Number(wagon.total.toFixed(2));
                        edit_dt_orders.row(index).data(wagon).draw();
                    });

                    var total_amount = edit_dt_orders.column(7).data().sum()
                    var surcharge = total_amount * $('#surcharge-percent').val()
                    var total_ton = 0;
                    $.each(edit_dt_orders.rows().data(), function(index, item) {
                        if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                            total_ton =  total_ton + Number(item["tariff_tonnage"]);
                        } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                            total_ton =  total_ton +  Number(item["actual_tonnes"]);
                        }
                    });

                    $('#wagon_count').val(modify_consign_dt.rows().count());
                    $('#total_tonnage').val(Number(total_ton).toFixed(3));
                    $('#total_amount').val(Number(total_amount).toFixed(2));
                    $('#surcharge_total').val(Number(surcharge).toFixed(2))
                  

                    // if ($('#edit-vat').val() == 'YES') {
                    //     $("#vat").attr('checked', 'checked');
                    //     // $("#no_vat").prop("disabled", true);
                    //     var vat = total_amount * $('#vat-percentage').val()
                    //     $('#vat_total').val(Number(vat).toFixed(2));
                    //     $('#overall_total').val(Number(total_amount + surcharge + vat).toFixed(2));

                    // } else {

                    //     $("#no_vet").attr('checked', 'checked');
                    //     // $("#vat").prop("disabled", true);
                    //     $('#overall_total').val(Number(total_amount + surcharge).toFixed(2));

                    // }
           
                    
                   }


                }

            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

    $('.create_station_code').on('change', function() {

        station = $('#reporting_station_id option:selected').data('reporting_station_code');

        if ($('#document_date').val() == "" || station == undefined)
            return false;

        if (station == "") {
            $('#station_code').val('');
            // $('#station_code').attr('readonly', false);
        } else {
            var year = $('#capture_date').val().slice(0, 4);
            var month = $('#capture_date').val().slice(5, 7);
            var seq_no = $("#station_code").attr("data-doc_seq_no");
            station = $('#reporting_station_id option:selected').data('reporting_station_code');

            const str = station + '/'+ year +'/'+ month + '/' + '';
            $('#station_code').val(str)
            // $('#station_code').attr('readonly', true);
        }

    });

    $('.apply_vat').click(function() {

        if (dt_tariff_lines_rates.rows().count() <= 0) {
             return false;
        } else {

            var value = $("input[type=radio][name=vat_applied]:checked").val();
            if (value == 'YES') {
                var vat = (parseFloat($("#vat-percentage").val()) * edit_dt_orders.column(7).data().sum());
                $('#vat_total').val(Number(vat).toFixed(2));
                var surcharge = parseFloat($('#surcharge_total').val());
                var amount = parseFloat($('#total_amount').val());

                $('#overall_total').val(Number(parseFloat(vat) + surcharge + amount).toFixed(2));
            } else {
                var surcharge = parseFloat($('#surcharge_total').val());
                var amount = parseFloat($('#total_amount').val());
                $('#vat_total').val(0);
                $('#overall_total').val(Number(surcharge + amount).toFixed(2));

            }
        }

    });

    // condition category table

    var dt_cond_cat = $('#dt_cond_cat').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Condition category",
                filename: "Condition category",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Condition category",
                filename: "Condition category",
                exportOptions: {
                    columns: [  0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Condition category",
                filename: "Condition category",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#dt_cond_cat tbody').on('click', '.change-status', function() {
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
                    url: '/change/user/cond/category/status',
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

                            dt_cond_cat.cell($tr, 2).data(stat).draw();
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

    $('#wagon_defects').on('click', function() {
        $('#wagon-defects').modal('show');
    });


    $('#dt_user').on('click', '.admin_assign_loco', function(e) {
        e.preventDefault();
        var button = $(this);
        // prompt("Are you sure")
        Swal.fire({
            title: 'Are you sure?',
            text: "You won't be able to revert this!",
            type: "warning",
            showCancelButton: true,
            confirmButtonColor: '#23b05d',
            cancelButtonColor: '#d33',
            confirmButtonText: 'Yes!',
            showLoaderOnConfirm: true
        }).then((result) => {
            if (result.value) {
                $.ajax({
                    url: '/admin/assign/loco/driver',
                    type: 'POST',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        if (result.status === 0) {
                            Swal.fire(
                                'Success',
                                'Operation successful!',
                                'success'
                            )
                        } else {
                            Swal.fire(
                                'Error',
                                result.message,
                                'error'
                            )
                        }
                    },
                    error: function(request, msg, error) {
                        Swal.fire(
                            'Oops..',
                            error,
                            'error'
                        )
                    },
                });
            } else {
                Swal.fire(
                    'error',
                    'Operation not performed :)',
                    'error'
                )
            }
        });
    });

    var dt_view_tariff_line_rates = $('#dt_view_tariff_line_rates').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        columns: [
            { data: "admin" },
            { data: "rate" },
            { data: "total", "defaultContent": 0.00 }
        ]

    });

    var dt_order_batch_entries = $('#dt-order-batch-entries').DataTable({
        bLengthChange: false,
        responsive: true,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        bSort: false,
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "capacity_tonnes" },
            { data: "actual_tonnes" },
            { data: "tariff_tonnage" },
            { data: "container_no" },
            { data: "total" },
            { data: "comment" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '  <a href= "#"  data-id = ' + data + ' data-comment = ' + row["comment"] + ' data-container_no = ' + row["container_no"] + ' data-actual_tonnes = ' + row["actual_tonnes"] + ' data-tariff_tonnage = ' + row["tariff_tonnage"] + ' data-capacity_tonnes = ' + row["capacity_tonnes"] + ' data-wagon = ' + row["wagon_code"] + ' data-wagon-type = ' + row["wagon_type"] + ' data-wagon-owner = ' + row["wagon_owner"] + '  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_selected_row" title= "View "> <i class= "la la-eye "></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "12",
                "className": "text-center"
            },
        ]
    });


    $('#dt-order-batch-entries tbody').on('click', '.view_selected_row', function() {
        var $tr = $(this).closest('tr');
        var rowData = dt_order_batch_entries.row($tr).data()
        $('#traiff_line_rate_total').val('');
        dt_view_tariff_line_rates.clear().rows.add([]).draw();

        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
            if (!isNaN(rowData["tariff_tonnage"]) && (Number(rowData["tariff_tonnage"]) > 0)) {

                var total = item["rate"] * rowData["tariff_tonnage"]
                item.total =  Number(total).toFixed(2);
                dt_view_tariff_line_rates.rows.add([item]).draw(false);
                $('#traiff_line_rate_total').val(dt_view_tariff_line_rates.column(2).data().sum());

            } else if (!isNaN(rowData["actual_tonnes"]) && (Number(rowData["actual_tonnes"]) > 0)) {

                var total = item["rate"] * rowData["actual_tonnes"];
                item.total =  Number(total).toFixed(2);
                dt_view_tariff_line_rates.rows.add([item]).draw(false);
                $('#traiff_line_rate_total').val(dt_view_tariff_line_rates.column(2).data().sum());
            }
        });

        $('#tariff_line_model').modal('show');

    });

    if ($('#consignment-verification-batch').length) {
        spinner.show();
        $.ajax({
            url: '/consignment/sales/order/batch/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                status: $("#status").val(),
                _csrf_token: $("#csrf").val(),
                client_id: $('#consignment-batch').val(),
                orign_station: $('#origin_tariff_id').val(),
                destin_station: $('#destin_tariff_id').val(),
                tarriff_id: $('#tarriff_id').val(),

            },
            success: function(result) {
                spinner.hide();
                $(".disable-fields").prop('disabled', true);
                if (result.data.length < 1) {

                    dt_order_batch_entries.clear().rows.add([]).draw();
                    dt_tariff_lines_rates.clear().rows.add([]).draw();

                } else {
                    consignment = result.data;
                    rate = result.rate;

                    dt_order_batch_entries.clear().rows.add(consignment).draw();
                    dt_tariff_lines_rates.clear().rows.add(rate).draw();
                    var total_amount = dt_order_batch_entries.column(7).data().sum()
                    var surcharge = total_amount * $('#surcharge-percent').val()

                    $.each(dt_order_batch_entries.rows().data(), function(index, wagon) {
                        var order_sum = !isNaN(wagon["tariff_tonnage"]) && (Number(wagon["tariff_tonnage"]) > 0) ? wagon["tariff_tonnage"] :  wagon["actual_tonnes"];

                        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
                            item.total = item.total + (item["rate"] * order_sum)
                            item.total = Number(item.total.toFixed(2));
                            dt_tariff_lines_rates.row(index).data(item).draw();
                        });
                    });

                    var total_ton = 0;
                    $.each(dt_order_batch_entries.rows().data(), function(index, item) {
                        if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                            total_ton =  total_ton + Number(item["tariff_tonnage"]);
                        } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                            total_ton =  total_ton +  Number(item["actual_tonnes"]);
                        }
                    });

                    $('#wagon_count').val(dt_order_batch_entries.rows().count());
                    $('#total_tonnage').val(Number(total_ton).toFixed(3));
                    $('#total_amount').val(Number(total_amount).toFixed(2));
                    $('#surcharge_total').val(Number(surcharge).toFixed(2))

                    if ($('#vat').val() == 'YES') {
                        $("#vat").attr('checked', 'checked');
                        $("#no_vat").prop("disabled", true);
                        var vat = total_amount * $('#vat-percentage').val()
                        $('#vat_total').val(Number(vat).toFixed(2));
                        $('#overall_total').val(Number(total_amount + surcharge + vat).toFixed(2));

                    } else {

                        $("#no_vat").attr('checked', 'checked');
                        $("#vat").prop("disabled", true);
                        $('#overall_total').val(Number(total_amount + surcharge).toFixed(2));

                    }

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

    $('#draft_consignment_batches').DataTable({
        responsive: true,
        'columnDefs': [{
                "targets": 3,
                "width": "12",
                "className": "text-center"
            },
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });

    $('#draft_movement_batches').DataTable({
        responsive: true,
        'columnDefs': [{
            "targets": 3,
            "width": "12",
            "className": "text-center"
            },
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });

    $('.station_owner').on('change', function() {
        owner = $('#reporting_station option:selected').data('station_owner');
        $('#station_owner').val(owner);
    });

    var movent = [
        { "wagon_code": "", "wagon_owner": "", "wagon_type": "", "origin_name": "", "invoice_no": "", "sales_order": "", edited: false }
    ];

    var editable_movement_dt = $('#editable_movement_dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        keys: true,
        bSort: false,
        data: movent,
		'columnDefs': [
            {
                "targets": [0, 4, 3],
                "width": "12%",
                "className": "text-center"
            },
            {
                "targets": [5],
                "width": "3%",
                "className": "text-center"
            },
            {
                "targets": [1, 2],
                "width": "8%",
                "className": "text-center"
            }
        ],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "invoice_no" },
            { data: "sales_order" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected_row m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'><i class='la la-trash'></i></a>" }
        ]
    });

    editable_movement_dt.on('key-focus', function(e, datatable, cell, originalEvent) {
        cell.node().closest('td').click();
        $('input', cell.node()).focus();

    }).on("focus", "td input", function() {
        $(this).select();
    });


    $("#editable_movement_dt tbody").on("click", "tr td", function(e) {
        // table.row($(this).closest("tr")).remove().draw();
        if (editRow == 1)
            return false;

        var $row = $(this).closest("tr").off("click");
        var $tds = $row.find("td").not(':last');

        $.each($tds, function(index, el) {
            var txt = $(this).text();
            if (index == 0) {
                $(this).html("").append("<input type='text' class=\"form-control wagon_lookup row-input\" value=\"" + txt + "\">");
            } else {
                $(this).html("").append("<input type='text' class=\"form-control row-input\" value=\"" + txt + "\">");
            }
        });

        if(editRow < 0){
            editRow = 0;
        } else {
            editRow = 1;
        }
    })

    $("#editable_movement_dt tbody").on('input', ".wagon_lookup", function(e) {
        var $select = $(this);
        var $row = $(this).closest("tr");
        var $tds = $row.find("td").not(':first').not(':last');

        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $(".wagon_lookup").val()
            },
            success: function(result) {
               
                if (result.data.length < 1) {
                    WagonID ="";
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").val("");
                        } else if (index == 1) {
                            $(this).find("input").val("");
                        }else
                         {
                            return false;
                        }
                    });
                     
                   
                } else {

                    WagonID = result.data[0].id
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").val(result.data[0].wagon_owner);
                        } else if (index == 1) {
                            $(this).find("input").val(result.data[0].wagon_type);
                        }else
                         {
                            return false;
                        }
                    });
                }
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                editRow == -1
            }
        });

    });

    if ($('#newRow').length) {
        var rowmovent = $("#newRow").find("tr")[0].outerHTML;
    }

    $("#editable_movement_dt tbody").on('keyup', ".row-input", function(e) {
        if (e.keyCode == 13) {

            var $row = $(this).closest("tr");
            var $tds = $row.find("td").not(':last');
            var total_consigns = editable_movement_dt.rows().data().length;
            var rowIndex = editable_movement_dt.row($row).index();
            var edited = false;
            // var wagonId = null;
            // var origin_station_id = null;
            // var destin_station_id = null;
            // var commodity_id = null;
            // var consignee_id = null;
            // var consigner_id = null;


            $.each($tds, function(index, el) {
                var $this = $(this);
                var txt = (index == 0 ?  $this.find("input").val() : $this.find("input").val());

                // wagonId = index == 0 ? $this.find("select").val() : wagonId;
                // origin_station_id = index == 3 ? $this.find("select").val() : origin_station_id;
                // destin_station_id = index == 4 ? $this.find("select").val() : destin_station_id;
                // commodity_id = index == 5 ? $this.find("select").val() : commodity_id;
                // consigner_id = index == 6 ? $this.find("select").val() : consigner_id;
                // consignee_id = index == 7 ? $this.find("select").val() : consignee_id;


                if ((txt.trim().length < 1) && (index <= 3)) {
                    Swal.fire(
                        'Oops...',
                        'column ' + (index) + ' can\'t be blank',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                edited = true;
                editable_movement_dt.cell({ row: rowIndex, column: index }).data(txt).draw();
            });
            var rowData = editable_movement_dt.row($row).data();
            rowData.edited = edited;
            rowData.wagon_id =  WagonID;

         
            // rowData.destin_station_id = destin_station_id;
            // rowData.origin_station_id = origin_station_id;
            // rowData.consignee_id = consignee_id;
            // rowData.consigner_id = consigner_id;
            // rowData.commodity_id = commodity_id;


            $.ajax({
                url: '/consignment/sales/order/lookup',
                type: 'POST',
                data: {
                    _csrf_token: $("#csrf").val(),
                    wagon: WagonID,
                    station_code: rowData.invoice_no
                },
                success: function(result) {
                    if (result.length < 1) {

                        editRow = 0;
                        if ((editable_movement_dt.row($row).index() == total_consigns - 1) && editable_movement_dt.row($row).data().edited) {
                            editable_movement_dt.row.add($(rowmovent)).draw();
                            var wagon = count= editable_movement_dt.rows().count() - 1
                            $("#total_wagon_count").text(wagon);
     
                        }

                        rowData.sales_order = "";
                        editable_movement_dt.row($row).data(rowData).draw();
                        var wagon = count= editable_movement_dt.rows().count() - 1
                        $("#total_wagon_count").text(wagon);
 
    
                    } else {

                        editRow = 0;
                        if ((editable_movement_dt.row($row).index() == total_consigns - 1) && editable_movement_dt.row($row).data().edited) {
                            editable_movement_dt.row.add($(rowmovent)).draw();
                            var wagon = count= editable_movement_dt.rows().count() - 1
                            $("#total_wagon_count").text(wagon);
     
                        }

                        rowData.sales_order = result.data.sale_order;
                        rowData.consignment_id = result.data.id;

                        editable_movement_dt.row($row).data(rowData).draw();
                        var wagon = count= editable_movement_dt.rows().count() - 1
                        $("#total_wagon_count").text(wagon);
 
                    }
                },
                error: function(request, msg, error) {
                    edited = -1;
                    swal({
                        title: "Oops...",
                        text: "Something went wrong!",
                        confirmButtonColor: "#EF5350",
                        type: "error"
                    });
                }
            });


        }
    });

    var edit_dt_orders = $('#edit-dt-orders').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        keys: true,
        bSort: false,
        data: consign,
        'columnDefs': [{
            "targets": [0, 3, 4, 5 ,6, 7],
            "width": "15%",
            "className": "text-center"
        }, 
        {
            "targets": [1, 2, 9],
            "width": "8%",
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
            { data: "total" },
            { data: "comment" },
            { data: "action", "defaultContent": "<a href='#' class='view_selected_row m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-eye'></i></a> <a href='#' class='remove_selected_row m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'>\n <i class='la la-trash'></i></a>" }
        ]
    });

    edit_dt_orders.on('key-focus', function(e, datatable, cell, originalEvent) {
        cell.node().closest('td').click();
        $('input', cell.node()).focus();

    }).on("focus", "td input", function() {
        $(this).select();
    });

    $('#edit-dt-orders tbody').on('click', '.remove_selected_row', function() {
        if(edit_dt_orders.rows().count() < 2)
            return false;
            
        var $tr = $(this).closest('tr');
        var rowData = edit_dt_orders.row($tr).data()
        edit_dt_orders.row($tr).remove().draw(false);
        editRow = -1;
        var $row = $(this).closest("tr").off("click");

        $('#wagon_count').val('');
        $('#wagon_count').val(edit_dt_orders.rows().count() - 1);
        $('#total_tonnage').val('');
         
        var total_ton = 0;
        $.each(edit_dt_orders.rows().data(), function(index, item) {
            if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                total_ton =  total_ton + Number(item["tariff_tonnage"]);
            } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                total_ton =  total_ton +  Number(item["actual_tonnes"]);
            }
        });
        
        $('#total_tonnage').val(Number(total_ton).toFixed(3));
        $('#total_amount').val(edit_dt_orders.column(7).data().sum());
        var total_sur = (edit_dt_orders.column(7).data().sum() * parseFloat(surcharge_rate));
        $('#surcharge_total').val(total_sur);

        if ($('#vet').is(':checked')) {
            var vat = $("#vat-percentage").val() * edit_dt_orders.column(7).data().sum()
            $('#vat_total').val(vat);
            var total = Number(vat + total_sur + edit_dt_orders.column(7).data().sum()).toFixed(2)
            $('#overall_total').val(total);
        } else {

            var total = Number(total_sur + edit_dt_orders.column(7).data().sum()).toFixed(2)
            $('#overall_total').val(total);
            $('#vat_total').val('');
        }

        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
            if (!isNaN(rowData["tariff_tonnage"]) && (Number(rowData["tariff_tonnage"]) > 0)) {

                var total = item["rate"] * rowData["tariff_tonnage"]
                item.total = (item["total"] - Number(total).toFixed(2))
                dt_tariff_lines_rates.row(index).data(item).draw();

            } else if (!isNaN(rowData["actual_tonnes"]) && (Number(rowData["actual_tonnes"]) > 0)) {
                var total = item["rate"] * rowData["actual_tonnes"];
                item.total = (item["total"] - Number(total).toFixed(2))
                dt_tariff_lines_rates.row(index).data(item).draw();
            }else {
                return false;
            }

        });
    });

    $('#edit-dt-orders tbody').on('click', '.view_selected_row', function() {
        var $tr = $(this).closest('tr');
        var rowData = edit_dt_orders.row($tr).data()
        $('#traiff_line_rate_total').val('');
        dt_view_tariff_line_rates.clear().rows.add([]).draw();

        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
            if (!isNaN(rowData["tariff_tonnage"]) && (Number(rowData["tariff_tonnage"]) > 0)) {

                var total = item["rate"] * rowData["tariff_tonnage"]
                item.total =  Number(total).toFixed(2);
                dt_view_tariff_line_rates.rows.add([item]).draw(false);
                $('#traiff_line_rate_total').val(dt_view_tariff_line_rates.column(2).data().sum());

            } else if (!isNaN(rowData["actual_tonnes"]) && (Number(rowData["actual_tonnes"]) > 0)) {

                var total = item["rate"] * rowData["actual_tonnes"];
                item.total =  Number(total).toFixed(2);
                dt_view_tariff_line_rates.rows.add([item]).draw(false);
                $('#traiff_line_rate_total').val(dt_view_tariff_line_rates.column(2).data().sum());
            }
        });

        $('#tariff_line_model').modal('show');

    });

    $('#editable_movement_dt tbody').on('click', '.remove_selected_row', function() {
        if(editable_movement_dt.rows().count() < 2)
        return false;
         var $tr = $(this).closest('tr');
        editable_movement_dt.row($tr).remove().draw(false);
        var wagon = count= editable_movement_dt.rows().count() - 1
        editRow = -1;
        $("#total_wagon_count").text(wagon);
    });

    if ($('#newRow').length) {
        var rowConsign = $("#newRow").find("tr")[0].outerHTML;
    }

    $("#edit-dt-orders tbody").on("click", "tr td", function(e) {
        // table.row($(this).closest("tr")).remove().draw();
        if (editRow == 1){
            return false;
        }

        var $row = $(this).closest("tr").off("click");
        var $tds = $row.find("td").not(':last');

        $.each($tds, function(index, el) {
            var txt = $(this).text();
            if (index == 0) {
                // $(this).html("").append('<select name="wagon_code" class="form-control wagon-code row-input">' + wagonOptions + '</select>');
                $(this).html("").append("<input type='text' class=\"form-control wagon_lookup row-input\" value=\"" + txt + "\">");
            } else {
                $(this).html("").append("<input type='text' class=\"form-control row-input\" value=\"" + txt + "\">");
            }
        });

        if(editRow < 0){
            editRow = 0;
        } else {
            editRow = 1;
        }
    })

    $("#edit-dt-orders tbody").on('input', ".wagon_lookup", function(e) {
        var $select = $(this);
        var $row = $(this).closest("tr");
        var $tds = $row.find("td").not(':first').not(':last');

        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $(".wagon_lookup").val()
            },
            success: function(result) {
               
                if (result.data.length < 1) {
                    WagonID ="";
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").val("");
                        } else if (index == 1) {
                            $(this).find("input").val("");
                        }else if (index == 2) {
                            $(this).find("input").val("0");
                        }else
                         {
                            return false;
                        }
                    });
                     
                   
                } else {

                    
                    WagonID = result.data[0].id
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").val(result.data[0].wagon_owner);
                        } else if (index == 1) {
                            $(this).find("input").val(result.data[0].wagon_type);
                        }else if (index == 2) {
                            $(this).find("input").val(result.data[0].capacity);
                        }else
                         {
                            return false;
                        }
                    });
                }
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
               
            }
        });
    });

    $("#edit-dt-orders tbody").on('keyup', ".row-input", function(e) {
        if (e.keyCode == 13) {

            if (dt_tariff_lines_rates.rows().count() <= 0) {
                Swal.fire(
                    'Oops..!',
                    'No Tariff line rate found!',
                    'error'
                )
                return false;
            }
            var $row = $(this).closest("tr");
            var total_tariff_charge = 0;
            var wagon_total = 0;
            var $tds = $row.find("td").not(':last');
            var total_consigns = edit_dt_orders.rows().data().length;
            var rowIndex = edit_dt_orders.row($row).index();
            var edited = false;
            var wagonId = null;
            $.each($tds, function(index, el) {
                var $this = $(this);
                var txt = (index == 0 ? $this.find("input").val() : $this.find("input").val());
                wagonId = index == 0 ? $this.find("select").val() : wagonId;

                if ((txt.trim().length < 1) && (index <= 3)) {
                    Swal.fire(
                        'Oops...',
                        'column ' + (index+1) + ' can\'t be blank',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                edited = true;
                edit_dt_orders.cell({ row: rowIndex, column: index }).data(txt).draw();
            });
            var rowData = edit_dt_orders.row($row).data();
            rowData.edited = edited;
            rowData.wagon_id = WagonID;

            $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
                if (!isNaN(rowData["tariff_tonnage"]) && (Number(rowData["tariff_tonnage"]) > 0)) {
                    var wagon_amount = item["rate"] * rowData["tariff_tonnage"] 
                    var tarrif_total = wagon_amount + item["total"];
                    wagon_total = wagon_amount + wagon_total;
                    item.total = Number(tarrif_total.toFixed(2));
                    // total_tariff_charge = total_tariff_charge + total;
                    dt_tariff_lines_rates.row(index).data(item).draw();

                } else if (!isNaN(rowData["actual_tonnes"]) && (Number(rowData["actual_tonnes"]) > 0)) {
                    var wagon_amount = item["rate"] * rowData["actual_tonnes"];
                    var tarrif_total = wagon_amount + item["total"];
                    wagon_total = wagon_amount + wagon_total;
                    item.total = Number(tarrif_total.toFixed(2));
                    // total_tariff_charge = total_tariff_charge + total;
                    dt_tariff_lines_rates.row(index).data(item).draw();
                } else {
                    return false;
                }
            });

            rowData.total = Number(wagon_total.toFixed(2));
            wagon_total = 0;
            total_tariff_charge = 0;

            editRow = 0;
            if ((edit_dt_orders.row($row).index() == total_consigns - 1) && edit_dt_orders.row($row).data().edited) {
                edit_dt_orders.row.add($(rowConsign)).draw();

            }

            edit_dt_orders.row($row).data(rowData).draw();
            $('#wagon_count').val(edit_dt_orders.rows().count() - 1);
            var total_ton = 0

            $.each(edit_dt_orders.rows().data(), function(index, item) {
                if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                    total_ton =  total_ton + Number(item["tariff_tonnage"]);
                } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                    total_ton =  total_ton +  Number(item["actual_tonnes"]);
                }
            });
            
            $('#total_tonnage').val(Number(total_ton).toFixed(3));
            $('#total_amount').val(Number(edit_dt_orders.column(7).data().sum().toFixed(2)));  
            var total_sur = Number(edit_dt_orders.column(7).data().sum() * parseFloat(surcharge_rate)).toFixed(2)

            $('#surcharge_total').val(total_sur);

            if ($('#vet').is(':checked')) {
                var vat = parseFloat($("#vat-percentage").val()) * edit_dt_orders.column(7).data().sum()
                $('#vat_total').val(vat);
                $('#overall_total').val(vat + (edit_dt_orders.column(7).data().sum() * parseFloat(surcharge_rate)) + edit_dt_orders.column(7).data().sum());
            } else {
                $('#overall_total').val(Number((edit_dt_orders.column(7).data().sum() * parseFloat(surcharge_rate)) + edit_dt_orders.column(7).data().sum()).toFixed(2))
            }

        }
    });

    if ($('#consignment-draft-batch').length) {
        spinner.show();
        $.ajax({
            url: '/consignment/sales/order/batch/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                _csrf_token: $("#csrf").val(),
                client_id: $('#consignment-batch').val(),
                orign_station: $('#origin_tariff_id').val(),
                status: $('#status').val(),
                destin_station: $('#destin_tariff_id').val(),
                tarriff_id: $('#tarriff_id').val(),

            },
            success: function(result) {
                spinner.hide();
            
                if (result.data.length < 1 && result.data.length > 1) {
                    edit_dt_orders.clear().rows.add([]).draw();
                    dt_tariff_lines_rates.clear().rows.add([]).draw();
                    edit_dt_orders.row.add($(rowConsign)).draw();

                } else {
                    consignment = result.data;
                    rate = result.rate;
                    edit_dt_orders.clear().rows.add(consignment).draw();
                    dt_tariff_lines_rates.clear().rows.add(rate).draw();
                    var total_amount = edit_dt_orders.column(7).data().sum()
                    var surcharge = total_amount * $('#surcharge-percent').val()


                    $.each(edit_dt_orders.rows().data(), function(index, wagon) {
                        var order_sum = !isNaN(wagon["tariff_tonnage"]) && (Number(wagon["tariff_tonnage"]) > 0) ? wagon["tariff_tonnage"] :  wagon["actual_tonnes"];
                        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
                            item.total = item.total + (item["rate"] * order_sum);
                            item.total = Number(item.total.toFixed(2));
                            dt_tariff_lines_rates.row(index).data(item).draw();
                        });
                    });

                    var total_ton = 0;
                    $.each(edit_dt_orders.rows().data(), function(index, item) {
                        if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                            total_ton =  total_ton + Number(item["tariff_tonnage"]);
                        } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                            total_ton =  total_ton +  Number(item["actual_tonnes"]);
                        }
                    });

                    $('#wagon_count').val(edit_dt_orders.rows().count());
                    $('#total_tonnage').val(Number(total_ton).toFixed(3));
                    $('#total_amount').val(Number(total_amount).toFixed(2));
                    $('#surcharge_total').val(Number(surcharge).toFixed(2))

                    if ($('#vat').val() == 'YES') {
                        $("#vat").attr('checked', 'checked');
                        var vat = total_amount * $('#vat-percentage').val()
                        $('#vat_total').val(Number(vat).toFixed(2));
                        $('#overall_total').val(Number(total_amount + surcharge + vat).toFixed(2));

                    } else {

                        $("#no_vat").attr('checked', 'checked');
                        $('#overall_total').val(Number(total_amount + surcharge).toFixed(2));

                    }

                    edit_dt_orders.row.add($(rowConsign)).draw();

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

    if ($('#wagon-code').length) {
        var wagonSelect = document.getElementById('wagon-code');
        var wagonOptions = '';
        $.each(wagonSelect.options, function(i, item) {
            wagonOptions = wagonOptions + item.outerHTML;
        });
    }

    if ($('#origin_station_id').length) {
        var originSelect = document.getElementById('origin_station_id');
        var originOptions = '';
        $.each(originSelect.options, function(i, item) {
            originOptions = originOptions + item.outerHTML;
        });
    }

    if ($('#destin_station_id').length) {
        var destinSelect = document.getElementById('destin_station_id');
        var destinOptions = '';
        $.each(destinSelect.options, function(i, item) {
            destinOptions = destinOptions + item.outerHTML;
        });
    }

    if ($('#commodity_id').length) {
        var commoditySelect = document.getElementById('commodity_id');
        var commodityOptions = '';
        $.each(commoditySelect.options, function(i, item) {
            commodityOptions = commodityOptions + item.outerHTML;
        });
    }

    if ($('#consigner').length) {
        var consignerSelect = document.getElementById('consigner');
        var consignerOptions = '';
        $.each(consignerSelect.options, function(i, item) {
            consignerOptions = consignerOptions + item.outerHTML;
        });
    }

    if ($('#consignee').length) {
        var consigneeSelect = document.getElementById('consignee');
        var consigneeOptions = '';
        $.each(consigneeSelect.options, function(i, item) {
            consigneeOptions = consigneeOptions + item.outerHTML;
        });
    }

    if ($('#payer_nam').length) {
        var payerSelect = document.getElementById('payer_nam');
        var payerOptions = '';
        $.each(payerSelect.options, function(i, item) {
            payerOptions = payerOptions + item.outerHTML;
        });
    }

    // **** Remove empty template menus *****
    // $('li > ul').not(':has(li)').closest("li").remove();
    // $('ul').not(':has(li)').closest("li").remove();

    // //**** Check for any empty menu link /
    // $('li > ul').not(':has(li)').closest("li").remove();
    // $('ul').not(':has(li)').closest("li").remove();


    var dt_manual_matching_report_batch_entries = $('#dt-manual-matching-report-batch-entries').DataTable({
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
            "url": '/movement/consignment/manual/matching/report',
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
            { "data": "document_date" },
            { "data": "consignee" },
            { "data": "payer" },
            { "data": "commodity" },
            { "data": "origin_station" },
            { "data": "final_destination" },
            { "data": "wagon_code" },
            { "data": "wagon_type" },
            { "data": "wagon_owner" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href="#"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill search_for_movemnent" title= "find"> <i class= "la la-search "></i></a>'

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

    $('#manual_matching_report_filter').on('click', function() {
        dt_manual_matching_report_batch_entries.on('preXhr.dt', function(e, settings, data) {
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
        dt_manual_matching_report_batch_entries.draw();
    });

    $('#download_consignment_manual_matching_excel').click(function() {
        $('#consignment_batch_report_form').attr('action', '/download/consignment/manual/matching/excel');
        $('#consignment_batch_report_form').attr('method', 'GET');
        $("#consignment_batch_report_form").submit();
    })

    $('#dt-manual-matching-report-batch-entries tbody').on('click', '.search_for_movemnent', function() {

        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/umatched/movement/lookup',
            type: 'post',
            data: {
                "id": button.attr("data-id"),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {

                    Swal.fire(
                        'Oops..!',
                        'No Related Movement entry found!',
                        'error'
                    )
                    return false;

                } else {
                    $('.cr-fields').val('');
                    $('#related_wagon_owner').val(result.data[0].wagon_owner);
                    $('#related_wagon_code').val(result.data[0].wagon_code);
                    $('#related_train_no').val(result.data[0].train_no);
                    $('#related_train_list').val(result.data[0].train_list_no);
                    $('#related_destination').val(result.data[0].destination_name);
                    $('#related_origin').val(result.data[0].origin_name);
                    $('#related_date').val(result.data[0].movement_date);
                    $('#related_time').val(result.data[0].movement_time);
                    $('#related_movenment_id').val(result.data[0].id);
                    $('#related_consignment_id').val(button.attr("data-id"));
                    $('#related_movement_model').modal('show');

                }

            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });

    });

    $('#match_entries').click(function() {

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
                    url: '/match/consignment/movement/entries',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        consignment_id: $('#related_consignment_id').val(),
                        movenment_id: $('#related_movenment_id').val()
                    },
                    success: function(result) {
                        spinner.hide();
                        $('#related_movement_model').modal('hide');
                        dt_manual_matching_report_batch_entries.draw();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Operation successfully!',
                                'success'
                            )
                            $('#related_movement_model').modal('hide');
                            dt_manual_matching_report_batch_entries.draw();
                            // dt_tariff_lines_rates.clear().rows.add([]).draw();
                            // edit_dt_orders.clear().rows.add([]).draw();
                            // $('.clear_form').val('');

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

    if ($('#maximize-page').length) {
       $('body').addClass('m-aside-left--minimize m-brand--minimize');  
    }


    ///user region

    var dt_user_region = $('#dt_user_region').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "User Regions",
                filename: "System User Regions",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "User Regions",
                filename: "System User Regions",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                messageTop: "User Regions",
                filename: "System User Regions",
                exportOptions: {
                    columns: [ 0, 1, 2, 3]
                }
            }
        ],
    });

    $('#dt_user_region tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#station_id').val(button.attr("data-station"));
        $('#description').val(button.attr("data-description"));
        $('#code').val(button.attr("data-code"));
        $('#id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_user_region tbody').on('click', '.view', function() {
        var button = $(this);

        $('#vw_status').val(button.attr("data-status"));
        $('#vw_station').val(button.attr("data-station"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#status').val(button.attr("data-status"));
        $('#vw_description').val(button.attr("data-description"));
        $('#vw_code').val(button.attr("data-code"));
        $('#view_modal').modal('show');
    });

    $('#dt_user_region tbody').on('click', '.change-status', function() {
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
                    url: '/change/user/region/status',
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

                            dt_user_region.cell($tr, 3).data(stat).draw();
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

    $('#dt_user_region tbody').on('click', '.delete', function() {
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
                    url: '/delete/user/region',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        dt_user_region.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'User region deleted successfully!',
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
   
   
    if ($('#aces_lvl').length) {
        var type = $('#aces_lvl').attr('data-aces-lvl');
        $('#aces_lvl').val(type);
        $('#aces_lvl').trigger('change');
    }

    if ($('#loco_id').length) {
        if( $('#loco_id').attr('data_loco_no') != ''){
            var type = JSON.parse($('#loco_id').attr('data_loco_no'));
            $('#loco_id').val(type).trigger('change');
        }
       
    }

    if ($('#maximize-page').length) {
       $('body').addClass('m-aside-left--minimize m-brand--minimize');  
    }


    ///user region

   
    if ($('#aces_lvl').length) {
        var type = $('#aces_lvl').attr('data-aces-lvl');
        $('#aces_lvl').val(type);
        $('#aces_lvl').trigger('change');
    }

    $('#dt_wagon_bulk_file_errors').DataTable({
        responsive: true,
        // 'columnDefs': [{
        //         "targets": 3,
        //         "width": "12",
        //         "className": "text-center"
        //     },
        // ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
    });


    if ($('#consignt-draft').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-draft-link").addClass("m-menu__item--active");
        
    }

    if ($('#rejected-consignmts').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".rejected-consignmts-link").addClass("m-menu__item--active"); 
    }

    if ($('#consgnmnt-apvals').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consgnmnt-apvals-link").addClass("m-menu__item--active"); 
    }

    if ($('#consgnmnt-invice-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consgnmnt-invice-link").addClass("m-menu__item--active"); 
    }

    if ($('#movenment-menu-draft-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-draft-link").addClass("m-menu__item--active"); 
    }

    if ($('#movenment-menu-rejected-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-rejected-link").addClass("m-menu__item--active"); 
    }

    if ($('#movenment-menu-verification-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-verification-link").addClass("m-menu__item--active"); 
    }

    if ($('#movenment-menu-train-intransit-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-train-intransit-link").addClass("m-menu__item--active"); 
    }

    if ($('#movenment-menu-detached-wagon-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movenment-menu-detached-wagon-link").addClass("m-menu__item--active"); 
    }

    if ($('#fuel-requisite-menu-new-requisite-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-new-requisite-link").addClass("m-menu__item--active"); 
    }

    if ($('#fuel-requisite-menu-rejected-requisite-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-rejected-requisite-link").addClass("m-menu__item--active"); 
    }

    if ($('#fuel-requisite-menu-approval-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-approval-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-menu-approval-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-tracking-new-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-new-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-tracking-bulk-upload-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-bulk-upload-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-tracking-upload-errors-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-upload-errors-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-tracking-list-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-tracking-list-link").addClass("m-menu__item--active"); 
    }

    if ($('#new-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".new-interchange").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-material').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-material").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-tracking-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-tracking-link").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-foreign-tracking-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-tracking-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-foreign-tracking-link").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing-auxiliary-hire-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing-auxiliary-hire-link").addClass("m-menu__item--active"); 
    }

    if ($('#incoming-auxiliary-hire-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming-auxiliary-hire-link").addClass("m-menu__item--active"); 
    }

    if ($('#auxiliary-hire-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-link").addClass("m-menu__item--active"); 
    }
    
    if ($('#auxiliary-tracking-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-tracking-link").addClass("m-menu__item--active"); 
    }

    if ($('#incoming-on-hire-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-incoming-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming-on-hire-interchange").addClass("m-menu__item--active"); 
    }

    if ($('#incoming-off-hire-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-incoming-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming-off-hire-interchange").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing-on-hire-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-outgoing-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing-on-hire-interchange").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing-off-hire-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-outgoing-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing-off-hire-interchange").addClass("m-menu__item--active"); 
    }
  
    if ($('#incoming-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-on-hire-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming-interchange").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing-interchange').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-on-hire-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing-interchange").addClass("m-menu__item--active"); 
    }     

    if ($('#company-info-link').length) {
        $(".company-info-link").addClass("m-menu__item--active"); 
    }

    if ($('#system-users-link').length) {
        $(".user-management-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".system-users-link").addClass("m-menu__item--active"); 
    }

    if ($('#user-regions-link').length) {
        $(".user-management-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".user-regions-link").addClass("m-menu__item--active"); 
    }

    if ($('#user-roles-link').length) {
        $(".user-management-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".user-roles-link").addClass("m-menu__item--active"); 
    }
  
    if ($('#loco-drivers-link').length) {
        $(".user-management-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-drivers-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-position-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-position-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-summary-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-summary-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-allocation-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-allocation-report-link").addClass("m-menu__item--active"); 
    }
    
    if ($('#yard-postion-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".yard-postion-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#wagon-condition-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-condition-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#wagon-delayed-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-delayed-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#bad-order-average-report-link').length) {
        $(".wagon-tracking-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".bad-order-average-report-link").addClass("m-menu__item--active"); 
    }         
    
    if ($('#consignment-list-report-link').length) {
        $(".consignment-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-list-report-link ").addClass("m-menu__item--active"); 
    }  

    if ($('#consignment-matching-report-link').length) {
        $(".consignment-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-matching-report-link").addClass("m-menu__item--active"); 
    } 
    
    if ($('#consignment-haulage-invoice-report-link').length) {
        $(".consignment-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-haulage-invoice-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#consignment-unmatched-aging-report-link').length) {
        $(".consignment-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-unmatched-aging-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#consignment-monthly_income-report-link').length) {
        $(".consignment-reports-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment-monthly_income-report-link").addClass("m-menu__item--active"); 
    }      

    if ($('#movement-train-list-report-link').length) {
        $(".movement-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement-train-list-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#movement-monthly_income-report-link').length) {
        $(".movement-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement-monthly_income-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#movement-monthly_income-report-link').length) {
        $(".movement-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement-monthly_income-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#fuel-requisite-list-link').length) {
        $(".fuel-monitoring-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-requisite-list-link").addClass("m-menu__item--active"); 
    }  

    if ($('#fuel-exco-report-link').length) {
        $(".fuel-monitoring-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-exco-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#depo-summary-report-link').length) {
        $(".fuel-monitoring-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".depo-summary-report-link").addClass("m-menu__item--active"); 
    }  

    if ($('#section-summary-report-link').length) {
        $(".fuel-monitoring-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".section-summary-report-link").addClass("m-menu__item--active"); 
    }  
    
    if ($('#locomotive-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-link").addClass("m-menu__item--active"); 
    }      
 
    if ($('#locomotive-model-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-model-link").addClass("m-menu__item--active"); 
    }    

    if ($('#locomotive-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".locomotive-type-link").addClass("m-menu__item--active"); 
    }    
 
    if ($('#commodity-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".commodity-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".commodity-link").addClass("m-menu__item--active"); 
    }    

    if ($('#commodity-group-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".commodity-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".commodity-group-link").addClass("m-menu__item--active"); 
    }   

    if ($('#wagon-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-list-link").addClass("m-menu__item--active"); 
    }   

    if ($('#wagon-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-type-link").addClass("m-menu__item--active"); 
    }   

    if ($('#wagon-status-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-status-link").addClass("m-menu__item--active"); 
    }   

    if ($('#condition-category-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".condition-category-link").addClass("m-menu__item--active"); 
    }   
      
    if ($('#wagon_condition-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon_condition-list-link").addClass("m-menu__item--active"); 
    }   

    if ($('#spare-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".equipments-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".spare-list-link").addClass("m-menu__item--active"); 
    }   
    
    if ($('#spare-fee-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".equipments-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".spare-fee-list-link").addClass("m-menu__item--active"); 
    }   

    if ($('#equipment-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchnage-equipments-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".equipment-list-link").addClass("m-menu__item--active"); 
    }   
    
    if ($('#equipment-rate-list-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchnage-equipments-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".equipment-rate-list-link").addClass("m-menu__item--active"); 
    }   
    
    if ($('#stations-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".stations-link").addClass("m-menu__item--active"); 
    } 
    
    if ($('#fuel-rates-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".fuel-rates-link").addClass("m-menu__item--active"); 
    }   
    
    if ($('#train-route-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".train-route-link").addClass("m-menu__item--active"); 
    }
    
    if ($('#region-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".region-link").addClass("m-menu__item--active"); 
    }   

    if ($('#railway-administrator-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".railway-administrator-link").addClass("m-menu__item--active"); 
    }   

    if ($('#country-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".country-link").addClass("m-menu__item--active"); 
    }  
    
    if ($('#transport-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".transport-type-link").addClass("m-menu__item--active"); 
    } 

    if ($('#currency-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".currency-link").addClass("m-menu__item--active"); 
    } 

    if ($('#payment-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".payment-type-link").addClass("m-menu__item--active"); 
    } 

    if ($('#interchange-fee-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagons-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-fee-link").addClass("m-menu__item--active"); 
    } 

    if ($('#exchange-rate-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".exchange-rate-link").addClass("m-menu__item--active"); 
    } 

    if ($('#tariff_line-rates-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".tariff_line-rates-link").addClass("m-menu__item--active"); 
    } 

    if ($('#distance-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".distance-link").addClass("m-menu__item--active"); 
    } 

    if ($('#surchage-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".surchage-link").addClass("m-menu__item--active"); 
    } 

    if ($('#clients-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".clients-link").addClass("m-menu__item--active"); 
    } 

    if ($('#defect-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".defects-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".defect-link").addClass("m-menu__item--active"); 
    } 

    if ($('#defect-link-intl').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".defects-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".defect-link-intl").addClass("m-menu__item--active"); 
    } 

    if ($('#train-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".train-type-link").addClass("m-menu__item--active"); 
    } 

    if ($('#section-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".section-link").addClass("m-menu__item--active"); 
    } 

    if ($('#refueling-type-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".refueling-type-link").addClass("m-menu__item--active"); 
    } 

    if ($('#notification-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".notification-link").addClass("m-menu__item--active"); 
    } 

    if ($('#domain-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".domain-link").addClass("m-menu__item--active"); 
    } 

    if ($('#loco-detention-rate-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-rate-link").addClass("m-menu__item--active"); 
    } 

    if ($('#haulage-rate-link').length) {
        $(".sys-maintenance-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".haulage-rate-link").addClass("m-menu__item--active"); 
    } 

    if ($('#dashbaord-link').length) {
        $(".dashbaord-link").addClass("m-menu__item--active"); 
    } 

    if ($('#interchange-incoming-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-incoming-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-outgoing-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-outgoing-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-list-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-hire-report-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-list-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#customer_based_consignment_list').length) {
        $(".reports-export-menu ").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-consignment").addClass("m-menu__item--open m-menu__item--expanded");
        $(".customer_based_consignment_list").addClass("m-menu__item--active"); 
    }

    if ($('#consignment_haulage_report').length) {
        $(".reports-export-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-consignment").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment_haulage_report").addClass("m-menu__item--active"); 
    }

    if ($('#movement_haulage_report').length) {
        $(".reports-export-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-movement").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement_haulage_report").addClass("m-menu__item--active"); 
    }

    if ($('#movement_recon_report').length) {
        $(".reports-export-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-movement").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement_recon_report").addClass("m-menu__item--active"); 
    }

    if ($('#movement_wagon_querry_report').length) {
        $(".reports-export-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-movement").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement_wagon_querry_report").addClass("m-menu__item--active"); 
    }

    if ($('#movement_customer_based_report').length) {
        $(".reports-export-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-movement").addClass("m-menu__item--open m-menu__item--expanded");
        $(".movement_customer_based_report").addClass("m-menu__item--active"); 
    }

    if ($('#incoming_auxiliary_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-report").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming_auxiliary_report").addClass("m-menu__item--active"); 
    }
    
    if ($('#auxiliary-daily-summary-report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-report").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-daily-summary-report").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing_auxiliary_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".auxiliary-hire-report").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing_auxiliary_report").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-incoming-wagons-report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".material-supply-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-incoming-wagons-report").addClass("m-menu__item--active"); 
    }

    if ($('#interchange-outgoing-wagons-report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".material-supply-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-outgoing-wagons-report").addClass("m-menu__item--active"); 
    }

    if ($('#consignment_wagon_querry_report').length) {
        $(".reports-export-menu ").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-consignment").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment_wagon_querry_report").addClass("m-menu__item--active"); 
    }
         
    if ($('#consignment_recon_report').length) {
        $(".reports-export-menu ").addClass("m-menu__item--open m-menu__item--expanded");
        $(".reports-export-menu-consignment").addClass("m-menu__item--open m-menu__item--expanded");
        $(".consignment_recon_report").addClass("m-menu__item--active"); 
    }

    if ($('#incoming-loco-detention').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming-loco-detention").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing-loco-detention').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing-loco-detention").addClass("m-menu__item--active"); 
    }

    if ($('#new-loco-detention').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-menu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".new-loco-detention").addClass("m-menu__item--active"); 
    }

    if ($('#incoming_detention_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming_detention_report").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing_detention_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing_detention_report").addClass("m-menu__item--active"); 
    }

    if ($('#summary_detention_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".loco-detention-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".summary_detention_report").addClass("m-menu__item--active"); 
    }

    if ($('#incoming_haulage_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".haulage-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".incoming_haulage_report").addClass("m-menu__item--active"); 
    }

    if ($('#outgoing_haulage_report').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".haulage-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".outgoing_haulage_report").addClass("m-menu__item--active"); 
    }

    if ($('#new-haulage-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".new-haulage-link").addClass("m-menu__item--active"); 
    } 
    
    if ($('#interchange-exceptions-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".Interchange-menu-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".interchange-exceptions-link").addClass("m-menu__item--active"); 
    } 

    if ($('#mechanical-bills-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".mechanical-bills-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#wagon-turn-around-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".wagon-turn-around-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#current-acc-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".current-acc-report-link").addClass("m-menu__item--active"); 
    }
    if ($('#current-acc-summary-report-link').length) {
        $(".interchange-report-link").addClass("m-menu__item--open m-menu__item--expanded");
        $(".current-acc-summary-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#demurrage-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".demurrage-link").addClass("m-menu__item--active");
    } 

    if ($('#demurrage-report-link').length) {
        $(".demurrage-report-link").addClass("m-menu__item--active"); 
    }

    if ($('#works-order-link').length) {
        $(".main_manu").addClass("m-menu__item--open m-menu__item--expanded");
        $(".works-order-link").addClass("m-menu__item--active");
    } 

    if ($('#works-order-report-link').length) {
        $(".works-order-report-link").addClass("m-menu__item--active"); 
    }
    
    // var current_url = window.location.pathname;
    // var current_link = $('a[href="'+ current_url +'"]');
    // if (current_link) {
    //     $(current_link).parent('li').addClass("m-menu__item--open m-menu__item--expanded");
    //     $(current_link).parent('li').parents('li').add(this).each(function() {
    //         $(this).addClass("m-menu__item--active");
    //     });
    // }


    //////////////////////////// Russell //////////////////////////////////////////

    $('#dt_cond_cat tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_cond_code').val(button.attr("data-code"));
        $('#edit_cond_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#dt_cond_cat tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#created_dt').val(button.attr("data-created"));
        $('#modified_dt').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
       $('#maker').val(capitalize(button.attr("data-maker")));
        $('#view_modal').modal('show');
    });

    // wagon position filter
    $('#position_date_filter').click(function() {

        $('#position_date_filter_model').modal('show');
    });



    var wagon_tracking_defects = $('#wagon_tracking_defects').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        columns: [
            { data: "code" },
            { data: "description" },
        ]
    });

    var wagon_tracking_spares = $('#wagon_tracking_spares').DataTable({
        responsive: true,
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        columns: [
            { data: "code" },
            { data: "spare" },
            { data: "quantity" },
            {
                data: "cost",
                "render": function ( data, type, row ) {
                    if (isNaN(data) == true){
                        return "<span></span>"
                    } else {
                        var cost = (row["quantity"] * data)
                        parseFloat(cost).toFixed(2);

                        return "<span>"+cost+"</span>"
                    }
                },
                "defaultContent": "<span></span>"
            },
        ]
    });

    $('#wagon_defects_lookup').click(function() {
        spinner.show();
        $.ajax({
            url: '/wagon/tracking/defects/lookup',
            type: 'post',
            data: {
                "wagon_id": $('#wagon_id').val(),
                "tracker_id": $('#tracker_id').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {
                spinner.hide();
                wagon_tracking_spares.clear().rows.add(result.spares).draw();
                wagon_tracking_defects.clear().rows.add(result.data).draw()
                $('#wagon-defects-model').modal('show');
            },
            error: function(request, msg, error) {
                spinner.hide();
                $('.loading').hide();
            }
        });
    });



    // wagon bad order report

    var dt_bad_order_ave_report = $('#dt-wagon-bad-order-report').DataTable({
        "responsive": true,
        "processing": true,
        "bFilter": false,
        "select": {
            "style": 'multi'
        },
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: ["copyHtml5", "excelHtml5", "csvHtml5", "pdfHtml5"],
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/wagon/bad/order/entries',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "bo_wagon_condition": $('#bo_wagon_condition').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),

            }
        },

        "columns": [{
                data: "date",
                "render": function(data, type, row) {
                    return 'Date: ' + row.date + 'Total: ' + row.grand_total;
                }
            },
            { data: "condition" },
            { data: "total_wagons" },
            { data: "curr_loaded" },
            { data: "commulative_loaded" },
            { data: "count_active" },
            { data: "non_act_count" },
            {
                data: "reliability",
                "render": function(data, type, row) {
                    return (parseFloat(data).toFixed(2));
                    if (data == nil) {
                        return "0";
                    }
                }
            },
            {
                data: "daily_utilization",
                "render": function(data, type, row) {
                    return (parseFloat(data).toFixed(2));
                }
            },
            {
                data: "utilization",
                "render": function(data, type, row) {
                    return (parseFloat(data).toFixed(2));
                }
            }

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
            },

            {
                "targets": [2, 3, 4, 5, 6, 7, 8],
                "className": "text-right",
            },
            {
                "targets": 1,
                "className": "text-right",
            },


        ],
        "drawCallback": function(settings) {
                var groupColumn = 0;
                var total = 0;
                var api = this.api();
                var rows = api.rows({ page: 'current' }).nodes();
                var data_rows = api.rows({ page: 'current' }).data();
                var last = null;

                api.column(groupColumn, { page: 'current' }).data().each(function(group, i) {
                    if (last !== group) {
                        data_rows.each(function(row, i) {
                            if (row.date == group) {
                                total += parseInt(row.total_wagons);
                            }
                        });
                        $(rows).eq(i).before(
                            '<tr class="group"><td colspan="9">Date: ' + group + '</td></tr>' +
                            '<tr class="group"><td colspan="9">Total: ' + total + '</td></tr>'
                        );
                        total = 0;
                        last = group;
                    }
                });
            }
            // "rowGroup": { dataSrc: ['date'], "font-weight": 800 }
    });


    // wagon position filter
    $('#bad_order_date_filter').click(function() {

        $('#bo_date_filter_model').modal('show');
    });

    $('#bo-average-report-filter').on('click', function() {
        dt_bad_order_ave_report.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.bo_wagon_condition = $('#bo_wagon_condition').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        $('#bo_date_filter_model').modal('hide');
        dt_bad_order_ave_report.draw();
    });

 ///-------------------------------movement without consignment --------------------------------////
    
    var mvt_no_cosignmt = [
        { "wagon_code": "", "invoice_no": "", "netweight": "", "origin_name": "", "destination_name": "", "commodity_name": "", "consigner_name": "", "consignee_name": "", "consignment_date": "", edited: false , "payer_name": ""}
    ];

    var mvt_no_consignmt_dt = $('#mvt_no_consignmt_dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        keys: true,
        bSort: false,
        data: mvt_no_cosignmt,
        'columnDefs': [
            {
                "targets": [6, 5, 4, 3],
                "width": "12%",
                "className": "text-center"
            },
            {
                "targets": [0, 1, 7, 8, 10],
                "width": "8%",
                "className": "text-center"
            },
            {
                "targets": [9, 2],
                "width": "6%",
                "className": "text-center"
            }
        ],
        columns: [
            { data: "wagon_code" },
            { data: "invoice_no" },
            { data: "netweight" },
            { data: "origin_name" },
            { data: "destination_name" },
            { data: "commodity_name" },
            { data: "consigner_name" },
            { data: "consignee_name" },
            { data: "payer_name" },
            { data: "consignment_date" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected_row m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'><i class='la la-trash'></i></a>" }
        ]
    });

    mvt_no_consignmt_dt.on('key-focus', function(e, datatable, cell, originalEvent) {
        cell.node().closest('td').click();
        $('input', cell.node()).focus();
        $('select', cell.node()).focus();

    }).on("focus", "td input", function() {
        $(this).select();
    });

    $("#mvt_no_consignmt_dt tbody").on("click", "tr td", function(e) {
        // table.row($(this).closest("tr")).remove().draw();
        if (editRow == 1)
            return false;

        var $row = $(this).closest("tr").off("click");
        var $tds = $row.find("td").not(':last');

        $.each($tds, function(index, el) {
            var txt = $(this).text();
            if (index == 0) {
                $(this).html("").append("<input type='text' class=\"form-control wagon_lookup row-input\" value=\"" + txt + "\">");
            } 
            else if (index == 1) {
                $(this).html("").append("<input type='text' class=\"form-control invoice_lookup row-input\" value=\"" + txt + "\">");
            }
            else if (index == 2) {
                $(this).html("").append("<input type='text' class=\"form-control row-input\" value=\"" + txt + "\">");
            }else if (index == 3) {

                $(this).html("").append('<select  name="origin_station_id" id="vw-origin" class="form-control origin_station style="width:50px !important;" >' + originOptions + '</select>');
            } else if (index == 4) {

                $(this).html("").append('<select  name="destin_station_id" id="final_destination_id" class="form-control destin_station" >' + destinOptions + '</select>');
            } else if (index == 5) {

                $(this).html("").append('<select required name="commodity_id" id="vw-commodity" class="form-control commodity">' + commodityOptions + '</select>');
            } else if (index == 6) {

                $(this).html("").append('<select  name="consigner" class="form-control form-control">' + consignerOptions + '</select>');
            } else if (index == 7) {

                $(this).html("").append('<select  name="consignee" class="form-control form-control-bg clear_form field-clr">' + consignerOptions + '</select>');  
            } else if (index == 8) {

                $(this).html("").append('<select  name="payer" class="form-control form-control-bg clear_form field-clr">' + payerOptions + '</select>');  
            }else if (index == 9) {

                $(this).html("").append("<input type='date' class=\"form-control row-input\">");
            }  
            else {
                $(this).html("").append("<input type='text' class=\"form-control row-input\">");
            }
        });

        if(editRow < 0){
            editRow = 0;
        } else {
            editRow = 1;
        }
    })

    $("#mvt_no_consignmt_dt tbody").on('input', ".wagon_lookup", function(e) {

        var $select = $(this);
        var $row = $(this).closest("tr");
        var $tds = $row.find("td").not(':last');
        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $(".wagon_lookup").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    WagonID ="";
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").css("color", "#fa050d");
                        }
                        else
                        {
                            return false;
                        }
                    });
                    
                } else {
                    WagonID = result.data[0].id
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            $(this).find("input").css("color", "#09e850");
                        }else
                        {
                            return false;
                        }
                    });
                }
                
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                editRow == -1
            
            }
        });

    });

    if ($('#newRow').length) {
        var rowmvt_no_cosignmt = $("#newRow").find("tr")[0].outerHTML;
    }

    $("#mvt_no_consignmt_dt tbody").on('input', ".invoice_lookup", function(e) {
        var $select = $(this);
        var $row = $(this).closest("tr");
        var $tds = $row.find("td").not(':first').not(':last');
        if ( $(".invoice_lookup").val() == "") {
            return false;
        }
        if ( WagonID == null) {
            Swal.fire(
                'Oops...',
                'wagon number has not been entered',
                'error'
            )
            return false;
        }
    
        $.ajax({
            url: '/find/invoice/no',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                station_code: $(".invoice_lookup").val(),
                wagon_id: WagonID
            },
            success: function(result) {
                
                if (result.data == null) {
                    $.each($tds, function(index, el) {
                        if (index == 0) {
                            // $(this).find("input").val("uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu");  
                        } else if (index == 1) {
                            $(this).find("input").val("0");
                        }
                        else if (index == 2) {
                            $(this).find("select").val([]);
                        }
                        else if (index == 3) {
                            $(this).find("select").val([]);
                        }
                        else if (index == 4) {
                            $(this).find("select").val([]);
                        }
                        else if (index == 5) {
                            $(this).find("select").val([]); 
                        }
                        else if (index == 6) {
                            $(this).find("select").val([]);
                        }
                        else if (index == 7) {
                            $(this).find("select").val([]);
                        }
                        else if (index == 8) {
                            $(this).find("input").val("");

                        }else
                        {
                            return false;
                        }
                    });
                } else {
                    $.each($tds, function(index, el) {
                        
                        if (index == 0) {
                            // $(this).find("input").val("uuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuuu");  
                        } else if (index == 1) {
                            $(this).find("input").val(result.data.actual_tonnes);
                        }
                        else if (index == 2) {
                            $(this).find("select").val(result.data.origin_station_id);
                        }
                        else if (index == 3) {
                            $(this).find("select").val(result.data.final_destination_id);
                        }
                        else if (index == 4) {
                            $(this).find("select").val(result.data.commodity_id);
                        }
                        else if (index == 5) {
                            $(this).find("select").val(result.data.consigner_id); 
                        }
                        else if (index == 6) {
                            $(this).find("select").val(result.data.consignee_id);
                        }
                        else if (index == 7) {
                            $(this).find("select").val(result.data.payer_id);
                        }
                        else if (index == 8) {
                            $(this).find("input").val(result.data.document_date);

                        }else
                        {
                            return false;
                        }
                    });
                }
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                editRow == -1
            
            }
        });

    });
   
    $("#mvt_no_consignmt_dt tbody").on('keyup', ".row-input", function(e) {
        if (e.keyCode == 13) {

            var $row = $(this).closest("tr");
            var $tds = $row.find("td").not(':last');
            var total_mvt = mvt_no_consignmt_dt.rows().data().length;
            var rowIndex = mvt_no_consignmt_dt.row($row).index();
            var edited = false;
            // var wagonId = null;
            var origin_station_id = null;
            var destin_station_id = null;
            var commodity_id = null;
            var consignee_id = null;
            var consigner_id = null;
            var invoice_no = null;
            var payer_id = null;

            $.each($tds, function(index, el) {
                var $this = $(this);
                var txt = (index == 3 || index == 4 || index == 5 || index == 6 || index == 7  || index == 8 ? $this.find("select").find(':selected').text() : $this.find("input").val());
                
                // wagonId = index == 0 ? $this.find("select").val() : wagonId;
                origin_station_id = index == 3 ? $this.find("select").val() : origin_station_id;
                destin_station_id = index == 4 ? $this.find("select").val() : destin_station_id;
                
                commodity_id = index == 5 ? $this.find("select").val() : commodity_id;
                consigner_id = index == 6 ? $this.find("select").val() : consigner_id;
                consignee_id = index == 7 ? $this.find("select").val() : consignee_id;
                payer_id = index == 8 ? $this.find("select").val() : payer_id;
                // invoice_no = index == 8 ? $this.find("input").val() : invoice_no;

                if ((txt.trim().length < 1) && (index == 0)) {
                    Swal.fire(
                        'Oops...',
                        'you have not entered the wagon number',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                if ((txt.trim().length < 1) && (index == 3)) {
                    Swal.fire(
                        'Oops...',
                        'You have not selected the origin station',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                if ((txt.trim().length < 1) && (index == 4)) {
                    Swal.fire(
                        'Oops...',
                        'You have not selected the destination station',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                if ((txt.trim().length < 1) && (index == 5)) {
                    Swal.fire(
                        'Oops...',
                        'You have not selected the commodity',
                        'error'
                    )
                    edited = false;
                    return false;
                }
                edited = true;
                mvt_no_consignmt_dt.cell({ row: rowIndex, column: index }).data(txt).draw();
            });
            var total_ton = Number(mvt_no_consignmt_dt.column(2).data().sum()).toFixed(2);
            $("#mvt_total_ton").text(total_ton);
            var rowData = mvt_no_consignmt_dt.row($row).data();
            rowData.edited = edited;
            rowData.wagon_id =  WagonID;
            rowData.destin_station_id = destin_station_id;
            rowData.origin_station_id = origin_station_id;
            rowData.consignee_id = consignee_id;
            rowData.customer_id = consignee_id;
            rowData.consigner_id = consigner_id;
            rowData.payer_id = payer_id;
            rowData.commodity_id = commodity_id;
            if (commodity_id == "12551") {
                rowData.consignee_id = "";
                rowData.consigner_id = "";
                rowData.payer_id = "";
                rowData.customer_id = "";
            }
            editRow = 0;
            
            mvt_no_consignmt_dt.row($row).data(rowData).draw();
            editRow = 0;
            if ((mvt_no_consignmt_dt.row($row).index() == total_mvt - 1) && mvt_no_consignmt_dt.row($row).data().edited) {
                mvt_no_consignmt_dt.row.add($(rowmvt_no_cosignmt)).draw();
                var wagon = count= mvt_no_consignmt_dt.rows().count() - 1
                $("#total_wagon_count").text(wagon);
            }
        }
        
    });

    $('#mvt_no_consignmt_dt tbody').on('click', '.remove_selected_row', function() {
        if(mvt_no_consignmt_dt.rows().count() < 2)
        return false;

        var $tr = $(this).closest('tr');
        mvt_no_consignmt_dt.row($tr).remove().draw(false);
        var wagon = count= mvt_no_consignmt_dt.rows().count() - 1
        $("#total_wagon_count").text(wagon);
        editRow = -1;

        var total_ton = Number(mvt_no_consignmt_dt.column(2).data().sum()).toFixed(2);
        $("#mvt_total_ton").text(total_ton);
            
    });

    $('#save-movement-no-consgnmt').click(function() {

        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (mvt_no_consignmt_dt.rows().count() < 2) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }
        var data_row = [];
        for (let index = 0; index < (mvt_no_consignmt_dt.rows().count()); index++) {
            data_row.push(Object.assign(mvt_no_consignmt_dt.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/submit/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), loco_no: $("#loco_id").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement order submited for approval!',
                                'success'
                            )
                            $(".select2_form option:selected").remove();
                            $('.m-select2').val(null).trigger("change")
                            $('.clear_form').val('');
                            $("#total_wagon_count").text("0");
                            mvt_no_consignmt_dt.clear().rows.add([]).draw();
                            window.location.replace("/dashboard"); 
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

    //--------------------------------edit movement entries------------------------------------------//
    
    var mvt_modify_dt = $('#mvt_modify_dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        responsive: true,
        bSort: false,
        'columnDefs': [
            {
                "targets": [0, 6, 5, 4, 3],
                "width": "12%",
                "className": "text-center"
            },
            {
                "targets": [1, 2, 7, 9],
                "width": "8%",
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
            { data: "invoice_no"},
            {
                data: "id",
                "render": function(data, type, row) {

                    return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill edit" title= "Edit "> <i class= "la la-edit "></i></a>'

                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "60",
                "className": "text-center"
            },
        ]
    });

    if ($('#modify_movement_entries').length) {

        spinner.show();
        $.ajax({
            url: '/movement/batch/entries/lookup',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                status: $("#entries_type").val(),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                mvt_modify_dt.clear().rows.add(result.data).draw();
                var wagon = count= mvt_modify_dt.rows().count()
                $("#total_wagon_count").text(wagon);
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

    $('#mvt_modify_dt tbody').on('click', '.edit', function() {
        var button = $(this);
        $('.clear_select').val(null).trigger("change")
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/movement/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),

            },
            success: function(results) {
                spinner.hide();
                result = results.data
                $('#mvt_wagon_code').val(result.wagon_code);
                $('#wagon_owner').val(result.wagon_owner);
                $('#wagon_type').val(result.wagon_type);
                $('#consignee').val(result.consignee_id);
                $('#commodity_id').val(result.commodity_id);
                $('#consigner').val(result.consigner_id);
                $('#payer_name').val(result.payer_id);
                $('#destin_station_id').val(result.destin_station_id); 
                $('#origin_station_id').val(result.origin_station_id);
                $('#consignment_date').val(result.consignment_date);
                $('#invoice').val(result.invoice_no);
                $('#mvt_id').val(button.attr("data-id"));
                $('#wagon_id').val(result.wagon_id);
                $('#edit_movement').modal('show');
              
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

    $("#mvt_wagon_code").on("input", function() {
        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $("#mvt_wagon_code").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    $('#wagon_owner').val("");
                    $('#new_wagon_owner').val("");
                    $('#wagon_type').val("");
                    $('#wagon_id').val("");
                    $('#wagon_capacity').val("");
    
                } else {
                    $('#wagon_owner').val(result.data[0].wagon_owner);
                    $('#new_wagon_owner').val(result.data[0].wagon_owner);
                    $('#wagon_type').val(result.data[0].wagon_type);
                    $('#wagon_id').val(result.data[0].id); 
                    $('#wagon_capacity').val(result.data[0].capacity);
                }
            },
            error: function(request, msg, error) {
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#modify-mvt-entry').click(function() {

        if (($('#wagon_id').val() == "")) {
            swal({
                title: "Opps",
                text: "Fields Can not be blank!",
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
                    url: '/update/movement/batch/item',
                    type: 'post',
                    data: { id: $("#mvt_id").val(), 
                            commodity_id: $("#commodity_id").val(), 
                             _csrf_token: $("#csrf").val(), 
                            payer_id: $("#payer_name").val(), 
                            consignee_id: $("#consignee").val(),
                            consigner_id: $("#consigner").val(), 
                            destin_station_id: $("#destin_station_id").val(), 
                            origin_station_id: $("#origin_station_id").val(), 
                            consignment_date: $("#consignment_date").val(), 
                            wagon_id: $("#wagon_id").val(), 
                            invoice_no: $("#invoice").val()
                         },
            
                    success: function(result) {
                        spinner.hide();
                        $('#edit_movement').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Entry updated Successfully!',
                                'success'
                            )
                            location.reload();
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
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('#update-movement-batch').click(function() {

        var details = {};
        $.each($('.entry_data').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        if (mvt_modify_dt.rows().count()  < 1) {
            Swal.fire(
                'Oops..!',
                'No movement order found!',
                'error'
            )
            return false;
        }

        var data_row = [];
        for (let index = 0; index < (mvt_modify_dt.rows().count()); index++) {
            data_row.push(Object.assign(mvt_modify_dt.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/update/movement/entries',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val(), batch_id: $("#batch_id").val(), loco_no: $("#loco_id").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Movement updated successfully!',
                                'success'
                            )
                            location.reload();
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


    //----------------------------edit consignment------------------------------//

    var modify_consign_dt = $('#modify-consign-dt').DataTable({
        bLengthChange: false,
        responsive: true,
        bPaginate: false,
        bFilter: false,
        bInfo: false,
        orderable: !0,
        bSort: false,
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "wagon_type" },
            { data: "capacity_tonnes" },
            { data: "actual_tonnes" },
            { data: "tariff_tonnage" },
            { data: "container_no" },
            { data: "total" },
            { data: "comment" },
            {
                data: "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-id = "' + data + '" data-comment = "' + row["comment"] + '" data-container_no = "' + row["container_no"] +'" data-actual_tonnes = "'+ row["actual_tonnes"] +'" data-tariff_tonnage = "'+ row["tariff_tonnage"] +'" data-capacity_tonnes ="'+ row["capacity_tonnes"] +'" data-wagon = "'+ row["wagon_code"] +'" data-wagon-type = "'+ row["wagon_type"] +'" data-wagon-owner = "'+ row["wagon_owner"] +'" data-wagon-id = "'+ row["wagon_id"] +'"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill edit" title= "Edit "> <i class= "la la-edit "></i></a>'

                  
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "12",
                "className": "text-center"
            },
        ]
    });

    if ($('#edit-consignment-batch').length) {
        spinner.show();
        $.ajax({
            url: '/consignment/sales/order/batch/entries',
            type: 'POST',
            data: {
                batch_id: $("#batch_id").val(),
                status: $("#status").val(),
                _csrf_token: $("#csrf").val(),
                client_id: $('#consignment-batch').val(),
                orign_station: $('#origin_tariff_id').val(),
                destin_station: $('#destin_tariff_id').val(),
                tarriff_id: $('#tarriff_id').val(),

            },
            success: function(result) {
                spinner.hide();
                $(".disable-fields").prop('readonly', true);
                if (result.data.length < 1) {

                    modify_consign_dt.clear().rows.add([]).draw();
                    modify_consign_dt.clear().rows.add([]).draw();

                } else {
                    consignment = result.data;
                    rate = result.rate;

                    modify_consign_dt.clear().rows.add(consignment).draw();
                    dt_tariff_lines_rates.clear().rows.add(rate).draw();
                    var total_amount = modify_consign_dt.column(7).data().sum()
                    var surcharge = total_amount * $('#surcharge-percent').val()

                    $.each(modify_consign_dt.rows().data(), function(index, wagon) {
                        var order_sum = !isNaN(wagon["tariff_tonnage"]) && (Number(wagon["tariff_tonnage"]) > 0) ? wagon["tariff_tonnage"] :  wagon["actual_tonnes"];
                        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
                            item.total = item.total + (item["rate"] * order_sum)
                            item.total = Number(item.total.toFixed(2));
                            dt_tariff_lines_rates.row(index).data(item).draw();
                        });
                    });

                    var total_ton = 0;
                    $.each(modify_consign_dt.rows().data(), function(index, item) {
                        if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                            total_ton =  total_ton + Number(item["tariff_tonnage"]);
                        } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                            total_ton =  total_ton +  Number(item["actual_tonnes"]);
                        }
                    });

                    $('#wagon_count').val(modify_consign_dt.rows().count());
                    $('#total_tonnage').val(Number(total_ton).toFixed(3));
                    $('#total_amount').val(Number(total_amount).toFixed(2));
                    $('#surcharge_total').val(Number(surcharge).toFixed(2))
                  

                    if ($('#edit-vat').val() == 'YES') {
                        $("#vat").attr('checked', 'checked');
                        var vat = total_amount * $('#vat-percentage').val()
                        $('#vat_total').val(Number(vat).toFixed(2));
                        $('#overall_total').val(Number(total_amount + surcharge + vat).toFixed(2));

                    } else {

                        $("#no_vet").attr('checked', 'checked');
                        $('#overall_total').val(Number(total_amount + surcharge).toFixed(2));

                    }

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

    $('#modify-consign-dt tbody').on('click', '.edit', function() {
        var button = $(this);
        $('.field-clr').val('');
        var comment ="";
        if (button.attr("data-comment") != 'null') {
        comment = button.attr("data-comment")
        }
        $('#cons_wagon_code').val(button.attr("data-wagon"));
        $('#wagon_owner').val(button.attr("data-wagon-owner"));
        $('#wagon_type').val(button.attr("data-wagon-type"));
        $('#wagon_capacity').val(button.attr("data-capacity_tonnes"));
        $('#comment').val(comment);
        $('#container_no').val(button.attr("data-container_no"));
        $('#actual_tonnes').val(button.attr("data-actual_tonnes"));
        $('#consign_id').val(button.attr("data-id")); 
        $('#tariff_tonnage').val(button.attr("data-tariff_tonnage"));
        $('#wagon_id').val(button.attr("data-wagon-id"));
        $('#edit_order').modal('show');
    });

    $('#modify-consign-entry').click(function() {

        if (($('#wagon_id').val() == "")) {
            swal({
                title: "Opps",
                text: "Fields Can not be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        var wagon_total = 0;

        $.each(dt_tariff_lines_rates.rows().data(), function(index, item) {
            if (!isNaN( $('#tariff_tonnage').val()) && (Number($('#tariff_tonnage').val()) > 0)) {
                var wagon_amount = item["rate"] *  $('#tariff_tonnage').val();
                wagon_total = wagon_amount + wagon_total;
    
            } else if (!isNaN($('#actual_tonnes').val()) && (Number($('#actual_tonnes').val()) > 0)) {
                var wagon_amount = item["rate"] * $('#actual_tonnes').val();
                wagon_total = wagon_amount + wagon_total;
                
            } else {
                return false;
            }
        });

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
                    url: '/update/consignment/batch/item',
                    type: 'post',
                    data: { id: $("#mvt_id").val(), 
                             _csrf_token: $("#csrf").val(), 
                            actual_tonnes: $('#actual_tonnes').val(),
                            tariff_tonnage: $('#tariff_tonnage').val(),
                            wagon_id: $("#wagon_id").val(), 
                            comment: $("#comment").val(),
                            container_no: $("#container_no").val(),
                            id: $('#consign_id').val(),
                            total: wagon_total
                         },
            
                    success: function(result) {
                        spinner.hide();
                        $('#edit_movement').modal('hide');
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Entry updated Successfully!',
                                'success'
                            )
                            location.reload();
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
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    $('.apply_vat_edit').click(function() {

        if (dt_tariff_lines_rates.rows().count() <= 0) {
             return false;
        } else {
           
            var value = $("input[type=radio][name=vat_applied]:checked").val();

            if (value == 'YES') {
                var vat = (parseFloat($("#vat-percentage").val()) * modify_consign_dt.column(7).data().sum());
                $('#vat_total').val(Number(vat).toFixed(2));
                var surcharge = parseFloat($('#surcharge_total').val());
                var amount = parseFloat($('#total_amount').val());

                $('#overall_total').val(Number(parseFloat(vat) + surcharge + amount).toFixed(2));
            } else {
                var surcharge = parseFloat($('#surcharge_total').val());
                var amount = parseFloat($('#total_amount').val());
                $('#vat_total').val("");
                $('#overall_total').val(Number(surcharge + amount).toFixed(2));

            }
        }

    });

    $('.tariff-lookup-edit').on('change', function() {
     
        if ($('#origin_tariff').val().length < 1 || $('#destin_tariff').val().length < 1 || $('#client_id').val().length < 1 || $('#commodity_type').val().length < 1 || $('#document_date').val().length < 1 ) {
            return false;
        }

        $.ajax({
            url: '/tariff/line/lookup',
            type: 'post',
            data: {
                "client_id": $('#client_id').val(),
                "orign_station": $('#origin_tariff').val(),
                "destin_station": $('#destin_tariff').val(),
                "commodity": $('#commodity_type').val(),
                "date": $('#document_date').val(),
                "_csrf_token": $("#csrf").val()
            },
            success: function(result) {

                if (result.data.length < 1) {

                    dt_tariff_lines_rates.clear().rows.add([]).draw();
                    $('#surcharge-percent').val('');
                    $('#tarrif_id').val('');
                    $('#overall_total').val('');
                    $('#total_amount').val('');
                    $('#surcharge_total').val('');
                    $('#total_tonnage').val('');
                    surcharge_rate = 0

                } else {

                    var surcharge_percent = result.data[0].surcharge > 0 == true ? (result.data[0].surcharge / 100) : 0;
                    var tarriff_id = result.data[0].id > 0 == true ? (result.data[0].id) : ""
                    $('#tarrif_id').val(tarriff_id);

                    surcharge_rate = Number(surcharge_percent).toFixed(2)
                    $('#surcharge-percent').val(Number(surcharge_percent).toFixed(2));
                    dt_tariff_lines_rates.clear().rows.add(result.data).draw();

                    $.each(modify_consign_dt.rows().data(), function(index, wagon) {
                        var total_amt = 0;
                        var order_sum = !isNaN(wagon["tariff_tonnage"]) && (Number(wagon["tariff_tonnage"]) > 0) ? wagon["tariff_tonnage"] :  wagon["actual_tonnes"];
                        $.each(dt_tariff_lines_rates.rows().data(), function(index_rate, item) {
                            total_amt = (item["rate"] * order_sum) + total_amt
                            item.total = item.total + (item["rate"] * order_sum)
                            item.total = Number(item.total.toFixed(2));
                            dt_tariff_lines_rates.row(index_rate).data(item).draw();
                          
                        });
                        wagon.total = total_amt
                        wagon.total =  Number(wagon.total.toFixed(2));
                        modify_consign_dt.row(index).data(wagon).draw();
                    });

                    var total_amount = modify_consign_dt.column(7).data().sum()
                    var surcharge = total_amount * $('#surcharge-percent').val()
                    var total_ton = 0;
                    $.each(modify_consign_dt.rows().data(), function(index, item) {
                        if ((!isNaN(item["tariff_tonnage"])) && (Number(item["tariff_tonnage"]) > 0)) {
                            total_ton =  total_ton + Number(item["tariff_tonnage"]);
                        } else if ((!isNaN(item["actual_tonnes"])) && (Number(item["actual_tonnes"]) > 0)) {
                            total_ton =  total_ton +  Number(item["actual_tonnes"]);
                        }
                    });

                    $('#wagon_count').val(modify_consign_dt.rows().count());
                    $('#total_tonnage').val(Number(total_ton).toFixed(3));
                    $('#total_amount').val(Number(total_amount).toFixed(2));
                    $('#surcharge_total').val(Number(surcharge).toFixed(2))
                  

                    if ($('#edit-vat').val() == 'YES') {
                        $("#vat").attr('checked', 'checked');
                        var vat = total_amount * $('#vat-percentage').val()
                        $('#vat_total').val(Number(vat).toFixed(2));
                        $('#overall_total').val(Number(total_amount + surcharge + vat).toFixed(2));

                    } else {

                        $("#no_vet").attr('checked', 'checked');
                        $('#overall_total').val(Number(total_amount + surcharge).toFixed(2));

                    }

                }

            },
            error: function(request, msg, error) {
                $('.loading').hide();
            }
        });
    });

    $('#update-consignment-order').click(function() {
        
        if (modify_consign_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No consignment order found!',
                'error'
            )
            return false;
        }

        if (dt_tariff_lines_rates.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'Tarriff Rate found!',
                'error'
            )
            return false;
        }
        
        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];

        for (let index = 0; index < (modify_consign_dt.rows().count()); index++) {
            data_row.push(Object.assign(modify_consign_dt.rows().data()[index], details));
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/update/consignment/order/entries',
                    type: 'post',
                    data: {entries: data_row, _csrf_token: $("#csrf").val(), batch: $('#batch_id').val()},
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Consignment order updated successfully!',
                                'success'
                            )
                            location.reload();
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


        //  Equipments table

    var equipment_dt = $('#equipment-dt').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Equipments",
                filename: "Equipment List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Equipments",
                filename: "Equipment List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Equipments",
                filename: "Equipment List",
                exportOptions: {
                    columns: [ 0, 1, 2]
                }
            }
        ],
    });

    $('#equipment-dt tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_code').val(button.attr("data-code"));
        $('#edit_description').val(button.attr("data-description"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#equipment-dt tbody').on('click', '.view', function() {
        var button = $(this);
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#status').val(button.attr("data-status"));
        $('#vw_code').val(button.attr("data-code"));
        $('#vw_description').val(button.attr("data-description"));
        $('#view_modal').modal('show');
    });

    $('#equipment-dt tbody').on('click', '.change-status', function() {
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
                    url: '/change/equipment/status',
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

                            equipment_dt.cell($tr, 2).data(stat).draw();
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

    $('#equipment-dt tbody').on('click', '.delete', function() {
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
                    url: '/delete/equipment',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        equipment_dt.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Equipment deleted successfully!',
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


        // Equipment rates table

    var equipment_rate_dt = $('#equipment-rate-dt').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Equipment Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Equipment Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Rates",
                filename: "Equipment Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            }
        ],
    });

    $('#equipment-rate-dt tbody').on('click', '.edit', function() {
        var button = $(this);

        $('#edit_equipment').val(button.attr("data-equipment"));
        $('#edit_year').val(button.attr("data-year"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency').val(button.attr("data-currency"));
        $('#edit_partner').val(button.attr("data-partner"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#equipment-rate-dt tbody').on('click', '.view', function() {
        var button = $(this);

        $('#vw_equipment').val(button.attr("data-equipment"));
        $('#vw_year').val(button.attr("data-year"));
        $('#vw_amount').val(button.attr("data-amount"));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_partner').val(button.attr("data-partner"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        
        $('#view_modal').modal('show');
    });

    $('#equipment-rate-dt tbody').on('click', '.change-status', function() {
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
                    url: '/change/equipment/rate/status',
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

                            equipment_rate_dt.cell($tr, 5).data(stat).draw();
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

    $('#equipment-rate-dt tbody').on('click', '.delete', function() {
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
                    url: '/delete/equipment/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        equipment_rate_dt.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Equipment rate deleted successfully!',
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

    //-----------------------------material tracking-----------------------------------------

    $('#create-material-tracker').click(function() {
        date = $('#entry_date').val() == "" ? $('#exit_date').val() : $('#entry_date').val() 

        if (($('#direction').val() == "") ||
        ($('#equipment_id').val() == "") ||
        ($('#adminstrator_id').val() == "") ||
        (date == "") 
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
                    url: '/new/interchange/materials',
                    type: 'POST',
                    data: data,
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('.clear_select').val(null).trigger("change")
                            $('.clear_input').val('');
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

    $('#update-material-tracker').click(function() { 

        if (($('#direction').val() == "") ||
        ($('#equipment_id').val() == "") ||
        ($('#adminstrator_id').val() == "")
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
                    url: '/modify/material',
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

    var materials_dt = $('#materials-dt').DataTable({
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
            "url": '/interchange/material/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "equipment": $('#equipment').val(),
                "administrator": $('#administrator').val(),
                "date_received_to": $('#date_received_to').val(),
                "date_received_from": $('#date_received_from').val(),
                "direction": $("#materal-direction").val(),
                "date_sent_from": $('#date_sent_from').val(),
                "date_sent_to": $('#date_sent_to').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "administrator"},
            { "data": "equipment"},
            {
                "data": "amount",
                "render": function(data, type, row) {
                    amount = row["symbol"] +" "+ data;
                    return amount;
                },
                "defaultContent": "<span></span>",
            },
            {   
                "data": "direction",
                "render": function(data, type, row) {
                    date = data == 'INCOMING' ? row["date_received"]  :  row["date_sent"];
                    return date;
                },
                "defaultContent": "<span></span>",
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "/modify/' + data + '/material"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"><i class= "la la-edit"></i></a>';
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

    $('#materials-filter').on('click', function() {
        materials_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.administrator = $('#administrator').val();
            data.date_received_to = $('#date_received_to').val();
            data.date_received_from = $('#date_received_from').val();
            data.direction = $('#materal-direction').val();
            data.date_sent_from = $('#date_sent_from').val();
            data.date_sent_to = $('#date_sent_to').val();
            data.equipment = $('#equipment').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        materials_dt.draw();
    });

    $('#material-reset-report-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        materials_dt.draw();
    });


    $('#create-auxiliary-hire').click(function() {
        date = $('#entry_date').val() == "" ? $('#exit_date').val() : $('#entry_date').val() 

        if (($('#direction').val() == "") ||
        ($('#adminstrator_id').val() == "") ||
        (date == "") 
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
        var domEquipment = document.querySelectorAll("div[data-repeater-add]");
        
        var equipments = [];
        domEquipment.forEach(function(spare) {
            var equipment = {
                equipment_id: spare.querySelector('.add_equipment_id').value,
                wagon_code: spare.querySelector('.add_wagon_code').value,
                equipment_code: spare.querySelector('.add_equipment_code').value,
            }
            $.each($('.entry_data').serializeArray(), function(i, field) {
                equipment[field.name] = field.value;
            });
            equipments.push(equipment);
        });
     
        console.log(equipments)

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
                    url: '/new/auxiliary/hire',
                    type: 'POST',
                    data: {
                        _csrf_token: $("#csrf").val(), 
                        equipments: equipments,
                   },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            location.reload();
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

    var auxiliary_on_hire_dt = $('#auxiliary-on-hire-dt').DataTable({
        "responsive": true,
        "processing": true,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "serverSide": true,
        "paging": true,
        "select": {
            "style": 'multi'
        },
        'ajax': {
            "type": "POST",
            "url": '/auxiliary/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "equipment": $('#equipment').val(),
                "administrator": $('#administrator').val(),
                "date_received_to": $('#date_received_to').val(),
                "date_received_from": $('#date_received_from').val(),
                "direction": $("#materal-direction").val(),
                "status": $("#materal-status").val(),
                "date_sent_from": $('#date_sent_from').val(),
                "date_sent_to": $('#date_sent_to').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "administrator"},
            { "data": "equipment"},
            { "data": "equipment_code"},
            { "data": "wagon_code"},
            { "data": "current_station"},
            {
                "data": "total_amount",
                "render": function(data, type, row) {
                    amount = row["symbol"] +" "+ data;
                    return amount;
                },
                "defaultContent": "<span></span>",
            },
            {   "data": "accumlative_days",
                "width": "130",
                "className": "text-center"
            },
            {   
                "data": "direction",
                "render": function(data, type, row) {
                    date = data == 'INCOMING' ? row["received_date"]  :  row["sent_date"];
                    return date;
                },
                "defaultContent": "<span></span>",
                "width": "120",
                "className": "text-center"
            },
            {
                "data": "status",
                "render": function ( data, type, row ) {
                    if (data == 'ON_HIRE'){
						return "<span class='text-warning'>On Hire</span>"
					} else if (data == 'OFF_HIRE') {
						return "<span class='text-success'>Off HIRE</span>"
					} else {
                        return "<span>"+data+"</span>"
                    }
				},
				"defaultContent": "<span class='text-danger'>No Actions</span>"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    off_hire_link =  row["status"] == 'ON_HIRE' ? 'block;' : 'none;';
                    on_hire_link =  row["status"] == 'OFF_HIRE' ? 'block;' : 'none;';
                    return '<span class="dropdown">' +
                                '<a href="#" class="btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" data-toggle="dropdown" aria-expanded="true">' +
                                '<i class="la la-ellipsis-h"></i>' +
                                '</a>'+
                                '<div class="dropdown-menu dropdown-menu-right">' +
                                    '<a class="dropdown-item vw-auxiliary-item"href="#" data-id= "' + data + '" ><i class="la la-eye"></i>View</a>' +
                                    // '<a class="dropdown-item auxiliary-off-hire" style="display: ' + on_hire_link + '" href="#" data-id= "' + data + '" data-status="ON_HIRE" ><i class="la la-check"></i>On Hire</a>' +
                                    // '<a class="dropdown-item auxiliary-off-hire" style="display: ' + off_hire_link + '" href="#" data-id= "' + data + '" data-status="OFF_HIRE"><i class="la la-check"></i>Off Hire</a>' +
                                    // '<a class="dropdown-item archive-auxiliary-item"href="#" data-id= "' + data + '" ><i class="flaticon-open-box"></i>Archive</a>' +
                                ' </div>' +
                            '</span>'
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

    $('#aux-hire-select-all').on( 'click', function () {
		auxiliary_on_hire_dt.rows().select();
        auxiliary_on_hire_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#aux-unselect-all').on( 'click', function () {
        auxiliary_on_hire_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		auxiliary_on_hire_dt.rows().deselect();
    });

    $('#aux-set-off-hire').click(function() {
        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }
        $('#off-hire-date').val('');
        $('#off-hire-comment').val('');
        $('#off-hire-model').modal('show');
    });

    $('#aux-set-on-hire').click(function() {
        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }
        $('#on-hire-date').val('');
        $('#on-hire-comment').val('');
        $('#on-hire-model').modal('show');
    });


    $('#auxiliary-filter').on('click', function() {
        auxiliary_on_hire_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.administrator = $('#administrator').val();
            data.date_received_to = $('#date_received_to').val();
            data.date_received_from = $('#date_received_from').val();
            data.direction = $('#materal-direction').val();
            data.date_sent_from = $('#date_sent_from').val();
            data.status = $("#materal-status").val(),
            data.date_sent_to = $('#date_sent_to').val();
            data.equipment = $('#equipment').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        auxiliary_on_hire_dt.draw();
    });

    $('#auxiliary-reset-report-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        auxiliary_on_hire_dt.draw();
    });

    $('#set-auxiliary-off-hire').click(function() {
        date = $('#off-hire-date').val() == "" ?  $('#on-hire-date').val()  :  $('#off-hire-date').val();

        if (($('#off-hire-date').val() == "")) {
            swal({
                title: "Opps",
                text: "Off Hire Date Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        auxiliary_on_hire_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );
      
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
                    url: '/set/auxiliary/off/hire',
                    type: 'POST',
                    data: {
                         _csrf_token: $("#csrf").val(), 
                         off_hire_date: $('#off-hire-date').val(),
                         on_hire_date: $('#on-hire-date').val(),
                         status: "OFF_HIRE",
                         entries: data_row,
                         comment: $('#off-hire-comment').val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('#off-hire-model').modal('hide');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            auxiliary_on_hire_dt.draw();
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

    $('#set-auxiliary-on-hire').click(function() {
        alert()
        date = $('#off-hire-date').val() == "" ?  $('#on-hire-date').val()  :  $('#off-hire-date').val();

        if (($('#on-hire-date').val() == "")) {
            swal({
                title: "Opps",
                text: "On Hire Date Can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        auxiliary_on_hire_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );
      
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
                    url: '/set/auxiliary/off/hire',
                    type: 'POST',
                    data: {
                         _csrf_token: $("#csrf").val(), 
                         off_hire_date: $('#off-hire-date').val(),
                         on_hire_date: $('#on-hire-date').val(),
                         status: "ON_HIRE",
                         entries: data_row,
                         comment: $('#on-hire-comment').val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('#on-hire-model').modal('hide');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            auxiliary_on_hire_dt.draw();
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

    $('#auxiliary-on-hire-dt tbody').on('click', '.vw-auxiliary-item', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/auxiliary/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),
            },
            success: function(result) {
                spinner.hide();
                result = result.data
                date = result.direction == 'INCOMING' ? result.received_date  :  result.sent_date;
                amount = result.total_accum_days * result.amount;
                $('#vw-accumlated-ammount').val(Number(amount).toFixed(2));
                $('#vw-equipment').val(result.equipment);
                $('#vw-comment').val(result.comment);
                $('#vw-direction').val(result.direction);
                $('#vw-off-hire-date').val(result.off_hire_date);
                $('#vw-on-hire-date').val(result.on_hire_date);
                $('#vw-accumlated-days').val(result.accumlative_days);
                $('#vw-administrator').val(result.administrator);
                $('#vw-date').val(date);
                $('#vw-update-date').val(result.update_date);
                $('#vw-current-location').val(result.current_station);
                $('#vw-interchange-point').val(result.interchange_point);
                $('#vw-wagon-code').val(result.wagon_code);
                $('#vw-equipment-code').val(result.equipment_code);
                $('#vw-total-accum-days').val(result.total_accum_days);
                $('#view-auxiliary-model').modal('show');
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

    $('#close-aux').click(function() {
        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }

        $('#archive-auxiliary-date').val('');
        $('#archive-auxiliary-remark').val('');
        $('#archive-auxiliary-model').modal('show');
    });

    $('#set-auxiliary-item-archive').click(function() {
        if (($('#archive-auxiliary-date').val() =="") || ($('#archive-auxiliary-remark').val() ==""))
        {
            swal({
                title: "Opps",
                text: "Fields can not be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        row = auxiliary_on_hire_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Equipments selected!',
                'error'
            )
            return false;
        }

        var data_row = []
        auxiliary_on_hire_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            data_row.push(data);
        } );

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
                    url: '/archive/hire/auxiliary',
                    type: 'POST',
                    data: {
                         _csrf_token: $("#csrf").val(), 
                         id: $('#archive-auxiliary-id').val(),
                         archive_remark: $('#archive-auxiliary-remark').val(),
                         archive_date: $('#archive-auxiliary-date').val(),
                         entries : data_row
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('#archive-auxiliary-model').modal('hide');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            auxiliary_on_hire_dt.draw();
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

    $('.auxiliary-hire-lookup').on('input', function() {
        if ($('#entry-equipment-code').val().length < 1 || $('#entry-wagon-code').val().length < 1 ) {
            return false;
        }
        $('.clear_input').val('');
        $('.clear_select').val(null).trigger("change");
        spinner.show();
        $.ajax({
            url: '/auxiliary/tracking/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                equipment_code: $('#entry-equipment-code').val(),
                wagon_code: $('#entry-wagon-code').val()
            },
            success: function(result) {
                spinner.hide();
                result = result.data
                $('#vw-entry-id').val(result.id);
                $('#vw-status').val(result.status);
                $('#vw-direction').val(result.direction);
                $('#vw-equipment-id').val(result.equipment_code);
                $('#vw-adminstrator').val(result.administrator);
                $('#vw-current-wagon').val(result.current_wagon);
                $('#vw-current-location').val(result.current_station);
                $('#vw-interchange-point').val(result.interchange_point);
                $('#vw-wagon-code').val(result.wagon_code);
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

    $('#track-auxiliary-hire').click(function() {
        if (($('#vw-entry-id').val() ==""))
        {
            swal({
                title: "Opps",
                text: "Auxiliary Item not found!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (($('#current_location').val() ==""))
        {
            swal({
                title: "Opps",
                text: "Current location can not be blank!",
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
                    url: '/auxiliary/tracking',
                    type: 'POST',
                    data: {
                         _csrf_token: $("#csrf").val(), 
                         current_location_id: $('#current_location').val(),
                         wagon_id: $('#wagon_id').val(),
                         id: $('#vw-entry-id').val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            $('.clear_input').val('');
                            $('#entry-wagon-code').val('');
                            $('.clear_select').val(null).trigger("change");
                            $('#entry-equipment-code').val(null).trigger("change");
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
    

   //---------------------------------auxiliary Report-----------------------------------------

    var auxiliary_report_dt = $('#auxiliary-report-dt').DataTable({
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
            "url": '/auxiliary/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "equipment": $('#equipment').val(),
                "administrator": $('#administrator').val(),
                "date_received_to": $('#date_received_to').val(),
                "date_received_from": $('#date_received_from').val(),
                "direction": $("#materal-direction").val(),
                "status": $("#materal-status").val(),
                "date_sent_from": $('#date_sent_from').val(),
                "date_sent_to": $('#date_sent_to').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "administrator"},
            { "data": "equipment"},
            { "data": "equipment_code"},
            { "data": "wagon_code"},
            { "data": "current_station"},
            {
                "data": "amount",
                "render": function(data, type, row) {
                    amount = row["symbol"] +" "+ data;
                    return amount;
                },
                "defaultContent": "<span></span>",
            },
            {   "data": "accumlative_days",
                "width": "130",
                "className": "text-center"
            },
            {   
                "data": "direction",
                "render": function(data, type, row) {
                    date = data == 'INCOMING' ? row["received_date"]  :  row["sent_date"];
                    return date;
                },
                "defaultContent": "<span></span>",
                "width": "120",
                "className": "text-center"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                     return '<a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill vw-auxiliary-off-hire" title= "View "> <i class= "la la-eye"></i></a>' +
                     '<a href= "/modify/auxililary/' + data + '/hire"  data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"><i class= "la la-edit"></i></a>';
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
    

    $('#auxiliary-report-filter').on('click', function() {
        auxiliary_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.administrator = $('#administrator').val();
            data.date_received_to = $('#date_received_to').val();
            data.date_received_from = $('#date_received_from').val();
            data.direction = $('#materal-direction').val();
            data.date_sent_from = $('#date_sent_from').val();
            data.status = $("#materal-status").val(),
            data.date_sent_to = $('#date_sent_to').val();
            data.equipment = $('#equipment').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        auxiliary_report_dt.draw();
    });

    $('#auxiliary-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        auxiliary_report_dt.draw();
    });
    
    $('#auxiliary-report-dt tbody').on('click', '.vw-auxiliary-off-hire', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/auxiliary/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),
            },
            success: function(result) {
                spinner.hide();
                result = result.data
                date = result.direction == 'INCOMING' ? result.received_date  :  result.sent_date;
                amount = result.total_accum_days * result.amount;
                $('#vw-accumlated-ammount').val(Number(amount).toFixed(2));
                $('#vw-equipment').val(result.equipment);
                $('#vw-comment').val(result.comment);
                $('#vw-direction').val(result.direction);
                $('#vw-off-hire-date').val(result.off_hire_date);
                $('#vw-on-hire-date').val(result.on_hire_date);
                $('#vw-accumlated-days').val(result.accumlative_days);
                $('#vw-administrator').val(result.administrator);
                $('#vw-date').val(date);
                $('#vw-update-date').val(result.update_date);
                $('#vw-current-location').val(result.current_station);
                $('#vw-interchange-point').val(result.interchange_point);
                $('#vw-wagon-code').val(result.wagon_code);
                $('#vw-equipment-code').val(result.equipment_code);
                $('#vw-total-accum-days').val(result.total_accum_days);
                $('#view-auxiliary-model').modal('show');
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

//-------------------------------auxiliary_daily_summary_report---------------------

    var auxiliary_daily_summary_report_dt = $('#auxiliary-daily-summary-report-dt').DataTable({
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
            "url": '/auxiliary/daily/summary/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "equipment": $('#equipment').val(),
                "administrator": $('#administrator').val(),
                "date_received_to": $('#date_received_to').val(),
                "date_received_from": $('#date_received_from').val(),
                "direction": $("#materal-direction").val(),
                "status": $("#materal-status").val(),
                "date_sent_from": $('#date_sent_from').val(),
                "date_sent_to": $('#date_sent_to').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
            }
        },
        "columns": [
            { "data": "administrator"},
            { "data": "equipment"},
            { "data": "equipment_code"},
            { "data": "wagon_code"},
            { "data": "current_station"},
            {
                "data": "amount",
                "render": function(data, type, row) {
                    amount = row["symbol"] +" "+ data;
                    return amount;
                },
                "defaultContent": "<span></span>",
            },
            {   "data": "accumlative_days",
                "className": "text-center"
            },
            {   
                "data": "direction",
                "render": function(data, type, row) {
                    date = data == 'INCOMING' ? row["received_date"]  :  row["sent_date"];
                    return date;
                },
                "defaultContent": "<span></span>",
                "className": "text-center"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                     return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill vw-auxiliary-off-hire" title= "View "> <i class= "la la-eye"></i></a>'
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

    $('#auxiliary-daily-summary-report-filter').on('click', function() {
        auxiliary_daily_summary_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.administrator = $('#administrator').val();
            data.date_received_to = $('#date_received_to').val();
            data.date_received_from = $('#date_received_from').val();
            data.direction = $('#materal-direction').val();
            data.date_sent_from = $('#date_sent_from').val();
            data.status = $("#materal-status").val(),
            data.date_sent_to = $('#date_sent_to').val();
            data.equipment = $('#equipment').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        auxiliary_daily_summary_report_dt.draw();
    });

    $('#auxiliary-daily-summary-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        auxiliary_daily_summary_report_dt.draw();
    });

    $('#auxiliary-daily-summary-report-dt tbody').on('click', '.vw-auxiliary-off-hire', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/auxiliary/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),
            },
            success: function(result) {
                spinner.hide();
                result = result.data
                date = result.direction == 'INCOMING' ? result.received_date  :  result.sent_date;
                amount = result.total_accum_days * result.amount;
                $('#vw-accumlated-ammount').val(Number(amount).toFixed(2));
                $('#vw-equipment').val(result.equipment);
                $('#vw-comment').val(result.comment);
                $('#vw-direction').val(result.direction);
                $('#vw-off-hire-date').val(result.off_hire_date);
                $('#vw-on-hire-date').val(result.on_hire_date);
                $('#vw-accumlated-days').val(result.accumlative_days);
                $('#vw-administrator').val(result.administrator);
                $('#vw-date').val(date);
                $('#vw-update-date').val(result.update_date);
                $('#vw-current-location').val(result.current_station);
                $('#vw-interchange-point').val(result.interchange_point);
                $('#vw-wagon-code').val(result.wagon_code);
                $('#vw-equipment-code').val(result.equipment_code);
                $('#vw-total-accum-days').val(result.total_accum_days);
                $('#view-auxiliary-model').modal('show');
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

    var bulk_auxiliary_dt = $('#bulk-auxiliary-dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        data: [],
        columns: [
            { data: "administrator" },
            { data: "equipment" },
            { data: "equipment_code" },
            { data: "wagon_code" },   
            { data: "current_station" },
            { data: "current_wagon" },
            { data: "current_wagon_owner" }
        ]
    });

    $('.auxiliary-lookup').on('change', function() {
     
        if ($('#equipment').val().length < 1 || $('#direction').val().length < 1 ){
            return false;
        }
        spinner.show();
        $.ajax({
            url: '/auxiliary/tracking/lookup',
            type: 'POST',
            data: { equipment: $("#equipment").val(), _csrf_token: $("#csrf").val(), direction: $("#direction").val() },
            success: function(result) {
                spinner.hide();
                data = result.data
                 
                if (data.length < 1) {
                    bulk_auxiliary_dt.clear().rows.add([]).draw();
                } else {
                    bulk_auxiliary_dt.clear().rows.add(data).draw(); 
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

    $("#bulk-auxiliary-dt tbody").on("click", "tr td", function(e) {
        // table.row($(this).closest("tr")).remove().draw();
        if (editRow == 1)
            return false;

        var $row = $(this).closest("tr").off("click");
        var $tds = $row.find("td");

        $.each($tds, function(index, el) {
            var txt = $(this).text();
            if (index == 4) {
                $(this).html("").append('<select  name="destin_station_id" class="form-control destin_station" >' + destinOptions + '</select>');
            } else if (index == 5) {
                $(this).html("").append("<input type='text' class=\"form-control row-input wagon_lookup\">");
            }else if (index == 6) {
                $(this).html("").append("<input type='text' class=\"form-control row-input\">");
            }  
        });

        if(editRow < 0){
            editRow = 0;
        } else {
            editRow = 1;
        }
    });

    $("#bulk-auxiliary-dt tbody").on('input', ".wagon_lookup", function(e) {
        var $select = $(this);
        var $row = $(this).closest("tr");
        var $tds = $row.find("td");
        
        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $(".wagon_lookup").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    WagonID ="";
                    $.each($tds, function(index, el) {
                        if (index == 6) {
                            $(this).find("input").val("");
                        }
                    });
                } else {
                    WagonID = result.data[0].id
                    $.each($tds, function(index, el) {
                        if (index == 6) {
                            $(this).find("input").val(result.data[0].wagon_owner);
                        }
                    });
                }
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                editRow == -1
            
            }
        });

    });

    $("#bulk-auxiliary-dt tbody").on('keyup', ".row-input", function(e) {
        if (e.keyCode == 13) {

            var $row = $(this).closest("tr");
            var $tds = $row.find("td");
            var rowIndex = bulk_auxiliary_dt.row($row).index();
            var edited = false;
            var current_station_id = null;
            var current_wagon = null;
         
            $.each($tds, function(index, el) {
                
                var $this = $(this);

                if (index == 4){
                    var txt =  $this.find("select").find(':selected').text();
                    current_station_id = index == 4 ? $this.find("select").val() : current_station_id;

                    if ((txt.trim().length < 1)) {
                        Swal.fire(
                            'Oops...',
                            'Current location can\'t be blank',
                            'error'
                        )
                        edited = false;
                        return false;
                    }
                    edited = true;
                    bulk_auxiliary_dt.cell({ row: rowIndex, column: index }).data(txt).draw();
                }else  if (index == 5){

                    var txt =  $this.find("input").val();

                    if ((txt.trim().length < 1)) {
                        Swal.fire(
                            'Oops...',
                            'Wagon code can\'t be blank',
                            'error'
                        )
                        edited = false;
                        return false;
                    }
                    edited = true;
                    bulk_auxiliary_dt.cell({ row: rowIndex, column: index }).data(txt).draw();
                    
                }
                else  if (index == 6){

                    var txt =  $this.find("input").val();
                    bulk_auxiliary_dt.cell({ row: rowIndex, column: index }).data(txt).draw();
                    
                }
            });
            var rowData = bulk_auxiliary_dt.row($row).data();
            rowData.edited = edited;
            rowData.current_wagon_id =  WagonID;
            rowData.current_station_id =  current_station_id;
            editRow = 0;
            bulk_auxiliary_dt.row($row).data(rowData).draw();
        }
    });

    $('#submit-bulk-auxiliary').click(function() {
        
        if (bulk_auxiliary_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        
        var details = {};
        var data_row = [];

        for (let index = 0; index < (bulk_auxiliary_dt.rows().count()); index++) {
            data_row.push(Object.assign(bulk_auxiliary_dt.rows().data()[index], details));
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
                    url: '/bulk/auxiliary/tracking',
                    type: 'post',
                    data: {entries: data_row, _csrf_token: $("#csrf").val()},
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            bulk_auxiliary_dt.clear().rows.add([]).draw();
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

    //INTERCHNGE WAGON TRACKING

    var interchange_wagon_tracking_dt = $('#interchange-wagon-tracking-dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        select: {
            "style": 'multi'
        },
        bInfo: false,
        orderable: !0,
        bSort: false,
        columns: [
            { data: "wagon_code"},
            { data: "wagon_owner"},
            { data: "train_no"},
            { data: "direction" },
            { data: "commodity_name" },
            { data: "origin_name" },
            { data: "destination_name"},
            {
                "data": "current_location",
                "render": function ( data, type, row ) {
                    if ((row["wagon_curent_stat_pur_code"]  == 'ARRIVAL')){
                        return "<span style='color:#02f52f'>"+data+"</span>"
                    } else {
                        var location
                        if (data === null || data === undefined) {
                            location = ""
                           }
                        else{
                            location = data
                        }

                        return "<span>"+location+"</span>"
                    }
                },
                "defaultContent": "<span></span>"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return '<a href= "#" data-admin-id = "' + row["admin_id"] + '"  data-id = "' + data + '"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view_interchange_entry" title= "View"> <i class= "la la-eye "></i></a>' +
                    '<a href= "#" data-admin-id = "' + row["admin_id"] + '" data-id = "' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill wagon-condition" title= "Edit"><i class= "la la-edit"></i></a>';
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "width": "80",
                "className": "text-center"
            }
        ]
    });

    $('#int-tracker-select-all').on( 'click', function () {
		interchange_wagon_tracking_dt.rows().select();
        interchange_wagon_tracking_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#int-tracker-unselect-all').on( 'click', function () {
        interchange_wagon_tracking_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		interchange_wagon_tracking_dt.rows().deselect();
    });

    $("#track-train-no").on("input", function() {
        spinner.show();
        $.ajax({
            url: '/interchange/train/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                train_no: $("#track-train-no").val(),
                track: "YES"
            },
            success: function(result) {
                spinner.hide();
                if (result.data.length < 1) {
                     
                    interchange_wagon_tracking_dt.clear().rows.add(result.data).draw();

                } else {
                    interchange_wagon_tracking_dt.clear().rows.add(result.data).draw();
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

    $('#current_location_id').on('change', function() {
        domain = $('#current_location_id option:selected').data('domain');
        region = $('#current_location_id option:selected').data('region');
        $('#domain_id').val(domain)
        $('#region_id').val(region)
    });

    $('#interchange-wagon-tracking-dt tbody').on('click', '.view_interchange_entry', function(e) {
        e.preventDefault()
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(), admin: button.attr("data-admin-id") },
            success: function(result) {
                spinner.hide();
                var wagon = result.wagon
                $('#vw-comment').val(wagon.comment);
                $('#vw-wagon').val(wagon.wagon_code);
                $('#vw-wagon-owner').val(wagon.wagon_owner);
                $('#vw-accumulative-days').val(wagon.accumulative_days);
                $('#vw-accumulative-amount').val(wagon.accumulative_amount);
                $('#vw-on-hire-date').val(wagon.on_hire_date);
                $('#vw-off-hire-date').val(wagon.off_hire_date);
                $('#vw-origin').val(wagon.origin);
                $('#vw-destination').val(wagon.destination);
                $('#vw-train-number').val(wagon.train_no);
                $('#vw-commodity').val(wagon.commodity);
                $('#vw-current-station').val(wagon.current_station);
                $('#vw-region').val(wagon.region);
                $('#vw-wagon-status').val(wagon.wagon_status);
                $('#vw-wagon-condition').val(wagon.wagon_condition);
                $('#vw-total-accum-days').val(wagon.total_accum_days);
                wagon.off_hire_date == null ?  jQuery('.off-hire-dt').remove() :  jQuery('.on-hire-dt').remove();
                 
                if (result.data.length < 1) {
                    dt_interchange_view_defect.clear().rows.add([]).draw();
                    $('#defects_total').text("0");
                    $('#view-hired-wagon-model').modal('show');
                } else {
                    var data_row = [];
                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    for (let index = 0; index < (result.data.length); index++) {
                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_view_defect.clear().rows.add(data_row).draw();
                    $('#view-hired-wagon-model').modal('show');
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

    $('#interchange-wagon-tracking-dt tbody').on('click', '.wagon-condition', function(e) {
        e.preventDefault()
        var button = $(this);
        var admin =  button.attr("data-admin-id")
        var $tr = $(this).closest('tr');          
        wagon_row = $tr;
       $('#new-comment').val('');
       $('#condition_id').val(null);

        spinner.show();
        $.ajax({
            url: '/interchange/defect/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(),  admin: admin },
            success: function(result) {
                spinner.hide();
                var wagon = result.wagon;
                $('.clear').val('');
                $('#new-wagon').val(wagon.wagon_code);
                $('#new-wagon-owner').val(wagon.wagon_owner);
                $('#vw-on-hire-date').val(wagon.on_hire_date);
                $('#new-entry-id').val(wagon.id);
                $('#new-admin-id').val(admin);
                $('#new-on-hire-dt').val(wagon.on_hire_date);
           
                if (result.data.length < 1) {
                    dt_interchange_defect_approval.clear().rows.add([]).draw();
                    $('#wagon-condition-model').modal('show');
                } else {
                    var data_row = [];
                    var defect = {
                        "admin_id": button.attr("data-admin-id"),
                        "interchange_id": button.attr("data-id")
                    }
                    
                    for (let index = 0; index < (result.data.length); index++) {
                        result.data[index].amount =  result.data[index].currency.concat(result.data[index].amount)
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    dt_interchange_defect_approval.clear().rows.add(data_row).draw();
                    $('#wagon-condition-model').modal('show');
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
    
    $('#update-tracked-wagon').click(function() {
        var defects = [];
        $.each(dt_interchange_defect_approval.rows().data(), function(index, item) {
            defects.push(item);
        });
        
        var rowData = interchange_wagon_tracking_dt.row(wagon_row).data();
        rowData.new_comment = $('#new-comment').val();
        rowData.new_condition_id =  $('#condition_id').val();
        rowData.defects = defects
        interchange_wagon_tracking_dt.row(wagon_row).data(rowData).draw();
        $('#wagon-condition-model').modal('hide');
        $('.wagon-field-clr').val('');
    });

    $('#tracked-wagon-condition').click(function() {
        if (($('#current_location_id').val() == "") ||
            ($('#update_date').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }

        if (interchange_wagon_tracking_dt.rows().count()  < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        row = interchange_wagon_tracking_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }
        $('#condition-tracker-modal').modal('show');
        $('#bulk_current_status_id').val(null);
        $('#crnt_stat_id').val('');
    });

    $('#track-wagons').click(function() {
       
         $('#crnt_stat_id').val($('#bulk_current_status_id').val());

        if (($('#crnt_stat_id').val() == "")){
            Swal.fire(
                'Oops..!',
                'Wagon condition cannot be blank!',
                'error'
            )
            return false;
        }

        if (($('#current_location_id').val() == "") ||
            ($('#update_date').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }

        if (interchange_wagon_tracking_dt.rows().count()  < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        row = interchange_wagon_tracking_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

        var data_row = [];
      
        interchange_wagon_tracking_dt.rows( { selected: true } ).every(function(rowIdx) {
            data_row.push(Object.assign(interchange_wagon_tracking_dt.rows().data()[rowIdx], details));
        })

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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/track/wagon',
                    type: 'post',
                    data: { entries: data_row, _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Entries saved successfully!',
                                'success'
                            )
                            $.each(interchange_wagon_tracking_dt.rows( { selected: true } ).indexes(), function(index, item) {
                                var rowData = interchange_wagon_tracking_dt.row(item).data()
                                rowData.current_location =  $("#current_location_id option:selected").attr('data-current-location');
                                rowData.current_location_id =  $("#current_location_id").val();
                                rowData.wagon_curent_stat_pur_code =  $("#bulk_current_status_id option:selected").attr('data-pur-code');
                                rowData.departure =  $("#bulk_current_status_id").val();
                                interchange_wagon_tracking_dt.row(item).data(rowData).draw();
                            });
                            $('#condition-tracker-modal').modal('hide');
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


    // Loco detention rates table

    var loco_rate_dt = $('#loco-rate-dt').DataTable({
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
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Loco Detention Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Loco Detention Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Rates",
                filename: "Loco Detention Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5]
                }
            }
        ],
    });

    $('#loco-rate-dt tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_delay_charge').val(button.attr("data-delay"));
        $('#edit_date').val(button.attr("data-date"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency').val(button.attr("data-currency"));
        $('#edit_admin').val(button.attr("data-admin"));
        $('#edit_id').val(button.attr("data-id"));
        $('#edit_modal').modal('show');
    });

    $('#loco-rate-dt tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_delay_charge').val(button.attr("data-delay"));
        $('#vw_date').val(button.attr("data-date"));
        $('#vw_amount').val(button.attr("data-amount"));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_admin').val(button.attr("data-admin"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        
        $('#view_modal').modal('show');
    });

    $('#loco-rate-dt tbody').on('click', '.change-status', function() {
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
                    url: '/change/locomotive/detention/rate/status',
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

                            loco_rate_dt.cell($tr, 5).data(stat).draw();
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

    $('#loco-rate-dt tbody').on('click', '.delete', function() {
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
                    url: '/delete/locomotive/detention/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        loco_rate_dt.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Loco rate deleted successfully!',
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


    //----------------------------------loco detetion-------------------------------------

    $('#locomotive_id').on('change', function() {
        owner = $('#locomotive_id option:selected').data('owner');
        $('#loco_owner_id').val(owner);
    });

    $('#create-loco-detention').click(function() {

        if (($('#interchange_date').val() == "") ||
           ($('#locomotive_id').val() == "") ||
           ($('#arrival_time').val() == "")  ||
           ($('#train_no').val() == "")  ||
           ($('#direction').val() == "") ||
           ($('#admin_id').val() == "")
        ) {
            Swal.fire(
                'Oops..!',
                'Fields cannot be blank!',
                'error'
            )
            return false;
        }

        var details = {};
        $.each($('.data_entry').serializeArray(), function(i, field) {
            details[field.name] = field.value;
        });

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
                    url: '/locomotive/detention',
                    type: 'POST',
                    data: {
                        data: details,
                        loco_no: $('#locomotive_id').val(),
                        _csrf_token: $("#csrf").val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('.clear_select').val(null).trigger("change")
                            $('.clear_input').val('');
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

    $('#update-loco-detention').click(function() {

        if (($('#comment').val() == ""))
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
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
                var data = $("form").serialize();
                spinner.show();
                $.ajax({
                    url: '/modify/locomotive',
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


    var loco_detention_dt = $('#loco-detention-dt').DataTable({
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
            "url": '/locomotive/detention/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "direction": $('#detention_direction').val(),
                "status": $('#detention_status').val(),
                "loco_no": $('#loco_no').val(),
                "admin": $('#admin').val(),
                "interchange_date_from": $("#interchange_date_from").val(),
                "interchange_date_to": $("#interchange_date_to").val(),
                "arrival_time": $('#arrival_time').val(),
                "departure_date_from": $('#departure_date_from').val(),
                "departure_date_to": $('#departure_date_to').val(),
                "departure_time": $('#departure_time').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
                "train_no": $('#train_no').val(),
                "type" : "LOCO_DETENTATION"                
            }
        },
        "columns": [
            { "data": "interchange_date"},
            { "data": "train_no"},
            { "data": "loco_no"},
            { "data": "arrival_date"},
            { "data": "arrival_time"},
            { "data": "admin"},
            {
                "data": "id",
                "render": function(data, type, row) {
                     return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill archive-loco-detention" title= "Archive"> <i class= "la la-check"></i></a>'
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

    $('#loco-detention-filter').on('click', function() {
        loco_detention_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.direction = $('#detention_direction').val(),
            data.status = $('#detention_status').val(),
            data.loco_no = $('#loco_no').val(),
            data.admin = $('#admin').val(),
            data.interchange_date_from = $("#interchange_date_from").val(),
            data.interchange_date_to = $("#interchange_date_to").val(),
            data.arrival_time = $('#arrival_time').val(),
            data.departure_date_from = $('#departure_date_from').val(),
            data.departure_date_to = $('#departure_date_to').val(),
            data.departure_time = $('#departure_time').val(),
            data.from = $('#from').val(),
            data.train_no = $('#train_no').val()   
        });
        loco_detention_dt.draw();
    });

    $('#loco-detention-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        loco_detention_dt.draw();
    });


    $('#loco-detention-dt tbody').on('click', '.archive-loco-detention', function() {
        var button = $(this);
        $('#loco-detention-comment').val('');
        $('#loco-departure-time').val('');
        $('#loco-departure-date').val('');
        $('#loco-detention-id').val(button.attr("data-id"));
        $('#archive-loco-detention').modal('show');
    });

    $('#archive-loco-detention-item').click(function() {
        if (($('#loco-departure-time').val() ==""))
        {
            swal({
                title: "Opps",
                text: "Departure time can not be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        if (( $('#loco-departure-date').val() ==""))
        {
            swal({
                title: "Opps",
                text: "Departure date can not be blank!",
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
                    url: '/archive/locomotive/detention',
                    type: 'POST',
                    data: {
                         _csrf_token: $("#csrf").val(), 
                         comment:$('#loco-detention-comment').val(),
                         departure_time: $('#loco-departure-time').val(),
                         departure_date:  $('#loco-departure-date').val(),
                         id: $('#loco-detention-id').val()
                    },
                    success: function(result) {
                        if (result.info) {
                            spinner.hide();
                            $('#archive-loco-detention').modal('hide');
                            Swal.fire(
                                'Success!',
                                'Operation complete!',
                                'success'
                            )
                            loco_detention_dt.draw();
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
    
    //------------------------------loco detention reports--------------------------

    var loco_detention_report_dt = $('#loco-detention-report-dt').DataTable({
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
            "url": '/locomotive/detention/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "direction": $('#detention_direction').val(),
                "status": $('#detention_status').val(),
                "loco_no": $('#loco_no').val(),
                "admin": $('#admin').val(),
                "interchange_date_from": $("#interchange_date_from").val(),
                "interchange_date_to": $("#interchange_date_to").val(),
                "arrival_time": $('#arrival_time').val(),
                "departure_date_from": $('#departure_date_from').val(),
                "departure_date_to": $('#departure_date_to').val(),
                "departure_time": $('#departure_time').val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
                "train_no": $('#train_no').val(),
                "type" : "LOCO_DETENTATION"               
            }
        },
        "columns": [
            { "data": "loco_no"},
            { "data": "train_no"},
            { "data": "arrival_date"},
            { "data": "arrival_time"},
            { "data": "departure_date"},
            { "data": "departure_time"},
            { "data": "admin"},
            { "data": "chargeable_delay"},
            { "data": "amount"},
            {
                "data": "id",
                "render": function(data, type, row) {
                     return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill vw-archive-loco-detention" title= "View"> <i class= "la la-eye"></i></a>' +
                        ' <a href="/modify/' + data + '/locomotive"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"> <i class= "la la-edit"></i></a>'
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

    $('#loco-detention-report-filter').on('click', function() {
        loco_detention_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.direction = $('#detention_direction').val(),
            data.status = $('#detention_status').val(),
            data.loco_no = $('#loco_no').val(),
            data.admin = $('#admin').val(),
            data.interchange_date_from = $("#interchange_date_from").val(),
            data.interchange_date_to = $("#interchange_date_to").val(),
            data.arrival_time = $('#arrival_time').val(),
            data.departure_date_from = $('#departure_date_from').val(),
            data.departure_date_to = $('#departure_date_to').val(),
            data.departure_time = $('#departure_time').val(),
            data.from = $('#from').val(),
            data.train_no = $('#train_no').val()   
        });
        loco_detention_report_dt.draw();
    });

    $('#loco-detention-report-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        loco_detention_report_dt.draw();
    });

    $('#loco-detention-report-dt tbody').on('click', '.vw-archive-loco-detention', function(e) {
        e.preventDefault()
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/locomotive/item/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val()},
            success: function(result) {
                spinner.hide();
                var loco = result.data
                $('#vw-comment').val(loco.comment);
                $('#vw-loco-no').val(loco.loco_no);
                $('#vw-train-no').val(loco.train_no);
                $('#vw-actual-delay').val(loco.actual_delay);
                $('#vw-grace-period').val(loco.grace_period);
                $('#vw-chargeable-delay').val(loco.chargeable_delay);
                $('#vw-rate').val(loco.rate);
                $('#vw-currency').val(loco.currency);
                $('#vw-amount').val(loco.amount);
                $('#vw-archive-loco-model').modal('show');
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

    var loco_detention_summary_dt = $('#loco-detention-summary-dt').DataTable({
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
            "url": '/locomotive/detention/summary/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "direction": $('#detention_direction').val(),
                "admin": $('#admin').val(),
                "from": $('#from').val(),
                "to": $('#to').val()         
            }
        },
        "columns": [
           
            { "data": "admin"},
            { "data": "direction"},
            { "data": "chargeable_delay"},
            { "data": "currency"},
            { "data": "amount"},
        ],
        "lengthMenu": [
            [10, 25, 50, 100, 500, 1000],
            [10, 25, 50, 100, 500, 1000]
        ],
        "order": [
            [1, 'asc']
        ]
    });

    $('#loco-detention-summary-report-filter').on('click', function() {
        loco_detention_summary_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.direction = $('#detention_direction').val(),
            data.admin = $('#admin').val(),
            data.from = $('#from').val()   
        });
        loco_detention_summary_dt.draw();
    });

    $('#loco-detention-summary-report-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        loco_detention_summary_dt.draw();
    });

    $('.haulage-rate-type').on('change', function() {
        $('.haulage-distance').val('');

        if ($('.haulage-rate-type').val() == "PER_KM") {
            $(".haulage-distance").prop('disabled', false);
        } else {
            $(".haulage-distance").prop('disabled', true);
            
        }
    });

    $('.edit-haulage-rate-type').on('change', function() {
        $('.edit-haulage-distance').val('');

        if ($('.edit-haulage-rate-type').val() == "PER_KM") {
            $(".edit-haulage-distance").prop('disabled', false);
        } else {
            $(".edit-haulage-distance").prop('disabled', true);
            
        }
    });
   

    //-----------------------------hualage rates--------------------------------------------------

    var haulage_rate_dt = $('#haulage-rate-dt').DataTable({
        responsive: true,

        'columnDefs': [{
                "targets": 8,
                "width": "12",
                "className": "text-center"
            },
            {
                "targets": 7,
                "width": "12",
                "className": "text-center"
            }
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
                text: 'Copy',
                titleAttr: 'Copy Table',
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'excelHtml5',
                text: 'Excel',
                titleAttr: 'Generate Excel',
                messageTop: "Rates",
                filename: "Haulage Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'csvHtml5',
                text: 'CSV',
                titleAttr: 'Generate CSV',
                messageTop: "Rates",
                filename: "Haulage Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            },
            {
                extend: 'pdfHtml5',
                text: 'PDF',
                titleAttr: 'Generate PDF',
                messageTop: "Rates",
                filename: "Haulage Rate List",
                exportOptions: {
                    columns: [ 0, 1, 2, 3, 4, 5, 6, 7]
                }
            }
        ],
    });

    $('#haulage-rate-dt tbody').on('click', '.edit', function() {
        var button = $(this);
        $('#edit_equipment').val(button.attr("data-equipment"));
        $('#edit_year').val(button.attr("data-year"));
        $('#edit_amount').val(button.attr("data-amount"));
        $('#edit_currency').val(button.attr("data-currency"));
        $('#edit_category').val(button.attr("data-category"));
        $('#edit_distance').val(button.attr("data-distance"));
        $('#edit_rate_type').val(button.attr("data-rate-type"));
        $('#edit_partner').val(button.attr("data-partner"));
        $('#edit_id').val(button.attr("data-id"));

        if (button.attr("data-rate-type") == "PER_KM") {
            $(".edit-haulage-distance").prop('disabled', false);
        } else {
            $(".edit-haulage-distance").prop('disabled', true);
        }

        $('#edit_modal').modal('show');
    });

    $('#haulage-rate-dt tbody').on('click', '.view', function() {
        var button = $(this);
        $('#vw_equipment').val(button.attr("data-equipment"));
        $('#vw_year').val(button.attr("data-year"));
        $('#vw_amount').val(button.attr("data-amount"));
        $('#vw_currency').val(button.attr("data-currency"));
        $('#vw_category').val(button.attr("data-category"));
        $('#vw_partner').val(button.attr("data-partner"));
        $('#vw_status').val(button.attr("data-status"));
        $('#created').val(button.attr("data-created"));
        $('#modified').val(button.attr("data-modified"));
        $('#checker').val(capitalize(button.attr("data-checker")));
        $('#maker').val(capitalize(button.attr("data-maker")));
        $('#vw_distance').val(button.attr("data-distance"));
        $('#vw_rate_type').val(button.attr("data-rate-type"));
        $('#view_modal').modal('show');
    });

    $('#haulage-rate-dt tbody').on('click', '.change-status', function() {
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
                    url: '/change/haulage/rate/status',
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

                            haulage_rate_dt.cell($tr, 7).data(stat).draw();
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

    $('#haulage-rate-dt tbody').on('click', '.delete', function() {
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
                    url: '/delete/haulage/rate',
                    type: 'DELETE',
                    data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val() },
                    success: function(result) {
                        spinner.hide();
                        haulage_rate_dt.row($tr).remove().draw(false);
                        Swal.fire(
                            'Success',
                            'Haulage rate deleted successfully!',
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

//---------------------------haulage----------------------------

    $('#create-new-haulage').click(function() {
            // console.log($('#locomotive_id').val())
        if(($('#train_no').val() == "") ||
            ($('#date').val() == "") ||
            ($('#direction').val() == "") ||
            ($('#locomotive_id').val() == "") ||
            ($('#wagon_grand_total').val() == "")
        ) {
                Swal.fire(
                    'Oops..!',
                    'Fields can not be blank!',
                    'error'
                )
                return false;
            }
        
        var domAdmins = document.querySelectorAll("div[data-repeater-add]");
        
        var admins = [];
        domAdmins.forEach(function(spare) {
            var admin = {
                admin_id: spare.querySelector('.add_admin_id').value,
                total_wagons: spare.querySelector('.add_count').value,
            }
            $.each($('.entry_data').serializeArray(), function(i, field) {
                admin[field.name] = field.value;
                admin.loco_no = $('#locomotive_id').val();
            });
            admins.push(admin);
        });

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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/interchange/haulage',
                    type: 'post',
                    data: {
                        admins: admins, 
                        _csrf_token: $("#csrf").val(),
                     },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Submited successfully!',
                                'success'
                            )
                            location.reload();
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
    
    $('#update-haulage').click(function() {
        if(($('#train_no').val() == "") ||
            ($('#date').val() == "") ||
            ($('#direction').val() == "") ||
            ($('#loco_id').val() == "") ||
            ($('#wagon_grand_total').val() == "")
        ) {
                Swal.fire(
                    'Oops..!',
                    'Fields can not be blank!',
                    'error'
                )
                return false;
            }
            
            var details = {};
            $.each($('.entry_data').serializeArray(), function(i, field) {
                details[field.name] = field.value;
            });
           console.log(details)
        
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
                $(window).scrollTop(0);
                spinner.show();
                $.ajax({
                    url: '/modify/haulage',
                    type: 'post',
                    data: {
                        entry: details,
                        _csrf_token: $("#csrf").val(),
                        loco:  $('#loco_id').val()
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'successfully updated!',
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
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    var haulage_report_dt = $('#haulage-report-dt').DataTable({
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
            "url": '/haulage/report/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "direction": $('#haulage_direction').val(),
                "admin": $('#admin').val(),
                "date_from": $("#date_from").val(),
                "date_to": $("#date_to").val(),
                "from": $('#from').val(),
                "to": $('#to').val(), 
                "train_no": $('#train_no').val(),
                "type": "HAULAGE",                  
            }
        },
        "columns": [
            { "data": "date"},
            { "data": "train_no"},
            { "data": "loco_no"},
            { "data": "admin"},
            { "data": "wagon_ratio"},
            { "data": "currency"},
            { "data": "amount"},
            {
                "data": "id",
                "render": function(data, type, row) {
                     return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill vw-haulage" title= "view"> <i class= "la la-eye"></i></a>' +
                     '<a href= "/modify/' + data + '/haulage" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "Edit"><i class= "la la-edit"></i></a>';
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

    $('#haulage-report-filter').on('click', function() {
        haulage_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.direction = $('#haulage_direction').val(),
            data.admin = $('#admin').val(),
            data.date_from = $("#date_from").val(),
            data.date_to = $("#date_to").val(),
            data.train_no = $('#train_no').val(),
            data.type = "HAULAGE"
        });
        haulage_report_dt.draw();
    });

    $('#haulage-report-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        haulage_report_dt.draw();
    });

    $('#haulage-report-dt tbody').on('click', '.vw-haulage', function(e) {
        e.preventDefault()
        var button = $(this);
        spinner.show();
        $.ajax({
            url: '/haulage/item/lookup',
            type: 'POST',
            data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val()},
            success: function(result) {
                spinner.hide();
                var haulage = result.data
                $('#vw-comment').val(haulage.comment);
                $('#vw-loco-no').val(haulage.loco_no);
                $('#vw-train-no').val(haulage.train_no);
                $('#vw-number-of-wagons').val(haulage.total_wagons);
                $('#vw-total-wagons').val(haulage.wagon_grand_total);
                $('#vw-admin').val(haulage.admin);
                $('#vw-rate').val(haulage.rate);
                $('#vw-currency').val(haulage.currency);
                $('#vw-amount').val(haulage.amount);
                $('#vw-comment').val(haulage.comment);
                $('#vw-observations').val(haulage.observation);
                $('#vw-wagon-ratio').val(haulage.wagon_ratio);
                $('#vw-haulage-model').modal('show');
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

    //-------------------------foreign wagon upload form-------------------------------------------

    $('#ForeignWagonUpload').submit(function(e){
		e.preventDefault();
		spinner.show();
		$(".btn").prop('disabled', true);
		$(".btnSubmit").html('please wait...');
		$('#upload-alert').hide();

		$.ajax({
			url: "/foreign/wagon/tracking",
			type: "POST",
			dataType: "json",
			data:  new FormData(this),
			contentType: false,
			cache: false,
			processData: false,
			success: function(result) {
				if (result.info) {
					Swal.fire(
						'Success',
						result.info,
						'success'
					)
					$(".btn").prop('disabled', false);
					$(".btnSubmit").html('Upload File');
					$('input[type=file]').val(null);
                    $('#update_date').val(null);
					spinner.hide();
				} else {
					$(".btn").prop('disabled', false);
					$(".btnSubmit").html('Upload File');
					$('input[type=file]').val(null);
                    $('#update_date').val(null);
					spinner.hide();

					Swal.fire(
						'Oops..!',
						result.error,
						'error'
					)
				}
			},
			error: function(request,msg,error) {
				$(".btn").prop('disabled', false);
				$(".btnSubmit").html('Upload File');
				$('input[type=file]').val(null);
                $('#update_date').val(null);
                
				spinner.hide();

				Swal.fire(
					'Oops...',
					'Something went wrong!',
					'error'
				)
			}
		});
	});

    //============================================exceptions for foreign tracking================

    function formatDate(date) {
        var hours = date.getHours();
        var minutes = date.getMinutes();
        var ampm = hours >= 12 ? 'pm' : 'am';
        hours = hours % 12;
        hours = hours ? hours : 12; // the hour '0' should be '12'
        minutes = minutes < 10 ? '0'+minutes : minutes;
        var strTime = hours + ':' + minutes + ' ' + ampm;
        return (date.getMonth()+1) + "/" + date.getDate() + "/" + date.getFullYear();
      }

    var foreign_tracking_errors_dt = $('#foreign-tracking-errors-dt').DataTable({
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
            "url": '/interchange/exceptions',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "type": $('#error-type').val(),
                "filename": $('#error-filename').val(),
                "from": $('#from').val(),
                "to": $('#to').val()         
            }
        },
        "columns": [
           
            { "data": "filename"},
            {   
                "data": "user_id",
                "render": function(data, type, row) {
                    name = data == null ? ""  : row["first_name"] +" "+  row["last_name"];
                    return name;
                },
                "defaultContent": "<span></span>",
                "className": "text-center"
            },
            {
                "data": "inserted_at",
                "render": function(data, type, row) {
                     data = data.slice(0, data.length - 9)
                    return data;
                },
                "defaultContent": "<span></span>",
                "className": "text-center"
            },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return ' <a href= "/download/exception/file?filename=' + row.new_filename + '&path_key=cic_processed_dir"  class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill vw-auxiliary-off-hire" title= "View "> <i class= "la la-download"></i></a>'
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

    $('#foreign-tracking-report-filter').on('click', function() {
        foreign_tracking_errors_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.from = $('#from').val();
            data.to = $('#to').val();
            data.type = $('#error-type').val(),
            data.filename = $('#error-filename').val()
        });
        foreign_tracking_errors_dt.draw();
    });

    $('#foreign-tracking-report-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        foreign_tracking_errors_dt.draw();
    });

///-------------------------------------------demurrage------------------------------------
    var demurrage_dt = $('#demurrage-dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        data: [],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "charge_rate" },   
            { data: "arrival_dt" },
            { data: "date_placed" },
            { data: "date_offloaded" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'>\n <i class='la la-trash'></i></a> <a href='#' class='view_selected m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-eye'></i></a>" }
        ]
    });

    $('#add-demurrage').on('click', function() {
        if (($("#wagon_id").val() == "") ||
            ($("#charge_rate").val()== "") ||
            ($("#arrival_dt").val()== "") ||
            ($("#date_placed").val()== "") ||
            ($("#currency_id").val()== "") ||
            ($("#dt_placed_over_weekend").val()== "") ||
            ($("#date_offloaded").val()== "") ||
            ($("#total_charge").val()== "") ||
            ($("#date_cleared").val()== "") ||
            ($("#commodity_in_id").val()== "") ||
            ($("#commodity_out_id").val()== "") ||
            ($("#charge_rate").val()== "") )
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
        
        var data = [{
            "commodity_in": $('#commodity_in_id option:selected').data('commodity-description'),
            "commodity_out": $('#commodity_out_id option:selected').data('commodity-description'),
            "currency": $('#currency_id option:selected').data('currency'),
            "currency_id": $("#currency_id").val(),
            "wagon_id": $("#wagon_id").val(),
            "wagon_code": $("#mvt_wagon_code").val(),
            "wagon_owner": $("#wagon_owner").val(),
            "charge_rate": $("#charge_rate").val(),
            "arrival_dt": $("#arrival_dt").val(),
            "date_placed": $("#date_placed").val(),
            "dt_placed_over_weekend": $("#dt_placed_over_weekend").val(),
            "date_offloaded": $("#date_offloaded").val(),
            "date_loaded": $("#date_loaded").val(),
            "date_cleared": $("#date_cleared").val(),
            "commodity_in_id": $("#commodity_in_id").val(),
            "commodity_out_id": $("#commodity_out_id").val(),
            "yard": $("#yard").val(),
            "sidings": $("#sidings").val(),
            "total_days": $("#total_days").val(),
            "total_charge": $("#total_charge").val(),
        }, ];

        demurrage_dt.rows.add(data).draw(false);
        $('.clear-form').val('');
        $('.clear_selects').val(null).trigger("change");
    });

    $('#demurrage-dt tbody').on('click', '.remove_selected', function() {
        var $tr = $(this).closest('tr');
        demurrage_dt.row($tr).remove().draw(false);
    });

    $('#submit-demurrage').click(function() {
        
        if (demurrage_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        
        var details = {};
        var data_row = [];

        for (let index = 0; index < (demurrage_dt.rows().count()); index++) {
            data_row.push(Object.assign(demurrage_dt.rows().data()[index], details));
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
                    url: '/new/demurrage',
                    type: 'post',
                    data: {entries: data_row, _csrf_token: $("#csrf").val()},
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                         demurrage_dt.clear().rows.add([]).draw();
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

    $('#demurrage-dt tbody').on('click', '.view_selected', function() {
        var $tr = $(this).closest('tr');
        var data = demurrage_dt.row($tr).data();
        $("#vw-wagon-code").val(data.wagon_code);
        $("#vw-wagon-owner").val(data.wagon_owner);
        $("#vw-charge-rate").val(data.charge_rate);
        $("#vw-arrival-date").val(data.arrival_dt);
        $("#vw-date-placed-weekend").val(data.dt_placed_over_weekend);
        $("#vw-date-placed").val(data.date_placed);
        $("#vw-date-offloaded").val(data.date_offloaded);
        $("#vw-date-loaded").val(data.date_loaded);
        $("#vw-date-cleared").val(data.date_cleared);
        $("#vw-yard").val(data.yard);
        $("#vw-total-charge").val(data.total_charge);
        $("#vw-commodity-in").val(data.commodity_in);
        $("#vw-commodity-out").val(data.commodity_out);
        $("#vw-sidings").val(data.sidings);
        $("#vw-currency").val(data.currency);
        $("#vw-total").val(data.total_days);
        $('#view-demurrage-model').modal('show');  
    });

    var demurrage_report_dt = $('#demurrage-report-dt').DataTable({
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
            "url": '/demurrage/report',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "dt_offloaded_to": $('#dt_offloaded_to').val(),
                "administrator": $('#administrator').val(),
                "commodity_out": $('#commodity_out').val(),
                "dt_loaded_to": $('#dt_loaded_to').val(),
                "dt_loaded_from": $("#dt_loaded_from").val(),
                "commodity_in": $("#commodity_in").val(),
                "wagon_code": $('#wagon_code').val(),
                "wagon_owner": $('#wagon_owner').val(),
                "arrival_date_to": $('#arrival_date_to').val(),
                "arrival_date_from": $('#arrival_date_from').val(),
                "dt_offloaded_from": $('#dt_offloaded_from').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),   
            }
        },
        "columns": [
            { "data": "wagon_code" },
            { "data": "wagon_owner" },
            { "data": "charge_rate" },   
            { "data": "arrival_dt" },
            { "data": "date_placed" },
            { "data": "date_offloaded" },
            { "data": "total_charge" },
            {
                "data": "id",
                "render": function(data, type, row) {
                     return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view-item" title= "View "> <i class= "la la-eye"></i></a>'
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

    $('#demurrage-report-filter').on('click', function() {
        demurrage_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.administrator = $('#administrator').val();
            data.dt_offloaded_to = $('#dt_offloaded_to').val();
            data.commodity_out = $('#commodity_out').val();
            data.dt_loaded_to = $('#dt_loaded_to').val();
            data.dt_loaded_from = $('#dt_loaded_from').val();
            data.commodity_in = $("#commodity_in").val(),
            data.wagon_code = $('#wagon_code').val();
            data.arrival_date_to = $('#arrival_date_to').val();
            data.arrival_date_from = $('#arrival_date_from').val();
            data.wagon_owner = $('#wagon_owner').val();
            data.dt_offloaded_from = $('#dt_offloaded_from').val();
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        demurrage_report_dt.draw();
    });

    $('#demurrage-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        demurrage_report_dt.draw();
    });
    
    $('#demurrage-report-dt tbody').on('click', '.view-item', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/demurrage/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),
            },
            success: function(result) {
                spinner.hide();
                data = result.data
                $("#vw-wagon-code").val(data.wagon_code);
                $("#vw-wagon-owner").val(data.wagon_owner);
                $("#vw-charge-rate").val(data.charge_rate);
                $("#vw-arrival-date").val(data.arrival_dt);
                $("#vw-date-placed-weekend").val(data.dt_placed_over_weekend);
                $("#vw-date-placed").val(data.date_placed);
                $("#vw-date-offloaded").val(data.date_offloaded);
                $("#vw-date-loaded").val(data.date_loaded);
                $("#vw-date-cleared").val(data.date_cleared);
                $("#vw-yard").val(data.yard);
                $("#vw-total-charge").val(data.total_charge);
                $("#vw-commodity-in").val(data.commodity_in);
                $("#vw-commodity-out").val(data.commodity_out);
                $("#vw-sidings").val(data.sidings);
                $("#vw-total").val(data.total_days);
                $("#vw-currency").val(data.currency);
                $('#view-demurrage-model').modal('show');  
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

    $('#date_placed').on('change', function() {
        var date = $(this).val();
        day = get_day(date);

        if (day == 0) {
            var tomorrow = new Date(date);
            tomorrow.setDate(tomorrow.getDate() + 1);
            var next_date = tomorrow.toISOString().split('T')[0]
            $("#dt_placed_over_weekend").val(next_date);
        }else if (day == 6){
            var tomorrow = new Date(date);
            tomorrow.setDate(tomorrow.getDate() + 2);
            var next_date = tomorrow.toISOString().split('T')[0]
    
            $("#dt_placed_over_weekend").val(next_date);
        }else {
            $("#dt_placed_over_weekend").val(date);
        }
    });

    $('.demurrage-yard').on('change', function() {
        if (($("#arrival_dt").val()== "") ||
            ($("#date_placed").val()== "") ||
            ($("#commodity_in_id").val()== ""))
        {
            return false;
        }

        load_status = $('#commodity_in_id option:selected').data('load-status');
        if (load_status == "E") {
            $("#yard").val("0");
        } else {
            var date_placed = new Date($("#date_placed").val());
            var arrival_dt = new Date($("#arrival_dt").val());
            var difference = (date_placed.getDate() - arrival_dt.getDate()) -3;
            difference = difference > 0 ? difference : 0;
            $("#yard").val(difference);
        } 
    });

    $('.demurrage-sidings').on('change', function() {
        if (($("#date_offloaded").val()== "") ||
            ($("#dt_placed_over_weekend").val()== "") ||
            ($("#commodity_in_id").val()== ""))
        {
            return false;
        }

        var date_offloaded = new Date($("#date_offloaded").val());
        var dt_placed_over_weekend = new Date($("#dt_placed_over_weekend").val());
        var date_loaded = new Date($("#date_loaded").val());
        var difference 
        
        load_status = $('#commodity_in_id option:selected').data('load-status');
        if (load_status == "E") {
              if($("#date_loaded").val()== ""){
                difference = (date_offloaded.getDate() - dt_placed_over_weekend.getDate()) -3;
               
              }else{
                
                difference = (date_loaded.getDate() - dt_placed_over_weekend.getDate()) -3;
              }
        } else {
            if($("#date_loaded").val()== ""){
                difference = (date_offloaded.getDate() - dt_placed_over_weekend.getDate()) -3;
             }else{
               var diff1 = (date_loaded.getDate() - date_offloaded.getDate()) -3;
               var diff2 = (date_offloaded.getDate() - dt_placed_over_weekend.getDate()) -3;
               difference =(diff2 + diff1 );
             }
        } 

        difference = difference > 0 ? difference : 0;
        $("#sidings").val(difference); 

        var total = (parseInt(difference) + parseInt($("#yard").val()));
        $("#total_days").val(total);
        total_chg = ($("#charge_rate").val() * total);
        $("#total_charge").val(Number(total_chg).toFixed(2));
    });

    var current_acc_income_dt = $('#current-acc-income-dt').DataTable({
        bLengthChange: false,
        responsive: true,
        bInfo: false,
        ordering: false,
        columnDefs : [
            { targets: [1, 2, 3, 4, 5, 6, 7], className: 'text-right' },            
        ],
        lengthMenu: [
            [12],
            [12]
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
            },
            {
                extend: 'excelHtml5',
                messageTop: "INCOME",
                filename: "Current Account Income"
            },
            {
                extend: 'csvHtml5',
                messageTop: "INCOME",
                filename: "Current Account Income"
            },
            {
                extend: 'pdfHtml5',
                messageTop: "INCOME",
                filename: "Current Account Income"
            }
        ]
    });

    var current_acc_cost_dt = $('#current-acc-cost-dt').DataTable({
        bLengthChange: false,
        responsive: true,
        bInfo: false,
        ordering: false,
        columnDefs : [
            { targets: [1, 2, 3, 4, 5, 6, 7], className: 'text-right' },            
        ],
        lengthMenu: [
            [12],
            [12]
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
            },
            {
                extend: 'excelHtml5',
                messageTop: "COST",
                filename: "Current Account Cost"
            },
            {
                extend: 'csvHtml5',
                messageTop: "COST",
                filename: "Current Account Cost"
            },
            {
                extend: 'pdfHtml5',
                messageTop: "COST",
                filename: "Current Account Cost"
            }
        ]
    });

    var current_acc_summary_dt = $('#current-acc-summary-dt').DataTable({
        bLengthChange: false,
        responsive: true,
        bInfo: false,
        ordering: false,
        columnDefs : [
            { targets: [1, 2, 3], className: 'text-right' },            
        ],
        // lengthMenu: [
        //     [12],
        //     [12]
        // ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
            },
            {
                extend: 'excelHtml5',
                messageTop: "Current Account Summary",
                filename: "Current Account Summary"
            },
            {
                extend: 'csvHtml5',
                messageTop: "Current Account Summary",
                filename: "Current Account Summary"
            },
            {
                extend: 'pdfHtml5',
                messageTop: "Current Account Summary",
                filename: "Current Account Summary"
            }
        ]
    });

    if ($('#current-administrator').length) {
        var type = $('#current-administrator').attr('data-administrator');
        $('#current-administrator').val(type);
        $('#current-administrator').trigger('change');
    }

    if ($('#current-year').length) {
        var type = $('#current-year').attr('data-year');
        $('#current-year').val(type);
        $('#current-year').trigger('change');
    }

    if ($('#direction').length) {
        var type = $('#direction').attr('data-direction');
        $('#direction').val(type);
        $('#direction').trigger('change');
    }

    if ($('#edit-interchange-point').length) {
        var type = $('#edit-interchange-point').attr('data-interchange-point');
        $('#edit-interchange-point').val(type);
        $('#edit-interchange-point').trigger('change');
    }

    if ($('#edit-adminstrator-id').length) {
        var type = $('#edit-adminstrator-id').attr('data-adminstrator');
        $('#edit-adminstrator-id').val(type);
        $('#edit-adminstrator-id').trigger('change');
    }

    if ($('#edit-current-station').length) {
        var type = $('#edit-current-station').attr('data-current-station');
        $('#edit-current-station').val(type);
        $('#edit-current-station').trigger('change');
    }

    if ($('#edit-commodity').length) {
        var type = $('#edit-commodity').attr('data-commodity');
        $('#edit-commodity').val(type);
        $('#edit-commodity').trigger('change');
    }

    if ($('#edit-wagon-status').length) {
        var type = $('#edit-wagon-status').attr('data-wagon-status');
        $('#edit-wagon-status').val(type);
        $('#edit-wagon-status').trigger('change');
    }

    if ($('#edit-wagon-condition').length) {
        var type = $('#edit-wagon-condition').attr('data-wagon-condition');
        $('#edit-wagon-condition').val(type);
        $('#edit-wagon-condition').trigger('change');
    }

   

    // $('#interchange-wagon-tracking-dt tbody').on('click', '.wagon-condition', function(e) {
    //     e.preventDefault()
    //     var button = $(this);
    //     var admin =  button.attr("data-admin-id")
    //     var $tr = $(this).closest('tr');          
    //     wagon_row = $tr;
    //    $('#new-comment').val('');
    //    $('#condition_id').val(null);

    //     spinner.show();
    //     $.ajax({
    //         url: '/interchange/defect/lookup',
    //         type: 'POST',
    //         data: { id: button.attr("data-id"), _csrf_token: $("#csrf").val(),  admin: admin },
    //         success: function(result) {
    //             spinner.hide();
    //             var wagon = result.wagon;
    //             $('.clear').val('');
    //             $('#new-wagon').val(wagon.wagon_code);
    //             $('#new-wagon-owner').val(wagon.wagon_owner);
    //             $('#vw-on-hire-date').val(wagon.on_hire_date);
    //             $('#new-entry-id').val(wagon.id);
    //             $('#new-admin-id').val(admin);
    //             $('#new-on-hire-dt').val(wagon.on_hire_date);
           
    //             if (result.data.length < 1) {
    //                 dt_interchange_defect_approval.clear().rows.add([]).draw();
    //                 $('#wagon-condition-model').modal('show');
    //             } else {
    //                 var data_row = [];
    //                 var defect = {
    //                     "admin_id": button.attr("data-admin-id"),
    //                     "interchange_id": button.attr("data-id")
    //                 }
                    
    //                 for (let index = 0; index < (result.data.length); index++) {
    //                     
    //                     data_row.push(Object.assign(result.data[index], defect))
    //                 }
    //                 dt_interchange_defect_approval.clear().rows.add(data_row).draw();
    //                 $('#wagon-condition-model').modal('show');
    //             }
    //         },
    //         error: function(request, msg, error) {
    //             spinner.hide();
    //             swal({
    //                 title: "Oops...",
    //                 text: "Something went wrong!",
    //                 confirmButtonColor: "#EF5350",
    //                 type: "error"
    //             });
    //         }
    //     });
    // });



    var interchange_defect_edit_dt = $('#interchange-defect-edit-dt').DataTable({
        "responsive": true,
        "processing": true,
        'language': {
            'loadingRecords': '&nbsp;',
            processing: '<i class="fa fa-spinner fa-spin fa-2x fa-fw"></i><span class="sr-only">Loading...</span> '
        },
        "bLengthChange": false,
        "bPaginate": false,
        "bFilter": false,
        "bInfo": false,
        // "serverSide": true,
        // "paging": true,
        'ajax': {
            "type": "POST",
            "url": '/interchange/defect/lookup',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "admin": $('#edit-adminstrator-id').val(),
                "id": $('#entry_id').val(),
            }
        },
        "columns": [
            { "data": "equipment" },
            { "data": "code" },
            { "data": "count" },
            {
                "data": "amount",
                "render": function(data, type, row) {
                     return  row['currency'].concat(data)
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "className": "text-center"
            },
            {
                "data": "defect_id",
                "render": function(data, type, row) {
                     return '<a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view-item" title= "View "> <i class= "la la-eye"></i></a>' +
                     '<a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill delete" title= "Delete "> <i class= "la la-trash"></i></a>'
                },
                "defaultContent": "<span class='text-danger'>No Actions</span>",
                "className": "text-center"
            },
        ],
        "order": [
            [1, 'asc']
        ]
    });


    $('#edit-defects').on('change', function() {
        if(spare_loading) {
            return false;
        }
        spare_loading = true;
       
        var defect = {
            "equipment": $(this).find(':selected').attr('data-description'),
            "code": $(this).find(':selected').attr('data-code'),
            "admin_id": $("edit-adminstrator-id").val(),
            "defect_id": $(this).find(':selected').attr('data-id'),
            "interchange_id": $("#entry_id").val(),
            "edited": "yes"
        }

        spinner.show();
        $.ajax({
            url: '/admin/defect/spare/rates/lookup',
            type: 'POST',
            data: {
                date: $("#on_hire_date").val(),
                admin_id: $("#edit-adminstrator-id").val(),
                defect_id:  $(this).find(':selected').attr('data-id'),
                _csrf_token: $("#csrf").val(),

            },
            success: function(result) {
                spinner.hide();
                
               if(result.data.length > 0){
                  
                    var data_row = [];
                    
                    for (let index = 0; index < (result.data.length); index++) {
                    
                        data_row.push(Object.assign(result.data[index], defect))
                    }
                    
                    interchange_defect_edit_dt.rows.add(data_row).draw(false);
               }else{

                swal({
                    title: "Oops...",
                    text: "Spare rate not maintained for defect!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });

               }
                
                spare_loading = false;
            },

            error: function(request, msg, error) {
                spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
                spare_loading = false;
            }
        });
    });
  

    if ($('#interchange_point_id').length) {
        var type = $('#interchange_point_id').attr('data-interchange-point');
        $('#interchange_point_id').val(type);
        $('#interchange_point_id').trigger('change');
    }

    if ($('#equipment_id').length) {
        var type = $('#equipment_id').attr('data-equipment');
        $('#equipment_id').val(type);
        $('#equipment_id').trigger('change');
    }

    if ($('#adminstrator_id').length) {
        var type = $('#adminstrator_id').attr('data-admin');
        $('#adminstrator_id').val(type);
        $('#adminstrator_id').trigger('change');
    }

    if ($('#current_station_id').length) {
        var type = $('#current_station_id').attr('data-current-station');
        $('#current_station_id').val(type);
        $('#current_station_id').trigger('change');
    }

    if ($('#direction').length) {
        var type = $('#direction').attr('data-direction');
        $('#direction').val(type);
        $('#direction').trigger('change');
    }

    if ($('#locomotive_id').length) {
        var type = $('#locomotive_id').attr('data-loco');
        $('#locomotive_id').val(type);
        $('#locomotive_id').trigger('change');
    }

    if ($('#spare_id').length) {
        var type = $('#spare_id').attr('data-spare');
        $('#spare_id').val(type);
        $('#spare_id').trigger('change');
    }

    if ($('#payee_admin_id').length) {
        var type = $('#payee_admin_id').attr('data-payee');
        $('#payee_admin_id').val(type);
        $('#payee_admin_id').trigger('change');
    }

    $("#edit_wagon_code").on("input", function() {
        $.ajax({
            url: '/wagon/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                code: $("#edit_wagon_code").val()
            },
            success: function(result) {
                if (result.data.length < 1) {
                    $('#current_wagon_owner').val("");
                    $('#current_wagon_id').val("");
    
                } else {
                    $('#current_wagon_owner').val(result.data[0].wagon_owner);
                    $('#current_wagon_id').val(result.data[0].id); 
                }
            },
            error: function(request, msg, error) {
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });
    });

    $('#update-auxiliary-hire').click(function() {
        if (($('#direction').val() == "") ||
        ($('#interchange_point_id').val() == "") ||
        ($('#wagon_id').val() == "") ||
        ($('#total_accum_days').val() == "") ||
        ($('#current_station_id').val() == "") ||
        ($('#equipment_id').val() == "") ||
        ($('#modification_reason').val() == "") ||
        ($('#adminstrator_id').val() == "") 
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
                    url: '/modify/auxililary/hire',
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

    $('#interchange-defect-edit-dt tbody').on('click', '.delete', function() {
        var button = $(this);
        var $tr = $(this).closest('tr');
        var data= interchange_defect_edit_dt.row($tr).data();
       if( data.edited == "yes"){

            interchange_defect_edit_dt.row($tr).remove().draw(false);
            Swal.fire(
                'Success',
                'Deleted successfully!',
                'success'
            )
       }
       else{
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
                        url: '/delete/defects',
                        type: 'Post',
                        data: { defect_id: button.attr("data-id"), _csrf_token: $("#csrf").val(), interchange_id: $("#entry_id").val() },
                        success: function(result) {
                            spinner.hide();
                            interchange_defect_edit_dt.row($tr).remove().draw(false);
                            Swal.fire(
                                'Success',
                                'Deleted successfully!',
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
       }
    });


    $('#update-wagon-histroy').click(function() {

        if (($('#modification_reason').val() == "")) {
            swal({
                title: "Opps",
                text: "Modification reason can't be blank!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        var entry = {};
        $.each($('.edited-details').serializeArray(), function(i, field) {
            entry[field.name] = field.value;
        });

        var data_row = [];
        for (let index = 0; index < interchange_defect_edit_dt.rows().count(); index++) {
            data_row.push(Object.assign(interchange_defect_edit_dt.rows().data()[index], {}));
        }
        
        data_row = 
            data_row.filter(function new_defects(item) {
                return item.edited;
            })

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
                    url: '/update/wagon/hire',
                    type: 'post',
                    data: {
                        _csrf_token: $("#csrf").val(),
                        defects: data_row,
                        entry: entry
                    },
                    success: function(result) {
                        spinner.hide();
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
                spinner.hide();
                Swal.fire(
                    'Cancelled',
                    'Operation not performed :)',
                    'error'
                )
            }
        })
    });

    var wagon_turn_around_dt = $('#wagon-turn-around-dt').DataTable({
        bLengthChange: false,
        responsive: true,
        bInfo: false,
        ordering: false,
        columnDefs : [
            { targets: [1, 2, 3], className: 'text-right' },            
        ],
        dom: "<'row'<'col-sm-6 text-left'f><'col-sm-6 text-right'B>>\n\t\t\t<'row'<'col-sm-12'tr>>\n\t\t\t<'row'<'col-sm-12 col-md-5'i><'col-sm-12 col-md-7 dataTables_pager'lp>>",
        buttons: [
            {
                extend: 'copyHtml5',
            },
            {
                extend: 'excelHtml5',
                messageTop: "Wagon Turn Around",
                filename: "Wagon Turn Around"
            },
            {
                extend: 'csvHtml5',
                messageTop: "Wagon Turn Around",
                filename: "Wagon Turn Around"
            },
            {
                extend: 'pdfHtml5',
                messageTop: "INCOME",
                filename: "Wagon Turn Around"
            }
        ]
    });
       
    ///-----------------------------------------works order -----------------------------------------------

    var workers_order_dt = $('#workers-order-dt').DataTable({
        bLengthChange: false,
        bPaginate: false,
        responsive: true,
        bFilter: false,
        bInfo: false,
        data: [],
        columns: [
            { data: "wagon_code" },
            { data: "wagon_owner" },
            { data: "commodity" },   
            { data: "origin" },
            { data: "destination" },
            { data: "supplied" },
            { data: "action", "defaultContent": "<a href='#' class='remove_selected m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'>\n <i class='la la-trash'></i></a> <a href='#' class='view_selected m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='View'>\n <i class='la la-eye'></i></a>" }
        ]
    });

    $('#add-works-order').on('click', function() {
        if (($("#wagon_id").val() == "") ||
            ($("#origin_station_id").val()== "") ||
            ($("#time_out").val()== "") ||
            ($("#yard_foreman").val()== "") ||
            ($("#area_name").val()== "") ||
            ($("#train_no").val()== "") ||
            ($("#driver_name").val()== "") ||
            ($("#commodity_id").val()== "") ||
            ($("#departure_time").val()== "")||
            ($("#client_id").val()== "") ||
            ($("#time_arrival").val()== "") ||
            ($("#placed").val()== "") ||
            ($("#origin_station_id").val()== "") ||
            ($("#destin_station_id").val()== "") ||
            ($("#departure_date").val()== "") )
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
        
        var data = [{
            "commodity": $('#commodity_id option:selected').data('commodity'),
            "destination": $('#destin_station_id option:selected').data('station'),
            "origin": $('#origin_station_id option:selected').data('station'),
            "wagon_id": $("#wagon_id").val(),
            "wagon_code": $("#mvt_wagon_code").val(),
            "wagon_owner": $("#wagon_owner").val(),
            "comment": $("#comment").val(),
            "off_loading_date": $("#off_loading_date").val(),
            "order_no": $("#order_no").val(),
            "date_on_label": $("#date_on_label").val(),
            "time_out": $("#time_out").val(),
            "yard_foreman": $("#yard_foreman").val(),
            "area_name": $("#area_name").val(),
            "train_no": $("#train_no").val(),
            "driver_name": $("#driver_name").val(),
            "client_id": $("#client_id").val(),
            "departure_date": $("#departure_date").val(),
            "time_arrival": $("#time_arrival").val(),
            "load_date": $("#load_date").val(),
            "placed": $("#placed").val(),
            "wagon_id": $("#wagon_id").val(),
            "commodity_id": $("#commodity_id").val(),
            "departure_time": $("#departure_time").val(),
            "origin_station_id": $("#origin_station_id").val(),
            "destin_station_id": $("#destin_station_id").val(),
            "supplied": $("#supplied").val()
        }, ];

        workers_order_dt.rows.add(data).draw(false);
        $('.clear-form').val('');
        $('.clear_selects').val(null).trigger("change");
    });

    $('#workers-order-dt tbody').on('click', '.remove_selected', function() {
        var $tr = $(this).closest('tr');
        workers_order_dt.row($tr).remove().draw(false);
    });

    $('#workers-order-dt tbody').on('click', '.view_selected', function() {
        var $tr = $(this).closest('tr');
        var data = workers_order_dt.row($tr).data();
        $("#vw-order-no").val(data.order_no);
        $("#vw-remarks").val(data.comment);
        $("#vw-date-on-label").val(data.date_on_label);
        $("#vw-supplied").val(data.supplied);
        $("#vw-load-date").val(data.load_date);
        $("#vw-off-loading-date").val(data.off_loading_date);
        $('#view-works-order-model').modal('show');  
    });

    $('#submit-workers-order').click(function() {
        
        if (workers_order_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        
        var details = {};
        var data_row = [];

        for (let index = 0; index < (workers_order_dt.rows().count()); index++) {
            data_row.push(Object.assign(workers_order_dt.rows().data()[index], details));
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
                    url: '/new/works/order',
                    type: 'post',
                    data: {entries: data_row, _csrf_token: $("#csrf").val()},
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            workers_order_dt.clear().rows.add([]).draw();
                            $('.clear--form').val('');
                            $('.clear-required').val('');
                            $('.clear_selects').val(null).trigger("change");
                            $('.clear-required-selects').val(null).trigger("change");
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

    var works_order_report_dt = $('#works-order-report-dt').DataTable({
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
            "url": '/works/order/report',
            "data": {
                "_csrf_token": $("#csrf").val(),
                "client_id": $('#client_id').val(),
                "origin_station_id": $('#origin_station_id').val(),
                "destin_station_id": $('#destin_station_id').val(),
                "train_no": $("#train_no").val(),
                "commodity_id": $("#commodity_id").val(),
                "wagon_code": $('#wagon_code').val(),
                "departure_time": $('#departure_time').val(),
                "order_no": $('#order_no').val(),
                "departure_date": $('#departure_date').val(),
                "administrator_id": $('#administrator_id').val(),
                "from": $('#from').val(),
                "to": $('#to').val(),            
            }
        },
        "columns": [
            { "data": "client" },
            { "data": "wagon_code" },
            { "data": "commodity" },   
            { "data": "origin_station" },
            { "data": "destin_station" },
            { "data": "departure_date" },
            { "data": "departure_time" },
            {
                "data": "id",
                "render": function(data, type, row) {
                    return ' <a href= "#"  data-id="' + data + '" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill view-item" title= "View "> <i class= "la la-eye"></i></a>' +
                        '<a href= "/works/order/' + data + '/file"  data-id="" class= "m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill" title= "PDF"> <i class= "fa fa-file-pdf"></i></a>'
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

    $('#works-order-report-filter').on('click', function() {
        works_order_report_dt.on('preXhr.dt', function(e, settings, data) {
            data._csrf_token = $("#csrf").val();
            data.client_id= $('#client_id').val();
            data.origin_station_id= $('#origin_station_id').val();
            data.destin_station_id= $('#destin_station_id').val();
            data.train_no= $("#train_no").val();
            data.commodity_id= $("#commodity_id").val();
            data.wagon_code= $('#wagon_code').val();
            data.departure_time= $('#departure_time').val();
            data.order_no= $('#order_no').val();
            data.departure_date= $('#departure_date').val();
            data.administrator_id= $('#administrator_id').val();
            data.from= $('#from').val();
            data.to= $('#to').val(); 
            data.from = $('#from').val();
            data.to = $('#to').val();
        });
        works_order_report_dt.draw();
    });

    $('#works-order-reset-filter').on('click', function() {
        $('.select2_form').val(null).trigger("change");
        $('.clear_form').val('');
        $('#date_sent_from').val('');
        $('#date_sent_to').val('');
        works_order_report_dt.draw();
    });


    $('#works-order-report-dt tbody').on('click', '.view-item', function() {
        var button = $(this);
        $('.field-clr').val('');
        spinner.show();
        $.ajax({
            url: '/works/order/item/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                id: button.attr("data-id"),
            },
            success: function(result) {
                spinner.hide();
                data = result.data
                console.log(data.load_date)
                console.log(data.off_loading_date)
                $("#vw-wagon-code").val(data.wagon_code);
                $("#vw-wagon-owner").val(data.wagon_owner);
                $("#vw-area-name").val(data.area_name);
                $("#vw-train-no").val(data.train_no);
                $("#vw-time-out").val(data.time_out);
                $("#vw-remarks").val(data.comment);
                $("#vw-offloadingdate").val(data.off_loading_date);
                $("#vw-loaddate").val(data.load_date);
                $("#vw-order-no").val(data.order_no);
                $("#vw-commodity ").val(data.commodity);
                $("#vw-placed").val(data.placed);
                $("#vw-departure-time").val(data.departure_time);
                $("#vw-departure-date").val(data.departure_date);
                $("#vw-client").val(data.client);
                $("#vw-supplied").val(data.supplied);
                $("#vw-arrival-time").val(data.time_arrival);
                $("#vw-driver-name").val(data.driver_name);
                $("#vw-yard-foreman").val(data.yard_foreman);
                $('#view-work-order-model').modal('show');  
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

    if ($('#current-administrator').length) {
        var type = $('#current-administrator').attr('data-administrator');
        console.log(type)
        $('#current-administrator').val(type);
        $('#current-administrator').trigger('change');
    }

    if ($('#acc-summary-admin').length) {
        if( $('#acc-summary-admin').attr(' data-admins') != ''){
            var type = JSON.parse($('#acc-summary-admin').attr('data-admins'));
            $('#acc-summary-admin').val(type).trigger('change');
        }
       
    }

    var intransit_train_dt = $('#intransit-train-dt').DataTable({
        scrollY: "500vh",
        scrollX: !0,
        scrollCollapse: !0,
        bLengthChange: false,
        bPaginate: false,
        bFilter: false,
        orderable: !0,
        bSort: false,
        bInfo: false,
        'columnDefs': [
            { "width": "20px", "targets": '_all' },
        ],
        columns: [
            { data: "wagon_code"},
            { data: "origin" },
            { data: "destination"},
            { data: "commodity" },
            { data: "consigner" },
            { data: "consignee" },
            { data: "consigment_date"},
            { data: "station_code"},
            { data: "action", 
                  "defaultContent":
                     "<a href='#' class='remove_selected_row m-portlet__nav-link btn m-btn m-btn--hover-brand m-btn--icon m-btn--icon-only m-btn--pill' title='Delete'>\n <i class='la la-trash'></i></a>"
            }
        ]
    });     

    $('#attach-wagon').on('click', function() {
        if (($("#wagon_id").val() == "") ||
            ($("#origin_station_id").val()== "") ||
            ($("#consigner_id").val()== "") ||
            ($("#customer_id").val()== "") ||
            ($("#destin_station_id").val()== "") ||
            ($("#commodity_id").val()== "") ||
            ($("#consignee_id").val()== "") ||
            ($("#payer_id").val()== "") ||
            ($("#mvt_wagon_code").val()== "")||
            ($("#consigment_date").val()== ""))
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }

        var data = [{
            "commodity": $('#commodity_id option:selected').data('commodity'),
            "destination": $('#destin_station_id option:selected').data('station'),
            "origin": $('#origin_station_id option:selected').data('station'),
            "wagon_id": $("#wagon_id").val(),
            "wagon_code": $("#mvt_wagon_code").val(),
            "wagon_owner": $("#wagon_owner").val(),
            "consigner_id": $("#consigner_id").val(),
            "consigner": $('#consigner_id option:selected').data('client'),
            "consignee_id": $("#consignee_id").val(),
            "consignee": $('#consignee_id option:selected').data('client'),
            "consignee_id": $("#consignee_id").val(),
            "customer_id": $("#customer_id").val(),
            "has_consignmt": "NO",
            "station_code": $("#station_code").val(),
            "payer_id": $("#payer_id").val(),
            "wagon_id": $("#wagon_id").val(),
            "commodity_id": $("#commodity_id").val(),
            "consigment_date": $("#consigment_date").val(),
            "origin_station_id": $("#origin_station_id").val(),
            "destin_station_id": $("#destin_station_id").val(),
            "supplied": $("#supplied").val()
        }, ];

        intransit_train_dt.rows.add(data).draw(false);
        var count = intransit_train_dt.rows().count() 
        $("#total_wagon_count").text(count);
        $('.clear-form').val('');
        $('.clear_selects').val(null).trigger("change");
    });

    $('#intransit-train-dt tbody').on('click', '.remove_selected_row', function() {
        var $tr = $(this).closest('tr');
        intransit_train_dt.row($tr).remove().draw(false);
        var count = intransit_train_dt.rows().count() 
        $("#total_wagon_count").text(count);
    });

    $('#save-attached-wagon').click(function() {
        
        if (intransit_train_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
        
        var data_row =  intransit_train_dt.rows().data().toArray();

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
                    url: '/add/wagons/instransit/train',
                    type: 'post',
                    data: {
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        train_no: $("#train_no").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            window.location.replace("/train/intransit");
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

    $('#mvt-wagon-select-all').on( 'click', function () {
		verification_movement_dt.rows().select();
        verification_movement_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            selected_rows.push(data);
        } );
    });

    $('#mvt-wagon-unselect-all').on( 'click', function () {
        verification_movement_dt.rows( { selected: true } ).every( function ( rowIdx, tableLoop, rowLoop ) {
            var data = this.data();
            for( var i = 0; i < selected_rows.length; i++){ 
                                       
                if ( selected_rows[i] === data) { 
                    selected_rows.splice(i, 1);
                    return false;
                }
            }
            
        } );
		verification_movement_dt.rows().deselect();
    });


    $('#detach-mvt-wagon').click(function() {
        row = verification_movement_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        // $('#archive-auxiliary-date').val('');
        // $('#archive-auxiliary-remark').val('');
        $('#detach-wagon-model').modal('show');
    });

    $('#save-detached-wagon').click(function() {

        if (($("#detach_date").val() == "") ||
        ($("#detach_reason").val()== "") ||
        ($("#reporting_station_id").val()== ""))
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
        
        if (verification_movement_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
         
        var data_row = verification_movement_dt.rows( { selected: true } ).data().toArray()

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
                $('#detach-wagon-model').modal('hide');
                $.ajax({
                    url: '/detach/train/wagon',
                    type: 'post',
                    data: {
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        detach_date: $("#detach_date").val(),
                        detach_reason: $("#detach_reason").val(),
                        reporting_station_id: $("#reporting_station_id").val()   
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            location.reload();
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
   
    $('#attach-mvt-wagon').click(function() {
        row = verification_movement_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }

        $('#attach-wagon-model').modal('show');
    });

    $('#attach-detached-wagons').click(function() {

        if (($("#attached_date").val() == "") ||
        ($("#new-train").val()== ""))
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
        
        row = verification_movement_dt.rows( { selected: true } ).data()[0];
        if(!row){
            Swal.fire(
                'Oops..',
                'No Wagons selected!',
                'error'
            )
            return false;
        }
         
        var data_row = verification_movement_dt.rows( { selected: true } ).data().toArray()

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
                $('#attach-wagon-model').modal('hide');
                $.ajax({
                    url: '/attach/wagons',
                    type: 'post',
                    data: {
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        attached_date: $("#attached_date").val(),
                        train_no: $("#new-train").val(),
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            location.reload();
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

    $('#mvt-train-arrived').click(function() {
        // row = verification_movement_dt.rows( { selected: true } ).data()[0];
        // if(!row){
        //     Swal.fire(
        //         'Oops..',
        //         'No Wagons selected!',
        //         'error'
        //     )
        //     return false;
        // }

        // $('#archive-auxiliary-date').val('');
        // $('#archive-auxiliary-remark').val('');
        $('#arrival-train-model').modal('show');
    });

    $('#mark-train-as-arrived').click(function() {

        if (($("#arrival_date").val() == ""))
        {
            swal({
                title: "Opps",
                text: "ensure all required fields are filled!",
                confirmButtonColor: "#2196F3",
                type: "error"
            });
            return false;
        }
        
        if (verification_movement_dt.rows().count() < 1) {
            Swal.fire(
                'Oops..!',
                'No Entries found!',
                'error'
            )
            return false;
        }
         
        var data_row = verification_movement_dt.rows().data().toArray()

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
                $('#attach-wagon-model').modal('hide');
                $.ajax({
                    url: '/mark/train/arrived',
                    type: 'post',
                    data: {
                        entries: data_row,
                        _csrf_token: $("#csrf").val(),
                        arrival_date: $("#arrival_date").val(),
                        train_no: $("#train_no").val(),
                        train_list_no: $("#train_list_no").val()
                    },
                    success: function(result) {
                        spinner.hide();
                        if (result.info) {
                            Swal.fire(
                                'Success',
                                'Successfully Saved!',
                                'success'
                            )
                            window.location.replace("/train/intransit");
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

    $('#station_code').on('input', function(){
        $.ajax({
            url: '/station/code/lookup',
            type: 'POST',
            data: {
                _csrf_token: $("#csrf").val(),
                station_code: $("#station_code").val()
            },
            success: function(result) {
                if (result == true) {
                    Swal.fire(
                        'Oops..',
                        'A consignment with the same PZ code already exists',
                        'error'
                    )
                }
            },
            error: function(request, msg, error) {
                // spinner.hide();
                swal({
                    title: "Oops...",
                    text: "Something went wrong!",
                    confirmButtonColor: "#EF5350",
                    type: "error"
                });
            }
        });

    });
});