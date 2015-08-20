# This image is used to create bleeding edge docker image and is not compatible with any other image
FROM golang:onbuild

ENV KUBE_SERVER http://192.168.1.1:8080

# Install docker client
RUN wget -qO- https://get.docker.com/ubuntu/ | sed -r 's/^apt-get install -y lxc-docker$/apt-get install -y lxc-docker-1.6.2/g' | sh

# Install runner
RUN /go/src/app/packaging/root/usr/share/gitlab-runner/post-install

# Install kubectl
RUN wget -c "https://github.com/kubernetes/kubernetes/releases/download/v1.0.3/kubernetes.tar.gz" && \
	tar -xf kubernetes.tar.gz && cp kubernetes/platforms/linux/amd64/kubectl /usr/bin
RUN kubectl config set-cluster szq --server=${KUBE_SERVER} --insecure-skip-tls-verify=true

# Preserve runner's data
VOLUME ["/etc/gitlab-runner", "/home/gitlab-runner"]

# init sets up the environment and launches gitlab-runner
ENTRYPOINT ["/go/src/app/dockerfiles/ubuntu/entrypoint"]
CMD ["run", "--user=gitlab-runner", "--working-directory=/home/gitlab-runner"]
