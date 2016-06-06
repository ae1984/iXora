/* rptcdaov.p
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
 * BASES
        BANK COMM
 * AUTHOR
        31/12/99 pragma
 * CHANGES
*/

/* rptcdaov.p */

def var vrate like aaa.rate.

{mainhead.i TDAMT}  /* CERTIFICATES OF DEPOSIT OVER 100,000 */

{image1.i rpt.img}
{image2.i}
{report1.i 59}

vtitle = "СЕРТИФИКАТЫ ДЕПОЗИТОВ СВЫШЕ 100,000".
for each crc where crc.sts ne 9 break by crc.crc:

  {report2.i 132}

  if first-of(crc.crc)  then do:
    if not first(crc.crc) then page.
    display   skip(1)
             "[ ВАЛЮТА    - "  + crc.des  + " ]"  format "x(45)" skip
             with no-label no-box page-top frame crc.
  end.
  for each led where led.led eq "CDA"
     ,each lgr of led
     ,each aaa of lgr where aaa.dr[1] - aaa.cr[1] le -100000
                        and aaa.crc eq crc.crc
     ,each cif of aaa break by aaa.crc by cif.type by aaa.aaa:

     vrate = 0.
     if lgr.lookaaa eq false
      then do:
        find pri where pri.pri eq lgr.pri no-error.
        vrate = pri.rate + lgr.rate.
     end.
     else vrate = aaa.rate.
     display aaa.aaa label "СЧЕТ"
     (sub-count by aaa.crc by cif.type) 
     aaa.cif label "КИФ"
     trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" label "НАИМЕНОВАНИЕ КЛИЕНТА" 
     cif.type label "ТИП"
          (aaa.dr[1] - aaa.cr[1]) * led.drcr (sub-total by aaa.crc by cif.type)
          format "z,zzz,zzz,zzz,zz9.99-" label "BALANCE "
     vrate label "СТАВКА"
     aaa.regdt label "ДАТА РЕГ." 
     aaa.expdt label "ДАТА ЗАКР."
          with width 132 down frame dda no-box.
end. /* for each led */
end. /* for each crc */
{report3.i}
{image3.i}
