# Phi-3-mini-128k-instruct

**What is it?**  
This model is designed for **long-context instruction tuning** with a massive 128k token limit! Perfect for summarization, long-form QA, and more.

**Minimum Requirements:**  
- **Intel Data Center GPU Max Series** (at least 17 GB VRAM for smooth operation).  
- TGI running in `bfloat16` or `float32`.

**License:**  
Check the license and terms of use on [Hugging Face](https://huggingface.co/microsoft/Phi-3-mini-128k-instruct). Ensure compliance before using!

---

## How to Run

1. Spin up an Intel GPU VM via [Intel Tiber AI Cloud](https://cloud.intel.com).
2. Navigate to this directory and run:
   ```
   sudo ./setup.sh
   ```
3. Test the API with `curl`:
   ```
   curl -X POST http://localhost:8080/generate \
   -H "Content-Type: application/json" \
   -d '{
       "inputs": "Explain quantum entanglement in simple terms.",
       "parameters": {"max_new_tokens": 200, "temperature": 0.7}
   }'
   ```

---
## Expose with Local Tunnel or a Cloudflare Tunnel

**First Option: Local Tunneling with SSH**  
You can use the `-L` flag with SSH to expose the TGI service running on a remote server:
```
ssh -L 8080:localhost:8080 guest@<remote-ip> username@<secondary-ip>
```
Once the SSH connection is active, you can access the TGI service locally at:
```
http://localhost:8080
```

**Second Option: Cloudflare Tunnel**  
To expose your TGI service publicly using a Cloudflare Tunnel:

- On Ubuntu (using `.deb` package):
  ```
  wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
  sudo dpkg -i cloudflared-linux-amd64.deb
  ```

Start the tunnel:
```
cloudflared tunnel --url http://localhost:8080
```

Cloudflare will generate a public URL. Share the link or use it to test the model:
```
curl -X POST <generated-public-url>/generate \
-H "Content-Type: application/json" \
-d '{
    "inputs": "Explain artificial intelligence.",
    "parameters": {"max_new_tokens": 100, "temperature": 0.7}
}'
```

**Note for Production Use:**  
To use Cloudflare Tunnel in production, you'll need to subscribe to their premium service. Ensure you review and agree to the [Cloudflare Terms of Service](https://www.cloudflare.com/terms/) before deployment.

---

**Fun Tip:**  
Want to explore more? Use the `/info` API to learn about the model:
```
curl -X GET http://localhost:8080/info
```

Happy querying!

To check the status of the service:
```
./check_status.sh
```

To stop and disable the service:
```
sudo ./stop.sh
```
