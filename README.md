# Docker-backup-azure

This container help you to backup importants files which are generated into a specific folder to Microsoft Azure Storage.

E.G. : I use this [redmine docker](https://github.com/sameersbn/docker-redmine) with automatic backup.
So with this container, each time a backup is created, it's uploaded to azure blob storage.   

## Environment variables

- _`$CONTAINER`_ - Container name in azure
- _`$AZURE_STORAGE_ACCOUNT`_ - Name of Azure Storare Account
- _`$AZURE_STORAGE_ACCESS_KEY`_ - Acess Key for Storage Account

## Example of running

```bash
docker run -d --name docker-azure-backup \
-e "AZURE_STORAGE_ACCOUNT=azure-storage" \
-e "AZURE_STORAGE_ACCESS_KEY=ashdgashdgasdsa--dadcdsfsd/sdfd--" \
-e "CONTAINER=logs-backup" \
-v /var/log:/var/files:ro \
nagarian47/docker-azure-backup
```

### Building image
If you want to build this docker by yourself, it's whith this command : 
```bash
docker build -t nagarian47/docker-azure-backup .
```

## Backup

### List available backup on azure
When you want to restore a file from azure, you must want to know what's have been uploaded yet.
So you can obtain this information with this command-line :
```bash
docker exec -it docker-azure-backup /opt/src/run.sh backup list
``` 
And you can filter this list with specify a `<schema>` :
```bash
docker exec -it docker-azure-backup /opt/src/run.sh backup list backup-*
```

### Restore backup from azure
To restore a file from azure, you have to do :
```bash
docker exec -it docker-azure-backup /opt/src/run.sh backup restore <file-name>
```

> NB : In order to use this feature, you need to run this docker with no read-only folder
> ```bash
> docker run -d --name docker-azure-backup \
> -e "AZURE_STORAGE_ACCOUNT=azure-storage" \
> -e "AZURE_STORAGE_ACCESS_KEY=your-personnal-key" \
> -e "CONTAINER=logs-backup" \
> -v /var/log:/var/files \
> nagarian47/docker-azure-backup
> ```

## Other Usage

### Display commands help
If you don\'t know what you can do, display the help :
```bash
docker exec -it docker-azure-backup /opt/src/run.sh help
```

### Get event logs
You can obtain logs of uploaded files by tiping this command :
```bash
docker logs -f docker-azure-backup
```

### Get a shell
If you have (want) to troubleshoot this container, you can have a shell by tiping : 
```bash
docker exec -it docker-azure-backup bash
```
