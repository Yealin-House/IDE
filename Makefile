APP_NAME := IDE
BUMP := bash partial/scripts/bump-version.sh
DMG := dist/$(APP_NAME)-$${IDE_VERSION}-macOS-$$(uname -m).dmg

.PHONY: build release clean

# Builds the release app. The version is bumped per build (patch) and per
# change (minor) and embedded into the app bundle's Info.plist.
build:
	@IDE_VERSION=$$($(BUMP) build); export IDE_VERSION; \
	cargo build --release --bin ide && \
	echo "Built target/release/IDE.app ($$IDE_VERSION)"

# Full release: bumps the version, persists it to VERSION, builds, then
# produces the release artifacts in dist/ — a .dmg (with the license files
# shipped alongside the app), its .sha256 file, and an updated CHANGELOG.md.
# Upload the .dmg and .sha256 to the GitHub release at
# https://github.com/Yealin-House/IDE, then commit VERSION and CHANGELOG.md.
release:
	@IDE_VERSION=$$($(BUMP) release); export IDE_VERSION; \
	cargo build --release --bin ide && \
	mkdir -p target/release/IDE.app/Contents/MacOS && \
	cp -f target/release/ide target/release/IDE.app/Contents/MacOS/ide && \
	mkdir -p dist/staging && \
	rm -rf dist/staging/* && \
	cp -R target/release/IDE.app dist/staging/ && \
	cp LICENSE-GPL LICENSE-APACHE dist/staging/ && \
	cp partial/LICENSE dist/staging/LICENSE-partial && \
	rm -f "$(DMG)" && \
	bash partial/scripts/create-dmg \
		--volname "$(APP_NAME)" \
		--volicon partial/assets/app_icon.icns \
		--background partial/assets/dmg-background.png \
		--window-pos 200 100 --window-size 660 480 \
		--icon-size 96 \
		--icon "IDE.app" 170 110 \
		--app-drop-link 490 110 \
		--icon "LICENSE-GPL" 170 330 \
		--icon "LICENSE-APACHE" 330 330 \
		--icon "LICENSE-partial" 490 330 \
		"$(DMG)" dist/staging && \
	shasum -a 256 "$(DMG)" > "$(DMG).sha256" && \
	$(BUMP) changelog "$$IDE_VERSION" && \
	echo "Release $$IDE_VERSION ready:" && \
	ls -la dist/

clean:
	rm -rf dist
