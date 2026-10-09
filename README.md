# russells-agent-sandbox

The GitHub repository is named **`russells-agent-sandbox`**; the installable Python package remains **`agent-sandbox-runtime`** (imported as `agent_sandbox_runtime`).

A standalone, **non-Modal** Docker execution backend, designed for the companion `cmu-11-768-assignment-1` repo. Works in GitHub Codespaces and local VS Code devcontainers. A host-level Docker runtime provides isolated containers for code execution; the Python process remains within the editor devcontainer.

## Quick start

1. Open this repository in VS Code and choose **Reopen in Container**, or create a GitHub Codespace.
2. Run `make doctor`, `make test`, then `make test-docker` (requires Docker image pulls).
3. Run `make smoke` to run a real container and verify cleanup.

You may use it from another Python project using `agent-sandbox-runtime` installed as a local editable dependency. The companion repo uses a sibling checkout.

```python
from agent_sandbox_runtime import Sandbox

with Sandbox(image="python:3.12-slim", cwd="/", deployment_timeout=120) as sandbox:
    print(sandbox.execute("python --version")["output"])
```

A `DockerImage` recipe supports Dockerfile builds, pinned requirements installed as the final layer, and whitelisted injected runtime files.

## Interfaces

- `Sandbox(image, cwd, ports, deployment_timeout, runtime_timeout, cpus, memory, network)`
- `.execute(command, timeout=None, cwd=None, env=None, shell=True, check=False)` returning `stdout`, `stderr`, `output`, `returncode`, `exception_info`
- `.tunnel_url(port)`, `.is_alive()`, `.stop()`, context-manager cleanup.
- `agent-sandbox doctor | smoke | list | cleanup`.

## Security / compatibility

Container ports bind to `127.0.0.1` only. Task containers receive **no host volume mounts, secrets, or Docker control socket** by default. Docker engine isolation **is not VM-grade security**; do not run actively malicious untrusted code without stronger VM/microVM containment. Docker-in-Docker devcontainers need privilege to control their dedicated Docker daemon. Protect devcontainer/GitHub credentials and keep Codespaces forwarded ports private.

Uses `bash` and GNU `timeout` *within* the testbed for command execution. Intended for Debian/Ubuntu-based task images, including CMU chess and SWE-bench. Other images may require adaptation. Supports `linux/amd64` under native x86 hosts; Apple Silicon running amd64-only SWE-bench images may require emulation and is not validated here.

A `--rm` container runs `sleep <deployment_timeout>` as PID 1, imposing a bounded maximum lifetime independent of the client. Explicit stop and context-manager exit also clean up. Build contexts exclude common private credential paths and symlinks; always inspect task sources before building untrusted Dockerfiles, as a Dockerfile can make arbitrary outbound connections during build.

