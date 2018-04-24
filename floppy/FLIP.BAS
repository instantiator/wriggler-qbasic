SCREEN 0
INPUT "Input file"; picfile$
INPUT "Output file"; outfile$
INPUT "1=FlipX 2=FlipY"; fliptype

OPEN picfile$ FOR INPUT AS #1
OPEN outfile$ FOR OUTPUT AS #2
   DO
      INPUT #1, op$
      INPUT #1, x1
      INPUT #1, y1
      INPUT #1, x2
      INPUT #1, y2
      INPUT #1, c
      SELECT CASE fliptype
         CASE 1
            x1 = 1 - x1
            x2 = 1 - x2
         CASE 2
            y1 = 1 - y1
            y2 = 1 - y2
      END SELECT
      PRINT #2, op$
      PRINT #2, x1
      PRINT #2, y1
      PRINT #2, x2
      PRINT #2, y2
      PRINT #2, c
   LOOP UNTIL EOF(1) <> 0
CLOSE #1
CLOSE #2

