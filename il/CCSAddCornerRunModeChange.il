/************************************************************************* 
* DISCLAIMER: The following code is provided for Cadence customers       * 
* to use at their own risk. The code may require modification to         * 
* satisfy the requirements of any user. The code and any modifications   * 
* to the code may not be compatible with current or future versions of   * 
* Cadence products. THE CODE IS PROVIDED "AS IS" AND WITH NO WARRANTIES, * 
* INCLUDING WITHOUT LIMITATION ANY EXPRESS WARRANTIES OR IMPLIED         * 
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.         * 
*************************************************************************/ 

procedure(CCSAddCornerRunModeChange( maeSession runMode)
let((model2add)
 cond(
     (runMode=="Single Run, Sweeps and Corners"
               model2add=list("<Path_to_the_model_file>/gpdk045.scs;tt" "<Path_to_the_model_file>/gpdk045.scs;fs")
     )       
     (runMode=="Monte Carlo Sampling"
               model2add=list("<Path_to_the_model_file>/gpdk045.scs;ss" "<Path_to_the_model_file>/gpdk045.scs;ff")
     )
 )          
  foreach(testName maeGetSetup(?typeName "tests")
        asiSetEnvOptionVal( maeGetTestSession(testName ?session maeSession) 'modelFiles model2add)
  ) ;foreach
t
) ;let
) ;procedure


procedure( CCSFnxCreationCB( maeSession )
  axlSessionConnect( maeSession "runModeChanged" 'CCSAddCornerRunModeChange ) 
t
)
 
axlSessionRegisterCreationCallback('CCSFnxCreationCB)
