# Assume the synthetic population ot be correct
# so simply return them, without doing any processing.
run_synthetic_population <- function(output_dir, population_source_file, experiment_id, df_households_csv, DHZW_pc4_codes_csv) {
  if (is.na(experiment_id)) {
    stop("No experiment id") # Do some processing of experiment id to make sure file is processed when changing experiment id
  }

  # Verify source file exists
  if (!file.exists(population_source_file)) {
    stop(paste("Source file not found:", population_source_file))
  }
  synthetic_population_csv <- file.path(output_dir, "synthetic_population.csv")

  if (experiment_id == "synth_pop") {
    df_gen_synth_pop <- read_csv(population_source_file)
    df_households <- read_csv(df_households_csv)

    reformat_synth_pop <- reformat_gen_synth_pop_to_correct_format(df_gen_synth_pop, df_households, DHZW_pc4_codes_csv)

    write_csv(reformat_synth_pop, synthetic_population_csv)
  } else {
    success <- file.copy(from = population_source_file, to = synthetic_population_csv, overwrite = TRUE)

    if (!all(success)) {
      stop("Failed to copy one or more synth_pop_files")
    }
  }
  return(synthetic_population_csv)
}

run_synthetic_households <- function(output_dir, population_source_file, experiment_id, df_households_csv, DHZW_pc4_codes_csv) {
  synthetic_households_csv <- file.path(output_dir, "synthetic_households.csv")

  if (experiment_id == "synth_pop") {
    df_gen_synth_pop <- read_csv(population_source_file)
    df_households <- read_csv(df_households_csv)

    reformatted_households <- reformat_households_to_correct_format(df_gen_synth_pop, df_households, DHZW_pc4_codes_csv)
    write_csv(reformatted_households, synthetic_households_csv)
  } else {
    success <- file.copy(from = df_households_csv, to = synthetic_households_csv, overwrite = TRUE)

    if (!all(success)) {
      stop("Failed to copy one or more synth_pop_files")
    }
  }
  return(synthetic_households_csv)
}
