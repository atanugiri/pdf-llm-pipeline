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

INPUT_PDF="$WORK/kpms_analysis_2/literature/keypoint_moseq_2024/Keypoint-MoSeq.pdf"
OUTPUT_DIR="$WORK/kpms_analysis_2/literature/keypoint_moseq_2024/mineru_fullpdf"
ENV_PREFIX="$WORK/conda/envs/pdfllm_clean"

mkdir -p "$OUTPUT_DIR" "$WORK/.cache" "$WORK/tmp" "$WORK/mplconfig"

export XDG_CACHE_HOME="$WORK/.cache"
export HF_HOME="$WORK/.cache/huggingface"
export MPLCONFIGDIR="$WORK/mplconfig"
export TMPDIR="$WORK/tmp"
export TMP="$WORK/tmp"
export TEMP="$WORK/tmp"

echo "Host: $(hostname)"
echo "Date: $(date)"
echo "Input: $INPUT_PDF"
echo "Output: $OUTPUT_DIR"
echo "Env: $ENV_PREFIX"

test -f "$INPUT_PDF"
test -d "$ENV_PREFIX"

conda run -p "$ENV_PREFIX" mineru \
  -p "$INPUT_PDF" \
  -o "$OUTPUT_DIR" \
  -b hybrid-engine \
  --effort high

echo "Done. Outputs:"
