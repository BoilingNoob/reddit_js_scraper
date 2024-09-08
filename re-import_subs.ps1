Import-Module .\func_lib.psm1 -Force

$url = "https://new.reddit.com/r/finance/"
$seconds_after_loading_page = 3 #seconds
$sleep_before_running_entire_script = 3
$wait_after_pasting = 1

Start-Sleep $sleep_before_running_entire_script
Write-Host "working!"

<#
Write-Host "url: $url
$locate_to_new_url_js
<<" -ForegroundColor Green
#>

#set-new_url_location -new_location $url -wait_x_seconds $seconds_after_loading_page -wshell $wshell -locate_to_new_url_js $locate_to_new_url_js

function subscribe_to_sub() {
    param(
        $subscribe_normal_js, 
        $wshell,
        #$wait_after_pasting_grab_JS = 3,
        $wait_between_check_looks_ms = 500,
        $max_loops = 40,
        $recursion_count = 0
    )
    $max_recursion = 10
    $got_clip_board = $subscribe_normal_js
    Set-Clipboard $got_clip_board
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")
    #Start-Sleep $wait_after_pasting_grab_JS
}
subscribe_to_sub -subscribe_normal_js $subscribe_normal_js -wshell $wshell