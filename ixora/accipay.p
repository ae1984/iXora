/* accipay.p
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
        15/08/2006 u00600 - оптимизация
*/

/* accipay.p
   12-05-90 cht
   accrd interest status report
*/

define buffer b-aaa for aaa.

define var grobal  like jl.dam.
define var avabal  like grobal.
define var intrat  like rate.rate.
define var lstint  like grobal.
define var mtddb   like grobal.
define var mtdcr   like grobal.
define var ytdint  like grobal.
define var vdet    as log.
define var vrel    as log.
define var vstop   as log.
define var fv  as cha.
define var inc as int.
def var vtitle1 as cha form "x(132)".
def var vtitle2 like vtitle1.
def var vtitle3 like vtitle1.

{mainhead.i BTRACC}  /* ACC INT STATUS LIST */
{image1.i rpt.img}
{image2.i}
{report1.i 63}

vtitle = "СПИСОК СТАТУСОВ ПРОЦЕНТОВ ПО СЧЕТАМ:  ДАТА " + string(g-today).
vtitle1 = "КИФ#   НАИМЕНОВАНИЕ         СЧЕТ#".
vtitle2 =
"           ОБЩИЙ БАЛАНС          ДОСТУПНЫЙ БАЛАНС НАЧ.ПРОЦ.           ВЫПЛ.ПР."
 + "           ПОСЛ.ПЛ.ПРОЦ.     КОД НАЛОГ.".

for each crc where crc.sts ne 9 no-lock:
 for each lgr where lgr.accgl ne 0 and lgr.intpay eq "M" no-lock:
  for each aaa where aaa.crc eq crc.crc and
                     aaa.lgr eq lgr.lgr and aaa.accrued gt 0 no-lock:
    vtitle3 = "[ ВАЛЮТА   - " + crc.des + " ]".
    {report2.i 132
    "vtitle3 skip fill(""="",132) form ""x(132)"" skip
     vtitle1 skip vtitle2 skip fill(""="",132) form ""x(132)"" "}
      find cif of aaa.
      if available aal then lstint = aal.amt.
      grobal = aaa.cr[1] - aaa.dr[1].
      avabal = aaa.cbal.
      ytdint = (aaa.dr[2] - aaa.idr[2]) - (aaa.cr[2] - aaa.icr[2]).
      mtddb = aaa.dr[1] - aaa.mdr[1].
      mtdcr = aaa.cr[1] - aaa.mcr[1].
      display cif.cif trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" aaa.aaa skip
             grobal avabal aaa.accrued
             ytdint lstint cif.pss
             with no-box width 132 no-label.
   end. /* for each aaa */
 end.  /* for each lgr */
 page.
end. /* crc */
{report3.i}
{image3.i}
