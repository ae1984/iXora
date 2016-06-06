/* plb-r.p
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

/*  pla-r.p
AGA - 26/04/96 - редактирование платежки

*/

DEF SHARED VAR v-nmb LIKE pla.nmb.
def shared var g-ofc LIKE ofc.ofc.
DEF SHARED VAR vld AS CHAR.
DEF SHARED FRAME plat.
DEF SHARED FRAME platr.
{plas.f}
{plasr.f}


FIND FIRST pla WHERE pla.who EQ g-ofc AND pla.lang EQ vld NO-ERROR.
IF vld EQ "l" THEN
DO:
  VIEW FRAME plat.
  UPDATE pla.nmb pla.regdt
    pla.ma1 pla.ma2 pla.rs1 pla.rs2
    pla.ba1 pla.ba2 pla.kb2 pla.code pla.summ
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME plat .
  v-nmb = pla.nmb.
END.
ELSE
DO:
  VIEW FRAME platr.
  UPDATE pla.nmb pla.regdt
    pla.ma1 pla.ma2 pla.rs1 pla.rs2
    pla.ba1 pla.ba2 pla.kb2 pla.code pla.summ
    pla.sa1 pla.sa2 pla.rs3 pla.rs4
    pla.ba3 pla.ba4 pla.kb4
    pla.ve  pla.me
    pla.ap[1] pla.ap[2] pla.ap[3]
    pla.ap[4] pla.ap[5]
    WITH FRAME platr .
  v-nmb = pla.nmb.
END.
PAUSE 0.
