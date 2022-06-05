# Home Assistant Community Add-on: Autossh

Use SSH to make ports of your local Home Assistant setup available at or
through a remote system.
This forms yet another way to make the Lovelace UI and other services
accessible from another network or the public internet.
If you do not have the authority to open ports into your local network,
and a VPN solutions seems overkill, this add-on might just be the solution
for you.

The solution is only useful to those with access to a publicly available
SSH server and some administrative privileges on that system.

Autossh is a well known tool to establish an SSH connection and keep it
connected over hours and months.
SSH is known for its high security and the ability to set up port forwardings
in both directions through the SSH connection.
In combination, this add-on offers tunneled port forwarding functionality.

The solution works reliably and without disruptions.

## Installation

The installation of this add-on is pretty straightforward and not different in
comparison to installing any other Home Assistant add-on.

1. Search for the "Autossh" add-on in the Supervisor add-on store and install
   it.
1. Configure add-on with the parameters of your server.
1. Start add-on and check the logs for grab the generated public key.
1. Add the key on your server to this path `~/.ssh/authorized_keys` and
   restart the add-on.

## Configuration

Eventought this add-on is just an example add-on, it does come with some
configuration options to play around with.

**Note**: _Remember to restart the add-on when the configuration is changed._

Example add-on configuration:

```yaml
hostname: yourremotehost.com
ssh_port: 22
username: autossh
remote_forwarding:
  - 127.0.0.1:8123:172.17.0.1:8123
local_forwarding:
  - ""
other_ssh_options: "-v"
monitor_port: 0
server_alive_interval: 30
server_alive_count_max: 3
gatetime: 0
retry_interval: 3
ssh_key_name: addon_autossh_key
use_share_folder: true
log_level: info
```

### Option: `hostname`

The hostname of your SSH server (DNS or IP).

### Option: `ssh_port`

The SSH port on your SSH server (typically 22).

### Option: `username`

The username to be connected as on the SSH server.
Remember to store the generated public key in `~/.ssh/authorized_keys` of
this users home.

### Option: `remote_forwarding`

A list of SSH remote forwadings to be applied.
For this add-on, the most meaningful setting is
`127.0.0.1:8123:172.17.0.1:8123`.
This line forwards the Lovelace UI to the remote server localhost on
the port 8123.
If you decided to go with `GatewayPorts`, you should know what to change.

### Option: `local_forwarding`

A list of SSH local forwadings to be applied.
Local port forwarding allows you to forward a port on the local (ssh client)
machine to a port on the remote (ssh server) machine, which is then forwarded
to a port on the destination machine.

### Option: `other_ssh_options`

Additional `ssh` options that will be added.
This is optional and for testing purposes a verbose output enabled by
`-v` can be useful.

### Option: `monitor_port`

Specifies the base monitoring port to use. Without the echo port, this port
and the port immediately above it (port + 1) should be something nothing else
is using. autossh will send test data on the base monitoring port, and
receive it back on the port above. For example, if you specify "-M 20000",
autossh will set up forwards so that it can send data on port 20000 and
receive it back on 20001.

Setting the monitor port to 0 turns the monitoring function off, and autossh
will only restart ssh upon ssh's exit. For example, if you are using a recent
version of OpenSSH, you may wish to explore using the ServerAliveInterval and
ServerAliveCountMax options to have the SSH client exit if it finds itself no
longer connected to the server. In many ways this may be a better solution
than the monitoring port.

### Option: `server_alive_interval`

Sets a timeout interval in seconds after which if no data has been received
from the server, ssh will send a message through the encrypted channel to
request a response from the server.
The ssh default is 0, indicating that these messages will not be sent to the
server.

### Option: `server_alive_count_max`

Sets the number of server alive messages which may be sent without ssh
receiving any messages back from the server.
If this threshold is reached while server alive messages are being sent,
ssh will disconnect from the server, terminating the session.

### Option: `gatetime`

Specifies how long ssh must be up before we consider it a successful
connection. The default is 30 seconds.
Note that if gatetime is set to 0, then not only is the gatetime behaviour
turned off, but autossh also ignores the first run failure of ssh.
This may be useful when running autossh at boot.

### Option: `retry_interval`

This directive is used to define the number of secons to wait before
scheduling a re-conection with the hosts.

### Option: `ssh_key_name`

Descriptive name for your SSH key.

### Option: `use_share_folder`

With this directive you can force the keys to be saved in the `share`
folder of the host.

### Option: `log_level`

The `log_level` option controls the level of log output by the add-on and can
be changed to be more or less verbose, which might be useful when you are
dealing with an unknown issue. Possible values are:

- `trace`: Show every detail, like all called internal functions.
- `debug`: Shows detailed debug information.
- `info`: Normal (usually) interesting events.
- `warning`: Exceptional occurrences that are not errors.
- `error`: Runtime errors that do not require immediate action.
- `fatal`: Something went terribly wrong. Add-on becomes unusable.

Please note that each level automatically includes log messages from a
more severe level, e.g., `debug` also shows `info` messages. By default,
the `log_level` is set to `info`, which is the recommended setting unless
you are troubleshooting.

## Changelog & Releases

This repository keeps a change log using [GitHub's releases][releases]
functionality.

Releases are based on [Semantic Versioning][semver], and use the format
of `MAJOR.MINOR.PATCH`. In a nutshell, the version will be incremented
based on the following:

- `MAJOR`: Incompatible or major changes.
- `MINOR`: Backwards-compatible new features and enhancements.
- `PATCH`: Backwards-compatible bugfixes and package updates.

## Support

Got questions?

You have several options to get them answered:

- The [Home Assistant Community Add-ons Discord chat server][discord] for
  add-on support and feature requests.
- The [Home Assistant Discord chat server][discord-ha] for general Home
  Assistant discussions and questions.
- The Home Assistant [Community Forum][forum].
- Join the [Reddit subreddit][reddit] in [/r/homeassistant][reddit]

You could also [open an issue here][issue] GitHub.

## Authors & contributors

For a full list of all authors and contributors,
check [the contributor's page][contributors].

## License

MIT License

Copyright (c) 2017-2021 DSR!

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

[contributors]: https://github.com/xchwarze/addon-autossh/graphs/contributors
[discord-ha]: https://discord.gg/c5DvZ4e
[discord]: https://discord.me/hassioaddons
[forum]: https://community.home-assistant.io
[issue]: https://github.com/xchwarze/addon-autossh/issues
[reddit]: https://reddit.com/r/homeassistant
[releases]: https://github.com/xchwarze/addon-autossh/releases
[semver]: http://semver.org/spec/v2.0.0.html
