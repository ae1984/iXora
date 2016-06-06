/* remzvkb.p
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

/***************************************************************************\
*****************************************************************************
**  Program: vkbrmz.p
**       By:
** Descript:
**
*****************************************************************************
\***************************************************************************/


def shared var s-remtrz like  remtrz.remtrz.
def var i6 as int.
def var c6 as cha .
def var a6 as cha.
def var b6 as int.

DEF VAR kods AS CHAR FORMAT "x(9)".
DEF VAR nos AS CHAR FORMAT "x(56)".
DEF VAR vacc AS CHAR FORMAT "x(10)".
DEF var  v-num as int.
define buffer blink for linkjl.
{lgps.i }
{global.i}
{remzvkb.f}
IF NOT CAN-FIND(sysc WHERE sysc.sysc = "LINKJL") THEN
RETURN.
FIND sysc WHERE sysc.sysc = "LINKJL" NO-LOCK no-error.
if avail sysc then vacc = sysc.chval.


if vacc = '' then return.

   do transaction on endkey undo,retry:
    find first blink where blink.rem = s-remtrz and blink.jdt = g-today
    no-lock no-error.
    if not available blink then CREATE linkjl.
    else find linkjl where recid(linkjl) = recid(blink)
    exclusive-lock.
    linkjl.rem = s-remtrz.
    FIND remtrz WHERE remtrz.remtrz = s-remtrz NO-LOCK NO-ERROR.
    nos = TRIM(remtrz.ord). 
    IF LENGTH(TRIM(remtrz.sbank)) = 3 THEN
    kods = "310101" + TRIM(remtrz.sbank).
    ELSE
    kods = remtrz.sbank.
    if linkjl.atr[5] = '' then linkjl.atr[5] = remtrz.sacc.
    linkjl.atr[7] = kods.
    linkjl.atr[8] = nos.
    v-num = integer(linkjl.atr[2]). 
    /* check integer */
    if v-num = ? or v-num =  0 then do:
      i6 = 1.
      c6 = substr(remtrz.sqn,19).
      if length(c6) > 6 then c6 = substr(c6,length(c6) - 5 ,6) .
     repeat:
      a6 = substring(c6,i6,1).
      b6 = asc(a6).
      if b6 < 0 then leave.
      if b6 le 47 or b6 ge 58
       then do:
          i6 = 99.
          leave.
          end.
          i6 = i6 + 1.
          if i6 > 6 then leave . 
      end.
     if i6 <> 99 then v-num = integer(c6). 
    end.
  linkjl.atr[1] = "53".
  linkjl.jdt = g-today.
  linkjl.docdate = g-today.
  linkjl.aaa = vacc.
  PAUSE 0.
  UPDATE v-num linkjl.docdate linkjl.atr[5]
    linkjl.atr[9] linkjl.atr[12]  WITH
    FRAME entvkb.

  linkjl.atr[2] = string(v-num).
  HIDE FRAME entvkb.
  end.

   v-text = remtrz.remtrz + " Made correction for VKD by ofc = " + g-ofc
   +   ",VALSTS KASE - subaccount = "  +  linkjl.atr[12].
       run lgps.

release linkjl.
