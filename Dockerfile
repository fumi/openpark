FROM ruby:2.3.1
RUN apt-get update -qq && apt-get install -y build-essential

# install phantomjs
#ENV PHANTOM_DIR /usr/local/phantomjs
#ENV PHANTOM_NAME phantomjs-2.1.1-linux-x86_64
#RUN mkdir -p "$PHANTOM_DIR" && chmod 755 "$PHANTOM_DIR"
#RUN cd "$PHANTOM_DIR"
#RUN wget https://bitbucket.org/ariya/phantomjs/downloads/$PHANTOM_NAME.tar.bz2
#RUN tar xjf "$PHANTOM_NAME.tar.bz2"
#RUN ln -s $PHANTOM_DIR/$PHANTOM_NAME/bin/phantomjs /usr/local/bin/phantomjs

ADD . /app
WORKDIR /app
RUN bundle install
