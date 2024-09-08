function get-all_of_mains_users_multis() {
    param(
        [wscript.shell]$wshell, 
        $get_multis_mains_users_js = (Get-Content -Path ".\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8)
    )
    Set-Clipboard $get_multis_mains_users_js
    
    $wshell.SendKeys("^a")
    Start-Sleep 1
    $wshell.SendKeys("^v")
    Start-Sleep 1
    $wshell.SendKeys("^~")
    Start-Sleep 1
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^c")
    Start-Sleep 1
    $wshell.SendKeys("{Enter}")

    $multis_mains_users = Get-Clipboard

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
            Default { Write-Host "no idea what this is: $($_)" }
        }
    }

    return $scrape
}
function set-new_url_location() {
    param(
        $new_location, 
        $wait_x_seconds = 4, 
        $locate_to_new_url_js = (Get-Content -Path ".\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8), 
        [wscript.shell]$wshell
    )
    Set-Clipboard ($locate_to_new_url_js -replace "#+", $new_location)
    Start-Sleep $wait_x_seconds
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")   
}
function get-internal_subs_to_multi() {
    param(
        $get_multis_internals_js = (Get-Content -Path ".\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8, 
            [wscript.shell]$wshell)
    )
    Set-Clipboard $get_multis_internals_js
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^v")
    $wshell.SendKeys("^~")
    Start-Sleep 1
    $wshell.SendKeys("^a")
    $wshell.SendKeys("^c")    
}

$get_multis_mains_users_js = Get-Content -Path ".\js_Supporting_scripts\get_basic_subs.js" -Raw -Encoding utf8
$get_multis_internals_js = Get-Content -Path ".\js_Supporting_scripts\get_multi_internals.js" -Raw -Encoding utf8
$locate_to_new_url_js = Get-Content -Path ".\js_Supporting_scripts\navigate_page.js" -Raw -Encoding utf8

$wshell = New-Object -ComObject wscript.shell;



<#
$wshell.AppActivate('Reddit - Dive into anything — Mozilla Firefox Private Browsing')
Start-Sleep 1
#>




Write-Host "open to https://new.reddit.com/

click Home and wait for it to populate entirely

open the dev tools (f12)

click the console

make sure pasting is enabled
"
Start-Sleep 3
$results = get-all_of_mains_users_multis -wshell $wshell
<#
Start-Sleep 3
$wshell.SendKeys("^a")
Start-Sleep 1
$wshell.SendKeys("^v")
Start-Sleep 1
$wshell.SendKeys("^~")
Start-Sleep 1
$wshell.SendKeys("^a")
$wshell.SendKeys("^c")
Start-Sleep 1
$wshell.SendKeys("{Enter}")
#>
$scrape = new-scrapeObject -my_array $results


set-new_url_location -new_location $scrape.multi_subs[0] -wait_x_seconds 4


get-internal_subs_to_multi



ConvertTo-Json -InputObject $scrape | Out-File ".\output_of_reddit.json"