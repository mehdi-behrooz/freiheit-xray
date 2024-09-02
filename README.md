# Usage

```yaml
xray:
  container_name: xray
  image: ghcr.io/mehdi-behrooz/freiheit-xray:latest
  environment:
    - PROTOCOL=ws
    - LOG_LEVEL=debug
    - USER_ID_DIRECT=5ca1ab1e-0000-4000-a000-000000000000 #example
    - USER_ID_WARP=f100ded0-0000-4000-a000-000000000000 #example
    - WEBSOCKET_PATH=/path/
    - REALITY_PRIVATE_KEY=${PRIVATE_KEY}
    - REALITY_PUBLIC_KEY=${PUBLIC_KEY}
    - REALITY_SNI=some-domain.com
    - WARP_ADDRESS=127.0.0.1
    - WARP_PORT=1080
```
