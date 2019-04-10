FROM fedora:28
#FROM registry.access.redhat.com/ubi7-dev-preview/ubi-minimal:7.6

RUN dnf install -y dnf-plugins-core && \
    dnf -y install \
    curl \
    cpio \
    patch \
    make \
    git \
    sudo && \
    dnf -y clean all

ENV GIMME_GO_VERSION=1.11.5

RUN mkdir -p /gimme && curl -sL https://raw.githubusercontent.com/travis-ci/gimme/master/gimme | HOME=/gimme bash >> /etc/profile.d/gimme.sh

ENV OPERATOR=/usr/local/bin/hyperconverged-cluster-operator \
    USER_UID=1001 \
    USER_NAME=hyperconverged-cluster-operator \
    GOPATH="/go" \
    GOBIN="/usr/bin"

# Install persisten go packages
RUN \
    mkdir -p /go && \
    source /etc/profile.d/gimme.sh && \
    go get -d golang.org/x/tools/cmd/goimports && \
    cd $GOPATH/src/golang.org/x/tools/cmd/goimports && \
    git checkout release-branch.go1.11 && \
    go install && \
    # Install mvdan/sh
    git clone https://github.com/mvdan/sh.git $GOPATH/src/mvdan.cc/sh && \
    cd $GOPATH/src/mvdan.cc/sh/cmd/shfmt && \
    git checkout v2.5.0 && \
    go get mvdan.cc/sh/cmd/shfmt && \
    go install && \
    go get -u -d k8s.io/code-generator/cmd/client-gen && \
    go get -u -d k8s.io/code-generator/cmd/deepcopy-gen && \
    go get -u -d k8s.io/code-generator/cmd/defaulter-gen && \
    go get -u -d k8s.io/code-generator/cmd/informer-gen && \
    go get -u -d k8s.io/code-generator/cmd/lister-gen && \
    go get -u -d k8s.io/kube-openapi/cmd/openapi-gen && \
    # Install client-gen
    cd $GOPATH/src/k8s.io/code-generator/cmd/client-gen && \
    go install && \
    # Install deepcopy-gen
    cd $GOPATH/src/k8s.io/code-generator/cmd/deepcopy-gen && \
    go install && \
    # Install defaulter-gen
    cd $GOPATH/src/k8s.io/code-generator/cmd/defaulter-gen && \
    go install && \
    # Install informer-gen
    cd $GOPATH/src/k8s.io/code-generator/cmd/informer-gen && \
    go install && \
    # Install lister-gen
    cd $GOPATH/src/k8s.io/code-generator/cmd/lister-gen && \
    go install && \
    # Install openapi-gen
    cd $GOPATH/src/k8s.io/kube-openapi/cmd/openapi-gen && \
    git checkout c59034cc13d587f5ef4e85ca0ade0c1866ae8e1d && \
    go install



# install operator binary
COPY build/bin /usr/local/bin
RUN  /usr/local/bin/user_setup.sh

COPY build/_output/bin/hyperconverged-cluster-operator ${OPERATOR}

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

USER ${USER_UID}
