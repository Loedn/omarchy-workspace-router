# Contributing

Issues and pull requests are welcome.

## Development

```sh
./tests/run
omarchy plugin add "$PWD" --enable --yes
```

Keep changes focused, preserve explicit consent for Hyprland edits, and
document every new command, file write, or dependency.

## Release checklist

1. Update `manifest.json` and `CHANGELOG.md` with the same version.
2. Run `./tests/run` on the oldest supported Omarchy version.
3. Test open, close, keyboard navigation, setup, assignment, disconnection,
   disable/re-enable, shell restart, update, and removal.
4. Confirm the README still describes every dependency and file write.
5. Tag the release as `vX.Y.Z` after merging.
