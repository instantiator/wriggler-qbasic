   '>>>>
   wallimages = 12
   '>>>>

   'FOR w = 14 TO 15
   w = 4
      picfile$ = "OBJ" + LTRIM$(STR$(w)) + ".PIO"
      outfile$ = "OBJ" + LTRIM$(STR$(w)) + ".PIC"
      fl = 0: fr = gw: ft = 0: fb = gh
      fun$ = "SETSIZE": GOSUB LoadPic
   'NEXT

END

LoadPic:

   IF fun$ = "SCALEFACTOR" THEN
      fr = 0: fl = scrw%
      ft = scrh%: fb = 0
   END IF

   IF fun$ = "SETSIZE" THEN
      sfx = fr - fl
      sfy = fb - ft
   END IF

   OPEN picfile$ FOR INPUT AS #1
   OPEN outfile$ FOR OUTPUT AS #2

     DO
        INPUT #1, op$
        INPUT #1, x1, y1
        INPUT #1, x2, y2
        INPUT #1, c


        PRINT #2, op$
        PRINT #2, x1, y1
        PRINT #2, x2, y2
        SELECT CASE c
         CASE 40
            PRINT #2, 48
         CASE 112
            PRINT #2, 120
         CASE 184
            PRINT #2, 193
         CASE ELSE
            PRINT #2, c
        END SELECT

     LOOP UNTIL EOF(1) <> NO%
   CLOSE #1
   CLOSE #2

RETURN

