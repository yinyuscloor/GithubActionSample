
add_rules("mode.debug", "mode.release")

set_languages("c++20")

add_requires("qt6widgets")

target("stem")
    add_rules("qt.widgetapp")
    add_packages("qt6widgets")

    add_headerfiles("src/*.h")
    add_files("src/*.cpp")
    add_files("src/MainWindow.ui")
    -- add files with Q_OBJECT meta (only for qt.moc)
    add_files("src/MainWindow.h")

target("stem_packager") do
    set_enabled(is_plat("macosx") and is_mode("release"))
    set_kind("phony")

    add_deps("stem")

    set_configvar("APPCAST", "")
    set_configvar("OSXVERMIN", "")
    set_configvar("STEM_NAME", "stem")

    local dmg_name= "stem-v" .. "20250126.dmg"

    after_install(function (target, opt)
        local app_dir = target:installdir() .. "/../../"
        local info_plist_path = "$(buildir)/Info.plist"

        -- 复制 Info.plist 文件
        if os.isfile(info_plist_path) then
            os.cp(info_plist_path, app_dir .. "/Contents")
        end

        -- 代码签名（在 GitHub Actions 中通常跳过或使用环境变量）
        local codesign_identity = os.getenv("CODESIGN_IDENTITY") or "-"
        if codesign_identity ~= "" and codesign_identity ~= "-" then
            os.execv("codesign", {"--force", "--deep", "--sign", codesign_identity, app_dir})
        else
            print("Skipping code signing (no valid identity provided)")
        end

        -- 创建 DMG 文件
        local hdiutil_command= "/usr/bin/hdiutil create $(buildir)/" .. dmg_name .. " -fs HFS+ -srcfolder " .. app_dir .. " -volname " .. "stem"
        io.write("Execute: ")
        print(hdiutil_command)

        local maxRetries= 3
        local retries = 0
        local success = false

        while retries < maxRetries and not success do
            try {
                function ()
                    os.execv(hdiutil_command)
                    success = true
                end,
                catch {
                    function (errors)
                        retries = retries + 1
                        io.write("Retrying, attempt ")
                        print(retries)
                        if retries >= maxRetries then
                            os.raise("Command failed after " .. maxRetries .. " retries: " .. tostring(errors))
                        end
                    end
                }
            }
        end

        -- 验证 DMG 文件是否创建成功
        local dmg_path = "$(buildir)/" .. dmg_name
        if os.isfile(dmg_path) then
            print("DMG created successfully: " .. dmg_path)
        else
            os.raise("Failed to create DMG file: " .. dmg_path)
        end
    end)
end