var Select2 = {
    init: function() {
        $(".m_select2_1, .m_select2_1_validate").select2({
            placeholder: "Select an option"
        }), $("#m_select2_2, #m_select2_2_validate").select2({
            placeholder: "Select an option"
        }), $(".multi_select2_form, .multi_select2_form_validate").select2({
            placeholder: "Select an option"
        }), $(".select2_form").select2({
            placeholder: "Select an option",
            allowClear: !0
        }), $("#m_select2_5").select2({
            placeholder: "Select a value",
            data: [{
                id: 0,
                text: "Enhancement"
            }, {
                id: 1,
                text: "Bug"
            }, {
                id: 2,
                text: "Duplicate"
            }, {
                id: 3,
                text: "Invalid"
            }, {
                id: 4,
                text: "Wontfix"
            }]
        }), 
        $(".js-data-locomotive-ajax").select2({
            placeholder: "Search for locomotive number",
            allowClear: !0,
            ajax: {
                url: "/ajax/select/locomotive",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'loco', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".ajax-movement-loco-no-search").select2({
            placeholder: "Search for locomotive number",
            allowClear: !0,
            ajax: {
                url: "/movement/search/locono",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'loco', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-station-ajax").select2({
            placeholder: "Search for station name",
            allowClear: !0,
            ajax: {
                url: "/ajax/search/station",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'station', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-station-name-ajax").select2({
            placeholder: "Search for station name",
            allowClear: !0,
            ajax: {
                url: "/movement/search/station",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'station', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".ajax-search-wagon-stn").select2({
            placeholder: "Search for station name",
            allowClear: !0,
            ajax: {
                url: "/station/search",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'station', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".ajax-search-wagon-spare").select2({
            placeholder: "Search for the spare name",
            allowClear: !0,
            ajax: {
                url: "/spare/search",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'spare', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-consign-search-station").select2({
            placeholder: "Search for station name",
            allowClear: !0,
            ajax: {
                url: "/ajax/search/consign/station",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'station', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-consign-search-cmmdity").select2({
            placeholder: "Search for commodity name",
            allowClear: !0,
            ajax: {
                url: "/ajax/search/consign/commodity",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'commodity', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-users-ajax").select2({
            placeholder: "Search for the name",
            allowClear: !0,
            ajax: {
                url: "/ajax/search/user",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'user', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-search_client-ajax").select2({
            placeholder: "Search for the client",
            allowClear: !0,
            ajax: {
                url: "/ajax/search/client",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'client', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
        $(".js-search-transport-type").select2({
            placeholder: "Search for the transport type",
            allowClear: !0,
            ajax: {
                url: "/search/transport/type",
                dataType: 'json',
                delay: 250,
                data: function (params) {
                    return {
                      search: params.term || 'transport', // search term
                      page: params.page || 0
                    };
                },
                processResults: function (data, params) {
    
                    // parse the results into the format expected by Select2
                    // since we are using custom formatting functions we do not need to
                    // alter the remote JSON data, except to indicate that infinite
                    // scrolling can be used
                    params.page = params.page || 1;
    
                    return {
                        results: data.results,
                        pagination: {
                            more: (params.page * 50) < data.total_count
                        }
                    };
                }
                // cache: true
            },
            minimumInputLength: 1,
            allowClear: true
        }),
         $("#m_select2_12_1, #m_select2_12_2, #m_select2_12_3, #m_select2_12_4").select2({
            placeholder: "Select an option"
        }), $("#m_select2_7").select2({
            placeholder: "Select an option"
        }), $("#m_select2_8").select2({
            placeholder: "Select an option"
        }), $("#m_select2_9").select2({
            placeholder: "Select an option",
            maximumSelectionLength: 2
        }), $("#m_select2_10").select2({
            placeholder: "Select an option",
            minimumResultsForSearch: 1 / 0
        }), $("#m_select2_11").select2({
            placeholder: "Add a tag",
            tags: !0
        }), $(".m-select2-general").select2({
            placeholder: "Select an option"
        }), $(".model_select_2").on("shown.bs.modal", function() {
            $("#m_select2_1_modal").select2({
                placeholder: "Select an option"
            }), $("#m_select2_2_modal").select2({
                placeholder: "Select an option"
            }), $(".multi_select2_modal").select2({
                placeholder: "Select an option"
            }), $(".select2_modal").select2({
                placeholder: "Select an option",
                allowClear: !0
            })
        })
    }
};
jQuery(document).ready(function() {
    Select2.init()
});