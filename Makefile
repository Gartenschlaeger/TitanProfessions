clean:
	rm -rf TitanProfessions
	rm -f *.zip

build: clean
	mkdir -p TitanProfessions
	cp *.lua *.toc *.md TitanProfessions
	zip -r titanprofessions.zip TitanProfessions