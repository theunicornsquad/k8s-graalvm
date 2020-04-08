default: docker_build

DOCKER_IMAGE ?= unicornsquad/k8s-maven-graalvm
GIT_BRANCH ?= `git rev-parse --abbrev-ref HEAD`

ifeq ($(GIT_BRANCH), master)
	DOCKER_TAG = latest
else
	TAG_VARS=$(GIT_BRANCH $2,$(subst -, ,$1))

	test.%:
    	export MAVEN_VERSION=$(call TAG_VARS,$*,1) && export GRAAL_VERSION=$(call TAG_VARS,$*,2)
	
	DOCKER_TAG = $(GIT_BRANCH)
endif

docker_build:
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