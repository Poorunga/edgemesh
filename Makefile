GOPATH?=$(shell go env GOPATH)

# make binaries
BINARIES=edgemesh


.EXPORT_ALL_VARIABLES:
OUT_DIR ?= _output/local

define ALL_HELP_INFO
# Build code.
#
# Args:
#   WHAT: binary names to build. support: $(BINARIES)
#         the build will produce executable files under $(OUT_DIR)
#         If not specified, "everything" will be built.
#
# Example:
#   make
#   make all
#   make all HELP=y
#   make all WHAT=edgemesh
#   make all WHAT=edgemesh GOLDFLAGS="" GOGCFLAGS="-N -l"
#     Note: Specify GOLDFLAGS as an empty string for building unstripped binaries, specify GOGCFLAGS
#     to "-N -l" to disable optimizations and inlining, this will be helpful when you want to
#     use the debugging tools like delve. When GOLDFLAGS is unspecified, it defaults to "-s -w" which strips
#     debug information, see https://golang.org/cmd/link for other flags.

endef
.PHONY: all
ifeq ($(HELP),y)
all: clean
	@echo "$$ALL_HELP_INFO"
else
all: verify-golang
	EDGEMESH_OUTPUT_SUBPATH=$(OUT_DIR) hack/make-rules/build.sh $(WHAT)
endif


define VERIFY_HELP_INFO
# verify golang,vendor and codegen
#
# Example:
# make verify
endef
.PHONY: verify
ifeq ($(HELP),y)
verify:
	@echo "$$VERIFY_HELP_INFO"
else
verify:verify-golang
endif

.PHONY: verify-golang
verify-golang:
	hack/verify-golang.sh


define LINT_HELP_INFO
# run golang lint check.
#
# Example:
#   make lint
#   make lint HELP=y
endef
.PHONY: lint
ifeq ($(HELP),y)
lint:
	@echo "$$LINT_HELP_INFO"
else
lint:
	hack/make-rules/lint.sh
endif


.PHONY: image
image:
	docker build --build-arg GO_LDFLAGS=${GO_LDFLAGS} -t ${IMAGE_REPO}/edgemesh:${IMAGE_TAG} -f build/Dockerfile .


# push target pushes sedna-built images
push: images
	docker push ${IMAGE_REPO}/sedna-gm:${IMAGE_TAG}
	docker push ${IMAGE_REPO}/sedna-lc:${IMAGE_TAG}
	bash scripts/storage-initializer/push_image.sh
