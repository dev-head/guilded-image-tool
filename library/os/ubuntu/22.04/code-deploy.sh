#!/usr/bin/env bash

ON_START=${1:-"false"}
AGENT_VERSION=${2:-""}

# Justification:
# The AWS team has not supported this code deploy agent very much over the past few years,
# while it sounds like they are renewing their efforts, it's still lagging behind newer distros.
# this script is intended to be able to support installing the lastest agent or a speicfic version.
# If you are deploying on ruby3 environment, use the specific version in order for this script to work around the
# lack of support from the development team.
#
# @issue: https://github.com/aws/aws-codedeploy-agent/issues/301
# @usage
#   ./code-deploy.sh disabled 1.4.1-2244
#   ./code-deploy.sh disabled
#   ./code-deploy.sh true

install_by_version(){
  mkdir -p /tmp/install-codedeploy
  cd /tmp/install-codedeploy
  curl -L -o install.deb https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/releases/codedeploy-agent_${AGENT_VERSION}_all.deb
  mkdir unpack-deb
  dpkg-deb -R install.deb unpack-deb
  sed 's/Depends:.*/Depends:ruby3.0/' -i ./unpack-deb/DEBIAN/control
  dpkg-deb -b unpack-deb/
  dpkg -i unpack-deb.deb
}

install_by_latest(){
  mkdir -p /tmp/install-codedeploy
  cd /tmp/install-codedeploy
  curl -L -o install https://aws-codedeploy-us-east-1.s3.amazonaws.com/latest/install
  chmod +x ./install
  ./install auto
  quit_on_fail
}

test_service(){
  systemctl list-units --type=service | grep codedeploy
  service codedeploy-agent status
}

install_dep() {
  apt-get update
  apt-get install ruby-full ruby-webrick -y
}

configure_startup() {
  if [ "${ON_START}" = "disabled" ]; then
    echo "[disabling code deploy on start]"
    update-rc.d codedeploy-agent disable || true
  fi
}

install_workspace() {
  cd /tmp
  if [ -d "/tmp/install-codedeploy" ]; then
    rm -Rf /tmp/install-codedeploy
  fi
  mkdir -p /tmp/install-codedeploy
  cd /tmp/install-codedeploy
}

cleanup() {
  cd /tmp

  if [ -d "/tmp/install-codedeploy" ]; then
    rm -Rf /tmp/install-codedeploy
  fi
}

quit_on_fail(){
  if [ $? != 0 ]; then
    echo "[ERROR]::[FAILED TO INSTALL CODE DEPLOY AGENT]::[${ON_START}]::[${AGENT_VERSION}]"
    cleanup
    exit 1
  fi
}

execute_install(){
  install_dep
  install_workspace

  if [  ${AGENT_VERSION} != "" ]; then
    install_by_version
  else
    install_by_latest
  fi

  test_service
  configure_startup
  cleanup
}

#-{Operations}-#
execute_install
