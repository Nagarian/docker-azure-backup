#!/bin/bash

[[ ${DEBUG} == true ]] && set -x

init() {
  # create incron watcher
  echo '/var/files IN_CLOSE_WRITE azure-backup-uploader $#' > /etc/incron.d/backup-azure
  chmod 400 /etc/incron.d/backup-azure

  # create script which push files to azure
  cat > /usr/bin/azure-backup-uploader << EOF
#!/bin/bash

export AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT}"
export AZURE_STORAGE_ACCESS_KEY="${AZURE_STORAGE_ACCESS_KEY}"

if [ -f /tmp/downloaded_file ] && [ "\$(cat /tmp/downloaded_file)" == "\${1}" ];
then
  rm /tmp/downloaded_file
  exit 0;
fi

azure storage blob upload -q "/var/files/\${1}" "${CONTAINER}"
EOF
  chmod 511 /usr/bin/azure-backup-uploader
}

case ${1} in
  init|start|backup)

    # init()

    case ${1} in
      init)
        init
        ;;
      start)
        init
        incrond --foreground
        ;;
      backup)
        shift 1
        case ${1} in
        list)
          shift 1
          if [ ! -z "${1}" ];
            then
              azure storage blob list -p "${1}" --container "${CONTAINER}"
          else
            azure storage blob list --container "${CONTAINER}"
          fi
          ;;
        restore)
          shift 1
          if [ ! -z "${1}" ];
            then
              echo "${1}" > /tmp/downloaded_file
              azure storage blob download -q --container "${CONTAINER}" -b "${1}" -d "/var/files/${1}"
          else
            azure storage blob list --container "${CONTAINER}"
            printf "\e[1;36m Blob name : \033[0m"
            read blobname
            azure storage blob download -q --container "${CONTAINER}" -b "${blobname}" -d "/var/files/${1}"
          fi
          ;;
        help|*)
          echo " backup list               - List backups on Azure."
          echo " backup list <schema>      - List backups on Azure with <schema> filter."
          echo " backup restore            - Restore an existing backup from Azure to /var/files folder (interactive mode)."
          echo " backup restore <blobname> - Restore specified backup from Azure to /var/files folder."
          ;;
        esac
        ;;
    esac
    ;;
  help)
    echo "Available options:"
    echo " start            - Starts the container (default)"
    echo " init             - Initialize the container, but don't start it."
    echo " backup list      - List backups on Azure."
    echo " backup restore   - Restore an existing backup (download it from Azure to /var/files folder."
    echo " backup help      - Display the backup help."
    echo " help             - Display the help."
    echo " [command]        - Execute the specified command, eg. bash."
    ;;
  *)
    exec "$@"
    ;;
esac