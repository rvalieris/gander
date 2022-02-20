suppressPackageStartupMessages({
library(tidyverse)
library(cowplot)
library(viridis)
theme_set(theme_cowplot())
})

col_type_class = function(col_class) {
    if(length(intersect(col_class, c("ts","numeric","integer","double","Date","POSIXct","POSIXt")))>0) {
        return("continuous")
    } else if(length(intersect(col_class, c("factor","ordered","character","logical")))>0) {
        return("discrete")
    } else {
        stop(paste0("column type \"",col_class, "\" unknown."))
    }
}

gander_col = function(col, cn) {
    df = tibble(val=col)
    na_vals = nrow(filter(df, is.na(val)))
    df = filter(df, !is.na(val))
    if(col_type_class(class(col)) == "continuous") {
        ggplot(df,aes(x=val)) + geom_histogram(bins=30) +
        labs(x=ifelse(na_vals>0, paste0(cn,", NA vals: ",na_vals), cn))
    } else if(col_type_class(class(col)) == "discrete") {
        ggplot(df,aes(x=val)) + geom_bar() +
        labs(x=ifelse(na_vals>0, paste0(cn,", NA vals: ",na_vals), cn))
    }
}

gander_col2 = function(col1, cn1, col2, cn2) {
    df = tibble(val1=col1, val2=col2)
    na_vals1 = nrow(filter(df, is.na(val1)))
    na_vals2 = nrow(filter(df, is.na(val2)))
    df = filter(df, !is.na(val1), !is.na(val2))
    if(col_type_class(class(col1)) == "continuous" && col_type_class(class(col2)) == "continuous") {
        ggplot(df, aes(x=val1, y=val2)) + geom_point() +
        labs(x=ifelse(na_vals1>0, paste0(cn1,", NA vals: ",na_vals1), cn1),
             y=ifelse(na_vals2>0, paste0(cn2,", NA vals: ",na_vals2), cn2))
    } else if((col_type_class(class(col1)) == "discrete" && col_type_class(class(col2)) == "continuous") || 
              (col_type_class(class(col1)) == "continuous" && col_type_class(class(col2)) == "discrete")) {
        ggplot(df, aes(x=val1, y=val2)) + geom_boxplot() +
        labs(x=ifelse(na_vals1>0, paste0(cn1,", NA vals: ",na_vals1), cn1),
             y=ifelse(na_vals2>0, paste0(cn2,", NA vals: ",na_vals2), cn2))
    } else {
        ggplot(df, aes(x=val1, y=val2)) + geom_bin_2d() + coord_cartesian(expand=0) +
        stat_bin2d(size=6,geom = "text", aes(label = ..count..)) + scale_fill_viridis() +
        labs(x=ifelse(na_vals1>0, paste0(cn1,", NA vals: ",na_vals1), cn1),
             y=ifelse(na_vals2>0, paste0(cn2,", NA vals: ",na_vals2), cn2))
    }
}

gander = function(.data, ...) {
    target_cols = map_chr(enquos(...), as_label)
    if(class(.data)[[1]] == 'table') {
        .data = as_tibble(.data) %>% uncount(n)
    }
    if(class(.data)[[1]] %in% c("mts","ts")) {
        x = .data
        .data = mutate(as_tibble(x),time=time(x))
    }
    if(length(intersect(class(.data),c("data.frame","tbl_df"))>0)) {
        if(length(target_cols)>0) {
            sel = dplyr::select(.data, all_of(target_cols))
            sel2 = dplyr::select_at(.data, setdiff(names(.data), target_cols))
            lapply(1:ncol(sel2), function(y, n, i) { gander_col2(pull(sel,1), names(sel)[[1]], pull(y,i), n[[i]]) }, y=sel2, n=names(sel2)) %>% plot_grid(plotlist=.)
        } else {
            lapply(1:ncol(.data), function(y, n, i) { gander_col(pull(y,i), n[[i]]) }, y=.data, n=names(.data)) %>% plot_grid(plotlist=.)
        }
    } else {
        stop(paste0("\"", class(.data), "\" type not supported."))
    }
}