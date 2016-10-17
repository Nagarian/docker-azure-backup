# Docker-backup-azure

container to backup files in folder to Microsoft Azure Storage.

# Container startup explained
* The container watch to ```/usr/data``` folder and upload each files he find
* Using azure-cli the file will be uploaded to Azure Storage
* After that, he watch the folder for any new file and then upload them

# Environment variables

- _`$CONTAINER`_ - Container name in azure
- _`$AZURE_STORAGE_ACCOUNT`_ - Name of Azure Storare Account
- _`$AZURE_STORAGE_ACCESS_KEY`_ - Acess Key for Storage Account

# Example of running

```bash
docker run -d --name docker-azure-backup \
-e "AZURE_STORAGE_ACCOUNT=azure-storage"
-e "AZURE_STORAGE_ACCESS_KEY=ashdgashdgasdsa--dadcdsfsd/sdfd--"
-e "CONTAINER=logs-backup" \
nagarian/docker-azure-backup
```

### Building image

```bash
docker build -t nagarian/docker-azure-backup .
```
