FROM centos:centos7


ARG GRAAL_VERSION=20.0.0
ARG MAVEN_VERSION=3.6.3
ARG VCS_REF
ARG BUILD_DATE

LABEL org.opencontainers.image.title="unicornsquad/k8s-maven-graalvm" \
      org.opencontainers.image.revision=$VCS_REF \
      org.opencontainers.image.source="https://github.com/theunicornsquad/k8s-maven-graalvm" \
      org.opencontainers.image.created=$BUILD_DATE \
      maintainer=pauloandresoares@gmail.com

RUN yum update -y && \
  yum install -y which git sudo && \
  yum clean all


ENV JAVA_HOME /opt/graalvm
ENV GRAALVM_HOME /opt/graalvm
ENV NATIVE_IMAGE_CONFIG_FILE $GRAALVM_HOME/native-image.properties
ENV PATH /opt/apache-maven/bin:$JAVA_HOME/jre/bin:$GRAALVM_HOME/bin:$PATH

ENV GRAAL_CE_URL=https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-${GRAAL_VERSION}/graalvm-ce-java8-linux-amd64-${GRAAL_VERSION}.tar.gz
ENV MAVEN_URL=https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz

RUN yum -y install gcc zlib-devel libc6-dev zlib1g-dev curl git nano upx-ucl libstdc++-static

# All in one step, to reduce number of layers
RUN curl ${MAVEN_URL} -o /tmp/maven.tar.gz && \
    tar -zxf /tmp/maven.tar.gz -C /tmp && \
    mv /tmp/apache-maven-${MAVEN_VERSION} /opt/apache-maven && \
    curl -L ${GRAAL_CE_URL} -o /tmp/graalvm.tar.gz && \
    tar -zxf /tmp/graalvm.tar.gz -C /tmp && \
    mv /tmp/graalvm-ce-java8-${GRAAL_VERSION} /opt/graalvm && \
    /opt/graalvm/bin/gu install native-image llvm-toolchain && \
    mkdir -p /root/.native-image && \
    echo "NativeImageArgs = --no-server" > $GRAALVM_HOME/native-image.properties && \ 
    rm -rf /var/lib/apt/lists/* \ 
    && rm -rf /tmp/*
    

WORKDIR /root