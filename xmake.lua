
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
        os.cp("$(buildir)/Info.plist", app_dir .. "/Contents")
        os.execv("codesign", {"--force", "--deep", "--sign", "-", app_dir})

        local hdiutil_command= "/usr/bin/sudo /usr/bin/hdiutil create $(buildir)/" .. dmg_name .. " -fs HFS+ -srcfolder " .. app_dir
        io.write("Execute: ")
        print(hdiutil_command)
        print("Remove /usr/bin/sudo if you want to package it by your own")

        local maxRetries= 5
        local retries = 0
        while retries <= maxRetries do
            try {
                function ()
                    os.execv(hdiutil_command)
                    os.exit(0)
                end,
                catch {
                    function (errors)
                        retries = retries + 1
                        io.write("Retrying, attempt ")
                        print(retries)
                        if retries > maxRetries then
                            os.raise("Command failed after " .. maxRetries .. " retries")
                        end
                    end
                }
            }
        end
    end)
end