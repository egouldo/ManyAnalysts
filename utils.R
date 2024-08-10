# Helper Functions
round_pluck <- function(data, x){pluck(data, x, \(y) round(y, 2))}

gt_fmt_yi <- function(gt_tbl, columns, ...) {
  gt_tbl %>% 
    gt::fmt(!!columns, 
            fns = function(x) str_replace(x, "y25", gt::md("$$y_{25}$$")) %>% 
              str_replace("y50", gt::md("$$y_{50}$$")) %>%
              str_replace("y75", gt::md("$$y_{75}$$")),
            ...)
}
