# Mathematical Algorithm Synthesis: Customization Options for Audio Generation

This project provides a small, dependency-free R implementation for generating audio signals from customization parameters. It includes:

- `f()`: additive synthesis for sine, square, sawtooth, and triangle waves.
- `calculate_objective_function()`: mean-squared error between a generated signal and a target signal.
- `grad_j()`: numerical finite-difference gradient of the objective with respect to frequency and amplitude.
- `vibe_voice()`: gradient-descent optimization of audio parameters toward a target tone.
- `notebook_lm()`: generates and combines signals from multiple parameter sets.
- WAV export using base R, so no external audio package is required.

## Requirements

- R 4.0 or newer.
- No third-party R packages are required.

The script can be run directly from a terminal:

```bash
Rscript audio_generation.R
```

It generates `generated_audio.wav` in the current directory and prints the initial and optimized objective values.

## Quick start

```r
source("audio_generation.R")

params <- list(
  frequency = 440,
  amplitude = 0.5,
  waveform = "sine",
  duration = 2,
  sample_rate = 44100
)

signal <- f(params)
write_wav(signal, "tone.wav", sample_rate = params$sample_rate)
```

Supported waveform names are `sine`, `square`, `saw`, and `triangle`. Frequency is specified in Hz, amplitude is in the range 0–1, duration is in seconds, and sample rate is specified in samples per second.

## Mathematical algorithm

For a parameter vector `x`, the synthesizer produces `y = f(x)`. Given a target signal `t`, the objective is:

\[
J(x) = \frac{1}{n}\sum_{k=1}^{n}(f(x)_k - t_k)^2
\]

`grad_j()` estimates the gradient with central finite differences:

\[
\frac{\partial J}{\partial x_i} \approx \frac{J(x + \epsilon e_i) - J(x - \epsilon e_i)}{2\epsilon}
\]

The optimizer then applies:

\[
x_{i+1} = x_i - \alpha \nabla J(x_i)
\]

Only numeric `frequency` and `amplitude` parameters are optimized. Waveform, duration, and sample rate remain fixed during optimization.

## Function reference

### `f(x)`

Generates a numeric audio vector from a parameter list. Defaults are 440 Hz, amplitude 0.5, sine waveform, one second, and a 44.1 kHz sample rate.

### `calculate_objective_function(yi, target = NULL)`

Returns mean squared error. When `target` is omitted, the objective is the signal energy relative to silence.

### `grad_j(x, target = NULL, epsilon = 1e-3)`

Returns a named numeric gradient for the tunable parameters. It uses central finite differences and clamps temporary parameters to valid audio ranges.

### `vibe_voice(x0, alpha = 0.01, iterations = 100, target = NULL)`

Optimizes `frequency` and `amplitude` using gradient descent. If no target is supplied, a target tone is built from `target_frequency` and `target_amplitude` in `x0`, or from the initial parameters when those fields are absent.

### `notebook_lm(M)`

Generates a matrix whose columns contain the signals generated from each parameter list in `M`. Inputs must use the same duration and sample rate.

### `write_wav(signal, path, sample_rate = 44100)`

Writes a mono, 16-bit PCM WAV file using base R only.

## Example output

Running the executable script creates:

```text
generated_audio.wav
```

The generated file can be opened in any standard audio player or imported into an audio editor.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).

## References

1. Pierre Larochelle, *Mathématiques pour les NLP*, 2018.
2. Julius O. Smith III, *Audio Signal Processing*, 2007.
3. [Microsoft VibeVoice vs Google NotebookLM](https://medium.com/data-science-in-your-pocket/microsoft-vibevoice-vs-google-notebooklm-98412ce2ccc1).
4. [Mathematical Algorithm Synthesis: Customization Options for Audio Generation](https://medium.com/@armelnong/mathematic-algorithm-synthesis-customization-options-for-audio-generation-0bc18a).
