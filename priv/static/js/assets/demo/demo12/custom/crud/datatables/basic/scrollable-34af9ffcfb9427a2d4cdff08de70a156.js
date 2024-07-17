var DatatablesBasicScrollable = {
    init: function() {
        $("#m_table_2").DataTable({
                scrollY: "50vh",
                scrollX: !0,
                scrollCollapse: !0,
                columnDefs: [{
                        targets: -1,
                        title: "Actions",
                        orderable: !1,

                    },

                    {

                    }
                ]
            }),
            $("#m_table_2").DataTable({
                scrollY: "50vh",
                scrollX: !0,
                scrollCollapse: !0


            })
    }
};
jQuery(document).ready(function() {
    DatatablesBasicScrollable.init()
});