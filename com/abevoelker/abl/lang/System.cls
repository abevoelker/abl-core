 
 /*------------------------------------------------------------------------
    File        : System
    Purpose     : 
    Description : 
    Author(s)   : Abe Voelker
    Created     : Fri Nov 12 19:54:38 CST 2010
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

CLASS abl.lang.System: 

    METHOD PUBLIC STATIC VOID arraycopy(fromArr AS MEMPTR, fromStart AS INT, toArr AS MEMPTR, toStart AS INT, length AS INT64):
        DEF VAR i AS INT NO-UNDO.
        DO i=0 TO length - 1:
            PUT-BYTE(toArr, i + toStart) = GET-BYTE(fromArr, i + fromStart).
        END.
    END METHOD.

END CLASS.