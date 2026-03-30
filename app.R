source("renv/activate.R")

###############################################
# app.R — Förenklad Excel-struktur


graphics.off()



library(shiny)
library(shinymanager)
library(readxl)
library(writexl)
library(janitor)
library(dplyr)
library(lubridate)
library(stringr)
library(rhandsontable)

# ===================== KONFIG =====================

source("R/config.R",               encoding = "UTF-8")
source("R/helpers_core.R",         local = environment(), encoding = "UTF-8")
source("R/helpers_ids_labels.R",   local = environment(), encoding = "UTF-8")
source("R/helpers_hot.R",          local = environment(), encoding = "UTF-8")
source("R/helpers_history.R",      local = environment(), encoding = "UTF-8")

# ===================== ENSURE SHEETS =====================

source("R/helpers_ensure.R",       local = environment(), encoding = "UTF-8")
source("R/helpers_report.R",       local = environment(), encoding = "UTF-8")
source("R/interval_report.R",      local = environment(), encoding = "UTF-8")

# ===================== DISPLAY HELPERS =====================

source("R/helpers_display.R",      local = environment(), encoding = "UTF-8")

# ===================== AUTENTISERING =====================

# Passphrase MUST match the one used in setup_credentials.R.
# Never hard-code this in production — use an environment variable:
#   Local (.Renviron):   SHINYMANAGER_PASSPHRASE=your-secret-here
#   Posit Cloud:         Settings → Environment Variables
PASSPHRASE <- Sys.getenv(
  "SHINYMANAGER_PASSPHRASE",
  unset = "Intaktsmotorn042026!"   # local dev fallback only
)

# Path to the encrypted SQLite credentials database.
# Created once by running setup_credentials.R.
DB_PATH <- "credentials.sqlite"

# Auto-create credentials DB if it doesn't exist (first deploy on Posit).
# Locally: run setup_credentials.R once instead.
# On Posit Connect: set SHINYMANAGER_ADMIN_PASSWORD as an environment variable.
if (!file.exists(DB_PATH)) {
  admin_pwd <- Sys.getenv("SHINYMANAGER_ADMIN_PASSWORD", unset = NA)
  if (is.na(admin_pwd) || nchar(admin_pwd) < 12) {
    stop(
      "credentials.sqlite not found and SHINYMANAGER_ADMIN_PASSWORD is not set ",
      "(or is shorter than 12 characters). ",
      "Set this environment variable on Posit Connect before deploying, ",
      "or run setup_credentials.R locally.",
      call. = FALSE
    )
  }
  shinymanager::create_db(
    credentials_data = data.frame(
      user     = "admin",
      password = admin_pwd,
      name     = "Administrator",
      role     = "admin",
      admin    = TRUE,
      stringsAsFactors = FALSE
    ),
    sqlite_path = DB_PATH,
    passphrase  = PASSPHRASE
  )
}

# ===================== UI =====================

source("R/ui.R", encoding = "UTF-8")

# Wrap the existing UI with shinymanager's secure login layer.
# secure_app() intercepts every session until the user authenticates.
ui <- secure_app(
  ui,
  enable_admin = FALSE,   # adds ?admin=true management panel for admin users
  tags_top = tags$div(
    style = "text-align:center; padding:20px 0 10px;",
    tags$h3(style = "color:#2c3e50; font-weight:600;", "Intaktsmotorn"),
    tags$p(style  = "color:#7f8c8d; margin:0;",        "Logga in f\u00f6r att forts\u00e4tta")
  ),
  tags_bottom = tags$div(
    style = "text-align:center; padding:10px 0; font-size:12px; color:#aaa;",
    paste0("\u00a9 ", format(Sys.Date(), "%Y"), " Roban")
  ),
  language = "se"
)

# ===================== SERVER =====================

source("R/server_refresh.R",       local = environment(), encoding = "UTF-8")
source("R/server_add_handlers.R",  local = environment(), encoding = "UTF-8")
source("R/server_bonus_report.R",  local = environment(), encoding = "UTF-8")
source("R/server.R",               encoding = "UTF-8")

# server() is defined in server.R and calls secure_server() at its very top.
# DB_PATH and PASSPHRASE defined above are visible to server() as globals.
shinyApp(ui, server)
