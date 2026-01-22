https://zmk.dev/docs/development/local-toolchain/setup/container

Check out the tag for the desired ZMK version.
- v0.2.1
- v0.3.0

```bash
docker volume create --driver local -o o=bind -o type=none -o device="$(pwd)" zmk-config
docker volume inspect zmk-config
```

dont need to create a zmk-module volume.
When you DON'T need zmk-modules:
- Building a standard zmk-config (your case)
- Using built-in ZMK shields and boards
- Custom keymaps in your config directory
- Your config has a module.yml (which yours does)

```bash
# start the devcontainer
devcontainer up --workspace-folder "$(cd ../zmk && pwd)"
# connect to the devcontainer
docker exec -w /workspaces/zmk -it \
  $(docker ps --format "{{.ID}}\t{{.Image}}" | grep zmk | awk '{print $1}') \
  /bin/bash
```

```bash
west init -l app/ # Initialization (takes a very long time)
west update       # Update modules
```

**Troubleshooting:** If you get "No board named 'nice_nano' found":
1. Ensure `west update` has been run to fetch all board definitions
2. Check available boards: `west boards` or search for "nice" in the error output

```bash
# in build container
/workspaces/zmk-config/build.sh

# on host
open ~/proj_keyboard/zmk/build
```
