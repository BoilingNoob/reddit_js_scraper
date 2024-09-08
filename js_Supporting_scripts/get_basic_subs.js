clear()
var list_elems = document.getElementsByClassName("XEkFoehJNxIH9Wlr5Ilzd _2MgAHlPDdKvXiG-Qbz5cbC ")

var regex_exp_multis = new RegExp("\/m\/", "g")
var regex_exp_mains = new RegExp("\/(r|user)\/", "g")

var multis = []

var main_subs_and_users = []

for(var i=0;i < list_elems.length;i++){
  if(list_elems[i].href.match(regex_exp_multis)){
    multis.push(list_elems[i].href)
  }
  else if(list_elems[i].href.match(regex_exp_mains)){
    main_subs_and_users.push(list_elems[i].href)
  }
}

var multi_string = ""
for(var i=0;i<multis.length;i++){
  multi_string+=multis[i]+";"
}

var main_subs_and_users_string = ""
for(var i=0;i<main_subs_and_users.length;i++){
  main_subs_and_users_string+=main_subs_and_users[i]+";\n"
}

var return_string = multi_string + ";" + main_subs_and_users_string


prompt(return_string,return_string)
