latest:
	docker build -t utxobr/monero .


images.lock.yaml: images.yaml
	kbld -f $< \
		--images-annotation=false \
		--build-concurrency=1 > $@


assets/build-graph.svg: ./Dockerfile
	cat ./Dockerfile | \
		dockerfile2llb  | \
		buildctl debug dump-llb --dot | \
		dot -Tsvg > $@
