/* rptunpay.p
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

/* rptunpay.p
   TIME DEPOSIT UNPAID INTEREST REPORT
*/

{mainhead.i CSABAL}  /* TIME DEPOSIT UNPAID INTEREST REPORT */

def var vrate like aaa.rate.
def var vdate as date label "ДАТА".
def var rdate like aaa.expdt.

vdate = g-today.
{image1.i rpt.img}
{image2.i no}
{report1.i 59}
vtitle = "ОТЧЕТ О НЕОПЛАЧЕННЫХ ПРОЦЕНТАХ ПО ДЕПОЗИТАМ".

for each crc where crc.sts ne 9 no-lock break by crc.crc:
  find first led where led.led = "CDA" no-lock no-error.
  if available led then
    find first lgr where lgr.led = led.led no-lock no-error.
    if available lgr then
      find first aaa where aaa.crc = crc.crc and aaa.lgr = lgr.lgr and
        aaa.accrued ne 0 no-lock no-error.
  if not available aaa then next.
  {report2.i 132}
  if first-of(crc.crc) then do:
    if not first(crc.crc) then page.
    disp "[ ВАЛЮТА   - " + crc.des + " ] " format "x(45)" skip(1)
         with frame crc no-box no-label page-top.
  end.
for each led where led.led eq "CDA"
   ,each lgr of led
   ,each aaa of lgr where aaa.crc = crc.crc and aaa.accrued ne 0
   ,each cif of aaa where break by aaa.crc by aaa.regdt:

  vrate = aaa.rate.
  display aaa.cif label "КИФ"
          trim(trim(cif.prefix) + " " + trim(cif.sname)) format "x(20)" label "НАИМЕНОВАНИЕ КЛИЕНТА" 
          aaa.aaa label "СЧЕТ"
          aaa.regdt label "ДАТА РЕГ." 
          aaa.opnamt label "СУММА ОТКРЫТИЯ" (total by aaa.crc)
          aaa.expdt  label "ДАТА ЗАКР."
          aaa.ddt label "ДАТА ВЫДАЧИ"
          aaa.ddt - aaa.regdt label "СРОК "
          vrate label "СТАВКА"
          aaa.accrued label "ПРОЦЕНТ"
          with width 132 down frame dda.
end.

end. /* crc loop */
{report3.i}
{image3.i}
