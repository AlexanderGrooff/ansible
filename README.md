# Ansible

This repo contains several ansible playbooks for certain usecases.

## Usecase

Typically you boot a new VPS at your favorite hosting company, and add your SSH key to the root user in their controlpanel.
After that, you run `./bootstrap <ipaddress>` to make sure the default user exists.
You can then use `ansible-playbook -i <ipaddr>, core.yaml -v` to set up the basics.

At this point the node is ready for any of the ansible playbooks.

## Dev

```shell
mkv
ansible-galaxy collection install -r requirements-ansible-collections.yml
ansible-playbook nomad.yml -v
```
