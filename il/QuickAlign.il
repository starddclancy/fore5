procedure(QuickAlign(option)
let((Value myPort inPort)
if((option == 1) then
leQckAlignForm->qckAlignSpacingValField->value = "0"
hiiToggleEnterForm(leQckAlignForm)
leHiQuickAlign()
else
inPort=infile("~/.myFile_QuickAlign")
gets(Value inPort)
Value = readstring(Value)
leQckAlignForm->qckAlignSpacingValField->value = Value
hiiToggleEnterForm(leQckAlignForm)
leHiQuickAlign()
);if
Value=leQckAlignForm->qckAlignSpacingValField->value
if(Value != "0" then
myPort = outfile("~/.myFile_QuickAlign")
print(Value myPort)
close(myPort)
);if
);let
);proc

hiSetBindKey("Layout" "<Key>Z" "QuickAlign(1)")
hiSetBindKey("Layout" "<Key>M" "QuickAlign(2)")