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
	rm -rf dist/staging/License && mkdir -p dist/staging/License && \
	cp LICENSE-GPL LICENSE-APACHE dist/staging/License/ && \
	cp partial/LICENSE dist/staging/License/LICENSE-partial && \
	ln -sf /Applications dist/staging/Applications && \
	hdiutil create -volname $(APP_NAME) -srcfolder dist/staging -ov -format UDZO "$(DMG)" && \
	shasum -a 256 "$(DMG)" > "$(DMG).sha256" && \
	$(BUMP) changelog "$$IDE_VERSION" && \
	echo "Release $$IDE_VERSION ready:" && \
	ls -la dist/

clean:
	rm -rf dist
