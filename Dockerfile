FROM ruby:2.6.5

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
 && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
 && apt-get update -qq && apt-get install -y vim less nodejs yarn git \
    build-essential libpq-dev postgresql-client unzip \
    \
 && CHROME_DRIVER_VERSION=`curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE` \
 && wget -N http://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip -P ~/ \
 && unzip ~/chromedriver_linux64.zip -d ~/ \
 && rm ~/chromedriver_linux64.zip \
 && chown root:root ~/chromedriver \
 && chmod 755 ~/chromedriver \
 && mv ~/chromedriver /usr/bin/chromedriver \
 && sh -c 'wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -' \
 && sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' \
 && apt-get update && apt-get install -y google-chrome-stable \
    \
 && gem install bundler \
 && gem install nokogiri -- --use-system-libraries \
 && gem install websocket-driver -- --use-system-libraries \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN mkdir /KamitechApp
ENV APP_ROOT /KamitechApp
WORKDIR $APP_ROOT

COPY Gemfile $APP_ROOT
COPY Gemfile.lock $APP_ROOT

RUN bundle install
COPY . $APP_ROOT

EXPOSE 3000
CMD ["rails", "server", "-b", "0.0.0.0"]
