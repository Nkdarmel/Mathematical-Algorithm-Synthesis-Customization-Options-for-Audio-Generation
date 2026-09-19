#!/usr/bin/env Rscript

# Mathematical Algorithm Synthesis: Customization Options for Audio Generation
# This executable uses base R only.

`%||%` <- function(value, fallback) {
  if (is.null(value)) fallback else value
}

clamp <- function(value, lower, upper) {
  max(lower, min(upper, value))
}

validate_parameters <- function(x) {
  if (!is.list(x)) stop("x must be a list of audio parameters")
  if (!is.null(x$frequency) && (!is.numeric(x$frequency) || length(x$frequency) != 1 || x$frequency <= 0)) {
    stop("frequency must be a single positive number")
  }
  if (!is.null(x$amplitude) && (!is.numeric(x$amplitude) || length(x$amplitude) != 1 || x$amplitude < 0 || x$amplitude > 1)) {
    stop("amplitude must be a number between 0 and 1")
  }
  invisible(TRUE)
}

# Generate a mono audio signal from customization parameters.
f <- function(x) {
  validate_parameters(x)

  frequency <- x$frequency %||% 440
  amplitude <- x$amplitude %||% 0.5
  waveform <- tolower(x$waveform %||% "sine")
  duration <- x$duration %||% 1
  sample_rate <- x$sample_rate %||% 44100

  if (!is.numeric(duration) || length(duration) != 1 || duration <= 0) stop("duration must be positive")
  if (!is.numeric(sample_rate) || length(sample_rate) != 1 || sample_rate <= 0) stop("sample_rate must be positive")
  if (!waveform %in% c("sine", "square", "saw", "triangle")) stop("unsupported waveform")

  sample_count <- max(1L, floor(duration * sample_rate))
  time <- seq(0, (sample_count - 1) / sample_rate, length.out = sample_count)
  phase <- 2 * pi * frequency * time
  cycle <- (frequency * time) %% 1

  wave <- switch(
    waveform,
    sine = sin(phase),
    square = ifelse(sin(phase) >= 0, 1, -1),
    saw = 2 * cycle - 1,
    triangle = 1 - 4 * abs(cycle - 0.5)
  )

  as.numeric(clamp(amplitude * wave, -1, 1))
}

# Mean squared error against silence or a supplied target signal.
calculate_objective_function <- function(yi, target = NULL) {
  if (!is.numeric(yi) || length(yi) == 0) stop("yi must be a non-empty numeric signal")
  if (is.null(target)) target <- numeric(length(yi))
  if (!is.numeric(target) || length(target) != length(yi)) stop("target must match yi length")
  mean((yi - target)^2)
}

# Numerical central-difference gradient for frequency and amplitude.
grad_j <- function(x, target = NULL, epsilon = 1e-3) {
  validate_parameters(x)
  if (is.null(target)) target <- numeric(length(f(x)))

  gradient <- c(frequency = 0, amplitude = 0)
  for (parameter in names(gradient)) {
    if (is.null(x[[parameter]])) next
    plus <- x
    minus <- x
    step <- if (parameter == "frequency") epsilon else epsilon / 10
    plus[[parameter]] <- x[[parameter]] + step
    minus[[parameter]] <- x[[parameter]] - step
    if (parameter == "frequency") minus[[parameter]] <- max(1e-6, minus[[parameter]])
    if (parameter == "amplitude") {
      plus[[parameter]] <- clamp(plus[[parameter]], 0, 1)
      minus[[parameter]] <- clamp(minus[[parameter]], 0, 1)
    }
    gradient[[parameter]] <- (
      calculate_objective_function(f(plus), target) -
        calculate_objective_function(f(minus), target)
    ) / (plus[[parameter]] - minus[[parameter]])
  }
  gradient
}

# Optimize frequency and amplitude toward a target signal.
vibe_voice <- function(x0, alpha = 0.01, iterations = 100, target = NULL) {
  validate_parameters(x0)
  xi <- x0
  if (is.null(target)) {
    target_parameters <- x0
    target_parameters$frequency <- x0$target_frequency %||% x0$frequency %||% 440
    target_parameters$amplitude <- x0$target_amplitude %||% x0$amplitude %||% 0.5
    target <- f(target_parameters)
  }

  history <- numeric(iterations + 1L)
  history[1] <- calculate_objective_function(f(xi), target)
  for (iteration in seq_len(iterations)) {
    gradient <- grad_j(xi, target)
    xi$frequency <- max(1e-6, xi$frequency - alpha * gradient[["frequency"]])
    xi$amplitude <- clamp(xi$amplitude - alpha * gradient[["amplitude"]], 0, 1)
    history[iteration + 1L] <- calculate_objective_function(f(xi), target)
  }
  list(parameters = xi, objective_history = history, signal = f(xi), target = target)
}

# Generate one signal per model and combine them as columns.
notebook_lm <- function(M) {
  if (!is.list(M) || length(M) == 0) stop("M must be a non-empty list of parameter lists")
  signals <- lapply(M, f)
  lengths <- vapply(signals, length, integer(1))
  if (length(unique(lengths)) != 1) stop("all models must produce equal-length signals")
  do.call(cbind, signals)
}

# Write a mono 16-bit PCM WAV file without external packages.
write_wav <- function(signal, path, sample_rate = 44100) {
  if (!is.numeric(signal) || length(signal) == 0) stop("signal must be non-empty numeric")
  signal <- as.numeric(round(clamp(signal, -1, 1) * 32767))
  raw_samples <- writeBin(as.integer(signal), raw(), size = 2, endian = "little")
  data_size <- length(raw_samples)
  riff_size <- 36 + data_size
  con <- file(path, "wb")
  on.exit(close(con), add = TRUE)
  writeBin(charToRaw("RIFF"), con)
  writeBin(as.integer(riff_size), con, size = 4, endian = "little")
  writeBin(charToRaw("WAVEfmt "), con)
  writeBin(as.integer(16), con, size = 4, endian = "little")
  writeBin(as.integer(1), con, size = 2, endian = "little")
  writeBin(as.integer(1), con, size = 2, endian = "little")
  writeBin(as.integer(sample_rate), con, size = 4, endian = "little")
  writeBin(as.integer(sample_rate * 2), con, size = 4, endian = "little")
  writeBin(as.integer(2), con, size = 2, endian = "little")
  writeBin(as.integer(16), con, size = 2, endian = "little")
  writeBin(charToRaw("data"), con)
  writeBin(as.integer(data_size), con, size = 4, endian = "little")
  writeBin(raw_samples, con)
  invisible(path)
}

if (sys.nframe() == 0) {
  initial <- list(
    frequency = 430,
    amplitude = 0.4,
    waveform = "sine",
    duration = 2,
    sample_rate = 44100,
    target_frequency = 440,
    target_amplitude = 0.5
  )
  result <- vibe_voice(initial, alpha = 0.1, iterations = 25)
  output_path <- file.path(getwd(), "generated_audio.wav")
  write_wav(result$signal, output_path, initial$sample_rate)
  cat(sprintf("Generated: %s\n", output_path))
  cat(sprintf("Initial objective: %.8f\n", result$objective_history[1]))
  cat(sprintf("Final objective: %.8f\n", tail(result$objective_history, 1)))
  cat(sprintf("Optimized frequency: %.3f Hz\n", result$parameters$frequency))
  cat(sprintf("Optimized amplitude: %.3f\n", result$parameters$amplitude))
}
