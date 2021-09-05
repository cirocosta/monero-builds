latest:
	docker build -t utxobr/monero .


publish:
	ytt -f ./config | kbld -f- \
		--images-annotation=false \
		--build-concurrency=1 > ./images.yaml


assets/build-graph.svg: ./Dockerfile
	cat ./Dockerfile | \
		dockerfile2llb  | \
		buildctl debug dump-llb --dot | \
		dot -Tsvg > $@
