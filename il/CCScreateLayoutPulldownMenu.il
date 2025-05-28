/*************************************************************************
* DISCLAIMER: The following code is provided for Cadence customers       *
* to use at their own risk. The code may require modification to         *
* satisfy the requirements of any user. The code and any modifications   *
* to the code may not be compatible with current or future versions of   *
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, *
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         *
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         *
*************************************************************************/

procedure( CCSCreateLayoutPulldownMenu() 
	hiCreatePulldownMenu( 
       'CCSlayoutPulldownMenu 
       "Example" 
       		list( ;the list of items in the Example menu
     		hiCreateSliderMenuItem(
        	?name 'CCSsliderMenuItem
        	?itemText "Print"
        	?subMenu 
			hiCreatePulldownMenu(
        		'CCSsubMenu
        		""
        			list( ; the list of menu items in the slider menu
				hiCreateMenuItem(
        			?name 'CCSa_MenuItem
        			?itemText "A"
        			?callback "println('A)" ;;; prints A in the CIW
        			)

     				hiCreateMenuItem(
        			?name 'CCSb_MenuItem
        			?itemText "B"
      				?callback "println('B)" ;;; prints B in the CIW
        			)

     				hiCreateMenuItem(
       				?name 'CCSc_MenuItem
        			?itemText "C"
        			?callback "println('C)" ;;; prints C in the CIW
        			)
        		     	    ) ;list
				) ; hiCreatePulldownMenu
			) ;hiCreateSliderMenuItem

;; Separator menu item
         hiCreateSeparatorMenuItem( ?name 'sep1)
	  	hiCreateMenuItem( ; list of menu items 
	     	?name 'Item1 
	     	?itemText "Item1" 
	     	?callback	 "println(\"Item One\")" 
	    	) 
	  	hiCreateMenuItem( ; list of menu items 
	     	?name 'Item2 
	     	?itemText "Item2" 
	     	?callback	 "println(\"Item two\")" 
	    	) 

       	) ; list 
    ) ; hiCreatePulldownMenu 
) ; procedure 

procedure( CCSUserPostInstallTrigger(args) 
;; Inserting the Example menu on the Layout banner	
 if(!rexMatchList("CCSlayoutPulldownMenu" hiGetBannerMenus(args->window))
	then
   	hiInsertBannerMenu( 
	args->window 
	if(!boundp('CCSlayoutPulldownMenu) then CCSCreateLayoutPulldownMenu() else  CCSlayoutPulldownMenu)
	length( hiGetBannerMenus( args->window)) 
   	) 
);if rexMatchList
) ; procedure 

;; This trigger will attach the menu to viewType maskLayout or the VLS L window
deRegUserTriggers("maskLayout" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to viewType maskLayoutXL or the VXL window
deRegUserTriggers("maskLayoutXL" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to viewType maskLayoutEXL or the EXL Editing window (ICADVM18.1)
deRegUserTriggers("maskLayoutEXL" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to the viewType schematic
deRegUserTriggers("schematic" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to the schematic XL window
deRegUserTriggers("schematicXL" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to the SystemVerilog Text Editor window
deRegUserTriggers("systemVerilogText" nil nil 'CCSUserPostInstallTrigger)

;; This trigger will attach the menu to viewType maskLayoutMXL or the MXL Editing window (IC23.1)
deRegUserTriggers("maskLayoutMXL" nil nil 'CCSUserPostInstallTrigger)
