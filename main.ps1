#region funcs
function get-all_of_mains_users_multis() {
    param(
        $wshell, 
        $get_multis_mains_users_js = (Get-Content -Path ".\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8),
        $wait_after_pasting_script = 1,
        $loop_wait_ms = 500
    )
    $got_clip_board = $get_multis_mains_users_js
    Set-Clipboard $got_clip_board
    
    $wshell.SendKeys("^a")
    $wshell.SendKeys(" ")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")
    #Start-Sleep $wait_after_pasting_script
    $loop_count = 0
    do {
        if ($loop_count -gt 5) {
            write-host "Looping, loop count: $($loop_count) , $got_clip_board"
        }
        $wshell.SendKeys("^a")
        $wshell.SendKeys("^c")
        $loop_count += 1
        Start-Sleep -Milliseconds $loop_wait_ms
        $got_clip_board = Get-Clipboard
    }while ($got_clip_board -notmatch "https:\/\/")
    
    $wshell.SendKeys("{Enter}")

    $multis_mains_users = $got_clip_board

    return $multis_mains_users.split(";")
}
function new-scrapeObject($my_array) {
    $multi_regex = "https:\/\/new\.reddit\.com\/user\/.*\/m\/"
    $basic_sub_regex = "https:\/\/new\.reddit\.com\/r\/"
    $user_regex = "https:\/\/new\.reddit\.com\/user\/"

    $scrape = [pscustomobject]@{
        main_subs       = New-Object System.Collections.ArrayList
        followed_users  = New-Object System.Collections.ArrayList
        multi_subs      = New-Object System.Collections.ArrayList
        multi_subs_objs = @{}
    }
    
    $my_array | ForEach-Object {
        switch -regex ($_) {
            $basic_sub_regex { 
                $null = $scrape.main_subs.add($_) 
            }
            $multi_regex { 
                $null = $scrape.multi_subs.add($_) 
                $null = $scrape.multi_subs_objs.add($_, $null) 
            }
            $user_regex { 
                $null = $scrape.followed_users.add($_) 
            }
            Default { Write-Host "no idea what this is:$($_)<<end of print" }
        }
    }

    return $scrape
}
function set-new_url_location() {
    param(
        $new_location, 
        $wait_x_seconds = 4, 
        $locate_to_new_url_js = (Get-Content -Path ".\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8), 
        $wshell
    )

    $new_loca_script = $locate_to_new_url_js -replace "#+", $new_location
    Set-Clipboard ($new_loca_script)
    $wshell.SendKeys("^a")
    $wshell.SendKeys(" ")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")   
    Start-Sleep $wait_x_seconds
}
function get-internal_subs_to_multi() {
    param(
        $get_multis_internals_js = (Get-Content -Path ".\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8), 
        $wshell,
        $wait_after_pasting_grab_JS = 3,
        $wait_between_check_looks_ms = 500,
        $max_loops = 40,
        $recursion_count = 0
    )

    $max_recursion = 10
    $got_clip_board = $get_multis_internals_js
    Set-Clipboard $get_multis_internals_js

    $got_clip_board = $null
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")
    Start-Sleep $wait_after_pasting_grab_JS
    $loop_count = 0
    do {
        if ($loop_count -gt 5) {
            Write-Host "Loop: $loop_count  , $got_clip_board"
        }
        $wshell.SendKeys("^a")
        $wshell.SendKeys("^c")
        $got_clip_board = Get-Clipboard
        $loop_count += 1
        Start-Sleep -Milliseconds $wait_between_check_looks_ms
    }while ($got_clip_board -notmatch "(https:\/\/|r/|u/|user/)" -and $max_loops -gt $loop_count)
    $wshell.SendKeys("{ENTER}")
    
    if ($loop_count -gt $max_loops) {
        if ($recursion_count -lt $max_recursion) {
            get-internal_subs_to_multi -get_multis_internals_js $get_multis_internals_js -wshell $wshell -wait_after_pasting_grab_JS $wait_after_pasting_grab_JS -wait_between_check_looks_ms $wait_between_check_looks_ms -max_loops $max_loops -recursion_count ($recursion_count + 1)
        }
        else {
            Write-Error -Message "could not recursivly do it" -ErrorAction Stop
        }
    }
    else {
        $list = (Get-Clipboard).split(";") | Where-Object { $_ -notin @($null, "", " ") }
    }
    return $list
}
#endregion funcs
$get_basic_subs = Get-Content -Path ".\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8
$get_multis_internals_js = Get-Content -Path ".\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8
$locate_to_new_url_js = Get-Content -Path ".\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8
$output_path = ".\output_of_reddit.json"
$looping_feedback_time = 300 #ms
$time_to_wait_after_pasting_script = 1 #seconds
$time_between_mutlis = 3
$seconds_after_loading_page = 3
$max_loops_for_checking = 20

$sleep_before_running_entire_script = 3

$wshell = New-Object -ComObject wscript.shell;

Write-Host "open to https://new.reddit.com/

click Home and wait for it to populate entirely

open the dev tools (f12)

click the console

make sure pasting is enabled
"

Start-Sleep $sleep_before_running_entire_script
Write-Host "working!"

$results = get-all_of_mains_users_multis -get_multis_mains_users_js $get_basic_subs -wshell $wshell -wait_after_pasting_script $time_to_wait_after_pasting_script -loop_wait_ms $looping_feedback_time
Write-Host "grabbed all mains and multis, $($results.count) things found"

$scrape = new-scrapeObject -my_array $results

foreach ($multi in $scrape.multi_subs) {
    set-new_url_location -new_location $multi -wait_x_seconds $seconds_after_loading_page -wshell $wshell -locate_to_new_url_js $locate_to_new_url_js
    Write-Host "went to new location: $($multi)|||||"
    $scrape.multi_subs_objs.($multi) = get-internal_subs_to_multi -wshell $wshell -get_multis_internals_js $get_multis_internals_js -wait_after_pasting_grab_JS $time_to_wait_after_pasting_script -wait_between_check_looks_ms $looping_feedback_time -max_loops $max_loops_for_checking
    Write-Host "scraped multi: $multi for $($scrape.multi_subs_objs.($multi).count) objects"
    Start-Sleep -Seconds $time_between_mutlis
}


ConvertTo-Json -InputObject $scrape | Out-File $output_path
Write-Host "outputted" -ForegroundColor Green