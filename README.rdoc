== README


* Setup test environment for Mac

    $ brew install readline ruby-build phantomjs
    $ RUBY_CONFIGURE_OPTS=--with-readline-dir=`brew --prefix readline` rbenv install 2.3.1 rbenv install 2.3.1
    $ bundle install

* Test
Currently Guard does not work with spring due to bundler path issue? So use rspec command directly

    $ bin/rspec


Please feel free to use a different markup language if you do not plan to run
<tt>rake doc:app</tt>.
