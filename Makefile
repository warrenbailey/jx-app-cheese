NAME := jx-app-cheese

all: build

build:
	go build -o bin/jx-brie brie.go

tag: build
	git add --all
	git commit -m "release ${VERSION}" --allow-empty # if first release then no verion update is performed
	git tag -fa v${VERSION} -m "Release version ${VERSION}"
	git push origin v${VERSION}

release: tag
	mkdir -p release
	cp bin/brie release

	go get -u github.com/progrium/gh-release
	gh-release checksums sha256
	gh-release create jenkins-x-apps/$(NAME) $(VERSION) master $(VERSION)
