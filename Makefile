publish:
	./hack/publish.sh


assets/build-graph.svg: ./Dockerfile
	cat ./Dockerfile | \
		dockerfile2llb  | \
		buildctl debug dump-llb --dot | \
		dot -Tsvg > $@
