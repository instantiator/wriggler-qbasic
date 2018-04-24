DECLARE FUNCTION rx (vx)
DECLARE FUNCTION ry (vy)
DECLARE FUNCTION SizeAPic (fl, fr, ft, fb)

COMMON SHARED sl%, sr%, st%, sb%, sw%, sh%, scrw%, scrh%

SCREEN 13
PALETTE 6, &H202001
PALETTE 14, &H303001

GOSUB Init
GOSUB LoadUp

GOSUB MainGame

END

'********************************* INIT *************************************
Init:
  
   scrw% = 319
   scrh% = 199

   dely = 20

   TYPE xy
      x AS SINGLE
      y AS SINGLE
   END TYPE

   TYPE WrigglerType
      p AS xy
      nrg AS INTEGER
      v AS xy
      score AS INTEGER
      w AS INTEGER
      h AS INTEGER
      room AS INTEGER
      frame AS SINGLE
   END TYPE

   TYPE BehaviourType
      movement AS INTEGER
      nrg AS INTEGER
      time AS INTEGER
      countime AS INTEGER
      spd AS xy
      orig AS xy
      target AS xy
   END TYPE

   TYPE ObjectType
      p AS xy
      w AS INTEGER
      h AS INTEGER
      img AS INTEGER
      behave AS BehaviourType
      room AS INTEGER
      index AS INTEGER
   END TYPE

   TYPE roomtype
      left AS INTEGER
      right AS INTEGER
      top AS INTEGER
      bottom AS INTEGER
   END TYPE

   CONST YES% = 1
   CONST NO% = 0

   REDIM w(2) AS WrigglerType

   sl% = 6: sr% = scrw% - sl%
   st% = 17: sb% = scrh% - 6

   sw% = sr% - sl%
   sh% = sb% - st%

   spd = 1

   tune$ = "CDEDCDECC"
RETURN

'********************************* LOADUP ***********************************
LoadUp:
 
   OPEN "map.dat" FOR INPUT AS #1
      INPUT #1, rooms
      REDIM SHARED room(rooms) AS roomtype
   
      FOR r = 1 TO rooms
         INPUT #1, room(r).left
         INPUT #1, room(r).top
         INPUT #1, room(r).right
         INPUT #1, room(r).bottom
      NEXT

      INPUT #1, gcx%, gcy%
      gw = sw% / gcx%
      gh = sh% / gcy%

      REDIM SHARED wallmap%(rooms, gcx%, gcy%)
      wallimages = 0

      FOR r = 1 TO rooms
         FOR y = 1 TO gcy%
            FOR x = 1 TO gcx%
               INPUT #1, wallmap%(r, x, y)
               IF wallmap%(r, x, y) > wallimages THEN
                  wallimages = wallmap%(r, x, y)
               END IF
            NEXT
         NEXT
      NEXT

      INPUT #1, objects
      REDIM SHARED obj(objects) AS ObjectType
      objectimages = 0

      FOR o = 1 TO objects
         INPUT #1, obj(o).p.x
         INPUT #1, obj(o).p.y
         INPUT #1, obj(o).room
         INPUT #1, obj(o).img
         INPUT #1, obj(o).behave.movement
         INPUT #1, obj(o).behave.orig.x
         INPUT #1, obj(o).behave.orig.y
         INPUT #1, obj(o).behave.target.x
         INPUT #1, obj(o).behave.target.y
         INPUT #1, obj(o).behave.time
         INPUT #1, obj(o).behave.nrg
        
         SELECT CASE obj(o).behave.movement
            CASE 1
               origx = obj(o).behave.orig.x
               origy = obj(o).behave.orig.y
               tgtx = obj(o).behave.target.x
               tgty = obj(o).behave.target.y
               obj(o).behave.spd.x = (tgtx - origx) / obj(o).behave.time
               obj(o).behave.spd.y = (tgty - origy) / obj(o).behave.time
               obj(o).behave.countime = obj(o).behave.time
         END SELECT

         IF obj(o).img > objectimages THEN
            objectimages = obj(o).img
         END IF
      NEXT

      TYPE TeleType
         start AS INTEGER
         finishroom AS INTEGER
         finish AS xy
      END TYPE

'      INPUT #1, teleports
'      REDIM teleport(teleports)  AS TeleType
'      FOR t = 1 TO teleports
'         INPUT #1, teleport(t).start
'         INPUT #1, teleport(t).finishroom
'         INPUT #1, teleport(t).finish.x
'         INPUT #1, teleport(t).finish.y
'      NEXT


   CLOSE #1

   wormframes = 2
   picfile$ = "WORM1.PIC": fun$ = "SCALEFACTOR"
   sfx = 1: sfy = 1: GOSUB LoadPic
   wormysize = size%
   size% = size% * wormframes
   REDIM SHARED wormy(size%)
   GET (fl, ft)-(fr, fb), wormy(0)
   PUT (fl, ft), wormy(0)
   FOR w = 2 TO wormframes
      picfile$ = "WORM" + LTRIM$(STR$(w)) + ".PIC"
      GOSUB LoadPic
      GET (fl, ft)-(fr, fb), wormy(wormysize * (w - 1))
      PUT (fl, ft), wormy(wormysize * (w - 1))
   NEXT
   FOR p = 1 TO 2
      w(p).w = fw
      w(p).h = fh
      w(p).frame = 1
   NEXT

   fl = 0: fr = gw
   ft = 0: fb = gh

   wallsize = SizeAPic(fl, fr, ft, fb)
   REDIM SHARED wally(wallsize * wallimages)
   FOR w = 1 TO wallimages
      picfile$ = "WALL" + LTRIM$(STR$(w)) + ".PIC"
      fl = 0: fr = gw: ft = 0: fb = gh
      fun$ = "SETSIZE": GOSUB LoadPic
      GET (fl, ft)-(fr, fb), wally((w - 1) * wallsize)
      PUT (fl, ft), wally((w - 1) * wallsize), XOR
   NEXT

   TYPE ObjectLeftoverType
      w AS INTEGER
      h AS INTEGER
      index AS INTEGER
   END TYPE
 
   REDIM ObjectImageDetails(200) AS ObjectLeftoverType
   objectysize = 0
   FOR o = 1 TO objectimages
      picfile$ = "OBJ" + LTRIM$(STR$(o)) + ".PIC"
      fun$ = "SCALEFACTOR": sfx = 1: sfy = 1: GOSUB LoadPic
      ObjectImageDetails(o).index = objectysize
      ObjectImageDetails(o).w = fw
      ObjectImageDetails(o).h = fh
      objectysize = objectysize + size%
      LINE (fl, ft)-(fr, fb), 0, BF
   NEXT
   REDIM SHARED objecty(objectysize)
   FOR o = 1 TO objectimages
      picfile$ = "OBJ" + LTRIM$(STR$(o)) + ".PIC"
      GOSUB LoadPic
      GET (fl, ft)-(fr, fb), objecty(ObjectImageDetails(o).index)
      PUT (fl, ft), objecty(ObjectImageDetails(o).index), XOR
   NEXT
   FOR o = 1 TO objects
      obj(o).index = ObjectImageDetails(obj(o).img).index
      obj(o).w = ObjectImageDetails(obj(o).img).w
      obj(o).h = ObjectImageDetails(obj(o).img).h
   NEXT
RETURN

'********************************* NEWGAME **********************************
NewGame:
   room = 1
   newroom = room
   Dead = NO%

   FOR p = 1 TO 2
      w(p).p.x = 50
      w(p).p.y = p * 33
      w(p).nrg = 100
      w(p).room = room
   NEXT
RETURN

'********************************** MAINGAME ********************************
MainGame:
   GOSUB NewGame
   GOSUB DrawScreen

   LOCATE 15, 14: PRINT "Get Ready ..."
   LOCATE 16, 14: PRINT "<hit any key>"
   DO: z$ = INKEY$: LOOP WHILE z$ = ""
   PLAY "T160O1>L20CDEDCDL10ECC"

   DO
      
      GOSUB RoomFade
      FOR o = 1 TO objects
         IF obj(o).room = room THEN
            IF obj(o).behave.movement = 1 THEN
               obj(o).p.x = obj(o).behave.orig.x
               obj(o).p.y = obj(o).behave.orig.y
               origx = obj(o).behave.orig.x
               origy = obj(o).behave.orig.y
               tgtx = obj(o).behave.target.x
               tgty = obj(o).behave.target.y
               obj(o).behave.spd.x = (tgtx - origx) / obj(o).behave.time
               obj(o).behave.spd.y = (tgty - origy) / obj(o).behave.time
               obj(o).behave.countime = obj(o).behave.time
            END IF
         END IF
      NEXT
      GOSUB DrawRoom
      quitroom = NO%

      DO

         k$ = INKEY$
         SELECT CASE k$
            CASE "e"
               Dead = YES%
            CASE "x"
               w(1).v.x = w(1).v.x + spd
               IF w(1).v.x > spd THEN w(1).v.x = spd
            CASE "z"
               w(1).v.x = w(1).v.x - spd
               IF w(1).v.x < -spd THEN w(1).v.x = -spd
            CASE ";"
               w(1).v.y = w(1).v.y - spd
               IF w(1).v.y < -spd THEN w(1).v.y = -spd
            CASE "."
               w(1).v.y = w(1).v.y + spd
               IF w(1).v.y > spd THEN w(1).v.y = spd
         END SELECT
        
         IF room = newroom THEN
            FOR p = 1 TO 2
               IF w(p).room = room THEN
                  GOSUB MoveWorm
               END IF
            NEXT

            FOR o = 1 TO objects
               IF obj(o).room = room THEN GOSUB MoveObject
            NEXT
         END IF


      LOOP UNTIL quitroom = YES% OR Dead = YES%

      p = 1: GOSUB PutWorm
     
      IF quitroom = YES% THEN
         GOSUB WormToOtherSide
         room = newroom
      END IF


   LOOP UNTIL Dead = YES%

RETURN

'********************************** DRAWOBJECTS *****************************
DrawObjects:
   FOR o = 1 TO objects
      IF obj(o).room = room THEN
         GOSUB PutObject
      END IF
   NEXT
RETURN

'********************************** DRAWROOM ********************************
DrawRoom:
   FOR p = 1 TO 2
      GOSUB PercentBar
   NEXT

   FOR drawx = 1 TO gcx%
      FOR drawy = 1 TO gcy%
         img = wallmap%(room, drawx, drawy)
         IF img > 0 THEN
            imgindex = wallsize * (img - 1)
            imgl = sl% + (gw * (drawx - 1))
            imgt = st% + (gh * (drawy - 1))
            PUT (imgl, imgt), wally(imgindex), PSET
         END IF
      NEXT
   NEXT

   GOSUB DrawWorms
   GOSUB DrawObjects
RETURN

'********************************* DRAWSCREEN *******************************
DrawScreen:
   LINE (0, 0)-(scrw%, scrh%), 7, BF
   LINE (0, 0)-(scrw%, scrh%), 15, B
   LINE (scrw%, 0)-(scrw%, scrh%), 8
   LINE (scrw%, scrh%)-(0, scrh%), 8
   PSET (scrw%, 0), 7
   PSET (0, scrh%), 7
  
   LINE (sl% - 1, sb% + 1)-(sl% - 1, st% - 1), 8
   LINE (sl% - 1, st% - 1)-(sr% + 1, st% - 1), 8
   LINE (sl% - 1, sb% + 1)-(sr% + 1, sb% + 1), 15
   LINE (sr% + 1, sb% + 1)-(sr% + 1, st% - 1), 15
   PSET (sl% - 1, sb% + 1), 7
   PSET (sr% + 1, st% - 1), 7
   LINE (sl%, st%)-(sr%, sb%), 0, BF
RETURN

'********************************** DRAWWORMS *******************************
DrawWorms:
   FOR p = 1 TO 2
      IF w(p).room = room THEN
         GOSUB PutWorm
      END IF
   NEXT
RETURN

'******************************** PUTOBJECT *********************************
PutObject:
   vx = obj(o).p.x: vy = obj(o).p.y
   px = rx(vx) - (obj(o).w / 2)
   py = ry(vy) - (obj(o).h / 2)
   PUT (px, py), objecty(obj(o).index), XOR
RETURN

'********************************* PUTWORM **********************************
PutWorm:
   windex = (INT(w(p).frame) - 1) * wormysize
   vx = w(p).p.x: vy = w(p).p.y
   px = rx(vx) - (w(p).w / 2)
   py = ry(vy) - (w(p).h / 2)
   PUT (px, py), wormy(windex), XOR
RETURN

'********************************* ROOMFADE *********************************
RoomFade:
   FOR fadey = 0 TO sh% / 2
      LINE (sl%, st% + fadey)-(sr%, st% + fadey), 0
      LINE (sl%, sb% - fadey)-(sr%, sb% - fadey), 0
      FOR delay = 0 TO dely: NEXT
   NEXT
RETURN

'******************************** PERCENTBAR ********************************
PercentBar:                          'INPUT: pl, pr, pt, pb, pfc, pbc, p
   GOSUB PercentPosition
   LINE (pl + 1, pt + 1)-(pr - 1, pb - 1), pbc, BF
   LINE (pl + 1, pt + 1)-(1 + pl + ((pw / 100) * pc), pb - 1), pfc, BF
   LINE (pl, pt)-(pr, pb), 8, B
   LINE (pl, pt)-(pl, pb), 15
   LINE (pl, pb)-(pr, pb), 15
   PSET (pl, pt), 7
   PSET (pr, pb), 7
RETURN

PercentPosition:
   pt = 5: pb = 11
   pfc = 10: pbc = 4
   SELECT CASE p
      CASE 1
         pl = 5: pr = (scrw% / 2) - 2.5
      CASE 2
         pl = (scrw% / 2) + 2.5: pr = scrw% - 5
   END SELECT
   pc = w(p).nrg
   IF pc < 0 THEN pc = 0
   IF pc > 100 THEN pc = 100
   pw = pr - pl - 2: ph = pb - pt
RETURN

UpPercentBar:
   GOSUB PercentPosition
   LINE (pl + 1, pt + 1)-(1 + pl + ((pw / 100) * pc), pb - 1), pfc, BF
   PLAY "MBO0L16>CCCE"
RETURN

ReducePercentBar:
   GOSUB PercentPosition
   LINE (pr - 1, pt + 1)-(1 + pl + ((pw / 100) * pc), pb - 1), pbc, BF
   IF p = 1 AND pc < 1 THEN Dead = YES%

   '37 through 32, 767
   rangelow = 200: rangehigh = 1000
   rangediff = rangehigh - rangelow
   pitch = INT(rangelow + ((rangediff / 100) * pc))
   SOUND pitch, 1
RETURN

'********************************** LOADPIC *********************************
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
  
     DO
        INPUT #1, op$
        INPUT #1, x1, y1
        INPUT #1, x2, y2
        INPUT #1, c

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

        SELECT CASE op$
           CASE "LINE"
              LINE (x1, y1)-(x2, y2), c
         
           CASE "BOX"
              LINE (x1, y1)-(x2, y2), c, B
         
           CASE "BOXFILL"
              LINE (x1, y1)-(x2, y2), c, BF
     
        END SELECT
     LOOP UNTIL EOF(1) <> NO%
   CLOSE #1

   size% = 4 + INT(((PMAP(fr, 0) - PMAP(fl, 0) + 1) * (8) + 7) / 8) * 1 * (PMAP(fb, 1) - PMAP(ft, 1) + 1)
   fw = fr - fl
   fh = fb - ft

RETURN

'********************************* MOVEWORM *********************************
MoveWorm:
   CanGo = YES%
   IF p = 1 THEN
      vx = w(p).p.x + w(p).v.x
      vy = w(p).p.y + w(p).v.y
      checkx% = rx(vx)
      checky% = ry(vy)
      checkw% = w(p).w: checkh% = w(p).h
      chkroom% = room
      GOSUB CheckPlaces
   END IF

   IF CanGo% = YES% THEN
      IF w(p).v.x <> 0 OR w(p).v.y <> 0 THEN
         GOSUB PutWorm
         w(p).p.x = w(p).p.x + w(p).v.x
         w(p).p.y = w(p).p.y + w(p).v.y
         w(p).frame = w(p).frame + .2
         IF w(p).frame > wormframes + .8 THEN w(p).frame = 1
         GOSUB PutWorm
      END IF
   ELSE
      'w(p).v.x = 0
      'w(p).v.y = 0
   END IF
RETURN

'******************************** CHECKPLACES *******************************
CheckPlaces:
   CanGo% = YES%
   chkbl% = checkx% - (checkw% / 2)
   chkbr% = checkx% + (checkw% / 2)
   chkbt% = checky% - (checkh% / 2)
   chkbb% = checky% + (checkh% / 2)

   FOR chkx% = 1 TO gcx%
      FOR chky% = 1 TO gcy%
         thewall% = wallmap%(chkroom%, chkx%, chky%)
         IF thewall% > 0 AND thewall% <> 16 AND thewall% <> 17 THEN
            wbl% = sl% + (gw * (chkx% - 1))
            wbr% = sl% + (gw * chkx%)
            wbt% = st% + (gh * (chky% - 1))
            wbb% = st% + (gh * chky%)

            CanGoX% = YES%: CanGoY% = YES%
            IF wbl% < chkbr% AND wbl% > chkbl% THEN CanGoX% = NO%
            IF wbr% < chkbr% AND wbr% > chkbl% THEN CanGoX% = NO%
            IF wbt% < chkbb% AND wbt% > chkbt% THEN CanGoY% = NO%
            IF wbb% < chkbb% AND wbb% > chkbt% THEN CanGoY% = NO%
            IF chkbl% > wbl% AND chkbl% < wbr% THEN CanGoX% = NO%
            IF chkbr% > wbl% AND chkbr% < wbr% THEN CanGoX% = NO%
            IF chkbt% > wbt% AND chkbt% < wbb% THEN CanGoY% = NO%
            IF chkbb% > wbt% AND chkbb% < wbb% THEN CanGoY% = NO%
            IF CanGoX% = NO% AND CanGoY% = NO% THEN CanGo% = NO%
            IF CanGo% = NO% THEN
               w(p).v.x = 0: w(p).v.y = 0
               SELECT CASE thewall%
                  CASE IS > 50
                     w(p).nrg = w(p).nrg - 1
                     GOSUB ReducePercentBar
                  CASE 15
                     CanGo% = YES%
                     wallmap%(chkroom%, chkx%, chky%) = 0
                     GOSUB PutWorm
                     LINE (wbl%, wbt%)-(wbr%, wbb%), 0, BF
                     GOSUB PutWorm
                     PLAY "MBO0L32EFGEFDC"
               END SELECT
            END IF
         END IF
         IF CanGo% = NO% THEN EXIT FOR
      NEXT
      IF CanGo% = NO% THEN EXIT FOR
   NEXT

   FOR o = 1 TO objects
      IF obj(o).room = w(p).room THEN
         Contact% = NO%
         ContactX% = NO%: ContactY% = NO%
         vx = obj(o).p.x: vy = obj(o).p.y
         obl% = rx(vx) - (obj(o).w / 2)
         obt% = ry(vy) - (obj(o).h / 2)
         obr% = obl% + obj(o).w
         obb% = obt% + obj(o).h
         IF obl% > chkbl% AND obl% < chkbr% THEN ContactX% = YES%
         IF obr% > chkbl% AND obr% < chkbr% THEN ContactX% = YES%
         IF obt% > chkbt% AND obt% < chkbb% THEN ContactY% = YES%
         IF obb% > chkbt% AND obb% < chkbb% THEN ContactY% = YES%
         IF chkbl% > obl% AND chkbl% < obr% THEN ContactX% = YES%
         IF chkbr% > obl% AND chkbr% < obr% THEN ContactX% = YES%
         IF chkbt% > obt% AND chkbt% < obb% THEN ContactY% = YES%
         IF chkbb% > obt% AND chkbb% < obb% THEN ContactY% = YES%
         IF ContactX% = YES% AND ContactY% = YES% THEN Contact% = YES%
         IF Contact% = YES% THEN
         w(p).nrg = w(p).nrg + obj(o).behave.nrg
         IF w(p).nrg > 100 THEN w(p).nrg = 100
         IF w(p).nrg < 0 THEN w(p).nrg = 0
            SELECT CASE obj(o).behave.nrg
               CASE 0
                  CanGo% = NO%
                  w(p).v.x = 0: w(p).v.y = 0
               CASE IS > 0
                  obj(o).room = 0
                  GOSUB PutObject
                  GOSUB UpPercentBar
               CASE IS < 0
                  GOSUB ReducePercentBar
            END SELECT
            IF obj(o).img > 2 AND obj(o).img < 6 THEN
               CanGo% = NO%
               w(p).v.y = -spd
               SELECT CASE obj(o).img
                  CASE 3
                     PLAY "T160O1>L20C"
                     playd$ = playd$ + "C"
                  CASE 4
                     PLAY "T160O1>L20D"
                     playd$ = playd$ + "D"
                  CASE 5
                     PLAY "T160O1>L20E"
                     playd$ = playd$ + "E"
               END SELECT
               IF LEN(playd$) >= 9 AND RIGHT$(playd$, 9) = tune$ THEN
                  PLAY "T160O1>L20CDEDCDL10ECC"
                  FOR rm = 1 TO rooms
                     FOR rdx = 1 TO gcx%
                        FOR rdy = 1 TO gcy%
                           IF wallmap%(rm, rdx, rdy) = 18 THEN
                              wallmap%(rm, rdx, rdy) = 0
                           END IF
                        NEXT
                     NEXT
                  NEXT
                  playd$ = ""
               END IF
            END IF
         END IF
      END IF
   NEXT
  
   IF p = 1 THEN
      IF chkbr% > sr% THEN
         quitroom = YES%: newroom = room(room).right
         w(p).room = newroom
      END IF

      IF chkbl% < sl% THEN
         quitroom = YES%: newroom = room(room).left
         w(p).room = newroom
      END IF

      IF chkbt% < st% THEN
         quitroom = YES%: newroom = room(room).top
         w(p).room = newroom
      END IF

      IF chkbb% > sb% THEN
         quitroom = YES%: newroom = room(room).bottom
         w(p).room = newroom
      END IF
   END IF

RETURN

'********************************* MOVEOBJECT *******************************
MoveObject:
   SELECT CASE obj(o).behave.movement
      CASE 1
         GOSUB PutObject
         origx = obj(o).behave.orig.x
         origy = obj(o).behave.orig.y
         tgtx = obj(o).behave.target.x
         tgty = obj(o).behave.target.y
         IF obj(o).behave.countime = 0 THEN
            obj(o).behave.spd.x = obj(o).behave.spd.x * -1
            obj(o).behave.spd.y = obj(o).behave.spd.y * -1
            obj(o).behave.countime = obj(o).behave.time
         END IF
         obj(o).behave.countime = obj(o).behave.countime - 1
         obj(o).p.x = obj(o).p.x + obj(o).behave.spd.x
         obj(o).p.y = obj(o).p.y + obj(o).behave.spd.y
         GOSUB PutObject
   END SELECT
RETURN

'******************************* WORM TO OTHER SIDE *************************
WormToOtherSide:
   SELECT CASE newroom
      CASE room(room).right
         vw = (100 / sw%) * w(1).w
         w(1).p.x = vw / 2
      CASE room(room).left
         vw = (100 / sw%) * w(1).w
         w(1).p.x = 100 - (vw / 2)
      CASE room(room).top
         vh = (100 / sh%) * w(1).h
         w(1).p.y = 100 - (vh / 2)
      CASE room(room).bottom
         vh = (100 / sh%) * w(1).h
         w(1).p.y = vh / 2
   END SELECT
RETURN

FUNCTION rx (vx)
   rx = sl% + ((sw% / 100) * vx)
END FUNCTION

FUNCTION ry (vy)
   ry = st% + ((sh% / 100) * vy)
END FUNCTION

FUNCTION SizeAPic (fl, fr, ft, fb)
   size% = 4 + INT(((PMAP(fr, 0) - PMAP(fl, 0) + 1) * (8) + 7) / 8) * 1 * (PMAP(fb, 1) - PMAP(ft, 1) + 1)
   SizeAPic = size%
END FUNCTION

