test_that(".nyc_coerce_types handles empty or non-character columns", {
  coerce <- nycOpenData:::.nyc_coerce_types

  # Trigger the "nrow(df) == 0" branch
  empty_df <- data.frame(a = character(0))
  expect_equal(nrow(coerce(empty_df)), 0)

  # Trigger the "if (!is.character(x)) next" branch
  df_mixed <- data.frame(a = c(1, 2), b = c("true", "false"))
  res <- coerce(df_mixed)
  expect_type(res$a, "double") # Should remain double, not touched by logic
})

test_that(".nyc_add_filters handles quotes and empty strings", {
  add_f <- nycOpenData:::.nyc_add_filters

  # Test the single quote escape logic
  q <- add_f(list(), list(name = "O'Reilly"))
  expect_match(q[["$where"]], "''")

  # Trigger the .nyc_abort for empty/whitespace values
  expect_error(add_f(list(), list(agency = " ")), "cannot be empty")
})

test_that(".nyc_add_where appends correctly", {
  add_w <- nycOpenData:::.nyc_add_where

  # Initial where
  q <- list("$where" = "a = 1")
  res <- add_w(q, "b = 2")
  expect_equal(res[["$where"]], "(a = 1) AND (b = 2)")
})

test_that(".nyc_build_date_where handles partial ranges", {
  builder <- nycOpenData:::.nyc_build_date_where

  # From only
  res_from <- builder("test_date", from = "2025-01-01")
  expect_match(res_from, ">= '2025-01-01T00:00:00.000'")

  # To only
  res_to <- builder("test_date", to = "2025-01-01")
  expect_match(res_to, "< '2025-01-01T00:00:00.000'")
})


test_that(".nyc_build_date_where throws errors on conflicting args", {
  builder <- nycOpenData:::.nyc_build_date_where

  expect_error(
    builder("my_date", date = "2025-01-01", from = "2025-01-01"),
    "not both"
  )

  # Trigger the NULL date_field branch
  expect_null(builder(NA_character_, date = "2025-01-01"))
})
