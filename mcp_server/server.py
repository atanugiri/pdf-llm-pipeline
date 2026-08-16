from pathlib import Path

from mcp.server.mcpserver import MCPServer

PDFS_DIR = Path(__file__).resolve().parent.parent / "pdfs"

mcp = MCPServer("pdf-llm-pipeline")


@mcp.tool()
def list_papers() -> list[str]:
    """List available paper IDs (relative paths to *_llm.md files under pdfs/)."""
    return [str(path.relative_to(PDFS_DIR)) for path in sorted(PDFS_DIR.rglob("*_llm.md"))]


@mcp.tool()
def get_paper(paper_id: str) -> str:
    """Return the full Markdown content of a paper. paper_id must be one of the values returned by list_papers()."""
    path = (PDFS_DIR / paper_id).resolve()
    if PDFS_DIR not in path.parents or not path.is_file():
        raise ValueError(f"Unknown paper_id: {paper_id!r}. Call list_papers() to see valid IDs.")
    return path.read_text(encoding="utf-8")


if __name__ == "__main__":
    mcp.run()
