# pdf-llm-pipeline

PDF to LLM-ready markdown conversion and cleanup.

## Scripts

**`scripts/clean_markdown_for_llm.py`**

Cleans markdown for LLM ingestion by removing image links, `<details>` blocks, HTML tags, and excessive blank lines. Outputs `<input_stem>_llm.md`.

```bash
python scripts/clean_markdown_for_llm.py <file.md>
```

**`hpc/pdf_to_md.sh`**

Slurm script for HPC PDF → markdown extraction using MinerU (primary package in `pdfllm_clean` environment).

```bash
INPUT_PDF=/path/to/paper.pdf \
OUTPUT_DIR=/path/to/output \
ENV_PREFIX=/path/to/pdfllm_clean \
sbatch hpc/pdf_to_md.sh
```

Optional environment variables:
- `MINERU_BACKEND` (default: `hybrid-engine`)
- `MINERU_EFFORT` (default: `high`)
- `CACHE_ROOT`, `TMP_ROOT`, `MPL_ROOT`

## Packages

- **MinerU** (primary) - PDF extraction in `pdfllm_clean` environment
- **pix2text**, **pymupdf4llm** - Alternative extraction options
