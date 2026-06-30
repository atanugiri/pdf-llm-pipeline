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

1. Edit variables in `hpc/pdf_to_md.sh`:
   - `INPUT_PDF`
   - `OUTPUT_DIR`
   - `ENV_PREFIX`

2. Submit:

```bash
sbatch hpc/pdf_to_md.sh
```

## Notes

- Keep this repo focused on reusable extraction/cleanup scripts.
