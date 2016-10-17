#!/bin/bash

[[ ${DEBUG} == true ]] && set -x

init() {
  # create incron watcher
  echo '/var/files IN_CLOSE_WRITE /opt/src/exec.sh $#' > /etc/incron.d/backup-azure
  chmod 400 /etc/incron.d/backup-azure

  # create script which push files to azure
  cat > /opt/src/exec.sh << EOF
#!/bin/bash

export AZURE_STORAGE_ACCOUNT="${AZURE_STORAGE_ACCOUNT}"
export AZURE_STORAGE_ACCESS_KEY="${AZURE_STORAGE_ACCESS_KEY}"

if [ "\$\{DOWNLOADING_FILES\}" == "\$\{1\}" ];
then
    exit 0;
fi

azure storage blob upload -q /var/files/\$\{1\} "${CONTAINER}"
EOF
  chmod 511 /opt/src/exec.sh
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
          export DOWNLOADING_FILES="${1}" 
          azure storage blob download -q --container "${CONTAINER}" -b "${1}" -d "/var/files/${1}"
          export DOWNLOADING_FILES=""
          ;;
        help|*)
          echo " backup list          - List backups on Azure."
          echo " backup list <schema> - List backups on Azure with <schema> filter."
          echo " backup restore       - Restore an existing backup (download it from Azure to /var/files folder."
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