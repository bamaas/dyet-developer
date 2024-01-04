FROM alpine:3.19.0

# Alpine packages
RUN apk update && \
    apk add curl make findutils wget bash vim openssh python3 py3-pip jq yq gettext --no-cache --update && \
    rm -rf ~/.cache/* /usr/local/share/man /tmp/*

# semver
RUN wget https://github.com/fsaintjacques/semver-tool/archive/refs/tags/3.2.0.zip && \
    unzip 3.2.0.zip && \
    chmod +x semver-tool-3.2.0/src/semver && \
    mv semver-tool-3.2.0/src/semver /usr/bin/semver && \
    rm -rf semver-tool-3.2.0 3.2.0.zip

# Helm
ARG HELM_VERSION=3.12.3
ENV BASE_URL="https://get.helm.sh"
RUN case `uname -m` in \
        x86_64) ARCH=amd64; ;; \
        armv7l) ARCH=arm; ;; \
        aarch64) ARCH=arm64; ;; \
        ppc64le) ARCH=ppc64le; ;; \
        s390x) ARCH=s390x; ;; \
        *) echo "un-supported arch, exit ..."; exit 1; ;; \
    esac && \
    apk add --update --no-cache wget git && \
    wget ${BASE_URL}/helm-v${HELM_VERSION}-linux-${ARCH}.tar.gz -O - | tar -xz && \
    mv linux-${ARCH}/helm /usr/bin/helm && \
    chmod +x /usr/bin/helm && \
    rm -rf linux-${ARCH}
RUN chmod +x /usr/bin/helm

# Drone cli
ARG DRONE_CLI_VERSION=1.5.0
RUN curl -L https://github.com/drone/drone-cli/releases/download/v${DRONE_CLI_VERSION}/drone_linux_amd64.tar.gz | tar zxx && \
    install -t /usr/local/bin drone && \
    rm drone

# Argocd cli
RUN curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/v2.4.11/argocd-linux-amd64 && \
    chmod +x /usr/local/bin/argocd

# Set gitconfig
COPY .gitconfig /root/.gitconfig

# Kubectl
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# Gitea
RUN apk add tea --repository=https://dl-cdn.alpinelinux.org/alpine/edge/community --no-cache

# Install pipx
RUN pip install --break-system-packages --no-cache-dir --upgrade pip && \
    python3 -m pip install pipx --break-system-packages --no-cache-dir && \
    python3 -m pipx ensurepath

# Install Python based cli tools
ENV PIPX_HOME=/opt/pipx 
ENV PIPX_BIN_DIR=/usr/local/bin
RUN pipx install commitizen==2.39.1 && \
    pipx install pre-commit==3.0.2

# Python3 packages
RUN pip3 install ruamel.yaml --break-system-packages