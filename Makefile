.PHONY: setup doctor test test-docker smoke
setup:
	uv sync
doctor:
	uv run agent-sandbox doctor
test:
	uv run pytest
test-docker:
	uv run pytest -m docker
smoke:
	uv run agent-sandbox smoke
