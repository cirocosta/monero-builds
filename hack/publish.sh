#!/usr/bin/env bash

set -o errexit

main() {
        case $1 in
        config)
		generate_build_config
		;;

        build)
		build
		;;

        *)
                echo "usage: $0 (build|config)"
                exit 1
                ;;

        esac
}

generate_build_config() {
        cat <(echo -e '#@data/values\n---') <(gyr ./config/values.yaml) |
                ytt --ignore-unknown-comments -f- -f ./config/images.yaml > \
                        ./build-config.yaml
}

build() {
        kbld -f ./build-config.yaml \
                --images-annotation=false --build-concurrency=1 > \
                ./images.yaml

}

main "$@"
