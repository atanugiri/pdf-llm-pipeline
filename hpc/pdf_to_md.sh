#!/bin/bash
#SBATCH --job-name=mineru_fullpdf
#SBATCH --output=/work/agiri/logs/%x-%j.out
#SBATCH --error=/work/agiri/logs/%x-%j.err
#SBATCH --partition=dgx
#SBATCH --gres=gpu:1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=6
#SBATCH --time=00:15:00
#SBATCH --mem=32G

set -euo pipefail

if [[ -z "${WORK:-}" ]]; then
  echo "ERROR: WORK is not set in the job environment" >&2
  exit 1
fi

REPO_DIR="$WORK/pdf-llm-pipeline"
CONDA_ENV_NAME=pdfllm_clean

INPUT_PDF="$REPO_DIR/pdfs/AM_Nature.pdf"
OUTPUT_DIR="$REPO_DIR/pdfs"
MINERU_BACKEND="hybrid-engine"
MINERU_EFFORT="medium"

export XDG_CACHE_HOME="$WORK/pip-cache"
export HF_HOME="$WORK/pip-cache/huggingface"
export MPLCONFIGDIR="$WORK/mplconfig"
export TMPDIR="$WORK/tmp"
export TMP="$WORK/tmp"
export TEMP="$WORK/tmp"

mkdir -p "$OUTPUT_DIR" "$WORK/pip-cache" "$WORK/tmp" "$WORK/mplconfig"

source "$HOME/miniconda3/etc/profile.d/conda.sh"
conda activate "$CONDA_ENV_NAME"

if [[ ! -f "$INPUT_PDF" ]]; then
  echo "ERROR: INPUT_PDF not found: $INPUT_PDF" >&2
  exit 1
fi

if ! conda env list | grep -q "$CONDA_ENV_NAME"; then
  echo "ERROR: Conda environment not found: $CONDA_ENV_NAME" >&2
  exit 1
fi

mineru \
  -p "$INPUT_PDF" \
  -o "$OUTPUT_DIR" \
  -b "$MINERU_BACKEND" \
  --effort "$MINERU_EFFORT"

echo "Done. Outputs: $OUTPUT_DIR"
