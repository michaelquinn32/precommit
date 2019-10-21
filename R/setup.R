#' Set up pre-commit
#'
#' @details
#' * installs pre-commit in your current directory.
#' * sets up a template `.pre-commit-config.yaml`.
#' * autoupdates the template to make sure you get the latest versions of the
#'   hooks.
#' * Open the config file if RStudio is running.
#'
#' @param force Whether to replace an existing config file.
#' @param open Whether or not to open the .pre-commit-config.yaml after
#'   it's been placed in your repo.
#' @inheritParams fallback_doc
#' @family helpers
#' @export
use_precommit <- function(force = FALSE,
                          open = TRUE,
                          path_root = here::here()) {
  withr::with_dir(path_root, {
    if (!is_installed()) {
      rlang::abort(paste0(
        "pre-commit is not installed on your system (or we can't find it). ",
        "If you have it installed, please set the R option ",
        "`precommit.executable` to this ",
        "path so it can be used to perform various pre-commit commands from R.",
        "If not, install it with ",
        "`precommit::install_precommit()` or an installation ",
        "method in the official installation guide ",
        "(https://pre-commit.com/#install). The latter requires you to set",
        "the R option `precommit.executable` as well after the installation."
      ))
    }
    install_repo()
    use_precommit_config(force)
    autoupdate()
    if (open) {
      open_config()
    }
  })
}

use_precommit_config <- function(force) {
  name_origin <- "pre-commit-config.yaml"
  escaped_name_target <- "^\\.pre-commit-config\\.yaml$"
  name_target <- ".pre-commit-config.yaml"
  # workaround for RCMD CHECK warning about hidden top-level directories.
  path_root <- getwd()
  if (!fs::file_exists(fs::path(name_target)) | force) {
    fs::file_copy(
      system.file(name_origin, package = "precommit"),
      fs::path(".", name_target),
      overwrite = TRUE
    )
  } else {
    rlang::abort(paste0(
      "There is already a pre-commit configuration file in ",
      path_root,
      ". Use `force = TRUE` to replace .pre-commit-config.yaml"
    ))
  }
  usethis::ui_done("Copied .pre-commit-config.yaml to {path_root}")
  if (is_package(".")) {
    usethis::write_union(".Rbuildignore", escaped_name_target)
  }
  usethis::ui_todo(c(
    "Edit .precommit-hooks.yaml to (de)activate the hooks you want to use. ",
    "All available hooks: ",
    "https://pre-commit.com/hooks.html",
    "R specific hooks:",
    "https://github.com/lorenzwalthert/precommit."
  ))
}

#' Install pre-commit on your system with conda
#' @keywords internal
install_precommit_impl <- function() {
  reticulate::conda_install(packages = "pre-commit")
}

#' Auto-update your hooks
#'
#' Runs `pre-commit autoupdate`.
#' @inheritParams fallback_doc
#' @export
autoupdate <- function(path_root = here::here()) {
  withr::with_dir(path_root, {
    system2(path_pre_commit_exec(), "autoupdate")
    usethis::ui_done(paste0(
      "Ran `pre-commit autoupdate` to get the latest version of the hooks."
    ))
  })
}