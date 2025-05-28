/*******************************************************************************

*  DISCLAIMER: The following code is provided for Cadence customers to use at  *

*   their own risk. The code may require modification to satisfy the           *

*   requirements of any user. The code and any modifications to the code may   *

*   not be compatible with current or future versions of Cadence products.     *

*   THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING WITHOUT     *

*   LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES OF MERCHANTABILITY *

*   OR FITNESS FOR A PARTICULAR USE.                                           *

*******************************************************************************/ 

/*

The SKILL code:

- takes an optional windowId as a parameter. It should be a window displaying a schematic

- asks for user to input a net by clicking on it

- returns a list of devices that belong to this net

- also prints to CIW,  the hierarchical paths to these devices that are on the net under consideration

- There is another function defined which does not require you to select the net on the schematic and you can pass the netname to this function.


Usage:

1) Load the following code in your DFII session and run the following command in CIW with the desired top level schematic open:

mylist = CCSGetInstsDevsForNet()

- asks for user to input a net by clicking on it

- returns a list of devices that belong to this net

2) There is another function defined which does not require you to select the net on the schematic and you can pass the netname to this function.

CCSGetInstsDevsForNetByNetName("<netName>")

Example: CCSGetInstsDevsForNetByNetName("avdd") 

This script has a SKILL Lint score of 100 and does not contain any private functions.

*/

 

;;-------------------------------------------------

procedure(CCSGetInstsDevsForNet(@optional (win hiGetCurrentWindow()) )  

let( (myprobes idList cv retVal)

  unless(win && win->cellView->cellViewType=="schematic"

   error("Please have a schematic window open and retry...")

        )

 

cv = geGetTopLevelCellView(win)

 

;;clean up existing probes and selections    

   if(geGetAllProbe()

     geDeleteAllProbe()

     geDeselectAll()

     )

 

;;ask for the net for which the devices need to be probed

auProbeAddDevsForNet()

 

;; get all the probes

myprobes=geGetAllProbe()

 

when(myprobes

foreach(probe myprobes

    println(probe~>probeName)

    retVal = CCSUtilFn(cv probe~>probeName )

        when(retVal

            idList = cons( retVal idList)

        );when

       );foreach

  );when

 

geDeleteAllProbe()

idList

 

    );let

);procedure

 

;;Utility function

procedure(CCSUtilFn(cvId probeName "dt")

   let( (mylis myDevName viewToUse newViewToUse inst

           tmpinst tmpvar myvar)  

   ;parse input hierarchical probeName

   mylis = parseString(probeName "/")

 

   ; Get the device name  

   myDevName = car(last(mylis))

 

   ;remove device name from the list          

   mylis = reverse(cdr(reverse(mylis)))  

 

  ;Intialize viewToUse variable to cvId

  viewToUse = cvId

 

   foreach(iName mylis  

             tmpinst=dbFindAnyInstByName(viewToUse iName)

 

;; The following portion of code is needed when dealing with iterated instances

    unless(tmpinst

        tmpvar = car(parseString(iName "<>"))

        tmpinst = car(setof(ins viewToUse~>instances

                            ins~>baseName == tmpvar

                           )  )

 

        )

 

   newViewToUse = dbGetAnyInstSwitchMaster(

                   tmpinst

                  "schematic symbol")

   ; Update viewToUse

   viewToUse = newViewToUse  

       ); foreach

  

   ;return the dbId of the required device

   inst = dbFindAnyInstByName(viewToUse myDevName)

 

;; The following portion of code is needed when dealing with iterated instances

unless(inst

        myvar = car(parseString(myDevName "<>"))

        inst = car(setof(ins newViewToUse~>instances

                            ins~>baseName == myvar

                           ))

 

             )

 

   inst

  );let

 

    );procedure
    
    
    procedure(CCSGetInstsDevsForNetByNetName(mynet @optional (win hiGetCurrentWindow()) )
let( (cv netId myfigs myfig point1 point2 mypoint)

 unless(win && win->cellView->cellViewType=="schematic"
   error("Please have a schematic window open and retry...")
           )

 cv = geGetWindowCellView(win)

 unless(netId=dbFindNetByName(cv mynet)
  error("Net %s does not exist in the current schematic being displayed\n" mynet))

 myfigs=setof(fig netId~>figs fig~>objType == "line")
  myfig=car(myfigs)
 point1=car(myfig~>points)
 point2=cadr(myfig~>points)
 mypoint=list( (xCoord(point1)+xCoord(point2))/2 (yCoord(point1)+yCoord(point2))/2 )

 printf("\n mypoint is %L\n" mypoint)
 CCSGetInstsDevsForNetByNet(win)

  );let
 );procedure



procedure(CCSGetInstsDevsForNetByNet(win)
 let( (myprobes idList cv retVal)
  unless(win && win->cellView->cellViewType=="schematic"
   error("Please have a schematic window open and retry...")
        )

 cv = geGetWindowCellView(win)

;;clean up existing probes and selections     
   if(geGetAllProbe()
     geDeleteAllProbe()
     geDeselectAll()
     )

hiRegTimer("addPoint(mypoint) finishEnterFun()" 10)
;;ask for the net for which the devices need to be probed
 auProbeAddDevsForNet() 
;; get all the probes
 myprobes=geGetAllProbe()

 when(myprobes 
 foreach(probe myprobes
    println(probe~>probeName)
    retVal = CCSNew(cv probe~>probeName )
   when(retVal
    idList = cons( retVal idList)
      );when
           
 
       );foreach
     );when

 geDeleteAllProbe()
 idList

    );let
         );procedure



procedure(CCSNew(cvId probeName "dt") 
   let( (mylis myDevName viewToUse newViewToUse inst 
           tmpinst tmpvar myvar)  
   ;parse input hierarchical probeName
   mylis = parseString(probeName "/")

   ; Get the device name  
   myDevName = car(last(mylis)) 

   ;remove device name from the list          
   mylis = reverse(cdr(reverse(mylis)))  

  ;Intialize viewToUse variable to cvId
  viewToUse = cvId 
 
   foreach(iName mylis  
             tmpinst=dbFindAnyInstByName(viewToUse iName) 

    unless(tmpinst
        tmpvar = car(parseString(iName "<>"))
        tmpinst = car(setof(ins viewToUse~>instances
                            ins~>baseName == tmpvar
                           ))

             )

   newViewToUse = dbGetAnyInstSwitchMaster( 
                   tmpinst
                  "schematic symbol") 
   ; Update viewToUse 
   viewToUse = newViewToUse  
       ); foreach
   
   ;return the dbId of the required device
   inst = dbFindAnyInstByName(viewToUse myDevName)

 unless(inst
        myvar = car(parseString(myDevName "<>"))
        inst = car(setof(ins newViewToUse~>instances
                            ins~>baseName == myvar
                           ))

             )

 ;println(inst~>cellName)
   inst
  );let

    );procedure



;;----------------------------------------------------
