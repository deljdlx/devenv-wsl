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

[Télécharger le snapshot](https://drive.google.com/file/d/1EJ1QjbhePUpzKi4cS5Lez3UEgfimP7KP/view?usp=sharing)

### Créations des dossiers

```
mkdir C:\Users\%USERNAME%\Desktop\devenv
mkdir C:\Users\%USERNAME%\Desktop\devenv\snapshots
# déplacer le snapshot téléchargé dans le dossier snapshots
```

### Créer la distribution WSL

```
cd C:\Users\%USERNAME%\Desktop\devenv
wsl --import devenv .\devenv\snapshots\20-devenv.tar.gz --version 2
```

### Lancer la distribution
```
wsl --distribution devenv
```


### Confirmer le provisionnement

___



### WIP


#### Restaurer un snapshot
```
wsl --unregister devenv
wsl --import devenv . snapshots/12-devenv.tar.gz --version 2
wsl --distribution devenv
```

#### Take snapshot
```
wsl --export devenv snapshots/12-devenv.tar.gz
```