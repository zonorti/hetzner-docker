# Hetzner::Docker

Ultra simple deployment of Docker-enabled Hetzner servers  

```
Usage: hetzner-docker [command] [options]
    -v, --version      module version
    -m, --methods      print all methods
    -h, --help         Display this help message.

Available commands:

  rescue      Enter Rescue mode
  ubuntu      Install ubuntu on server
  chef        Install chef
  cook        Cook docker recipes
  bootstrap   Do everything
```

## Installation

Add this line to your application's Gemfile:

    gem 'hetzner-docker'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install hetzner-docker

## Usage

```
export HETZNER_USER="" && export HETZNER_PASSWORD="" 

hetzner-docker bootstrap -i <server-ip> -d <server-domain>

```


## TODO

1. Modular config for do-install-trusty.sh
2. More options
3. Verbose and non-verbose output


## Contributing

1. Fork it ( http://github.com/imelnik/hetzner-docker/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
