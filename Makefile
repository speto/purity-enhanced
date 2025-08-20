.PHONY: test performance example

test:
	docker build --target test -t purity-test .
	docker run --rm purity-test

performance:
	docker build --target test -t purity-test .
	docker run --rm purity-test /workspace/tests/performance/run-benchmarks.sh

example:
	docker build --target example -t purity-example .
	docker run --rm -it purity-example