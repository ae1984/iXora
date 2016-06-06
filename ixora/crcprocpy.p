/* crcprocpy.p
 * MODULE
        Установка курсов валют
 * DESCRIPTION
        Копирование прогнозных курсов валют на все филиалы
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        06/06/2005 madiar
 * CHANGES
*/

define input parameter s-target as date.
def shared var g-ofc as char.

for each bank.crcpro where bank.crcpro.regdt = s-target no-lock:
  find first txb.crcpro where txb.crcpro.crc = bank.crcpro.crc and txb.crcpro.regdt = s-target no-error.
  if not avail txb.crcpro then do:
    create txb.crcpro.
    txb.crcpro.crc = bank.crcpro.crc.
    txb.crcpro.regdt = s-target.
  end.
  txb.crcpro.who = g-ofc.
  txb.crcpro.whn = today.
  txb.crcpro.rate[1] = bank.crcpro.rate[1].
end. /* for each bank.crcpro */

