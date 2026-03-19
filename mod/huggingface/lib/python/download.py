
from huggingface_hub import snapshot_download

import os
token       = os.getenv("___X_CMD_HUGGINGFACE_TOKEN")
model_id    = os.getenv("___X_CMD_HUGGINGFACE_MODEL_ID")
local_dir   = os.getenv("___X_CMD_HUGGINGFACE_LOCAL_DIR")
revision    = os.getenv("___X_CMD_HUGGINGFACE_REVISION")

snapshot_download(
    repo_id=model_id,
    local_dir=local_dir,
    local_dir_use_symlinks=False,
    revision=revision,
    use_auth_token=token
)

