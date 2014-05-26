# Berkshelf Solo

berkshelf-solo is an experimental project that acts as an adapter between [Berkshelf](http://berkshelf.com/) and [chef-solo](http://docs.opscode.com/chef_solo.html), it works by generating a chef-solo style layout and configuration files when executing the `berks vendor` command.

## Dependencies 
* Ruby 1.9+
* latest Berkshelf beta ( currently 3.0.0.beta9 )
* Berksfile

## Installation
with `bundler` just add this line to your `Gemfile` and then execute `bundle install`
```
gem 'berkshelf-solo'
```
else you can manually install it by running
```
gem install berkshelf-solo
```

## Usage
### Compile cookbooks and prepare chef-solo layout
add this line at the top of your Berksfile
```ruby
require 'berkshelf/solo'
```

after loading berkshelf-solo you will able to specify recipes that you want to install, for example lets say we want to install mysql server and client
```ruby
cookbook 'mysql', :recipes => ["client", "server"]
```
run the berks vendor command and specify the cookbooks output folder, in this example we save the cookbooks under the chef/cookbooks directory inside our current directory
```
berks vendor chef/cookbooks
```
after the command was successfully run, look for the `chef-solo` configuration files and folders layout under the chef directory, should look something like this

```
$ ls -lrth chef/
drwxr-xr-x   2  wheel    68B Aug 14 15:52 roles
drwxr-xr-x   2  wheel    68B Aug 14 15:52 environments
drwxr-xr-x   2  wheel    68B Aug 14 15:52 data_bags
drwxr-xr-x  11  wheel   374B Aug 14 16:21 cookbooks
-rw-r--r--   1  wheel   289B Aug 14 17:42 solo.rb
-rw-r--r--   1  wheel   313B Aug 14 17:42 solo.json

$ cat chef/solo.json
{
  "run_list": [
    "recipe[mysql::client]",
    "recipe[mysql::server]"
  ]
}
```

To override attributes just place them inside the `solo.json` at the root level, for example setting the root password for our mysql server

```
{
  "run_list": [
    "recipe[nginx::default]",
    "recipe[mysql::default]",
    "recipe[mysql::server]"
  ],
  "mysql": {
    "server_root_password": "password",
    "server_debian_password": "password",
    "server_repl_password": "password"
  }
}
```

### Install cookbooks using chef-solo on your target machine
Now to actually install the recipes using chef-solo you will need to run this command on your target machine ( inside the main project folder,  on `Berksfile` location  )
```
chef-client -c `pwd`/chef/solo.rb -j `pwd`/chef/solo.json`
```

## Warranty
This software is provided “as is” and without any express or implied warranties, including, without limitation, the implied warranties of merchantability and fitness for a particular purpose.
