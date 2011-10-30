
# Vagrant

- Keeping a definitive base of my development environment. I always have an image of a machine that I consider my minimum requirements for whatever project I might be working on. This is an Ubuntu image with all the tools I use, my vimrc and my virtualenv/pip shortcuts, etc. When I start a new project, I clone this image and add to it.
- Making my specific environments reproducible. This one I have tried and can now start doing seriously with Vagrant. For any project, I can maintain a script to build a development environment on top of my base. The benefits are two part. First, I can keep a clean record of what is required to work with a project. Second, when a change is made to my base, I can rebuild my development environment for all of my projects instantly. (Well, I can issue the command instantly, but I'll probably each lunch before its done!)
- VirtualBox images can be portable. It might even be possible to move suspended images, but I'm not completely sure about this, yet. If it turns out to be something I can do, I'll be able to suspend a project on my desktop, running the box off a USB key, and then resume it on my laptop in the park. Even if I can't do this, I can still build identical environments on multiple machines, for myself or for other developers.
- Replicating production and building local staging setups, machine the setups I have at Linode and EC2, will become something I can do with a minimal effort. I'm going to save a lot of time deploying to clones of my production machines running right here under my desk.

- http://wiki.opscode.com/display/chef/Chef+Basics
- http://vagrantup.com/docs/getting-started/index.html
- https://github.com/mitchellh/vagrant
- http://www.owengriffin.com/posts/2010/05/01/Vagrant_for_Debian_testing.html
- http://r35243.ovh.net/vagrant/
- http://edmund.haselwanter.com/de/blog/2009/10/14/chef-von-opscode-und-die-eleganz-von-ruby/

## Examples

- https://github.com/bmabey/continuous-cooking # => hudson, git, gerrit plugin

## Installation

alias vagrant="bundle exec vagrant"
alias vssh="bundle exec vagrant ssh"
alias vr="bundle exec vagrant resume"
alias vs="bundle exec vagrant ssh"

`git submodule init && git submodule update
# NOTE: Make sure you've installed VirtualBox first!
gem install vagrant
# Downloads a blank Ubuntu 11.04 64-bit image
# Or find your own box on http://vagrantbox.es
vagrant box add ubuntu-1104-server-i386 http://dl.dropbox.com/u/7490647/talifun-ubuntu-11.04-server-i386.box
# Adds a Vagrantfile to your Rails app which talks to the new image
vagrant init ubuntu-1104-server-amd64
# Starts the new VM
vagrant up
# Adds SSH details to your SSH config so Capistrano can deploy directly to your VM
vagrant ssh-config >> ~/.ssh/config
# Logs into your new VM
vagrant ssh
# Perform a lot of Chef recipe work
# ...Left as an exercise to the reader...`

### On NAT Error

`vagrant halt`

nat dns problems on osx:
-------------------------
9.9.6 Using the host’s resolve as a DNS proxy in NAT mode
For resolving network names, the DHCP server of the NAT engine offers a list of registered
DNS servers of the host. If for some reason you need to hide this DNS server list and use the
host’s resolver settings, thereby forcing the VirtualBox NAT engine to intercept DNS requests and
forward them to host’s resolver, use the following command:

`VBoxManage modifyvm "framework_test_env" --natdnshostresolver1 on`

Note that this setting is similar to the DNS proxy mode, however whereas the proxy mode
just forwards DNS requests to the appropriate servers, the resolver mode will interpret the DNS
requests and use the host’s DNS API to query the information and return it to the guest.

`vagrant reload`

### SSH Connect to VM

`vagrant ssh`

`cd /srv/apps/jojumi/current`

`rake db:create db:migrate`

## Other commands

`vagrant --help`

## Create Base Boxes with VirtualBox

- http://vagrantup.com/docs/base_boxes.html

## Chef Server

- http://vagrantup.com/docs/provisioners/chef_server.html

## Hudson

- Hudson CI
- http://drnicwilliams.com/2010/11/09/making-ci-easier-to-do-than-not-to-with-hudson-ci-and-vagrant/
- https://github.com/cowboyd/hudson.rb

`rvm ree
gem install hudson
rvm exec hudson server`
