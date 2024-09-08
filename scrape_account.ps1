Import-Module .\func_lib.psm1

$output_path = ".\output_of_reddit.json"
$looping_feedback_time = 300 #ms
$time_to_wait_after_pasting_script = 1 #seconds
$time_between_mutlis = 3 #seconds
$seconds_after_loading_page = 3 #seconds
$max_loops_for_checking = 20

$sleep_before_running_entire_script = 3 #seconds

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


#test
