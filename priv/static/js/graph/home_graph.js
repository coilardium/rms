var chart = AmCharts.makeChart("chartdiv", {
  "type": "serial",
  "theme": "light",
  "dataDateFormat": "YYYY-MM-DD",
  "precision": 2,
  "valueAxes": [{
    "id": "v1",
    "title": "Total Sms Transactions",
    "position": "left",
    "autoGridCount": true
  }],
  "graphs": [{
    "id": "g3",
    "valueAxis": "v1",
    "lineColor": "#033c99",
    "fillColors": "#033c99",
    "fillAlphas": 1,
    "type": "column",
    "title": "Sent",
    "valueField": "sent",
    "clustered": true,
    "columnWidth": 1.0,
    "legendValueText": "[[value]]",
    "balloonText": "[[title]]<br /><b style='font-size: 130%'>[[value]]</b>"
  }, {
    "id": "g4",
    "valueAxis": "v1",
    "lineColor": "#617e08",
    "fillColors": "#617e08",
    "fillAlphas": 1,
    "type": "column",
    "title": "Failed",
    "valueField": "failed",
    "clustered": false,
    "columnWidth": 0.6,
    "legendValueText": "[[value]]",
    "balloonText": "[[title]]<br /><b style='font-size: 130%'>[[value]]</b>"
  }],
  "chartCursor": {
    "pan": true,
    "valueLineEnabled": true,
    "valueLineBalloonEnabled": true,
    "cursorAlpha": 0,
    "valueLineAlpha": 0.2
  },
  "categoryField": "date",
  "categoryAxis": {
    "parseDates": true,
    "dashLength": 1,
    "minorGridEnabled": true
  },
  "legend": {
    "useGraphSettings": false,
    "position": "top"
  },
  "balloon": {
    "borderThickness": 1,
    "shadowAlpha": 0
  },
  "export": {
   "enabled": false
  },
  "dataProvider": [{
    "date": "2013-02-07",
    "failed": "<%= @summary[:first_week]["failed"] %>",
    "sent": "<%= @summary[:first_week]["sent"] %>"
  }, {
    "date": "2013-02-14",
    "failed": "<%= @summary[:second_week]["failed"] %>",
    "sent": "<%= @summary[:second_week]["sent"] %>"
  }, {
    "date": "2013-02-21",
    "failed": "<%= @summary[:third_week]["failed"] %>",
    "sent": "<%= @summary[:third_week]["sent"] %>"
  }, {
    "date": "2013-02-28",
    "failed": "<%= @summary[:fourth_week]["failed"] %>",
    "sent": "<%= @summary[:fourth_week]["sent"] %>"
  }]
});