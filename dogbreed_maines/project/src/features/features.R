library(data.table)

data <- fread("./project/volume/data/raw/data.csv")

fwrite(data, "./project/volume/data/interim/p_data.csv")
