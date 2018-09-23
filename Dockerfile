FROM fedora:28

MAINTAINER Paul Podgorsek <ppodgorsek@users.noreply.github.com>
LABEL description Robot Framework in Docker.

# Setup volumes for input and output
VOLUME /opt/robotframework/reports
VOLUME /opt/robotframework/tests

# Setup X Window Virtual Framebuffer
ENV SCREEN_COLOUR_DEPTH 24
ENV SCREEN_HEIGHT 1080
ENV SCREEN_WIDTH 1920

# Set number of threads for parallel execution
# By default, no parallelisation
ENV ROBOT_THREADS 1

# Dependency versions
ENV CHROMIUM_VERSION 69.0.*
ENV FIREFOX_VERSION 62.0*
ENV PYTHON_PIP_VERSION 9.0.*
ENV XVFB_VERSION 1.19.*

# Install system dependencies
RUN dnf upgrade -y \
  && dnf install -y \
    chromedriver-$CHROMIUM_VERSION \
    chromium-$CHROMIUM_VERSION \
    firefox-$FIREFOX_VERSION \
    python2-pip \
    xauth \
    xorg-x11-server-Xvfb-$XVFB_VERSION \
    which \
    wget \
    iputils \
    bind-utils \
    traceroute \
    mtr \
    jq \
  && dnf clean all

ENV ROBOT_FRAMEWORK_VERSION 3.0.4
ENV FAKER_VERSION 4.2.0
ENV PABOT_VERSION 0.43
ENV REQUESTS_VERSION 0.4.7
ENV SELENIUM_LIBRARY_VERSION 3.2.0
ENV DIFF_LIBRARY_VERSION 0.1.0
ENV DATABASE_LIBRARY_VERSION 1.1.1
ENV PYYAML_VERSION 3.13

# Install Robot Framework and Selenium Library
RUN pip install \
  robotframework==${ROBOT_FRAMEWORK_VERSION} \
  robotframework-faker==${FAKER_VERSION} \
  robotframework-pabot==${PABOT_VERSION} \
  robotframework-requests==${REQUESTS_VERSION} \
  robotframework-seleniumlibrary==${SELENIUM_LIBRARY_VERSION} \
  robotframework-difflibrary==${DIFF_LIBRARY_VERSION} \
  robotframework-databaselibrary==${DATABASE_LIBRARY_VERSION} \
  pyyaml==${PYYAML_VERSION}

ENV GECKO_DRIVER_VERSION v0.22.0

# Download Gecko drivers directly from the GitHub repository
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/$GECKO_DRIVER_VERSION/geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz" \
      && tar xzf geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz \
      && mkdir -p /opt/robotframework/drivers/ \
      && mv geckodriver /opt/robotframework/drivers/geckodriver \
      && rm geckodriver-$GECKO_DRIVER_VERSION-linux64.tar.gz

# Prepare binaries to be executed
COPY bin/chromedriver.sh /opt/robotframework/bin/chromedriver
COPY bin/chromium-browser.sh /opt/robotframework/bin/chromium-browser
COPY bin/run-tests-in-virtual-screen.sh /opt/robotframework/bin/

# FIXME: below is a workaround, as the path is ignored
RUN mv /usr/lib64/chromium-browser/chromium-browser /usr/lib64/chromium-browser/chromium-browser-original \
  && ln -sfv /opt/robotframework/bin/chromium-browser /usr/lib64/chromium-browser/chromium-browser

# Update system path
ENV PATH=/opt/robotframework/bin:/opt/robotframework/drivers:$PATH

# Execute all robot tests
CMD ["run-tests-in-virtual-screen.sh"]
