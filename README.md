## OpenResty bundle docker image

This image is based on [OpenResty](https://openresty.org/en/linux-packages.html) official builds for Debian and is built on top of [clover/base](https://hub.docker.com/r/clover/base/).

### Exposed ports

| Port | Description
| ---- | -----------
| 80   | TCP port for _HTTP_ traffic
| 443  | TCP port _HTTPS_ traffic

### Configuration files

| Location | Description
| -------- | -----------
| `/etc/nginx/nginx.conf` | Nginx configuration file

### Supported platforms

 * `linux/amd64`;
