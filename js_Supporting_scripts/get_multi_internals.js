clear()

document.getElementsByClassName("_31vaGAnztsBt2uSP6kVo6D _2iuoyPiKHN3kfOoeIQalDT _3zbhtNO0bdck0oYbYRhjMC HNozj_dKjQZ59ZsfEegz8 ")[0].click()
var multi_elems = document.getElementsByClassName("_3NFddqqrzfM8noBES52Qcy _14n0HZvxiP1OqS51zI7Sy3")

var multi_elems_string =""

for(var i=0; i<multi_elems.length;i++){
  multi_elems_string+=multi_elems[i].children[0].children[1].children[0].children[0].innerText+";\n"
}


prompt(multi_elems_string,multi_elems_string)
