# Security

## Supported versions

Security fixes are provided for the latest released version.

## Reporting a vulnerability

Please report vulnerabilities privately through GitHub's **Report a
vulnerability** form for this repository. Do not include secrets or private
window titles in a public issue.

## Security boundaries

Workspace Router:

- runs with the current user's permissions inside `omarchy-shell`;
- executes its bundled Bash helper only after a user action;
- reads `hyprctl -j clients` to discover local windows;
- writes the documented Workspace Router files under `~/.config/hypr/`;
- adds or removes only its marked entry in `omarchy-menu.jsonc` on request;
- modifies `hyprland.lua` only after confirmation and creates a backup first;
- never invokes `sudo`, `pkexec`, or a network client;
- does not collect telemetry, credentials, or window data.

Omarchy plugins are unsandboxed. Users should review plugin updates before
accepting them.
