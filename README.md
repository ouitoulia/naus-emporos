# Naûs émporos
Naûs émporos - Nave mercantile

## Variabili d'ambiente
Le variabili d'ambiente del container
```shell
DATABASE_NAME=''
DATABASE_USER=''
DATABASE_PASSWORD=''
DATABASE_PREFIX=''
DATABASE_HOST=''
DATABASE_PORT=''
DATABASE_DRIVER=''
HASH_SALT=''
```

## Volumi
I volumi per rendere persistenti i dati:

- public-files:/opt/drupal/web/public-files
- private-files:/opt/drupal/private-files
- config:/opt/drupal/config
- assets-cache:/opt/drupal/web/assets-cache
