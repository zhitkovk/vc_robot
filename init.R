library('data.table')
library('magrittr')
library('ggplot2')

# data ---------------------------------------------------
tr <- fread("data/train_data.csv")
te <- fread("data/test_data.csv")
