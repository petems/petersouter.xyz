opt-png:
	# Optimizes png files
	echo `date` >> ./optipng.log
	find ./static/ -iname '*.png' -print0 | \
	xargs -0 optipng -o7 -preserve >> ./optipng.log

opt-jpg:
	# Optimizes jpg files keeping EXIF data
	echo `date` >> ./jpegoptim.log
	find ./static/ -iname '*.jpg' -print0 | \
	 xargs -0 jpegoptim --max=90 --preserve --totals --all-progressive >> ./jpegoptim.log

spellcheck:
	@echo 'Running spellcheck with autofix'
	docker run \
	 -v $(CURDIR):/scripts \
	 --workdir=/scripts \
	 nickg/misspell:latest \
	 misspell -w -source=text content/
	@echo 'Completed spellcheck'
