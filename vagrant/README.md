# Vagrant setup for development machines

CentOS virtual machines using Vagrant


## Requirements

The `vagrant-vbguest` plugin is required. You can install it by running

    vagrant plugin install vagrant-vbguest


## Enabling shared folders

To enable sharing a folder, uncomment and edit the line with the configuration `config.vm.synced_folder`, replacing `<src>` with the path to the local directory to be made available in the virtual machine.


## Vagrant commands

To create or start, stop and destroy a virtual machine, use the commands below:

    vagrant up
    vagrant halt
    vagrant destroy

Additional documentation can be found at https://www.vagrantup.com/docs
