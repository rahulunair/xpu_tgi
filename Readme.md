# xpu_tgi

Welcome to `xpu_tgi`! 🚀  

This repo helps you deploy and manage large language models (LLMs) on Intel GPUs with ease. Each model is organized and ready to go!

## What's Inside?

The repo is organized by models, each in its own self-contained directory:

```
.
├── Phi-3-mini-128k-instruct/
├── Phi-3-mini-4k-instruct/
├── Qwen-7B/
├── hermes-2-pro/
├── hermes-3-llama3-1/
└── openhermes-mistral/
```

Each model directory contains:
- **`<model>.service`**: Systemd service file to deploy the model as a service.
- **`setup.sh`**: Script to set up and start the model.
- **`stop.sh`**: Script to stop and remove the model's service.
- **`check_status.sh`**: Script to check the current status of the model's service.

## Getting Started

1. Navigate to the desired model directory:
   ```
   cd Phi-3-mini-128k-instruct
   ```

2. Run the `setup.sh` script to set up and start the service:
   ```
   sudo ./setup.sh
   ```

3. Check the status of the service:
   ```
   ./check_status.sh
   ```

4. When done, stop and remove the service:
   ```
   sudo ./stop.sh
   ```

## Adding a New Model

0. Go to Intel Tiber AI cloud[https://cloud.intel.com], create an account and spin up an Intel Data Center Max series GPU.
1. Validate the model is compatible with Intel GPU and TGI.
2. Create a new directory named after your model.
3. Add a `.service` file, and copy over the `setup.sh`, `stop.sh`, and `check_status.sh` scripts.
4. Modify the files as needed for your model's configuration.
---

🎉 That's it! You're all set to manage LLMs on Intel GPUs with `xpu_tgi`. Happy deploying!

