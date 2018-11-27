NAME := jx-app-cheese
PLUGIN_NAME := jx-brie

all: build

build:
	go build -o bin/${PLUGIN_NAME} brie.go

release: build
	mkdir -p release
	cp bin/${PLUGIN_NAME} release

	go get -u github.com/progrium/gh-release
	gh-release checksums sha256
	gh-release create jenkins-x-apps/$(NAME) $(VERSION)

clean:
	rm -rf release bin