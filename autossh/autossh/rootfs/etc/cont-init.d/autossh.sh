#!/usr/bin/with-contenv bashio
# ==============================================================================
# Home Assistant Community Add-on: Autossh
# Autossh implementation logic
# ==============================================================================
declare SSH_KEY_PATH=/data/ssh
declare SSH_KEY_NAME=$(bashio::config 'ssh_key_name')
declare HOSTNAME=$(bashio::config 'hostname')
declare SSH_PORT=$(bashio::config 'ssh_port')
declare USERNAME=$(bashio::config 'username')
declare REMOTE_FORWARDING=$(bashio::config 'remote_forwarding')
declare LOCAL_FORWARDING=$(bashio::config 'local_forwarding')
declare OTHER_SSH_OPTIONS=$(bashio::config 'other_ssh_options')
declare MONITOR_PORT=$(bashio::config 'monitor_port')
declare SERVER_ALIVE_INTERVAL=$(bashio::config 'server_alive_interval')
declare SERVER_ALIVE_COUNT_MAX=$(bashio::config 'server_alive_count_max')
declare GATETIME=$(bashio::config 'gatetime')
declare RETRY_INTERVAL=$(bashio::config 'retry_interval')


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
    ssh-keygen -b 4096 -t rsa -N "" -f "${SSH_KEY_PATH}/${SSH_KEY_NAME}"  
fi

bashio::log.info "Using existing keys from: '${SSH_KEY_PATH}'"

bashio::log.info "-----------------------------------------------------------"
bashio::log.info "Public key is:"
cat "${SSH_KEY_PATH}/${SSH_KEY_NAME}.pub"
bashio::log.info "-----------------------------------------------------------"

# add host key to global ssh config
ssh-keyscan -p $SSH_PORT $HOSTNAME > /etc/ssh/ssh_known_hosts

# autossh params
# https://www.harding.motd.ca/autossh/
# https://linux.die.net/man/1/autossh
command_args="-M ${MONITOR_PORT} \
    -N -q \
    -o ExitOnForwardFailure=yes \
    -o ServerAliveInterval=${SERVER_ALIVE_INTERVAL} \
    -o ServerAliveCountMax=${SERVER_ALIVE_COUNT_MAX} \
    ${USERNAME}@${HOSTNAME} \
    -p ${SSH_PORT} \
    -i ${SSH_KEY_PATH}/${SSH_KEY_NAME}"

if [ -n "$REMOTE_FORWARDING" ]; then
    bashio::log.debug "Processing remote_forwarding argument '$REMOTE_FORWARDING'"
    while read -r line; do
        command_args="${command_args} -R $line"
    done <<< "$REMOTE_FORWARDING"
fi

if [ -n "$LOCAL_FORWARDING" ]; then
    bashio::log.debug "Processing local_forwarding argument '$LOCAL_FORWARDING'"
    while read -r line; do
        command_args="${command_args} -L $line"
    done <<< "$LOCAL_FORWARDING"
fi


command_args="${command_args} ${OTHER_SSH_OPTIONS}"
bashio::log.info "Autossh start!"
bashio::log.debug "Executing autossh with params: ${command_args}"

# Start autossh
until /usr/bin/autossh ${command_args} 2>&1 | ts '[%Y-%m-%d %H:%M:%S]'
do
    bashio::log.info "Failed, retrying in ${RETRY_INTERVAL}s"
    sleep ${RETRY_INTERVAL}
done
