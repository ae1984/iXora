/* gl-arpf.p
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
        11/01/05 saltanat
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        02/07/2007 madiyar - немного переделал, чтобы убрать явное упоминание кодов конкретных филиалов
*/


{mainhead.i}
{comm-txb.i}

def var v-dt1 as date.
def var v-dt2 as date.

v-dt1 = g-today.
v-dt2 = g-today.

display v-dt1 label "С ДАТЫ"
        v-dt2 label "ПО ДАТУ"
        with row 8 centered side-labels title 'ЗАДАЙТЕ ПЕРИОД' frame fr.

update v-dt1 
       validate(v-dt1 <= g-today,"За завтра невозможно получить отчет !")
       with row 8 centered side-labels title 'ЗАДАЙТЕ ПЕРИОД' frame fr.

update v-dt2 validate(v-dt2 >= v-dt1 and v-dt2 <= g-today,
                      "Должно быть: Начало <= Конец <= Сегодня")
       with row 8 centered side-labels title 'ЗАДАЙТЕ ПЕРИОД' frame fr.

if  comm-cod() = 0  then do:
  clear frame ww.
  display "Ж Д И Т Е . Идёт формирование отчета по Алматы"  with row 12 frame ww centered.
  pause 0.
  if not connected ("comm") then run conncom.
  find first comm.txb where comm.txb.bank = "TXB00" no-lock no-error.
  if avail txb then do:
     if connected ("txb") then disconnect "txb".
     connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
     run gl-arp("АЛМАТЫ",v-dt1, v-dt2, g-comp, g-ofc, g-fname, g-mdes, g-today). 
  end.
  hide frame ww. 
end.

for each comm.txb where comm.txb.consolid no-lock:
    if comm.txb.bank = 'txb00' then next.
    if comm-cod() = 0 or comm-cod() = txb.txb  then do:
      clear frame ww.
      display "Ж Д И Т Е . Идёт формирование отчета по " + comm.txb.info with row 12 frame ww centered. 
      pause 0.
      if connected ("txb") then disconnect "txb".
      connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
      run gl-arp(comm.txb.info,v-dt1, v-dt2, g-comp, g-ofc, g-fname, g-mdes, g-today).
      if connected ("txb") then disconnect "txb".
      hide frame ww.
    end.
end.


hide frame ww.

