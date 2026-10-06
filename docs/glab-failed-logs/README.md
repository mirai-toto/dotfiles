# glf / glab-failed-logs

`glf` (GitLab failed log) finds failed jobs in a GitLab CI pipeline and prints their
job traces. It requires `glab` and `jq`. `glf` is a short alias for
`glab-failed-logs`; both commands work the same way.

## Usage

Inspect the latest pipeline for the current branch:

```bash
glf
```

Inspect a specific pipeline in the current project:

```bash
glf 11119142
```

Inspect a pipeline in another project:

```bash
glf --repo tnl/o2n/sandbox/maven-sandbox 11119164
```

You can use `glab-failed-logs` in place of `glf` in these examples. Use
`glab auth login` if `glab` is not authenticated.
