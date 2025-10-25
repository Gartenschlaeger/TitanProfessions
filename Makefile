WOW_ADDONDIR_CLASSIC = "/Applications/World of Warcraft/_classic_era_/Interface/AddOns"
WOW_ADDONDIR_RETAIL = "/Applications/World of Warcraft/_retail_/Interface/AddOns"

clean:
	rm -rf TitanProfessions
	rm -f *.zip

build: clean
	mkdir -p TitanProfessions
	cp *.lua *.toc *.md *.xml TitanProfessions

pack: build
	zip -r titanprofessions.zip TitanProfessions

sync: build
	mkdir -p $(WOW_ADDONDIR_CLASSIC)/TitanProfessions
	cp -vf TitanProfessions/*.toc $(WOW_ADDONDIR_CLASSIC)/TitanProfessions
	cp -vf TitanProfessions/*.lua $(WOW_ADDONDIR_CLASSIC)/TitanProfessions
	cp -vf TitanProfessions/*.xml $(WOW_ADDONDIR_CLASSIC)/TitanProfessions

	mkdir -p $(WOW_ADDONDIR_RETAIL)/TitanProfessions
	cp -vf TitanProfessions/*.toc $(WOW_ADDONDIR_RETAIL)/TitanProfessions
	cp -vf TitanProfessions/*.lua $(WOW_ADDONDIR_RETAIL)/TitanProfessions
	cp -vf TitanProfessions/*.xml $(WOW_ADDONDIR_RETAIL)/TitanProfessions
