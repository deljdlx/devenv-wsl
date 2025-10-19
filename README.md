# Wsl environment management
Github repository https://github.com/STIMDATA/wsl-debian


## Cloning repository

```
git clone git@github.com:STIMDATA/wsl-debian.git
```


## First install
```
wsl --unregister devenv
wsl --import devenv . snapshots/12-devenv.tar.gz --version 2
wsl --distribution devenv
```

# Take snapshot
```
wsl --export devenv snapshots/12-devenv.tar.gz
```