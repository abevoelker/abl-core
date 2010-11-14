 
 /*------------------------------------------------------------------------
    File        : StringBuilder
    Purpose     : Stores a MUTABLE array of characters explicitly in memory.
                  Use as an alternative to CHARACTER and LONGCHAR when the 
                  string being stored is likely to change.  If it likely will
                  not change, use String instead.
    Description : Generally follows the implementation details from the open-
                  source Java OpenJDK class.
    Author(s)   : Abe Voelker
    Created     : Fri Nov 12 17:49:26 CST 2010
    Notes       : * This class is much slower than the Java equivalent due to
                    Progress interpreting a constant string of characters (e.g.
                    "foobar") as a CHARACTER variable, which is not a very
                    primitive datatype, making String instantiation expensive.
                    Java interprets "foobar" as being a char[], which is
                    basically just an array of bytes (2 bytes per char), making
                    it much faster.
                  * No support for special codepages or Unicode (yet)
                  * Limited to ~2GiB of memory.
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

CLASS abl.lang.StringBuilder IMPLEMENTS abl.lang.CharSequence: 
    
    &SCOPED-DEFINE CAPACITY_BUFFER 16
    
    DEF PRIVATE VAR mValue AS MEMPTR  NO-UNDO. /* Pointer to chunk of memory that holds characters */
    DEF PRIVATE VAR count  AS INTEGER NO-UNDO. /* The actual number of characters used */
		
	/**
	 *  Constructs a StringBuilder with no characters in it and an initial
	 *  capacity of 16 characters.
	 */
	CONSTRUCTOR PUBLIC StringBuilder():
	    SET-SIZE(mValue) = {&CAPACITY_BUFFER}.
	END CONSTRUCTOR.
		
    /* Creates an empty StringBuilder with the specified initial capacity */
	CONSTRUCTOR PUBLIC StringBuilder(capacity AS INT):
		SET-SIZE(mValue) = capacity.
	END CONSTRUCTOR.

    /**
	 *  Constructs a StringBuilder copied from the input CHAR value
	 *  capacity of 16 characters + the length of the input CHAR value.
	 */
    CONSTRUCTOR PUBLIC StringBuilder(c AS CHAR):
		count = LENGTH(c).
		SET-SIZE(mValue) = count + {&CAPACITY_BUFFER}.
		PUT-STRING(mValue, 1) = c.
	END CONSTRUCTOR.
	
	/**
	 *  Constructs a StringBuilder copied from the input String value
	 *  capacity of 16 characters + the length of the input String value.
	 */
    CONSTRUCTOR PUBLIC StringBuilder(str AS abl.lang.String):
		count = str:size().
		SET-SIZE(mValue) = count + {&CAPACITY_BUFFER}.
		str:getChars(1, str:size(), mValue, 1).
	END CONSTRUCTOR.

	DESTRUCTOR PUBLIC StringBuilder():
	    SET-SIZE(mValue) = 0.
	END DESTRUCTOR.
	
	/* Returns the actual length of the sequence of characters used */
	METHOD PUBLIC INT size():
	    RETURN count.
	END METHOD.
	
	/* Returns the allocated memory capacity */
	METHOD PUBLIC INT64 capacity():
	    RETURN GET-SIZE(mValue).
	END METHOD.
	
	/**
    *   Ensures that the capacity is at least equal to the specified minimum.
    *   If the current capacity is less than the argument, then a new internal
    *   array is allocated with greater capacity. The new capacity is the
    *   larger of:
    *    - The minimum capacity argument.
    *    - Twice the old capacity, plus 2.
    *
    */
	METHOD PUBLIC VOID ensureCapacity(iMinCapacity AS INT):
	    IF iMinCapacity GT capacity() THEN
            expandCapacity(iMinCapacity).
	END METHOD.
	
	/* Expands memory using algorithm described in ensureCapacity. */
	/* NOTE: Should only be called from ensureCapacity, as there   */
	/*       is no size checking here.                             */
	METHOD PRIVATE VOID expandCapacity(iMinCapacity AS INT):
	    DEF VAR newCapacity AS INT    NO-UNDO.
	    DEF VAR mNewValue   AS MEMPTR NO-UNDO.
	    newCapacity = (capacity() + 1) * 2.
	    IF newCapacity LT 0 THEN
            newCapacity = abl.lang.Integer:MAX_VALUE.
        ELSE IF iMinCapacity GT newCapacity THEN
            newCapacity = iMinCapacity.
        SET-SIZE(mNewValue) = newCapacity.
        abl.lang.System:arraycopy(mValue, 1, mNewValue, 1, count).
        SET-SIZE(mValue) = 0.
        mValue = mNewValue.
        /* Without the below code, Progress does something really fucking */
        /* dumb - it reuses previous expandCapacity calls' pointer        */
        /* addresses!  Ridiculous, but not surprising.  Fuck you Progress */
        FINALLY:
            SET-POINTER-VALUE(mNewValue) = 0.
        END.
	END METHOD.
	
	METHOD PUBLIC abl.lang.StringBuilder append(s AS abl.lang.String):
	    DEF VAR len     AS INT NO-UNDO.
	    DEF VAR newSize AS INT NO-UNDO.
	    IF s EQ ? THEN
            RETURN THIS-OBJECT.
        len = s:size().
        IF len EQ 0 THEN
            RETURN THIS-OBJECT.
        newSize = count + len.
        ensureCapacity(newSize).
        s:getChars(1, len, mValue, count + 1).
        count = count + len.
	    RETURN THIS-OBJECT.
	END METHOD.
	
	METHOD PUBLIC abl.lang.StringBuilder append(c AS CHAR):
	    DEF VAR s AS abl.lang.String NO-UNDO.
	    s = NEW abl.lang.String(c).
	    RETURN append(s).
	    FINALLY:
	      IF VALID-OBJECT(s) THEN
	        DELETE OBJECT s NO-ERROR.
	    END.
	END METHOD.
	
	/* @TODO */
	METHOD PUBLIC abl.lang.CharSequence subSequence(iStart AS INT, iEnd AS INT):
	END METHOD.
	
	/* @TODO */
	METHOD PUBLIC abl.lang.String toStringObj():
	END METHOD.
	
	METHOD PUBLIC CHARACTER toChar():
	    RETURN GET-STRING(mValue, 1).
	END METHOD.
	
	METHOD PUBLIC OVERRIDE CHARACTER toString():
        RETURN toChar().
    END METHOD.
	
    METHOD PUBLIC LONGCHAR toLongChar():
        DEF VAR lc AS LONGCHAR NO-UNDO.
        IF count LE 0 THEN
            RETURN "".
        COPY-LOB FROM mValue STARTING AT 1 FOR size() TO lc.
        RETURN lc.
    END METHOD.

END CLASS.
