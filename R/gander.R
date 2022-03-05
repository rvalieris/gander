
col_type_class = function(col_class) {
    if(length(intersect(col_class, c("ts","numeric","integer","double","Date","POSIXct","POSIXt")))>0) {
        return("continuous")
    } else if(length(intersect(col_class, c("factor","ordered","character","logical")))>0) {
        return("discrete")
    } else if(length(intersect(col_class, c("list")))>0) {
        return("list")
    } else {
        return("other")
    }
}

gander_col = function(col, cn) {
    df = tibble(val=col)
    na_vals = nrow(filter(df, is.na(val)))
    x_label = ifelse(na_vals>0, paste0(cn,", NA vals: ",na_vals), cn)
    df = filter(df, !is.na(val))

    if(col_type_class(class(col)) == "list") {
        df = unnest_longer(df, val)
    }
    
    p = ggplot(df,aes(x=val)) + labs(x=x_label)

    if(col_type_class(class(df$val)) == "continuous") {
        p + geom_histogram(bins=30)
    } else if(col_type_class(class(df$val)) == "discrete") {
        p + geom_bar() +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE))
    } else {
        message(paste0("skipping column: ",cn, ", col type not supported."))
    }
}

gander_col2 = function(col1, cn1, col2, cn2) {
    df = tibble(val1=col1, val2=col2)
    na_vals1 = nrow(filter(df, is.na(val1)))
    na_vals2 = nrow(filter(df, is.na(val2)))
    df = filter(df, !is.na(val1), !is.na(val2))
    x_label = ifelse(na_vals1>0, paste0(cn1,", NA vals: ",na_vals1), cn1)
    y_label = ifelse(na_vals2>0, paste0(cn2,", NA vals: ",na_vals2), cn2)

    if(col_type_class(class(col1)) == "list") {
        df = unnest_longer(df, val1)
    }
    if(col_type_class(class(col2)) == "list") {
        df = unnest_longer(df, val2)
    }
    
    p = ggplot(df, aes(x=val1, y=val2)) + labs(x=x_label, y=y_label)

    if(col_type_class(class(df$val1)) == "continuous" && col_type_class(class(df$val2)) == "continuous") {
        p + geom_point()
    } else if(col_type_class(class(df$val1)) == "discrete" && col_type_class(class(df$val2)) == "continuous") {
        p + geom_boxplot() +
         scale_x_discrete(guide = guide_axis(check.overlap = TRUE))
    } else if(col_type_class(class(df$val1)) == "continuous" && col_type_class(class(df$val2)) == "discrete") {
        p + geom_boxplot() +
         scale_y_discrete(guide = guide_axis(check.overlap = TRUE))
    } else if(col_type_class(class(df$val1)) == "discrete" && col_type_class(class(df$val2)) == "discrete"){
        p + geom_bin_2d() + coord_cartesian(expand=0) +
        stat_bin2d(size=6,geom = "text", aes(label = ..count..)) + scale_fill_viridis() +
        scale_x_discrete(guide = guide_axis(check.overlap = TRUE)) +
        scale_y_discrete(guide = guide_axis(check.overlap = TRUE))
    } else {
        message(paste0("skipping combo: ",cn1, "/", cn2,", col type not supported."))
    }
}


#' plot all columns of a data.frame
#'
#' @param df A tibble or data.frame
#' @param ... an optional target column
#'
#' @export
#'
#' @examples
#' gander(iris)
gander = function(df, ...) {
    target_cols = map_chr(enquos(...), as_label)
    if(class(df)[[1]] == 'table') {
        df = as_tibble(df) %>% uncount(n)
    }
    if(class(df)[[1]] %in% c("mts","ts")) {
        df = as_tibble(df) %>% mutate(time=time(df))
    }
    if(length(intersect(class(df),c("data.frame","tbl_df"))>0)) {
        old_theme = theme_set(theme_cowplot())
        if(length(target_cols)>0) {
            sel = dplyr::select(df, all_of(target_cols))
            sel2 = dplyr::select_at(df, setdiff(names(df), target_cols))
            
            p = map2(colnames(sel2), sel2, function(cn, y) { gander_col2(pull(sel,1), names(sel)[[1]], y, cn) }) %>% compact() %>% plot_grid(plotlist=.)
        } else {
            p = map2(colnames(df), df, function(cn, y) { gander_col(y, cn) }) %>% compact() %>% plot_grid(plotlist=.)
        }
        theme_set(old_theme)
        return(p)
    } else {
        stop(paste0("\"", class(df), "\" type not supported."))
    }
}
