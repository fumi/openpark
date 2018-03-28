# Openpark

https://openpark.jp 用のコード

## Setup test environment for Mac

```
$ brew install readline rbenv ruby-build phantomjs
$ RUBY_CONFIGURE_OPTS=--with-readline-dir=`brew --prefix readline` rbenv install 2.3.6
$ bundle install
```

```
$ bundle exec rackup config.ru
```

ブラウザで http://localhost:9292 開く。
ホスト名の処理サボっているのでテスト環境でリンククリックするとopenpark.jpに飛んでしまうので注意。;

## Test
現状殆ど意味ない
Currently Guard does not work with spring due to bundler path issue? So use rspec command directly

```
$ bin/rspec
```
