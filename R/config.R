# ===================== KONFIG =====================
# Central configuration for the Roban Shiny app.
# All environment-specific constants live here.
# Source this file at the top of app.R.
# NOTE: sourced without local=, so all variables land in .GlobalEnv.

# ---- Autentisering -------------------------------------------------------
# Sourced without local= so DB_PATH and PASSPHRASE land in .GlobalEnv,
# making them visible to shinymanager's observer when it re-evaluates
# check_credentials(DB_PATH, passphrase = PASSPHRASE) via rlang::enexpr.
DB_PATH <- "credentials.sqlite"

PASSPHRASE <- Sys.getenv(
  "SHINYMANAGER_PASSPHRASE",
  unset = "Intaktsmotorn042026!"   # local dev fallback only
)
# --------------------------------------------------------------------------

# Path to the Excel workbook used as the data store.
# Relative to the app working directory (project root when launched via shiny::runApp).
TARGET_XLSX <- file.path("data", "Base_data.xlsx")

# Revenue threshold above which the bonus percentage applies (SEK / month).
BONUS_THRESHOLD <- 100000

# Date columns per sheet — used by normalize_wb_dates() to coerce date fields
# after reading the workbook from disk.
DATE_COLS_MASTER <- list(
  "Konsulter"              = c("startdatum", "slutdatum"),
  "Uppdrag"                = c("startdatum", "slutdatum"),
  "Uppgift"                = c("startdatum", "created_at"),
  "Tidrapportering"        = c("startdatum", "slutdatum", "created_at"),
  "TimprisHistory"         = c("created_at"),
  "GrundlonHistory"        = c("created_at"),
  "BonusHistory"           = c("created_at"),
  "GroupBonusHistory"      = c("created_at"),
  "SalesBonusHistory"      = c("created_at"),
  "Maklare"                = c("created_at"),
  "Kunder"                 = c("created_at"),
  "ArbetstimmarGrund"      = c("date"),
  "FaktureringInformation" = c(),
  "BonusRapportering"      = c("start_date", "end_date", "created_at")
)
