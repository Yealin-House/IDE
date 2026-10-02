#![cfg(target_os = "macos")]

pub fn ensure_macos_app_bundle() {
    if std::env::var("IDE_NO_REEXEC").is_ok() {
        return;
    }
    let Ok(current_exe) = std::env::current_exe() else {
        return;
    };
    let in_bundle = current_exe
        .components()
        .any(|c| c.as_os_str().to_string_lossy().ends_with(".app"));
    if in_bundle {
        return;
    }

    let Some(target_dir) = current_exe.parent() else {
        return;
    };

    let app_bundle = target_dir.join("IDE.app");
    let macos_dir = app_bundle.join("Contents/MacOS");
    let resources_dir = app_bundle.join("Contents/Resources");
    let info_plist = app_bundle.join("Contents/Info.plist");
    let bundle_exe = macos_dir.join("ide");

    let _ = std::fs::create_dir_all(&macos_dir);
    let _ = std::fs::create_dir_all(&resources_dir);

    if !info_plist.exists() {
        let plist_content = r#"<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleIdentifier</key>
    <string>com.notapublicfigureanymore.ide</string>
    <key>CFBundleName</key>
    <string>IDE</string>
    <key>CFBundleDisplayName</key>
    <string>IDE</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleExecutable</key>
    <string>ide</string>
    <key>CFBundleIconFile</key>
    <string>app_icon</string>
    <key>CFBundleShortVersionString</key>
    <string>0.1.0</string>
    <key>CFBundleVersion</key>
    <string>0.1.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
"#;
        let _ = std::fs::write(&info_plist, plist_content);
    }

    let icon_dest = resources_dir.join("app_icon.icns");
    if !icon_dest.exists() {
        let icon_bytes = include_bytes!("../resources/app_icon.icns");
        let _ = std::fs::write(&icon_dest, icon_bytes);
    }

    let icon_alt_dest = resources_dir.join("app-icon.icns");
    if !icon_alt_dest.exists() {
        let icon_bytes = include_bytes!("../resources/app_icon.icns");
        let _ = std::fs::write(&icon_alt_dest, icon_bytes);
    }

    let _ = std::fs::remove_file(&bundle_exe);
    if std::fs::hard_link(&current_exe, &bundle_exe).is_err() {
        let _ = std::fs::copy(&current_exe, &bundle_exe);
    }

    let _ = std::process::Command::new("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister")
        .args(["-f", app_bundle.to_str().unwrap_or_default()])
        .output();

    let args: Vec<std::ffi::CString> = std::env::args_os()
        .enumerate()
        .filter_map(|(i, arg)| {
            if i == 0 {
                std::ffi::CString::new(bundle_exe.to_str()?).ok()
            } else {
                std::ffi::CString::new(arg.to_string_lossy().into_owned()).ok()
            }
        })
        .collect();

    if !args.is_empty() {
        let mut argv: Vec<*const libc::c_char> = args.iter().map(|s| s.as_ptr()).collect();
        argv.push(std::ptr::null());
        unsafe {
            libc::execv(args[0].as_ptr(), argv.as_ptr());
        }
    }
}
