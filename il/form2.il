;Purpose:A improved example for using cadence form
;
hiSetBindKey("Layout" "F10" "myformfunc()")
procedure(myformfunc()
mystring1=hiCreateStringField(?name `stringfield1 ?prompt "String1")
mystring2=hiCreateStringField(?name `stringfield2 ?prompt "String2")

myoptionsform3=hiCreateOptionsForm(`optionsform3 "OptionsForm" list(hiCreateStringField(?name `stringfield1 ?prompt "String1") hiCreateStringField(?name `stringfield2 ?prompt "String2")) nil)

myreportfield1=hiCreateReportField(?name `reportfield1 ?title "Report Field" ?headers `(("ID" 120 `left) ("NAME" 120 `left) ("WIDTH" 120 `left)) ?choices list(list("1" "one" "100") list("2" "two" "200") list("1" "three" "300")))

mytabfield1=hiCreateTabField(?name `tabfield1 ?tabPlacement `top ?tabs list("page1" "page2") ?fields list(list(list(hiCreateStringField(?name `stringfield1 ?prompt "String1") 0:0 400:60 80)) list(list(hiCreateStringField(?name `stringfield2 ?prompt "String2") 0:0 400:60 80))))

mytogglefield1=hiCreateToggleField(?name `togglefield1 ?choices list(`(abc "abc") `(def "def")) ?numSelect 1)

myformbutton1=hiCreateFormButton(?name `formbutton1 ?buttonText "FormButton1" ?callback "openmyoptionsform3()")
;optionsform is used with enterbox function only

myform1=hiCreateAppForm(
?name `formname7
?formTitle "My Form"
?callback nil
?fields list(

list(mytabfield1 0:0 400:200 200)
list(myreportfield1 400:0 400:200 200)
list(mytogglefield1 0:200 800:100 100)
list(myformbutton1 0:400 800:100 100)

);end-list
);end-create form

hiDisplayForm(`formname7)


procedure(openmyoptionsform3()
print("hello")
enterCircle(?prompts list("Center" "Radius") ?doneProc "doneopenmyoptionsform3" ?form optionsform3)
hiDisplayForm(`optionsform3)
)
procedure(doneopenmyoptionsform3(w done pts)
if(done then
optionsform3->stringfield1->value="abc"
optionsform3->stringfield2->value="123"
)
)
);end-procedure-myformfunc
