#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Autossh
# Autossh implementation logic
# ==============================================================================
declare SSH_KEY_PATH
declare SSH_KEY_NAME
declare HOSTNAME
declare SSH_PORT
declare USERNAME
declare REMOTE_FORWARDING
declare LOCAL_FORWARDING
declare OTHER_SSH_OPTIONS
declare MONITOR_PORT
declare SERVER_ALIVE_INTERVAL
declare SERVER_ALIVE_COUNT_MAX
declare GATETIME
declare RETRY_INTERVAL
declare -a autossh_params

SSH_KEY_PATH=/data/ssh
SSH_KEY_NAME=$(bashio::config 'ssh_key_name')
HOSTNAME=$(bashio::config 'hostname')
SSH_PORT=$(bashio::config 'ssh_port')
USERNAME=$(bashio::config 'username')
REMOTE_FORWARDING=$(bashio::config 'remote_forwarding')
LOCAL_FORWARDING=$(bashio::config 'local_forwarding')
OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options')
MONITOR_PORT=$(bashio::config 'monitor_port')
SERVER_ALIVE_INTERVAL=$(bashio::config 'server_alive_interval')
SERVER_ALIVE_COUNT_MAX=$(bashio::config 'server_alive_count_max')
GATETIME=$(bashio::config 'gatetime')
RETRY_INTERVAL=$(bashio::config 'retry_interval')

# Set AUTOSSH global variables
export AUTOSSH_GATETIME=$GATETIME

# Use host share folder for keys
if bashio::config.true "use_share_folder"; then
    SSH_KEY_PATH="/share/ssh"
fi

# Generate SSH key
if [ ! -f "${SSH_KEY_PATH}/${SSH_KEY_NAME}" ]; then
    bashio::log.info "Generating new private key"
    mkdir -p "${SSH_KEY_PATH}"
    ssh-keygen -b 4096 -t ED25519 -N "" -f "${SSH_KEY_PATH}/${SSH_KEY_NAME}"  
fi

bashio::log.info "Using existing keys from: '${SSH_KEY_PATH}'"

bashio::log.info "-----------------------------------------------------------"
bashio::log.info "Public key is:"
cat "${SSH_KEY_PATH}/${SSH_KEY_NAME}.pub"
bashio::log.info "-----------------------------------------------------------"

# add host key to global ssh config
ssh-keyscan -p "$SSH_PORT" "$HOSTNAME" > "/etc/ssh/ssh_known_hosts"

# autossh params
# https://www.harding.motd.ca/autossh/
# https://linux.die.net/man/1/autossh
autossh_params+=(-M "${MONITOR_PORT}")
autossh_params+=(-N)
autossh_params+=(-q)
autossh_params+=(-o ExitOnForwardFailure=yes)
autossh_params+=(-o ServerAliveInterval="${SERVER_ALIVE_INTERVAL}")
autossh_params+=(-o ServerAliveCountMax="${SERVER_ALIVE_COUNT_MAX}")
autossh_params+=("${USERNAME}"@"${HOSTNAME}")
autossh_params+=(-p "${SSH_PORT}")
autossh_params+=(-i "${SSH_KEY_PATH}"/"${SSH_KEY_NAME}")

if [ -n "$REMOTE_FORWARDING" ]; then
    bashio::log.debug "Processing remote_forwarding argument '$REMOTE_FORWARDING'"
    while read -r line; do
        autossh_params+=(-R "$line")
    done <<< "$REMOTE_FORWARDING"
fi

if [ -n "$LOCAL_FORWARDING" ]; then
    bashio::log.debug "Processing local_forwarding argument '$LOCAL_FORWARDING'"
    while read -r line; do
        autossh_params+=(-L "$line")
    done <<< "$LOCAL_FORWARDING"
fi

# Enable debug mode on autossh
if bashio::debug; then
    autossh_params+=(-v)
fi

autossh_params+=("${OTHER_SSH_OPTIONS}")

bashio::log.info "Autossh start!"
bashio::log.debug "Executing autossh with params:"
bashio::log.debug "${autossh_params[@]}"

# Start autossh
until /usr/bin/autossh "${autossh_params[@]}" 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'
do
    bashio::log.info "Failed, retrying in ${RETRY_INTERVAL}s"
    sleep "${RETRY_INTERVAL}"
done
