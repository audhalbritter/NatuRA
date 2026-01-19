library(tidyverse)
library(dataDocumentation)

threeD_meta <- create_threed_ZA_meta_data()

tomst <- read_csv("raw_data/NaturA_metadata_microclimate_2026.csv") |>
select(loggerID:date_out) |> 
slice(1:20) |>
rename(destSiteID = destSiteID...2) |>
mutate(
    # Normalize destSiteID to match threeD_meta format (capitalize first letter)
    destSiteID = case_when(
        destSiteID == "high" ~ "High",
        destSiteID == "med" ~ "Mid",
        destSiteID == "low" ~ "Low",
        TRUE ~ destSiteID
    ),
    # Clean turfID:
    # e.g., "4 AN1C a" -> "4 AN1C 4"
    turfID = if_else(
        turfID == "4 AN1C a",
        "4 AN1C 4",
        turfID
    )
)

# desired plots for tomst loggers
threeD_meta |>
    tidylog::filter(grazing != "N") |>
    tidylog::filter(Namount_kg_ha_y %in% c(0, 5, 10, 50, 100)) |> 
    tidylog::filter(Nlevel != 3) |>
    tidylog::full_join(tomst, by = c("destSiteID", "destBlockID", "turfID")) |>
    mutate(comment = if_else(destBlockID == 5, "Block 5 loggers should be moved", NA_character_)) |>
    write_csv("clean_data/NatuRA_Tomst_metadata_2026.csv")
