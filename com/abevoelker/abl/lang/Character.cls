 
 /*------------------------------------------------------------------------
    File        : Character
    Purpose     : Wrapper for the ABL 'primitive' `CHARACTER` datatype.
    Description : 
    Author(s)   : Abe Voelker
    Created     : Fri Nov 12 21:58:16 CST 2010
    Notes       : 
  ----------------------------------------------------------------------

   Copyright 2010 Abe Voelker

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
  */

USING Progress.Lang.*.

ROUTINE-LEVEL ON ERROR UNDO, THROW.

CLASS abl.lang.Character: 

    DEFINE PUBLIC STATIC PROPERTY MAX_LENGTH AS INT INITIAL 31991 NO-UNDO
      GET.
      PRIVATE SET.

END CLASS.