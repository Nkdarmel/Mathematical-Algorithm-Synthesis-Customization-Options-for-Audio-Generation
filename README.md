# Mathematical Algorithm Synthesis: Customization Options for Audio Generation

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Language: R](https://img.shields.io/badge/language-R-blue.svg)](https://www.r-project.org/)
[![Open Source](https://img.shields.io/badge/open--source-MIT-green.svg)](LICENSE)
[![Base R](https://img.shields.io/badge/dependencies-base%20R-276DC3.svg)](https://www.r-project.org/)

An open-source, dependency-free R project for generating customizable audio signals and optimizing synthesis parameters with mathematical algorithms.

## Overview

This project turns a small set of user preferences into audio signals. It demonstrates additive-free waveform synthesis, objective-function evaluation, finite-difference gradients, gradient descent, and WAV file generation using base R.

The project is designed to be easy to inspect, reuse, and extend. It requires no third-party R packages for its core functionality.

## Achievements

This project has reached a functional open-source milestone:

- ✅ Replaced placeholder algorithms with a working R audio-synthesis implementation.
- ✅ Added four waveform generators: sine, square, sawtooth, and triangle.
- ✅ Added customizable frequency, amplitude, duration, and sample-rate controls.
- ✅ Implemented mean-squared-error objective evaluation against target signals.
- ✅ Implemented central finite-difference gradients for frequency and amplitude.
- ✅ Implemented `vibe_voice()` gradient-descent optimization with objective history.
- ✅ Implemented `notebook_lm()` multi-signal generation.
- ✅ Added dependency-free mono 16-bit PCM WAV export.
- ✅ Added executable command-line usage through `Rscript audio_generation.R`.
- ✅ Added open-source documentation, contribution guidance, roadmap, and MIT licensing.

## Features

- Generate sine, square, sawtooth, and triangle waves.
- Customize frequency, amplitude, duration, and sample rate.
- Compare generated audio with a target signal using mean squared error.
- Estimate frequency and amplitude gradients with central finite differences.
- Optimize parameters with the `vibe_voice()` gradient-descent routine.
- Generate multiple signals with `notebook_lm()`.
- Export mono 16-bit PCM WAV files using base R only.
- Validate input parameters and fail with clear error messages.

## Requirements

- R 4.0 or newer.
- No external R packages are required.

## Quick start

Clone the repository and run the executable script:

```bash
git clone https://github.com/Nkdarmel/Mathematical-Algorithm-Synthesis-Customization-Options-for-Audio-Generation.git
cd Mathematical-Algorithm-Synthesis-Customization-Options-for-Audio-Generation
Rscript audio_generation.R
```

The command creates `generated_audio.wav` in the current directory and prints the initial and final objective values.

To run on the development branch containing the implementation:

```bash
git checkout build-r-audio-synthesis
Rscript audio_generation.R
```

## Use as an R library

The script can also be sourced from another R program or an interactive R session:

```r
source("audio_generation.R")

parameters <- list(
  frequency = 440,
  amplitude = 0.5,
  waveform = "sine",
  duration = 2,
  sample_rate = 44100
)

signal <- f(parameters)
write_wav(signal, "tone.wav", parameters$sample_rate)
```

Supported waveforms are `sine`, `square`, `saw`, and `triangle`.

## API

### `f(x)`

Generates a numeric mono signal from a parameter list. Frequency is measured in hertz, amplitude ranges from 0 to 1, duration is measured in seconds, and sample rate is measured in samples per second.

### `calculate_objective_function(yi, target = NULL)`

Calculates mean squared error between a generated signal and a target. If no target is supplied, silence is used as the target.

### `grad_j(x, target = NULL, epsilon = 1e-3)`

Calculates a central finite-difference gradient for the numeric `frequency` and `amplitude` parameters.

### `vibe_voice(x0, alpha = 0.01, iterations = 100, target = NULL)`

Optimizes frequency and amplitude with gradient descent. When no target is supplied, the function builds one from `target_frequency` and `target_amplitude` fields, if present.

The optimizer returns:

- `parameters`: optimized parameter list.
- `objective_history`: objective value for each iteration.
- `signal`: optimized audio signal.
- `target`: target signal used for optimization.

### `notebook_lm(M)`

Generates one signal per parameter list and returns them as columns in a matrix. All parameter lists must produce signals of equal length.

### `write_wav(signal, path, sample_rate = 44100)`

Writes a mono 16-bit PCM WAV file without requiring an audio package.

## Mathematical model

For a parameter vector `x`, synthesis produces `y = f(x)`. Given a target signal `t`, the objective function is:

\[
J(x) = \frac{1}{n} \sum_{k=1}^{n} (f(x)_k - t_k)^2
\]

The gradient is estimated numerically using central finite differences:

\[
\frac{\partial J}{\partial x_i} \approx \frac{J(x + \epsilon e_i) - J(x - \epsilon e_i)}{2\epsilon}
\]

Parameters are updated with gradient descent:

\[
x_{i+1} = x_i - \alpha \nabla J(x_i)
\]

Only frequency and amplitude are optimized; waveform, duration, and sample rate remain fixed during an optimization run.

## Project structure

```text
.
├── audio_generation.R   # Executable implementation and public functions
├── README.md             # Documentation and examples
├── LICENSE               # MIT open-source license
└── .github/workflows/    # GitHub Actions workflow
```

## Development and testing

Check the R source for syntax errors:

```bash
Rscript -e 'parse("audio_generation.R"); cat("R syntax OK\\n")'
```

Run the executable smoke test:

```bash
Rscript audio_generation.R
```

A successful run creates a non-empty `generated_audio.wav`. Generated audio files are ignored by Git and should not be committed.

## Contributing

Contributions are welcome. To contribute:

1. Fork the repository.
2. Create a focused branch: `git checkout -b improve-synthesis`.
3. Make and test your changes.
4. Update the documentation when behavior changes.
5. Open a pull request describing the change and validation performed.

Please keep contributions dependency-light, preserve the existing public functions where practical, and include reproducible examples for new behavior.

## Roadmap

- Add automated R tests for waveform generation, gradients, and WAV headers.
- Add optional stereo and envelope support.
- Add a Shiny interface for interactive parameter customization.
- Add richer target-signal similarity metrics.
- Improve optimization with analytic gradients and adaptive learning rates.

## License

This project is open source under the [MIT License](LICENSE). You are free to use, modify, distribute, and build upon the code, subject to the license terms.

## References

1. Pierre Larochelle, *Mathématiques pour les NLP*, 2018.
2. Julius O. Smith III, *Audio Signal Processing*, 2007.
3. [Microsoft VibeVoice vs Google NotebookLM](https://medium.com/data-science-in-your-pocket/microsoft-vibevoice-vs-google-notebooklm-98412ce2ccc1).
4. [Mathematical Algorithm Synthesis: Customization Options for Audio Generation](https://medium.com/@armelnong/mathematic-algorithm-synthesis-customization-options-for-audio-generation-0bc18a).
