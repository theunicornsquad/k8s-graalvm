default: docker_build

DOCKER_IMAGE ?= unicornsquad/k8s-maven-graalvm
GIT_BRANCH ?= `git rev-parse --abbrev-ref HEAD`
MAVEN_VERSION="3.6.3"
GRAAL_VERSION="20.0.0"


ifeq ($(GIT_BRANCH), master)
	DOCKER_TAG = latest
else
	TAG_VARS = $(subst -, ,$(GIT_BRANCH))

	MAVEN_VERSION = $(subst v,,$(word 1, $(TAG_VARS)) )
	GRAAL_VERSION = $(word 2, $(TAG_VARS))	

	DOCKER_TAG = $(GIT_BRANCH)
endif

docker_build:

	@echo "GIT_BRANCH: $(GIT_BRANCH)"

	@echo "MAVEN VERSION: ${MAVEN_VERSION}"

	@echo "GRAAL VERSION: ${GRAAL_VERSION}"

	docker build \
	  --build-arg VCS_REF=`git rev-parse --short HEAD` \
	  --build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
	  --build-arg MAVEN_VERSION=${MAVEN_VERSION} \
	  --build-arg GRAAL_VERSION=${GRAAL_VERSION} \
	  -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	  
docker_push:
	# Push to DockerHub
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)

test:
	docker run $(DOCKER_IMAGE):$(DOCKER_TAG) mvn --version