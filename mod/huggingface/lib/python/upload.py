

from huggingface_hub import HfApi

import os
token       = os.getenv("___X_CMD_HUGGINGFACE_TOKEN")
model_id    = os.getenv("___X_CMD_HUGGINGFACE_MODEL_ID")
local_dir   = os.getenv("___X_CMD_HUGGINGFACE_LOCAL_DIR")
revision    = os.getenv("___X_CMD_HUGGINGFACE_REVISION")


api = HfApi()
api.create_repo(model_id, exist_ok=True, repo_type="model")

api.upload_file(
    path_or_fileobj="vicuna-13b-v1.5.gguf",
    path_in_repo="vicuna-13b-v1.5.gguf",
    repo_id=model_id,
)