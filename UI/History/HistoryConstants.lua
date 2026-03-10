local _, NS = ...

local HistoryConstants = {
    ROW_HEIGHT = 40,
    ROW_SPACING = 44,
    DETAILS_LOCATION_FILTER_ALL = "__all__",

    DATE_FILTER_ALL = "__all_time__",
    DATE_FILTER_TODAY = "__today__",
    DATE_FILTER_YESTERDAY = "__yesterday__",
    DATE_FILTER_LAST_7_DAYS = "__last_7_days__",
    DATE_FILTER_THIS_MONTH = "__this_month__",
}

HistoryConstants.DATE_FILTER_OPTIONS = {
    { key = HistoryConstants.DATE_FILTER_ALL, label = "All time" },
    { key = HistoryConstants.DATE_FILTER_TODAY, label = "Today" },
    { key = HistoryConstants.DATE_FILTER_YESTERDAY, label = "Yesterday" },
    { key = HistoryConstants.DATE_FILTER_LAST_7_DAYS, label = "Last 7 days" },
    { key = HistoryConstants.DATE_FILTER_THIS_MONTH, label = "This month" },
}

NS.HistoryConstants = HistoryConstants
