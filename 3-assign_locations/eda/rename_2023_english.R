library('haven')
library("dplyr")
library(tibble)
library(tidyr)
library(readr)
library("this.path")
library(datasets)  
library(dplyr)


# 
# library(stringr)
# library(sjlabelled)
library(dplyr)
library(purrr)
library(labelled)

setwd(this.path::this.dir())




setwd(this.path::this.dir())
setwd('../../../dhzw_data/odin-ovin')
df <- read_sav("2023_ODiN.sav")
setwd(this.path::this.dir())
mapping <- read_excel("mapping.xlsx") # Columns: NL, EN

all_labels <- var_label(df)

label_vector <- unlist(lapply(all_labels, as.character))


writeLines(label_vector, "variable_labels.txt")



# 1. Read the edited lines from the text file
new_label_values <- readLines("eng.txt")

# 2. Ensure the length matches the number of columns in df
if(length(new_label_values) == ncol(df)) {
  
  # 3. Re-assign labels using a named list for safety
  # This maps each new label to the corresponding column name
  new_label_list <- setNames(as.list(new_label_values), names(df))
  
  var_label(df) <- new_label_list
  
} else {
  stop("Dimension mismatch: 'en.txt' line count does not match 'df' column count.")
}
setwd(this.path::this.dir())
setwd('../../../dhzw_data/odin-ovin')
write_sav(df, "2023_ODiN_EN.sav")



# # attributes(df[[1]])
# 
# subheadings <- map_chr(df, ~ attr(.x, "label") %||% NA_character_)
# 
# 
# mapping <- mapping %>%
#   mutate(
#     NL = str_squish(NL),
#     EN = str_squish(EN)
#   ) %>%
#   filter(NL != "" & EN != "")
# 
# label_vec <- setNames(mapping$EN, mapping$NL)
# 
# 
# missing_vars <- setdiff(subheadings, names(label_vec))
# 
# full_translation_map <- c(label_vec, setNames(missing_vars, missing_vars))
# 
# 
# english_lables <- full_translation_map[subheadings]
# 
# df <- set_label(df, label = final_label_vec)
# 
# setwd(this.path::this.dir())
# setwd('../../../dhzw_data/odin-ovin')
# write_sav(df, "2023_ODiN_EN.sav")


# Clear packages
detach("package:datasets", unload = TRUE)

# Clear plots
dev.off()  # But only if there IS a plot

# Clear console
cat("\014")  # ctrl+L
