## WIP Check hyper-v service
Vérifier que le service Hyper-V est bien activé

PowerShell (en mode administrateur)
```
dism.exe /Online /Enable-Feature:Microsoft-Hyper-V /All
```

## Vérifier les autres wsl

Attention à ne pas avoir d'autres distributions WSL en cours d'exécution, cela peut poser des problèmes de ports.

```
wsl --list --verbose
```

## Vérifier les ports (sous Windows Powershell)

Les ports 80 et 3306 doivent être libres (et 443 si SSL est activé)

```
netstat -aon | findstr LISTENING | findstr :80
netstat -aon | findstr LISTENING | findstr :3306
netstat -aon | findstr LISTENING | findstr :443
```

## Création WSL à partir d'un snapshot

[Télécharger le snapshot](https://drive.google.com/file/d/1bM1m-Y-yXHJJCsFMFmTwUGZWHLGSbhKL/view?usp=sharing)

### Créations des dossiers

```
mkdir C:\Users\%USERNAME%\Desktop\DEBIAN
mkdir C:\Users\%USERNAME%\Desktop\DEBIAN\snapshots
# déplacer le snapshot téléchargé dans le dossier snapshots
```

### Créer la distribution WSL

```
cd C:\Users\%USERNAME%\Desktop\DEBIAN
wsl --import DEBIAN . snapshots\24-devenv.tar.gz --version 2
```

### Lancer la distribution
```
wsl --distribution DEBIAN
```


### Confirmer le provisionnement

___



### WIP


#### Restaurer un snapshot
```
wsl --unregister DEBIAN
wsl --import DEBIAN . snapshots/26-devenv.tar.gz --version 2
wsl --distribution DEBIAN
```

#### Take snapshot

```
sudo apt-get autoremove -y
sudo apt-get autoclean -y
sudo apt-get clean

# Purge du cache apt et logs
sudo rm -rf /var/lib/apt/lists/*
sudo journalctl --vacuum-time=1d

sudo rm -rf /var/log/*.log
sudo rm -rf /var/log/**/*.log
sudo rm -rf /tmp/*
```


```
wsl --export DEBIAN snapshots/12-devenv.tar.gz
```