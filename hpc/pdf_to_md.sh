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

WORK_ROOT="${WORK:-$HOME}"

# Override these when submitting, e.g.:
# INPUT_PDF=/work/.../paper.pdf OUTPUT_DIR=/work/.../out ENV_PREFIX=/work/.../env sbatch hpc/pdf_to_md.sh
INPUT_PDF="${INPUT_PDF:-$WORK_ROOT/pdfs/input.pdf}"
OUTPUT_DIR="${OUTPUT_DIR:-$WORK_ROOT/pdf_outputs/mineru_fullpdf}"
ENV_PREFIX="${ENV_PREFIX:-$WORK_ROOT/conda/envs/pdfllm_clean}"
MINERU_BACKEND="${MINERU_BACKEND:-hybrid-engine}"
MINERU_EFFORT="${MINERU_EFFORT:-high}"

CACHE_ROOT="${CACHE_ROOT:-$WORK_ROOT/.cache}"
TMP_ROOT="${TMP_ROOT:-$WORK_ROOT/tmp}"
MPL_ROOT="${MPL_ROOT:-$WORK_ROOT/mplconfig}"

mkdir -p "$OUTPUT_DIR" "$CACHE_ROOT" "$TMP_ROOT" "$MPL_ROOT"

export XDG_CACHE_HOME="$CACHE_ROOT"
export HF_HOME="$CACHE_ROOT/huggingface"
export MPLCONFIGDIR="$MPL_ROOT"
export TMPDIR="$TMP_ROOT"
export TMP="$TMP_ROOT"
export TEMP="$TMP_ROOT"

echo "Host: $(hostname)"
echo "Date: $(date)"
echo "Input: $INPUT_PDF"
echo "Output: $OUTPUT_DIR"
echo "Env: $ENV_PREFIX"
echo "Backend: $MINERU_BACKEND"
echo "Effort: $MINERU_EFFORT"

if [[ ! -f "$INPUT_PDF" ]]; then
  echo "ERROR: INPUT_PDF not found: $INPUT_PDF" >&2
  exit 1
fi

if [[ ! -d "$ENV_PREFIX" ]]; then
  echo "ERROR: ENV_PREFIX directory not found: $ENV_PREFIX" >&2
  exit 1
fi

if ! command -v conda >/dev/null 2>&1; then
  echo "ERROR: conda command not found in PATH" >&2
  exit 1
fi

conda run -p "$ENV_PREFIX" mineru \
  -p "$INPUT_PDF" \
  -o "$OUTPUT_DIR" \
  -b "$MINERU_BACKEND" \
  --effort "$MINERU_EFFORT"

echo "Done. Outputs: $OUTPUT_DIR"
