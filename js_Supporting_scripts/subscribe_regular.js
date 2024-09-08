clear()
const delay = ms => new Promise(res => setTimeout(res, ms))
await delay(500)

var loop_delay = 100
var test_var = false
var already_done = false
while (test_var == false && already_done == false) {
  //console.log("check if needed looping")
  try {
    if (document.getElementsByClassName("_1Q_zPN5YtTLQVG72WhRuf3")[0].innerText.trim() == "Join") {
      test_var = true
    } else if ((document.getElementsByClassName("_1Q_zPN5YtTLQVG72WhRuf3")[0].innerText.trim() == "Join")) {
      test_var = true
      already_done = true
    }
    else{
      //console.log("\t>"+document.getElementsByClassName("_1Q_zPN5YtTLQVG72WhRuf3")[0].innerText.trim()+"<")
    }
    //console.log("\tworked")
  } catch {
    //console.log("\tCaught")
  }
  await delay(loop_delay)

}
if (already_done == false) {
  do {
    //console.log("try to click looping")
    try {
      var working_button = document.getElementsByClassName("_1LHxa-yaHJwrPK8kuyv_Y4 _2iuoyPiKHN3kfOoeIQalDT _10BQ7pjWbeYP63SAPNS8Ts HNozj_dKjQZ59ZsfEegz8 _34mIRHpFtnJ0Sk97S2Z3D9")[0]
      working_button.click()
    } catch {}
    await delay(loop_delay)
  } while (document.getElementsByClassName("_1Q_zPN5YtTLQVG72WhRuf3")[0].innerText.trim() != "Joined")
}