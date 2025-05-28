/*******************************************************************************
*  DISCLAIMER: The following code is provided for Cadence customers to use at  *
*   their own risk. The code may require modification to satisfy the           *
*   requirements of any user. The code and any modifications to the code may   *
*   not be compatible with current or future versions of Cadence products.     *
*   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     *
*   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *
*   OR FITNESS FOR A PARTICULAR USE                                            *
*******************************************************************************/

procedure(CCS_Add_Layer()
let((techLib layerName layerNum layerNum2 layerText layerPurpose layerPacket layerPacket2 PacketButton Field_list )
    techLib = hiCreateCyclicField(?name 'techLib ?prompt "Target Library" ?defValue "**Library**" ?choices cons("**Library**" ddGetLibList()~>name) ?callback "TechLib_CB()")
    layerName = hiCreateStringField(?name 'layerName ?prompt "Layer Name " ?editable nil )
    layerNum = hiCreateCyclicField(?name 'layerNum ?prompt "Layer Number" ?choices list("    ") ?callback "Layer_num_CB()")
    layerNum2 = hiCreateStringField(?name 'layerNum2 ?editable nil)
    layerText = hiCreateLabel(?name 'layerText ?labelText "Input 256 ~ 2^31-1" ?invisible t)
    layerPurpose = hiCreateCyclicField(?name 'layerPurpose ?prompt "Purpose" ?choices list("Purpose" "11"))
    layerPacket = hiCreateStringField(?name 'layerPacket ?prompt "Display Resources" ?editable nil)
    layerPacket2 = hiCreateListBoxField(?name 'layerPacket2 ?choices list("  ") ?changeCB "Add_LPP_Form->layerPacket->value=car(Add_LPP_Form->layerPacket2->value)")
    PacketButton = hiCreateButton(?name 'PacketButton ?buttonText "Display \n Resources\n Editor.." ?callback "dreInvokeDre()")
    Field_list = list(
			 list( techLib 10:10 300:50 100) 
			 list( layerName 10:30 260:50 100) 
			 list( layerNum 10:70 150:50 100) 
			 list( layerNum2 170:60 100:50 0) 
			 list( layerText 150:80 100:50 0) 
			 list( layerPurpose 10:110 260:50 100) 
			 list( layerPacket 10:130 260:50 100) 
			 list( layerPacket2 10:170 260:200 100) 
			 list( PacketButton 10:190 90:150) 
		       )
    hiCreateAppForm(
         ?name         'Add_LPP_Form
         ?formTitle    "Add Layer Purpose Pair"
         ?fields Field_list
         ?initialSize t
	 ?buttonLayout 'ApplyCancel
	 ?callback "Add_Layer_CB()"
    )
    hiDisplayForm( Add_LPP_Form )
);let
);procedure
procedure(TechLib_CB()
prog((Tech Layer_numbers Packetlist)
  Tech = techGetTechFile(ddGetObj(Add_LPP_Form->techLib->value))
  Layer_numbers = list()
  for(i 0 194
	if(lindex(Tech~>layers~>number i) == nil Layer_numbers=append1(Layer_numbers sprintf(nil "%d" i)))
  );for
  Layer_numbers=append1(Layer_numbers "Over")
  Packetlist = list()
  for(i 0 length(Tech~>lps~>packet)-1
	if(lindex(Packetlist nth(i Tech~>lps~>packet)) == nil Packetlist=append1(Packetlist nth(i Tech~>lps~>packet)))
  );for
  Add_LPP_Form->layerName->editable = t
  Add_LPP_Form->layerNum->choices = Layer_numbers
  Add_LPP_Form->layerNum2->value = Add_LPP_Form->layerNum->value 
  Add_LPP_Form->layerPurpose->choices = sort(Tech~>purposes nil)
  Add_LPP_Form->layerPurpose->value = "drawing"
  Add_LPP_Form->layerPacket2->choices = sort(Packetlist nil)
));procedure
procedure(Layer_num_CB()
if(Add_LPP_Form->layerNum->value == "Over" then
		Add_LPP_Form->layerNum2->editable = t
		Add_LPP_Form->layerNum2->value = ""
		Add_LPP_Form->layerText->invisible = nil
else Add_LPP_Form->layerNum2->value = Add_LPP_Form->layerNum->value
);if
);procedure


procedure(Add_Layer_CB()
CCScreateLayer( Add_LPP_Form->techLib->value
		Add_LPP_Form->layerName->value
		Add_LPP_Form->layerPurpose->value
		atoi(Add_LPP_Form->layerNum2->value)
		Add_LPP_Form->layerPacket->value
		)
);procedure

procedure(CCScreateLayer(techlib layerName purposeName layerNumber displayPacket @optional (purposeNumber 0) "tttxtx")
let((tf lppId)
tf=techGetTechFile(ddGetObj(techlib))

;; Check is techlib is editable
unless(techReopenTechFile(tf "a")
 error("Technology Library is not editable hence this program will abort\n")
);unless

;; Check if layer already exists
if(!techGetLayerNum(tf layerName) then
           if(!techGetLayerName(tf layerNumber) then
             printf("Creating new layer\n")
             techCreateLayer(tf layerNumber layerName)
             else
            error("Specified layer number %L already exists, new layer will not be created\n" layerNumber)
            );if
 else
 printf("Specified Layer %s already exists, new layer will not be created\n" layerName)
);if

;; Check if purpose already exists
if(!techGetPurposeNum(tf purposeName) then
;; Check if purpose number already exists
     if(!techGetPurposeName(tf purposeNumber) && (purposeNumber != 0) then
         printf("Creating new purpose\n")
         techCreatePurpose(tf purposeNumber purposeName)
       else
      error("Unable to create new purpose, either purpose number already exists or you didn't specify 6th argument\n")
      );if
 else
 printf("Specified purpose %s already exists \n" purposeName)
);if

;; Check if lpp already exists
if(!techGetLP(tf list(layerName purposeName)) then
     printf("Creating new lpp\n")
     lppId=techCreateLP(tf list(layerName purposeName) layerName)
     techSetLPPacketName(lppId displayPacket)
 else
 printf("Specified lpp %L already exists, new lpp will not be created\n" list(layerName purposeName))
 );if
;; If the techfile got modified, save it
when(tf~>modifiedButNotSaved techSaveTechFile(tf))
);let
);procedure



