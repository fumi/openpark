# Openpark


## Setup test environment for Mac

```
$ brew install readline rbenv ruby-build phantomjs
$ RUBY_CONFIGURE_OPTS=--with-readline-dir=`brew --prefix readline` rbenv install 2.3.6
$ bundle install
```


## Test
現状殆ど意味ない
Currently Guard does not work with spring due to bundler path issue? So use rspec command directly

```
$ bin/rspec
```
