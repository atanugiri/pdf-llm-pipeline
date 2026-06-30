# pdf-llm-pipeline

Minimal PDF to LLM-ready markdown workflow.

## Project layout

- `scripts/clean_markdown_for_llm.py`
  - Cleans markdown for LLM ingestion.
  - Removes markdown image links.
  - Removes full `<details>...</details>` blocks (including enclosed content).
  - Removes standalone HTML tag lines.
  - Collapses excessive blank lines.
  - Writes output as `<input_stem>_llm.md` in the same folder.

- `hpc/pdf_to_md.sh`
  - Slurm script for running MinerU on HPC.
  - Uses `hybrid-engine` with high effort.

## Local usage

Run cleaner:

```bash
python scripts/clean_markdown_for_llm.py /absolute/or/relative/path/to/file.md
```

Example:

```bash
python scripts/clean_markdown_for_llm.py ../kpms_analysis_2/literature/keypoint_moseq_2024/Keypoint-MoSeq_2/hybrid_auto/Keypoint-MoSeq.md
```

This writes:

```text
.../Keypoint-MoSeq_llm.md
```

## HPC usage

1. Submit with environment overrides:

```bash
INPUT_PDF=/work/<user>/papers/paper.pdf \
OUTPUT_DIR=/work/<user>/outputs/mineru_paper \
ENV_PREFIX=/work/<user>/conda/envs/pdfllm_clean \
sbatch hpc/pdf_to_md.sh
```

2. Optional overrides:
  - `MINERU_BACKEND` (default: `hybrid-engine`)
  - `MINERU_EFFORT` (default: `high`)
  - `CACHE_ROOT`, `TMP_ROOT`, `MPL_ROOT`

## Notes

- Keep this repo focused on reusable extraction/cleanup scripts.
