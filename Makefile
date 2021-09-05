latest:
	docker build -t utxobr/monero .

images.lock.yaml: images.yaml
	kbld -f $< \
		--images-annotation=false \
		--build-concurrency=1 > $@
.PHONY: images.lock.yaml
