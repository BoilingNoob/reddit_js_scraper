function get-all_of_mains_users_multis() {
    param(
        $wshell, 
        $get_multis_mains_users_js = (Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8),
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
        $locate_to_new_url_js = (Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8), 
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
        $get_multis_internals_js = (Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8), 
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

$get_basic_subs = Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8
$get_multis_internals_js = Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8
$locate_to_new_url_js = Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8
$subscribe_normal_js = Get-Content -Path "$PSScriptRoot\js_Supporting_scripts\subscribe_regular.js" -Raw -Encoding utf8


$wshell = New-Object -ComObject wscript.shell

Export-ModuleMember -Function get-all_of_mains_users_multis
Export-ModuleMember -Function new-scrapeObject
Export-ModuleMember -Function set-new_url_location
Export-ModuleMember -Function get-internal_subs_to_multi

Export-ModuleMember -Variable get_basic_subs
Export-ModuleMember -Variable get_multis_internals_js
Export-ModuleMember -Variable locate_to_new_url_js
Export-ModuleMember -Variable subscribe_normal_js


Export-ModuleMember -Variable wshell