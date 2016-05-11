# Salt Bootstrap Tests

This repo contains SLS files used for testing
[salt-bootstrap](https://github.com/saltstack/salt-bootstrap/).  The SLS files
assume very specific things about how Salt Cloud has been configured, but
should be easily modifiable as needed.  They also assume the custom execution
and state modules from [precipitate](https://github.com/jfindlay/precipitate/)
have been installed.  This step will be necessary until my (@jfindlay) [cloud
roster
rewrite](https://github.com/saltstack/salt/compare/develop...jfindlay:cloud_roster)
is complete and merged.

## Setup

Assuming Salt Cloud and the precipitate modules are already installed and
working, the following should be sufficient.
```yaml
# cd /root ; git clone https://github.com/jfindlay/salt-bootstrap-tests.git
# cat > /etc/salt/master
file_roots:
  base:
    - /root/salt-bootstrap-tests
```

## Provision VMs

- `stage` pillar argument: must be exactly set to either `present` or `absent`,
  otherwise the state application that provisions the VMs will fail.  The
  default is an empty string, so the argument is required.
- `type`: inserted into the VM names and will also parameterize the install
  type argument passed to the bootstrap script itself when that part is
  automated into the formula.
- `name`: namespaces your VMs on the cloud provider by being inserted at the
  beginning of each VM name.
- `provider`: (un)provision VMs from a single provider.  If this is unset, all
  providers configured in `bootstrap/params.jinja` will be (un)provisioned.
- `profiles`: (un)provision specific VMs from the named provider.  If this is
  unset, all profiles associated with the named provider will be
  (un)provisioned.

(This is awfully inefficient because it (un)provisions in series, which is
another reason to anticipate a fully functioning cloud roster.)

```console
# salt-call --local state.apply bootstrap.provision pillar="{'stage': 'present', 'type': 'stable', 'name': 'jmoney'}"
# salt-call --local state.apply bootstrap.provision pillar="{'stage': 'present', 'type': 'stable', 'name': 'jmoney', 'provider': 'do', 'profiles': ['fedora-22', 'fedora-23']}"
```

## Test bootstrap
```console
# less /etc/salt/roster
# salt-ssh 'jmoney-git-*' -i test.ping
# salt-ssh 'jmoney-git-*' cmd.run 'curl -L https://raw.githubusercontent.com/saltstack/salt-bootstrap/develop/bootstrap-salt.sh | sudo sh -s -- git stable 2016.8.9' &>> bootstrap.$(date --iso-8601).output
# salt-ssh 'jmoney-git-*' cmd.run 'which salt-minion ; salt-minion --version' env='PATH="/usr/local/bin:/usr/bin"'
```

## Unprovision VMs
Warning!  Always ensure you know exactly which VMs will be deleted.
```console
# salt-call --local state.apply bootstrap.provision mock=True pillar="{'stage': 'absent', 'type': 'stable', 'name': 'jmoney'}"
# salt-call --local state.apply bootstrap.provision pillar="{'stage': 'absent', 'type': 'stable', 'name': 'jmoney'}"
```
