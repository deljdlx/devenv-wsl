# First install
```
wsl --unregister devenv
wsl --import devenv . snapshots/07-devenv.tar.gz --version 2
wsl --distribution devenv
```

# Take snapshot
```
wsl --export devenv snapshots/07-devenv.tar.gz
```