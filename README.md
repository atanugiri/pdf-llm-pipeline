# pdf-llm-pipeline

PDF to LLM-ready Markdown conversion and cleanup. The project uses [uv](https://docs.astral.sh/uv/) to define dependencies and create a separate virtual environment on macOS and HPC Linux.

## Setup

Install `uv`, then create the project environment from the locked dependencies:

```bash
uv sync --locked
```

This creates `.venv/` for the current platform. Do not copy or commit `.venv/`; use the shared `pyproject.toml`, `uv.lock`, and `.python-version` files to recreate it.

Run project commands without manually activating the environment:

```bash
uv run python --version
uv run mineru --version
```

Alternatively, activate the environment for an interactive shell:

```bash
source .venv/bin/activate
```

## Local Extraction

### PyMuPDF4LLM

`pymupdf4llm` is a Python library rather than a command-line executable. This example extracts only the first page of a PDF; page indexes are zero-based.

```bash
mkdir -p pdf_outputs/local_test

uv run python -c '
import pymupdf4llm

markdown = pymupdf4llm.to_markdown("pdfs/AM_Nature.pdf", pages=[0])
with open("pdf_outputs/local_test/AM_Nature_page1.md", "w", encoding="utf-8") as output_file:
		output_file.write(markdown)
'
```

### MinerU

MinerU's `-o` option expects an output directory, not a Markdown filename.

```bash
mkdir -p pdf_outputs/local_test

uv run mineru \
	-p pdfs/test/AM_Nature_page1.pdf \
	-o pdf_outputs/local_test \
	-b hybrid-engine \
	--effort medium
```

MinerU creates a directory containing Markdown, JSON, and intermediate files beneath the requested output directory.

## Markdown Cleanup

`scripts/clean_markdown_for_llm.py` removes image links, `<details>` blocks, standalone HTML tags, and excessive blank lines. It writes `<input_stem>_llm.md` beside the input file.

```bash
uv run python scripts/clean_markdown_for_llm.py path/to/input.md
```

## HPC

Install `uv` for your user account, synchronize the environment on the shared filesystem, and do this again whenever `pyproject.toml`, `uv.lock`, or `.python-version` changes:

```bash
cd "$WORK/pdf-llm-pipeline"
uv sync --locked
```

The Slurm job [hpc/pdf_to_md.sh](hpc/pdf_to_md.sh) runs the explicit project executable at `$REPO_DIR/.venv/bin/mineru`. It does not activate Conda. Before submitting, set `INPUT_PDF`, `OUTPUT_DIR`, `MINERU_BACKEND`, and `MINERU_EFFORT` near the top of the script for the desired document and output location.

Submit the job with:

```bash
sbatch hpc/pdf_to_md.sh
```

To use a virtual environment outside the project directory:

```bash
ENV_PREFIX=/path/to/.venv sbatch hpc/pdf_to_md.sh
```

The job redirects Hugging Face, Matplotlib, temporary, and Triton caches to `$WORK` so GPU compilation does not consume the home-directory quota.

## Syncing With HPC

`.rsync-exclude` excludes `.venv/`, caches, and editor files. It is safe to use in either direction because each platform creates its own virtual environment:

```bash
rsync -avh --progress \
	--exclude-from=.rsync-exclude \
	./ punakha:"$WORK/pdf-llm-pipeline/"
```

Use `--dry-run` to preview a transfer. Add `--delete` only when the destination should exactly mirror the source.

## Dependencies

- **MinerU**: primary, high-accuracy extractor; `hybrid-engine` benefits from a GPU.
- **pymupdf4llm**: fast local Markdown extraction through Python.
- **pix2text**: alternative OCR and document-extraction tools.
- **accelerate**: required by MinerU's local Transformers-based hybrid backend.
