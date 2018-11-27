pipeline {
    agent any
    environment {
      ORG                 = 'jenkinsxio'
      GITHUB_ORG          = 'jenkins-x-apps'
      APP_NAME            = 'jx-app-cheese'
      GIT_PROVIDER        = 'github.com'
      CHARTMUSEUM_CREDS   = credentials('jenkins-x-chartmuseum')
      GH_CREDS            = credentials('jenkins-x-github')
      GITHUB_ACCESS_TOKEN = "$GH_CREDS_PSW"

    }
    stages {
      stage('CI Build and push snapshot') {
        when {
          branch 'PR-*'
        }
        environment {
          PREVIEW_VERSION = "0.0.0-SNAPSHOT-$BRANCH_NAME-$BUILD_NUMBER"
          PREVIEW_NAMESPACE = "$APP_NAME-$BRANCH_NAME".toLowerCase()
          HELM_RELEASE = "$PREVIEW_NAMESPACE".toLowerCase()
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            checkout scm
            sh "make build"
          }
        }
      }
      stage('Build Release') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            git 'https://github.com/jenkins-x-apps/jx-app-cheese'
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese/charts/jx-app-cheese') {
              // ensure we're not on a detached head
              sh "git checkout master"
              // until we switch to the new kubernetes / jenkins credential implementation use git credentials store
              sh "git config --global credential.helper store"

              sh "jx step git credentials"
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            // so we can retrieve the version in later steps
            sh "echo \$(jx-release-version) > VERSION"
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese/charts/jx-app-cheese') {
            sh "make release"
          }
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            sh "make build"
          }
        }
      }
      stage('Promote') {
        when {
          branch 'master'
        }
        steps {
          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese/charts/jx-app-cheese') {
            sh 'jx step changelog --version v\$(cat ../../VERSION)'
          }

          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            // release the binary
            sh 'export GORELEASER_VERSION=0.93.2 && mkdir goreleaser && \
    curl -Lf https://github.com/goreleaser/goreleaser/releases/download/v${GORELEASER_VERSION}/goreleaser_Linux_x86_64.tar.gz | tar -xzv -C ./goreleaser/ && \
    mv goreleaser/goreleaser /usr/bin/ && \
    rm -rf goreleaser'
          }

          dir ('/home/jenkins/go/src/github.com/jenkins-x-apps/jx-app-cheese') {
            // release the binary
            sh 'GO111MODULE=on make release'
          }
        }
      }
    }
  }