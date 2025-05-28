/*

Group Custom IC, Cadence Design Systems

Language SKILL

Revision No. 1.0

Date Created 27th Aug 2009

Last Modified 21st Mar 2021

Tested in IC20.1-ISR17

COS solution 11256326

Author hcquek

Lint score 100

Description This program will replace cells in specified libraries

********************************************************************

* DISCLAIMER: The following code is provided for Cadence customers *

* to use at their own risk. The code may require modification to *

* satisfy the requirements of any user. The code and any *

* modifications to the code may not be compatible with current or *

* future versions of Cadence products. *

* THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, INCLUDING *

* WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED WARRANTIES *

* OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE. *

********************************************************************

Save this program as "CCSmigrateDesign.il" in your working directory

Then key in the following in the CIW input panel :

load "CCSmigrateDesign.il"

Press F10 in CIW to display input form that uses mapping file for multiple devices.

- The mapping file should contain lines as shown below, # is used to separate the old vs new devices

- oldLib/oldCell/oldView will be replaced with newLib/newCell/newView for 1 or more cells in the list of libraries specified in the form

; This is a comment

oldLib oldCell oldView # newLib newCell newView newProp1

; Props are optional

oldLib oldCell oldView oldProp1 oldProp2 ... oldProp99 # newLib newCell newView newProp1 newProp2 ... newProp99

As an example, the following devices need to be migrated:

Old PDK uses nmos1 (W1, L1) and nmos2 (W2, L2)

New PDK uses nmos1a (W11, L11) and nmos2a (W22, L22)

The following mapping can be used:

oldTechLib nmos1 symbol W1 L1 # newTechLib nmos1a symbol W11 L11

oldTechLib nmos2 symbol W2 L2 # newTechLib nmos2a symbol W22 L22

*/

procedure( CCSmigrateDesignForm()

   let( (targetLib allTargetLibs targetCells mapFile fileSel viewType addLibButton backupOrg recreateInst)

      targetLib=hiCreateComboField(

         ?name 'targetLib

         ?prompt "Target library"

         ?items sort(setof(x ddGetLibList() !member("tech.db" x~>files~>name) && !pcreMatchp("tools.*(dfII|etc)" x~>readPath))~>name nil)

         ?callback "CCSaddCellsToForMigration(hiGetCurrentForm())"

      ) ;hiCreateComboField

      targetCells=hiCreateListBoxField(

         ?name 'targetCells

         ?prompt "Target cells"

         ?choices list()

         ?numRows 10

         ?multipleSelect t

      ) ;hiCreateListBoxField

      addLibButton=hiCreateFormButton(

         ?name 'addLibButton

         ?buttonText "+"

         ?callback "CCSaddLibForMigration(hiGetCurrentForm())"

      ) ;hiCreateFormButton

      allTargetLibs=hiCreateMLTextField(

         ?name 'allTargetLibs

         ?prompt "Target libs and cells"

         ?hasHorizontalScrollbar nil

         ?hasVerticalScrollbar t

         ?enableWordWrap t

      ) ;hiCreateMLTextField

      mapFile=hiCreateStringField(

         ?name 'mapFile

         ?prompt "Mapping file"

      ) ;hiCreateStringField

      fileSel=hiCreateFormButton(

         ?name 'fileSel

         ?buttonText "..."

         ?callback "ddsFileBrowseCB(hiGetCurrentForm() 'mapFile)"

      ) ;hiCreateFormButton

      viewType=hiCreateRadioField(

         ?name 'viewType

         ?prompt "Choose view type"

         ?choices list("schematic" "maskLayout")

      ) ;hiCreateRadioField

      backupOrg=hiCreateRadioField(

         ?name 'backupOrg

         ?prompt "Backup original"

         ?choices list("Yes" "No")

      ) ;hiCreateRadioField

      recreateInst=hiCreateRadioField(

         ?name 'recreateInst

         ?prompt "Recreate inst"

         ?choices list("Yes" "No")

         ?value "No"

      ) ;hiCreateRadioField

      hiCreateAppForm(

         ?name 'migrateDesignForm

         ?formTitle "Library migration helper"

         ?callback "CCSmigrateDesign(hiGetCurrentForm())"

         ?fields list(

            list(targetLib 0:0 500:50 150)

            list(targetCells 0:50 500:200 150)

            list(addLibButton 500:50 30:30)

            list(allTargetLibs 0:260 500:200 150)

            list(mapFile 0:460 500:50 150)

            list(fileSel 500:470 30:30 150)

            list(viewType 0:500 500:50 150)

            list(backupOrg 0:530 500:50 150)

            list(recreateInst 0:560 500:50 150)

         ) ;list

         ?initialSize list(550 650)

      ) ;hiCreateAppForm

      hiDisplayForm('migrateDesignForm)

   ) ;let

) ;procedure

procedure( CCSaddCellsToForMigration(migrateDesignForm)

   let( (targetLib)

      targetLib=migrateDesignForm~>targetLib~>value

      ; Will get the following warning if ddGetObj(targetLib) is used and form is cancelled with invalid lib name

      ; Use member cmd as workaround

      ; *WARNING* ddGetObj: invalid libId (0x(nil))

      when( member(targetLib ddGetLibList()~>name)

         migrateDesignForm~>targetCells~>choices=cons("All" ddGetObj(targetLib)~>cells~>name)

         migrateDesignForm~>targetCells~>value=list(car(migrateDesignForm~>targetCells~>choices))

      ) ;when

   ) ;let

) ;procedure

procedure( CCSaddLibForMigration(migrateDesignForm)

   let( (targetLib targetCells targetLibWithCell allTargetLibs)

      targetLib=migrateDesignForm~>targetLib~>value

      targetCells=migrateDesignForm~>targetCells~>value

      targetLibWithCell=foreach(mapcar x targetCells

         strcat(targetLib "/" x)

      ) ;foreach

      allTargetLibs=parseString(migrateDesignForm~>allTargetLibs~>value " \t\n")

      if( ddGetObj(targetLib) then

         allTargetLibs=buildString(append(allTargetLibs targetLibWithCell) "\n")

         migrateDesignForm~>allTargetLibs~>value=allTargetLibs

      else

         error("TargetLib %s not found\n" targetLib)

      ) ;if

   ) ;let

) ;procedure

procedure( CCSmigrateDesign(migrateDesignForm)

   let( (startTime endTime totalTime allTargetLibs mapFile inPort oldTable newTable k badLines

    oldCell newCell cv viewType inLine inLineList oldLib oldView newLib newView backupOrg recreateInst

 instList totalLibs libCount totalViews viewCount libList targetLibCellList targetLibList targetCellList

 paramTable j instCdf paramId instMaster instName instPt instOrient)

      startTime=getCurrentTime()

      allTargetLibs=parseString(migrateDesignForm~>allTargetLibs~>value " \t\n")

      mapFile=migrateDesignForm~>mapFile~>value

      viewType=migrateDesignForm~>viewType~>value

      backupOrg=migrateDesignForm~>backupOrg~>value

      recreateInst=migrateDesignForm~>recreateInst~>value

      unless( isFile(mapFile) error("File %s cannot be found\n" mapFile))

      inPort=infile(mapFile)

      oldTable=makeTable("oldTable" nil)

      newTable=makeTable("newTable" nil)

      k=0

      badLines=list()

      while( gets(inLine inPort)

         inLineList=parseString(inLine "#\n")

         when( !pcreMatchp("^(\\s*|\\t*);" inLine) && length(inLineList)>=2

            oldTable[k]=parseString(car(inLineList) " \t")

            newTable[k]=parseString(cadr(inLineList) " \t")

            unless( length(oldTable[k])==length(newTable[k])

               badLines=cons(inLine badLines)

            ) ;unless

            k++

         ) ;when

      ) ;while

      close(inPort)

      when( length(badLines)>0

         printf("The following lines in mapping file needs to be corrected:\n")

         foreach(line badLines

            printf("%s\n" line)

         ) ;foreach

         printf("=== Format of mapping file ===\n")

         printf("oldLib oldCell oldView # newLib newCell newView\n")

         error("")

      ) ;when

      libList=list()

      foreach( targetLib allTargetLibs

         targetLibList=parseString(targetLib "/")

         unless( member(car(targetLibList) libList)

            libList=append1(libList car(targetLibList))

         ) ;unless

      ) ;foreach

      totalLibs=length(libList)

      libCount=1

      foreach( targetLib libList

         printf("Processing lib %s\n" targetLib)

         targetLibCellList=setof(x allTargetLibs pcreMatchp(strcat("^" targetLib "/") x))

         targetCellList=list()

         foreach( targetLibCell targetLibCellList

            targetCellList=append1(targetCellList cadr(parseString(targetLibCell "/")))

         ) ;foreach

         if( member("All" targetCellList) then

            targetCellList=ddGetObj(targetLib)~>cells

         else

            targetCellList=foreach(mapcar x targetCellList

               ddGetObj(targetLib x)

            ) ;foreach

         ) ;if

         totalViews=0

         viewCount=1

         foreach( cell targetCellList

            totalViews=totalViews+length(setof(x cell~>views when(ddGetObj(targetLib cell~>name x~>name "*")

                        ddMapGetFileViewType(ddGetObj(targetLib cell~>name x~>name "*"))==viewType)))

         ) ;foreach

         paramTable=makeTable("paramTable" nil)

         foreach( cell targetCellList

            foreach( view setof(x cell~>views when(ddGetObj(targetLib cell~>name x~>name "*")

                        ddMapGetFileViewType(ddGetObj(targetLib cell~>name x~>name "*"))==viewType) && !pcreMatchp("^(schematic|layout)_\\d+_\\d+$" x~>name))

               cv=dbOpenCellViewByType(targetLib cell~>name view~>name "" "a")

               printf(" %s : Processing : %s/%s/%s (lib : %d/%d views in lib: %d/%d)\n"

   getCurrentTime() targetLib cell~>name view~>name libCount totalLibs viewCount totalViews)

               viewCount++

               when(backupOrg=="Yes" CCSbackupCellViewBeforeMigration(cell cv viewType))

               if(cv then

                  for(i 0 length(oldTable)-1

                     ; oldTable[i]=list(oldLib oldCell oldView oldParam1 oldParam2 ...)

                     ; newTable[i]=list(newLib newCell newView newParam1 newParam2 ...)

                     oldLib=nth(0 oldTable[i])

                     oldCell=nth(1 oldTable[i])

                     oldView=nth(2 oldTable[i])

                     newLib=nth(0 newTable[i])

                     newCell=nth(1 newTable[i])

                     newView=nth(2 newTable[i])

                     instList=setof(x cv~>instances x~>libName==oldLib && x~>cellName==oldCell && x~>viewName==oldView)

                     foreach( inst instList

                        j=0

                        instCdf=cdfGetInstCDF(inst)

                        foreach(param cdddr(oldTable[i])

             paramTable[j]=cdfFindParamByName(instCdf param)~>value

                           j++

                        ) ;foreach

                        if( recreateInst=="Yes" then

                           instMaster=dbOpenCellViewByType(newLib newCell newView)

                           instName=inst~>name

                           instPt=inst~>xy

                           instOrient=inst~>orient

                           dbDeleteObject(inst)

                           inst=dbCreateInst(cv instMaster instName instPt instOrient)

                        else

                           leReplaceAnyInstMaster(inst newLib newCell newView)

                        ) ;if

                        j=0

                        instCdf=cdfGetInstCDF(inst)

                        foreach(param cdddr(newTable[i])

                           paramId=cdfFindParamByName(instCdf param)

                           if( paramId~>paramType=="string" && !stringp(paramTable[j]) then

                              paramId~>value=sprintf(nil ""%s"" paramTable[j])

                           else

                              paramId~>value=paramTable[j]

                           ) ;if

                           j++

                        ) ;foreach

                        foreach( prop inst~>prop

                           unless( setof(x instCdf->parameters x->name==prop~>name)

                              dbDeleteObject(prop)

                           ) ;unless

                        ) ;foreach

                     ) ;foreach

                  ) ;for

                  when( cv~>modifiedButNotSaved

                     when(viewType=="schematic" schCheck(cv))

                     dbSave(cv)

                  ) ;when

                  dbClose(cv)

               else

                  printf(" Cellview %s/%s/%s not processed\n" targetLib cell~>name view~>name)

               ) ;if

            ) ;foreach

         ) ;foreach

         libCount++

      ) ;foreach

      endTime=getCurrentTime()

      printf("\n")

      printf("Migration start time : %s\n" startTime)

      printf("Migration end time : %s\n" endTime)

      totalTime=(stringToTime(endTime)-stringToTime(startTime))/3600.0

      printf("Total time : %.1f mins\n" totalTime)

   ) ;let

) ;procedure

procedure( CCSbackupCellViewBeforeMigration(cell cv viewType)

   let( (dateList year month day time backupViewName cvBackup)

      dateList=parseString(getCurrentTime())

      year=nth(3 dateList)

      day=nth(1 dateList)

      case( nth(0 dateList)

         ("Jan" month="01")

         ("Feb" month="02")

         ("Mar" month="03")

         ("Apr" month="04")

         ("May" month="05")

         ("Jun" month="06")

         ("Jul" month="07")

         ("Aug" month="08")

         ("Sep" month="09")

         ("Oct" month="10")

         ("Nov" month="11")

         ("Dec" month="12")

      ) ;case

      time=buildString(parseString(nth(2 dateList) ":") "")

      case( viewType

         ("schematic" backupViewName=sprintf(nil "schematic_%s%s%s_%s" year month day time))

         ("maskLayout" backupViewName=sprintf(nil "layout_%s%s%s_%s" year month day time))

      ) ;case

      ; schematic_20210224_134108

      unless( pcreMatchList("^(schematic|layout)_\\d+_\\d+$" cell~>views~>name)

         dbSave(cv cv~>libName cv~>cellName backupViewName)

         cvBackup=dbOpenCellViewByType(cv~>libName cv~>cellName backupViewName "" "a")

         when(viewType=="schematic" schCheck(cvBackup))

         dbSave(cvBackup)

         dbClose(cvBackup)

         printf(" %s : Backup view %s saved for %s/%s/%s\n" getCurrentTime() backupViewName cv~>libName cv~>cellName cv~>viewName)

      ) ;unless

   ) ;let

) ;procedure

hiSetBindKey("Command Interpreter" "F11" "CCSmigrateDesignForm()")
