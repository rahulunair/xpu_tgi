# TGI Models Collection

Welcome to `xpu_tgi`! 🚀  

A curated collection of Text Generation Inference (TGI) models optimized for Intel XPU.

<div align="center">
<img src="./hi_tgi.jpg" alt="TGI LLM Servers" width="400"/>
</div>

This repo helps you deploy and manage large language models (LLMs) on Intel GPUs using TGI with ease. Each model is organized and ready to go!

## What's Inside?

The repo is organized by models, each in its own self-contained directory:

## Usage

```bash
# Start a model
./models/start.sh <model-name>

# Check status
./models/status.sh <model-name>

# Stop a model
./models/stop.sh <model-name>
```

## Model Selection Guide

1. **Need long context?**
   - Phi-3-mini-128k (128k tokens)
   - Hermes-3-llama3.1 (8k tokens)

2. **Code generation?**
   - CodeLlama-7b (specialized)
   - Phi-3-mini-4k (good capability)

3. **Structured tasks?**
   - FLAN-T5-XXL (classification, QA)
   - FLAN-UL2 (translation, summarization)

4. **General purpose?**
   - OpenHermes-Mistral (efficient)
   - Hermes-2-pro (balanced)

## Available Models

### General Purpose
- **FLAN-UL2** (PORT 8083)
  - Best for: Translation, summarization, question answering
  - Context: 2039 tokens
  - Good balance of capabilities and performance

- **FLAN-T5-XXL** (PORT 8087)
  - Best for: Structured tasks, classification
  - Context: 512 tokens
  - Excellent for specific, focused tasks

### Reasoning & Analysis
- **Phi-3-mini-4k** (PORT 8081)
  - Best for: Reasoning, coding, structured tasks
  - Context: 4k tokens
  - Efficient for standard tasks

- **Phi-3-mini-128k** (PORT 8082)
  - Best for: Long document analysis, complex reasoning
  - Context: 128k tokens
  - Ideal for tasks requiring extensive context

- **Hermes-2-pro** (PORT 8084)
  - Best for: General tasks, instruction following
  - Context: 4k tokens
  - Good all-round performer

- **Hermes-3-llama3.1** (PORT 8085)
  - Best for: Advanced reasoning, analysis
  - Context: 8k tokens
  - Strong overall capabilities

- **OpenHermes-Mistral** (PORT 8086)
  - Best for: Technical tasks, efficient reasoning
  - Context: 8k tokens
  - Based on Mistral architecture

### Code Generation
- **CodeLlama-7b** (PORT 8089)
  - Best for: Code generation, explanation, review
  - Context: 4k tokens
  - Specialized for programming tasks

## Contributing

### Adding a New Model

1. **Verify TGI Compatibility**
   - Test the model on Intel Developer Cloud
   - Create an account at [Intel Developer Cloud](https://cloud.intel.com)
   - Use Intel Data Center Max GPU VM
   - Verify model works with TGI

2. **Create Model Directory**
   ```bash
   mkdir -p NewModel/config
   ```

3. **Create Configuration Files**
   - Add `config/model.env`:
     ```env
     MODEL_NAME=your-model-tgi
     MODEL_ID=org/model-name
     TGI_VERSION=2.4.0-intel-xpu
     PORT=808x  # Choose unused port
     SHM_SIZE=2g
     MAX_CONCURRENT_REQUESTS=1
     MAX_BATCH_SIZE=1
     MAX_TOTAL_TOKENS=xxxx
     MAX_INPUT_LENGTH=xxxx
     MAX_WAITING_TOKENS=10
     ```

   - Add `README.md` with:
     - Model description
     - License notice
     - Model information
     - Configuration
     - Example usage
     - Best practices

4. **Test Your Configuration**
   ```bash
   ./start.sh your-model
   ./status.sh your-model
   # Test with example queries
   ./stop.sh your-model
   ```

5. **Submit PR**
   - Include all test results
   - Document any special considerations
   - Explain model's unique capabilities


## License Notes

Each model has its own license terms. Please review the individual model's README and license before use.

🎉 That's it! You're all set to manage LLMs on Intel GPUs with `xpu_tgi`. Happy deploying!
