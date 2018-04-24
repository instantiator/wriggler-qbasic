DECLARE FUNCTION rx (vx)
DECLARE FUNCTION ry (vy)
DECLARE FUNCTION SizeAPic (fl, fr, ft, fb)

COMMON SHARED sl%, sr%, st%, sb%, sw%, sh%, scrw%, scrh%

SCREEN 13

GOSUB Init
GOSUB LoadUp

GOSUB Editor

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
RETURN

'********************************* LOADUP ***********************************
LoadUp:
 
   OPEN "map.dat" FOR INPUT AS #1
      INPUT #1, rooms
      REDIM SHARED room(200) AS roomtype
   
      FOR R = 1 TO rooms
         INPUT #1, room(R).left
         INPUT #1, room(R).top
         INPUT #1, room(R).right
         INPUT #1, room(R).bottom
      NEXT

      INPUT #1, gcx%, gcy%
      gw = sw% / gcx%
      gh = sh% / gcy%

      REDIM SHARED wallmap%(200, gcx%, gcy%)
      wallimages = 0

      FOR R = 1 TO rooms
         FOR y = 1 TO gcy%
            FOR x = 1 TO gcx%
               INPUT #1, wallmap%(R, x, y)
               IF wallmap%(R, x, y) > wallimages THEN
                  wallimages = wallmap%(R, x, y)
               END IF
            NEXT
         NEXT
      NEXT

      INPUT #1, objects
      REDIM SHARED obj(200) AS ObjectType
      ObjectImages = 0

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
         tgtx = obj(o).behave.target.x
         tgty = obj(o).behave.target.y
         origx = obj(o).behave.orig.x
         origy = obj(o).behave.orig.y
         IF obj(o).behave.movement = 1 THEN
            obj(o).behave.spd.x = (tgtx - origx) / obj(o).behave.time
            obj(o).behave.spd.y = (tgty - origy) / obj(o).behave.time
         END IF
         obj(o).behave.countime = obj(o).behave.time
         IF obj(o).img > ObjectImages THEN
            ObjectImages = obj(o).img
         END IF
      NEXT

      TYPE TeleType
         start AS INTEGER
         finishroom AS INTEGER
         finish AS xy
      END TYPE

      INPUT #1, teleports
      REDIM teleport(teleports)  AS TeleType
      FOR t = 1 TO teleports
         INPUT #1, teleport(t).start
         INPUT #1, teleport(t).finishroom
         INPUT #1, teleport(t).finish.x
         INPUT #1, teleport(t).finish.y
      NEXT


   CLOSE #1

   PRINT "Currently, there are "; ObjectImages; " Object-Images."
   INPUT "Type a new, highest, image-number:"; NewObjectImages
   IF NewObjectImages > ObjectImages THEN ObjectImages = NewObjectImages


   WormFrames = 2
   picfile$ = "WORM1.PIC": fun$ = "SCALEFACTOR"
   sfx = 1: sfy = 1: GOSUB LoadPic
   wormysize = size%
   size% = size% * WormFrames
   REDIM SHARED wormy(size%)
   GET (fl, ft)-(fr, fb), wormy(0)
   PUT (fl, ft), wormy(0)
   FOR w = 2 TO WormFrames
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

   '>>>>
   wallimages = 18
   '>>>>

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
   FOR o = 1 TO ObjectImages
      picfile$ = "OBJ" + LTRIM$(STR$(o)) + ".PIC"
      fun$ = "SCALEFACTOR": sfx = 1: sfy = 1: GOSUB LoadPic
      ObjectImageDetails(o).index = objectysize
      ObjectImageDetails(o).w = fw
      ObjectImageDetails(o).h = fh
      objectysize = objectysize + size%
      LINE (fl, ft)-(fr, fb), 0, BF
   NEXT
   REDIM SHARED objecty(objectysize)
   FOR o = 1 TO ObjectImages
      picfile$ = "OBJ" + LTRIM$(STR$(o)) + ".PIC"
      GOSUB LoadPic
      GET (fl, ft)-(fr, fb), objecty(ObjectImageDetails(o).index)
      PUT (fl, ft), objecty(ObjectImageDetails(o).index), XOR
      'LINE (fl, ft)-(fr, fb), 0, BF
   NEXT
   FOR o = 1 TO objects
      obj(o).index = ObjectImageDetails(obj(o).img).index
      obj(o).w = ObjectImageDetails(obj(o).img).w
      obj(o).h = ObjectImageDetails(obj(o).img).h
   NEXT
RETURN

'********************************* SAVEDOWN *********************************
SaveDown:

   SHELL "copy map.dat map.bak"

   OPEN "map.dat" FOR OUTPUT AS #1
      PRINT #1, rooms
     
      FOR R = 1 TO rooms
         PRINT #1, room(R).left
         PRINT #1, room(R).top
         PRINT #1, room(R).right
         PRINT #1, room(R).bottom
      NEXT

      PRINT #1, gcx%, gcy%

      FOR R = 1 TO rooms
         FOR y = 1 TO gcy%
            FOR x = 1 TO gcx%
               PRINT #1, wallmap%(R, x, y)
            NEXT
         NEXT
      NEXT

      PRINT #1, objects

      FOR o = 1 TO objects
         PRINT #1, obj(o).p.x
         PRINT #1, obj(o).p.y
         PRINT #1, obj(o).room
         PRINT #1, obj(o).img
         PRINT #1, obj(o).behave.movement
         PRINT #1, obj(o).behave.orig.x
         PRINT #1, obj(o).behave.orig.y
         PRINT #1, obj(o).behave.target.x
         PRINT #1, obj(o).behave.target.y
         PRINT #1, obj(o).behave.time
         PRINT #1, obj(o).behave.nrg
      NEXT

      PRINT #1, teleports
      
      FOR t = 1 TO teleports
         PRINT #1, teleport(t).start
         PRINT #1, teleport(t).finishroom
         PRINT #1, teleport(t).finish.x
         PRINT #1, teleport(t).finish.y
      NEXT


   CLOSE #1
RETURN

'********************************* NEWGAME **********************************
NewGame:
   room = 1
   dead = NO%

   FOR p = 1 TO 2
      w(p).p.x = 50
      w(p).p.y = p * 33
      w(p).nrg = 100
      w(p).room = 1
   NEXT
RETURN

'********************************** MAINGAME ********************************
Editor:
   GOSUB NewGame
   GOSUB DrawScreen

   DO

      GOSUB RoomFade
      FOR o = 1 TO objects
         IF obj(o).room = room THEN
            IF obj(o).behave.movement = 1 THEN
               obj(o).p.x = obj(o).behave.orig.x
               obj(o).p.y = obj(o).behave.orig.y
               tgtx = obj(o).behave.target.x
               tgty = obj(o).behave.target.y
               origx = obj(o).behave.orig.x
               origy = obj(o).behave.orig.y
               obj(o).behave.spd.x = (tgtx - origx) / obj(o).behave.time
               obj(o).behave.spd.y = (tgty - origy) / obj(o).behave.time
               obj(o).behave.countime = obj(o).behave.time
            END IF
         END IF
      NEXT
      GOSUB DrawRoom
      QuitRoom = NO%
      'GOSUB DrawEditGrid
 
      ex = INT(gcx% / 2)
      ey = INT(gcy% / 2)

      DO

         ebc = 99: GOSUB DrawEditBox
         k$ = INKEY$
         SELECT CASE k$
            CASE "e"
               dead = YES%
            CASE "s"
               GOSUB SaveDown
            CASE "r"
               QuitRoom = YES%
               newroom = room(room).right
            CASE "R"
               LOCATE 1, 1: PRINT "Right: "; room(room).right;
               INPUT " New:"; room(room).right
               GOSUB wipeline
            CASE "l"
               QuitRoom = YES%
               newroom = room(room).left
            CASE "L"
               LOCATE 1, 1: PRINT "Left: "; room(room).left;
               INPUT " New:"; room(room).left
               GOSUB wipeline
            CASE "u"
               QuitRoom = YES%
               newroom = room(room).top
            CASE "U"
               LOCATE 1, 1: PRINT "Up: "; room(room).top;
               INPUT " New:"; room(room).top
               GOSUB wipeline
            CASE "d"
               QuitRoom = YES%
               newroom = room(room).bottom
            CASE "D"
               LOCATE 1, 1: PRINT "Down: "; room(room).bottom;
               INPUT " New:"; room(room).bottom
               GOSUB wipeline
            CASE "x"
               ebc = 100: GOSUB DrawEditBox
               ex = ex + 1
            CASE "z"
               ebc = 100: GOSUB DrawEditBox
               ex = ex - 1
            CASE "t"
               LOCATE 1, 1
               teleports = teleports + 1
               INPUT "StartObject:"; teleport(teleports).start
               GOSUB wipeline
               LOCATE 1, 1
               INPUT "Finish room:"; teleport(teleports).finishroom
               GOSUB wipeline
               LOCATE 1, 1
               INPUT "Finish x,y:"; teleport(teleports).finish.x, teleport(teleports).finish.y
               GOSUB wipeline
               LOCATE 1, 1
               PRINT "Teleport: "; teleports; " set."
            CASE ";"
               ebc = 100: GOSUB DrawEditBox
               ey = ey - 1
            CASE "."
               ebc = 100: GOSUB DrawEditBox
               ey = ey + 1
            CASE " "
               LOCATE 1, 1
               INPUT "Wall"; newwall
               GOSUB wipeline
               wallmap%(room, ex, ey) = newwall
              
               imgl = sl% + (gw * (ex - 1))
               imgt = st% + (gh * (ey - 1))
               SELECT CASE newwall
                  CASE 0
                     imgr = imgl + gw
                     imgb = imgt + gh
                     LINE (imgl, imgt)-(imgr, imgb), 0, BF
                  CASE ELSE
                  imgindex = wallsize * (newwall - 1)
                  PUT (imgl, imgt), wally(imgindex), PSET
               END SELECT
            CASE "n"
               LOCATE 1, 1
               rooms = rooms + 1
               FOR x = 1 TO gcx%
                  FOR y = 1 TO gcy%
                     wallmap%(rooms, x, y) = 0
                     room(rooms).right = rooms
                     room(rooms).left = rooms
                     room(rooms).top = rooms
                     room(rooms).bottom = rooms
                  NEXT
               NEXT
               newroom = rooms
               QuitRoom = YES%
            CASE "o"
            objects = objects + 1
            LOCATE 1, 1: PRINT "Object: "; objects; " Location ..."
            GOSUB FindPlace
            obj(objects).p.x = fx: obj(objects).p.y = fy
            GOSUB wipeline
            LOCATE 1, 1: PRINT "Object: "; objects;
            INPUT "Image"; obj(objects).img
            obj(objects).index = ObjectImageDetails(obj(objects).img).index
            obj(objects).w = ObjectImageDetails(obj(objects).img).w
            obj(objects).h = ObjectImageDetails(obj(objects).img).h
            GOSUB wipeline
            LOCATE 1, 1: PRINT "Object: "; objects;
            INPUT "Movement Type"; obj(objects).behave.movement
            GOSUB wipeline
            IF obj(objects).behave.movement = 1 THEN
               obj(objects).behave.orig.x = obj(objects).p.x
               obj(objects).behave.orig.y = obj(objects).p.y
               LOCATE 1, 1: PRINT "Object: "; objects; " Target Position ..."
               GOSUB FindPlace
               obj(objects).behave.target.x = fx
               obj(objects).behave.target.y = fy
               GOSUB wipeline
               LOCATE 1, 1: INPUT "Frames for Movement: "; obj(objects).behave.time
               GOSUB wipeline
               tgtx = obj(objects).behave.target.x
               tgty = obj(objects).behave.target.y
               origx = obj(objects).behave.orig.x
               origy = obj(objects).behave.orig.y
               obj(objects).behave.spd.x = (tgtx - origx) / obj(objects).behave.time
               obj(objects).behave.spd.y = (tgty - origy) / obj(objects).behave.time
               obj(objects).behave.countime = obj(objects).behave.time
            END IF
            LOCATE 1, 1: INPUT "Energy effect: "; obj(objects).behave.nrg
            GOSUB wipeline
            obj(objects).room = room
            LOCATE 1, 1: PRINT "Object "; objects; " created."
            o = objects: GOSUB PutObject
           CASE "-"
            objects = objects - 1
            LOCATE 1, 1
            PRINT "Object: "; objects + 1; " removed."

         END SELECT

         FOR o = 1 TO objects
            IF obj(o).room = room THEN GOSUB MoveObject
         NEXT

         FOR delay = 0 TO dely * 5: NEXT

      LOOP UNTIL QuitRoom = YES% OR dead = YES%

      IF QuitRoom = YES% THEN
         room = newroom
      END IF

   LOOP UNTIL dead = YES%

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

   LOCATE 1, 33: PRINT "Room:"; room

   GOSUB DrawWalls
   GOSUB DrawWorms
   GOSUB DrawObjects
RETURN

DrawWalls:
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

DrawEditGrid:
   FOR ey = 1 TO gcy%
      FOR ex = 1 TO gcx%
         ebc = 0: GOSUB DrawEditBox
      NEXT
   NEXT
RETURN

DrawEditBox:
   ebl = sl% + (gw * (ex - 1))
   ebt = st% + (gh * (ey - 1))
   ebr = ebl + gw
   ebb = ebt + gh
   SELECT CASE ebc
      CASE 99
         ebc = INT(RND * 16)
         LINE (ebl, ebt)-(ebr, ebb), ebc, B
      CASE 100
         IF wallmap%(room, ex, ey) > 0 THEN
            imgindex = wallsize * (wallmap%(room, ex, ey) - 1)
            PUT (ebl, ebt), wally(imgindex), PSET
         ELSE
            LINE (ebl, ebt)-(ebr, ebb), 0, B
         END IF
      CASE ELSE
         LINE (ebl, ebt)-(ebr, ebb), ebc, B
   END SELECT
RETURN

wipeline:
   LOCATE 1, 1: PRINT SPACE$(31);
RETURN

FindPlace:

   fx = 50: fy = 50

   DO
      vx = fx: vy = fy
      chx = rx(vx)
      chy = ry(vy)
      LINE (chx - 5, chy)-(chx + 5, chy), 15
      LINE (chx, chy - 5)-(chx, chy + 5), 15

      DO: a$ = INKEY$: LOOP WHILE a$ = ""

      LINE (chx - 5, chy)-(chx + 5, chy), 0
      LINE (chx, chy - 5)-(chx, chy + 5), 0

      SELECT CASE a$
         CASE "z"
            fx = fx - 1
         CASE "x"
            fx = fx + 1
         CASE ";"
            fy = fy - 1
         CASE "."
            fy = fy + 1
         CASE "Z"
            fx = fx - 10
         CASE "X"
            fx = fx + 10
         CASE ":"
            fy = fy - 10
         CASE ">"
            fy = fy + 10
      END SELECT

   LOOP UNTIL a$ = "o"

   GOSUB DrawWalls
      LINE (chx - 5, chy)-(chx + 5, chy), 14
      LINE (chx, chy - 5)-(chx, chy + 5), 14

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

