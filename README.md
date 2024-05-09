# Naûs émporos

![GitHub](https://img.shields.io/github/license/ouitoulia/naus-emporos?style=for-the-badge)
![GitHub Actions Workflow Status](https://img.shields.io/github/actions/workflow/status/ouitoulia/naus-emporos/build-push-to-registry.yaml?style=for-the-badge)
![Docker Pulls](https://img.shields.io/docker/pulls/ouitoulia/naus-emporos?style=for-the-badge)


Naûs émporos (nave mercantile) è un'immagine docker del CMS Ouitoulía.
Tags: https://hub.docker.com/r/ouitoulia/naus-emporos/tags

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
- assets-cache:/opt/drupal/web/assets-cache (opzionale)
- tmp:/opt/drupal/tmp (opzionale)

## Come personalizzare le dipendenze
Questi i 3 modi principali:

A) monta `composer.custom.json:/opt/drupal/composer.custom.json` e aggiungi i tuoi moduli,
in questo modo non stai modificando il `composer.json` presente nell'immagine, quindi ad ogni 
aggiornamento di questa immagine avrai la versione aggiornata

B) monta `composer.json:/opt/drupal/composer.json` ad ogni aggiornamento dell'immagine dovresti
aggiornare il tuo `composer.json` con quello presente su ouitoulia/diagraphe/composer.json,
rispettando la versione

C) fai il build di un'immagine partendo da `FROM ouitoulia/naus-emporos:<tag>`
aggiungendo le tue personalizzazioni

## Come personalizzare settings.php
Monta `settings.local.php:/var/www/html/sites/default/settings.local.php`

## License
![GitHub](https://img.shields.io/github/license/ouitoulia/naus-emporos)

Copyright (C) 2023/2024 https://github.com/ouitoulia

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3 as published by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

Questo è un software libero: puoi ridistribuirlo e/o modificarlo secondo i termini della GNU General Public License versione 3 pubblicata dalla Free Software Foundation.

Questo programma è distribuito nella speranza che possa essere utile, ma SENZA ALCUNA GARANZIA; senza nemmeno la garanzia implicita di COMMERCIABILITÀ o IDONEITÀ PER UNO SCOPO PARTICOLARE. Vedere la GNU General Public License per maggiori dettagli.

Questo software è distribuito sotto i termini della GNU Affero General Public License versione 3 (AGPL-3.0)

