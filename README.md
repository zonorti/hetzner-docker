# Hetzner::Docker

[![CodeFactor](https://www.codefactor.io/repository/github/ZonOrti/hetzner-docker/badge)](https://www.codefactor.io/repository/github/ZonOrti/hetzner-docker)

Ultra simple deployment of Docker-enabled Hetzner servers.
Uses:
hetzner-api
Chef (knife-solo)
chef-docker cookbook  


## Installation

Add this line to your application's Gemfile:

    gem 'hetzner-docker'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hetzner-docker

## Usage
You should have your ssh public key located at ~/.ssh/id_rsa.pub and get a copy of Berksfile at your current working directory.

```
export HETZNER_USER="" && export HETZNER_PASSWORD="" 

hetzner-docker bootstrap -i <server-ip> -d <server-domain>

```


## TODO

1. Modular config for do-install-trusty.sh
2. More options
3. Verbose and non-verbose output
4. Enable OpenVSwitch install


## Contributing

1. Fork it ( http://github.com/ZonOrti/hetzner-docker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
