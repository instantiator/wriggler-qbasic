SCREEN 13
scrw% = 320: scrh% = 200

GOSUB Init
GOSUB NewImage
GOSUB MainEditor

END

'********************************** INIT ************************************
Init:
   TYPE partype
      op AS STRING * 10
      x1 AS SINGLE
      y1 AS SINGLE
      x2 AS SINGLE
      y2 AS SINGLE
      c AS INTEGER
   END TYPE

   maxparts = 200
   REDIM part(maxparts) AS partype
 
   


   CONST NO = 0
   CONST YES = 1

   fun$ = "SCALEFACTOR"
   sfx = 1: sfy = 1
   picfile$ = "CROSS.PIC"
   GOSUB LoadPic
   GOSUB DrawPic
   GOSUB FindSize
   REDIM Crossy(size%)
   GET (fl, ft)-(fr, fb), Crossy
   crossw = fr - fl
   crossh = fb - ft
   PUT (fl, ft), Crossy, XOR
RETURN

'********************************** NEWIMAGE ********************************
NewImage:
   CLS
   PRINT "Function? 1=SETSIZE 2=SCALEFACTOR? ";
   DO: a$ = INKEY$: LOOP UNTIL VAL(a$) > 0 AND VAL(a$) < 3
   fun = VAL(a$)
   SELECT CASE fun
      CASE 1
         fun$ = "SETSIZE"
         fl = 0: ft = 0
         fr = 160: fb = 100
      CASE 2
         fun$ = "SCALEFACTOR"
         sfx = 1: sfy = 1
   END SELECT
   PRINT fun$
   parts = 0
   PRINT "(L)oad or (N)ew? ";
   DO: a$ = INKEY$: LOOP UNTIL a$ = "L" OR a$ = "N"
   PRINT a$
   SELECT CASE a$
      CASE "L"
         INPUT "Filename: "; picfile$
         GOSUB LoadPic
      CASE "N"
         IF fun$ = "SCALEFACTOR" THEN
            fl = 0
            ft = 0
            fr = 160
            fb = 100
         END IF
         picfile$ = "<no filename>"
   END SELECT
  
   imgw = fr - fl
   imgh = fb - ft

   SELECT CASE fun$
      CASE "SETSIZE"
         x = .5
         y = .5
         xd = .01: yd = .01
      CASE "SCALEFACTOR"
         IF imgw = 0 AND imgh = 0 THEN
            x = 20: y = 20
         ELSE
            x = INT(imgw / 2): y = INT(imgh / 2)
         END IF
         xd = 1: yd = 1
   END SELECT
RETURN


'********************************** LOADPIC *********************************
LoadPic:
 
   REDIM part(maxparts) AS partype
  
   OPEN picfile$ FOR INPUT AS #1
      DO
         parts = parts + 1
         INPUT #1, part(parts).op
         INPUT #1, part(parts).x1
         INPUT #1, part(parts).y1
         INPUT #1, part(parts).x2
         INPUT #1, part(parts).y2
         INPUT #1, part(parts).c
      LOOP UNTIL EOF(1) <> NO
   CLOSE #1
RETURN

'********************************* DRAWPIC **********************************
DrawPic:
   CLS
   IF parts = 0 THEN RETURN
   IF fun$ = "SCALEFACTOR" THEN
      fr = 0: fl = scrw%
      ft = scrh%: fb = 0
   END IF

   IF fun$ = "SETSIZE" THEN
      sfx = fr - fl
      sfy = fb - ft
   END IF
  
   FOR n = 1 TO parts
      op$ = part(n).op
      x1 = part(n).x1: y1 = part(n).y1
      x2 = part(n).x2: y2 = part(n).y2
      c = part(n).c
      SELECT CASE fun$
         CASE "SETSIZE"
            x1 = fl + (x1 * sfx)
            x2 = fl + (x2 * sfx)
            y1 = ft + (y1 * sfy)
            y2 = ft + (y2 * sfy)
        
         CASE "SCALEFACTOR"
            x1 = x1 * sfx
            x2 = x2 * sfx
            y1 = y1 * sfy
            y2 = y2 * sfy

            IF x1 < fl THEN fl = x1
            IF x2 < fl THEN fl = x2
            IF x1 > fr THEN fr = x1
            IF x2 > fr THEN fr = x2
            IF y1 < ft THEN ft = y1
            IF y2 < ft THEN ft = y2
            IF y1 > fb THEN fb = y1
            IF y2 > fb THEN fb = y2
      END SELECT

      x1 = x1 + crossw
      x2 = x2 + crossw
      y1 = y1 + crossh
      y2 = y2 + crossh

      SELECT CASE LTRIM$(RTRIM$(op$))
         CASE "LINE"
            LINE (x1, y1)-(x2, y2), c
            
         CASE "BOX"
            LINE (x1, y1)-(x2, y2), c, B
            
         CASE "BOXFILL"
            LINE (x1, y1)-(x2, y2), c, BF
        
      END SELECT
   NEXT

RETURN

FindSize:
   size% = 4 + INT(((PMAP(fr, 0) - PMAP(fl, 0) + 1) * (8) + 7) / 8) * 1 * (PMAP(fb, 1) - PMAP(ft, 1) + 1)
   fw = fr - fl
   fh = fb - ft
RETURN

'******************************** MAINEDITOR ********************************
MainEditor:
   GOSUB DrawPic
   fl = fl + crossw
   fr = fr + crossw
   ft = ft + crossh
   fb = fb + crossh

   LINE (fl - 1, ft - 1)-(fr + 1, fb + 1), 15, B
   c = 15
    
   DO
      GOSUB FindPlace
      SELECT CASE a$
         CASE "N"
            GOSUB NewImage
            GOSUB DrawPic
            fl = fl + crossw
            fr = fr + crossw
            ft = ft + crossh
            fb = fb + crossh
            LINE (fl - 1, ft - 1)-(fr + 1, fb + 1), 15, B

         CASE "L"
            parts = parts + 1
            part(parts).op = "LINE"
            part(parts).x1 = x
            part(parts).y1 = y
            apx1 = apx: apy1 = apy
            DO: GOSUB FindPlace: LOOP UNTIL a$ = " "
            part(parts).x2 = x
            part(parts).y2 = y
            part(parts).c = c
            apx2 = apx: apy2 = apy
            LINE (apx1, apy1)-(apx2, apy2), c
        
         CASE "S"
            parts = parts + 1
            part(parts).op = "BOX"
            part(parts).x1 = x
            part(parts).y1 = y
            apx1 = apx: apy1 = apy
            DO: GOSUB FindPlace: LOOP UNTIL a$ = " "
            part(parts).x2 = x
            part(parts).y2 = y
            part(parts).c = c
            apx2 = apx: apy2 = apy
            LINE (apx1, apy1)-(apx2, apy2), c, B

         CASE "B"
            parts = parts + 1
            part(parts).op = "BOXFILL"
            part(parts).x1 = x
            part(parts).y1 = y
            apx1 = apx: apy1 = apy
            DO: GOSUB FindPlace: LOOP UNTIL a$ = " "
            part(parts).x2 = x
            part(parts).y2 = y
            part(parts).c = c
            apx2 = apx: apy2 = apy
            LINE (apx1, apy1)-(apx2, apy2), c, BF

         CASE "U"
            parts = parts - 1
            GOSUB DrawPic
            'fl = fl + crossw
            'fr = fr + crossw
            'ft = ft + crossh
            'fb = fb + crossh
            LINE (fl - 1, ft - 1)-(fr + 1, fb + 1), 15, B

         CASE "!"
            FOR p = 1 TO parts
               part(p).x1 = part(p).x1 + crossw
               part(p).x2 = part(p).x2 + crossw
               part(p).y1 = part(p).y1 + crossh
               part(p).y2 = part(p).y2 + crossh
            NEXT
            GOSUB DrawPic
            fl = fl + crossw
            fr = fr + crossw
            ft = ft + crossh
            fb = fb + crossh
            LINE (fl - 1, ft - 1)-(fr + 1, fb + 1), 15, B

         CASE "F"
            GOSUB save
            GOSUB DrawPic
            fl = fl + crossw
            fr = fr + crossw
            ft = ft + crossh
            fb = fb + crossh
            LINE (fl - 1, ft - 1)-(fr + 1, fb + 1), 15, B

      END SELECT
   LOOP UNTIL a$ = "Q"

RETURN

Positions:
   SELECT CASE fun$
      CASE "SETSIZE"
         apx = fl + (imgw * x)
         apy = ft + (imgh * y)
      CASE "SCALEFACTOR"
         apx = fl + x
         apy = fl + y
   END SELECT
RETURN

FindPlace:
   LOCATE 1, 1: PRINT fun$; " : "; picfile$
   DO
      GOSUB Positions
      SELECT CASE fun$
         CASE "SETSIZE"
            LOCATE 23, 1: PRINT INT(x * 100), INT(y * 100)
         CASE "SCALEFACTOR"
            LOCATE 23, 1: PRINT x, y
      END SELECT
     
      cm = c - 1
      IF cm = -1 THEN cm = 255
      LINE (270, 130)-(280, 150), cm, BF
      LINE (280, 130)-(300, 150), c, BF
      LINE (300, 130)-(310, 150), (c + 1) MOD 256, BF
      LINE (280, 130)-(300, 150), 15, B
      LOCATE 13, 30: PRINT c

      PUT (apx - (crossw / 2), apy - (crossh / 2)), Crossy, XOR

      DO: a$ = INKEY$: LOOP WHILE a$ = ""

      PUT (apx - (crossw / 2), apy - (crossh / 2)), Crossy, XOR

      SELECT CASE a$
         CASE "z"
            x = x - xd
         CASE "x"
            x = x + xd
         CASE ";"
            y = y - yd
         CASE "."
            y = y + yd
         CASE "Z"
            x = x - (xd * 10)
         CASE "X"
            x = x + (xd * 10)
         CASE ":"
            y = y - (yd * 10)
         CASE ">"
            y = y + (yd * 10)
         CASE "+"
            c = (c + 1) MOD 256
         CASE "-"
            c = c - 1
            IF c < 0 THEN c = 255
         CASE ELSE
            EXIT DO
      END SELECT
   LOOP
RETURN

save:
   LOCATE 1, 1
   PRINT SPACE$(39)
   LOCATE 1, 1
   INPUT "Filename:"; picfile$
   OPEN picfile$ FOR OUTPUT AS #1
      FOR p = 1 TO parts
         PRINT #1, part(p).op
         PRINT #1, part(p).x1
         PRINT #1, part(p).y1
         PRINT #1, part(p).x2
         PRINT #1, part(p).y2
         PRINT #1, part(p).c
      NEXT
   CLOSE #1
RETURN

