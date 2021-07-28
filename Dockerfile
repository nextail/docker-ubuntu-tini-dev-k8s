FROM rubensa/ubuntu-tini-dev
LABEL author="Ruben Suarez <rubensa@gmail.com>"

# Tell docker that all future commands should be run as root
USER root

# Set root home directory
ENV HOME=/root

# https://github.com/helm/helm/releases
ARG HELM_VERSION=3.5.2

# https://storage.googleapis.com/kubernetes-release/release/stable.txt
ARG KUBECTL_VERSION=1.20.2

# https://github.com/ahmetb/kubectx/releases
ARG KUBECTX_VERSION=0.9.1

# https://github.com/wercker/stern/releases
ARG STERN_VERSION=1.11.0

# https://github.com/weaveworks/eksctl/releases
ARG EKSCTL_VERSION=0.37.0

# https://github.com/aws/aws-cli/blob/v2/CHANGELOG.rst
ARG AWSCLI_VERSION=2.1.24

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Configure apt and install packages
RUN apt-get update \
    #
    # Install
    && echo 'Intalling groff and less...' \
    && apt-get -y install --no-install-recommends groff less \
    # 
    # Install jq
    && echo 'Intalling jq...' \
    && apt-get -y install jq \
    #
    # Install HELM
    && echo 'Intalling helm...' \
    && curl -sSL https://get.helm.sh/helm-v${HELM_VERSION}-linux-amd64.tar.gz | tar xvz \
    && mv linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && helm completion bash >/etc/bash_completion.d/helm \
    && rm -rf linux-amd64 \
    #
    # Install kubectl
    && echo 'Intalling kubectl...' \
    && curl -o /usr/local/bin/kubectl -sSL https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl \
    && chmod +x /usr/local/bin/kubectl \
    # kubectl bash completion
    && kubectl completion bash >/etc/bash_completion.d/kubectl \
    #
    # Install kubectx and kubens
    && echo 'Intalling kubectx and kubens...' \
    && curl -sSL https://github.com/ahmetb/kubectx/archive/v${KUBECTX_VERSION}.tar.gz | tar xvz \
    && mv kubectx-${KUBECTX_VERSION}/kubectx /usr/local/bin/kubectx \
    && mv kubectx-${KUBECTX_VERSION}/kubens /usr/local/bin/kubens \
    && chmod +x /usr/local/bin/kubectx \
    && chmod +x /usr/local/bin/kubens \
    # kubectx and kubens bash completion
    && mv kubectx-${KUBECTX_VERSION}/completion/kubectx.bash /etc/bash_completion.d/kubectx \
    && mv kubectx-${KUBECTX_VERSION}/completion/kubens.bash /etc/bash_completion.d/kubens \
    #
    # Install stern
    && echo 'Intalling stern...' \
    && curl -o /usr/local/bin/stern -sSL "https://github.com/wercker/stern/releases/download/${STERN_VERSION}/stern_linux_amd64"  \
    && chmod +x /usr/local/bin/stern \
    # stern bash completion
    && stern --completion=bash bash >/etc/bash_completion.d/stern \
    #
    # Install eksctl
    && echo 'Intalling eksctl...' \
    && curl -sSL "https://github.com/weaveworks/eksctl/releases/download/${EKSCTL_VERSION}/eksctl_Linux_amd64.tar.gz" | tar xz  \
    && mv eksctl /usr/local/bin \
    && chmod +x /usr/local/bin/eksctl \
    && eksctl completion bash >/etc/bash_completion.d/eksctl \
    #
    # Install AWS CLI v2
    && echo 'Intalling aws...' \
    && curl -o "awscliv2.zip" -sSL "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" \
    && unzip awscliv2.zip \
    && ./aws/install -i /opt/aws-cli \
    && rm awscliv2.zip \
    && rm -rf aws \
    # Configure aws bash completion for the non-root user
    && printf "\ncomplete -C '/usr/local/bin/aws_completer' aws\n" >> /home/${USER_NAME}/.bashrc \
    #
    # Clean up
    && echo 'Cleaning up...' \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=

# Tell docker that all future commands should be run as the non-root user
USER ${USER_NAME}

# Set user home directory (see: https://github.com/microsoft/vscode-remote-release/issues/852)
ENV HOME /home/$USER_NAME
