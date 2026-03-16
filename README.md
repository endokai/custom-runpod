# RunPod ComfyUI Startup Wrapper

A small startup wrapper built on top of the official RunPod ComfyUI worker image:
This wrapper allows you to run **custom startup commands** without modifying the container or rebuilding templates each time.

It supports:

* commands from **environment variables**
* scripts from **Network Volumes**
* **sequential or parallel execution**

---

## Run commands from environment variable

Variable:

```
RUNPOD_BASH_B64
```

The value must be **base64 encoded bash commands**.

Example script:

```bash
echo "Preparing environment"
pip install opencv-python
```

Encode:

```bash
echo -e 'echo "Preparing environment"\npip install opencv-python' | base64 -w0
```

Set environment variable:

```
RUNPOD_BASH_B64=<base64 string>
```

The container will execute:

```
bash -c "<decoded_script>"
```

---


# Network Volume Script

If the file exists:

```
/workspace/my-run.sh
```

it will automatically be executed.

Example:

```bash
#!/usr/bin/env bash

echo "Custom startup script"

pip install some-package
```

---

# Execution Order

At container startup the following steps may run:

```text
1. Base64 command from RUNPOD_BASH_B64
2. /workspace/my-run.sh
3. official /start.sh from base image
```






---

## Change execution mode

### Sequential mode (default)

```
RUNPOD_SCRIPT_MODE=sequential
```

it runs like:

```
env_command ; /workspace/my-run.sh ; /start.sh
```
### Parallel mode


```
RUNPOD_SCRIPT_MODE=parallel
```
it runs like:

```
env_command & /workspace/my-run.sh & /start.sh
```

---

# Use Cases

Typical things you may want to do at startup:

* install extra Python packages
* download models
* run setup scripts
* sync files from storage

All without changing the base container.
