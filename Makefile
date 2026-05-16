.PHONY: test performance example screenshot demo-gif demo-video demo-svg demo-asciinema demo-all demo-dev clean-demo

test:
	docker build --target test -t purity-test .
	docker run --rm purity-test

performance:
	docker build --target test -t purity-test .
	docker run --rm purity-test /workspace/tests/performance/run-benchmarks.sh

example:
	docker build --target example -t purity-example .
	docker run --rm -it purity-example

# Screenshot and demo generation targets

screenshot:
	@echo "📸 Generating screenshot..."
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-demo /workspace/screenshot.sh
	@if [ -f "demo/output/screenshot.png" ]; then \
		cp demo/output/screenshot.png screenshot.png; \
		echo "✅ Screenshot saved as screenshot.png"; \
	else \
		echo "❌ Screenshot generation failed"; \
	fi

demo-gif:
	@echo "🎬 Generating animated GIF demo..."
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-demo \
		sh -c "cd demo && vhs showcase.tape --output /workspace/output/demo.gif"
	@if [ -f "demo/output/demo.gif" ]; then \
		cp demo/output/demo.gif demo.gif; \
		echo "✅ Animated GIF saved as demo.gif"; \
	else \
		echo "❌ GIF generation failed"; \
	fi

demo-video:
	@echo "🎥 Generating MP4 video demo..."
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-demo \
		sh -c "cd demo && vhs showcase.tape --output /workspace/output/demo.mp4"
	@if [ -f "demo/output/demo.mp4" ]; then \
		cp demo/output/demo.mp4 demo.mp4; \
		echo "✅ MP4 video saved as demo.mp4"; \
	else \
		echo "❌ Video generation failed"; \
	fi

demo-svg:
	@echo "🎨 Generating SVG animation with Asciinema..."
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -v "$(PWD)/demo/output:/workspace/output" purity-demo \
		sh -c "cd demo && timeout 300 ./asciinema-demo.sh && cp demo.svg /workspace/output/ 2>/dev/null || echo 'SVG generation completed'"
	@if [ -f "demo/output/demo.svg" ]; then \
		cp demo/output/demo.svg demo.svg; \
		echo "✅ SVG animation saved as demo.svg"; \
	else \
		echo "❌ SVG generation failed"; \
	fi

demo-asciinema:
	@echo "📹 Recording Asciinema demo..."
	@echo "This will record a live demo session and optionally upload to asciinema.org"
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -it -v "$(PWD)/demo/output:/workspace/output" purity-demo \
		sh -c "cd demo && ./asciinema-demo.sh --upload"

demo-all: demo-gif demo-video demo-svg screenshot
	@echo "🎉 All demo formats generated!"
	@echo "📁 Generated files:"
	@ls -la demo.gif demo.mp4 demo.svg screenshot.png 2>/dev/null || echo "Some files may not have been generated"

demo-dev:
	@echo "🛠️ Starting interactive development environment..."
	docker build -f demo/Dockerfile -t purity-demo .
	docker run --rm -it -v "$(PWD):/workspace" -v "$(PWD)/demo/output:/workspace/output" purity-demo zsh

clean-demo:
	@echo "🧹 Cleaning demo outputs..."
	rm -f demo.gif demo.mp4 demo.svg screenshot.png
	rm -rf demo/output/
	docker rmi purity-demo 2>/dev/null || true
	@echo "✅ Demo cleanup complete"
	@echo "💡 Tip: Run 'docker image prune' to remove unused layers"
