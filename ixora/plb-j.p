/* plb-j.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* pla-j.p
AGA - 26/04/96 - редактирование платежки

*/

DEF SHARED VAR v-nmb LIKE pla.nmb.
DEF SHARED VAR vld AS CHAR.
DEF SHARED FRAME plat.
DEF SHARED FRAME platr.
DEF SHARED VAR g-ofc LIKE ofc.ofc.
DEF SHARED VAR g-today AS DATE.
{plas.f}
{plasr.f}
FIND FIRST cmp NO-LOCK.
FIND FIRST point NO-LOCK.
FIND FIRST sysc WHERE sysc.sysc EQ "CLECOD" NO-LOCK.
FIND FIRST pla WHERE pla.who EQ g-ofc AND pla.lang EQ vld EXCLUSIVE-LOCK.
pla.nmb = "0001".
pla.regdt = g-today.
pla.who = g-ofc.
pla.tim = TIME.
IF vld EQ "r" THEN
pla.ma1 = cmp.name.
ELSE
pla.ma1 = "OАО 'TexaKaBank' ".
IF vld EQ "r" THEN
pla.ma2 = point.regno.
ELSE
pla.ma2 = "Рег. # 600900050984".
IF vld EQ "r" THEN
pla.ba1 = cmp.name.
ELSE
pla.ba1 = "OАО 'TexaKaBank'".
IF vld EQ "r" THEN
pla.ba2 = point.regno.
ELSE
pla.ba2 = "Рег. # 600900050984".
pla.kb2 = sysc.chval.
IF pla.lang EQ "r" THEN
do:
 find crc where crc.crc = 1 no-lock no-error.
  if avail crc then pla.code = crc.code.
end.

ELSE
pla.code = "KZT".
pla.rs2 = "".
pla.summ = 0.
pla.sa1 = "".
pla.sa2 = "".
pla.ba3 = "".
pla.ba4 = "".
pla.kb4 = "".
pla.rs1 = "".
pla.rs3 = "".
pla.rs4 = "".
pla.ve  = "".
pla.me  = "".
pla.ap  = "".
IF vld = "l" THEN
DO:
  VIEW FRAME plat.
  DISP pla.nmb pla.regdt
    pla.ma1 pla.code pla.ma2 pla.rs1 pla.rs2 pla.summ
    pla.ba1 pla.ba2 pla.kb2
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME plat .
  PAUSE 0.

  UPDATE pla.nmb pla.regdt
    pla.ma1 pla.code pla.ma2 pla.rs1 pla.rs2 pla.summ
    pla.ba1 pla.ba2 pla.kb2
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME plat .
  pla.tim = TIME.
  v-nmb = pla.nmb.
  PAUSE 0.
END.
ELSE
DO:

  VIEW FRAME platr.
  DISP pla.nmb pla.regdt
    pla.ma1 pla.code pla.ma2 pla.rs1 pla.rs2 pla.summ
    pla.ba1 pla.ba2 pla.kb2
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME platr .
  PAUSE 0.

  UPDATE pla.nmb pla.regdt
    pla.ma1 pla.code pla.ma2 pla.rs2 pla.summ
    pla.ba1 pla.ba2 pla.kb2
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME platr .
  pla.tim = TIME.
  v-nmb = pla.nmb.
  PAUSE 0.

END.
