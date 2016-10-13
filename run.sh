#!/bin/bash

# create incron watcher
echo '/var/files IN_CLOSE_WRITE /opt/src/exec.sh $#' > /etc/incron.d/backup-azure
chmod 400 /etc/incron.d/backup-azure

# create script which push files to azure 
cat > /opt/src/exec.sh << EOF
#!/bin/bash

export AZURE_STORAGE_ACCOUNT=$AZURE_STORAGE_ACCOUNT
export AZURE_STORAGE_ACCESS_KEY=$AZURE_STORAGE_ACCESS_KEY

azure storage blob upload /var/files/$1 $CONTAINER

EOF

chmod 511 /opt/src/exec.sh

service incron start