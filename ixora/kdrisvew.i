/* kdzalvew.i
 * MODULE
        Кредитный Модуль
 * DESCRIPTION
        Форма для Работы с обеспечением
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-6
 * AUTHOR
        13.01.2004 marinav
 * CHANGES
        30/04/2004 madiar - Работа с досье филиалов в ГБ.
        17/05/2004 madiar - Исправил проблему с одновременным доступом к данным - теперь таблица лочится только в момент сохранения данных
        20/05/2004 madiar - Поиск записей в kdaffil - не только по коду досье, но и по коду клиента
    05/09/06   marinav - ДНАЮБКЕМХЕ ХМДЕЙЯНБ
*/



  find kdlon where kdlon.kdcif = s-kdcif and 
                   kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdlon then do:
    find first kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

 find bookcod where bookcod.bookcod = "kdsts" and bookcod.code = kdlon.sts no-lock no-error.
 if avail bookcod then v-stsdescr = bookcod.name.


  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = kdlon.type_ln no-lock no-error.
    if avail bookcod then v-insdescr = bookcod.name. 
/*  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repayz no-lock no-error.
    if avail bookcod then v-repdescr = bookcod.name. 
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay%z no-lock no-error.
    if avail bookcod then v-rep%descr = bookcod.name.
*/
/*  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay no-lock no-error.
    if avail bookcod then v-repdescr1 = bookcod.name. 
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay% no-lock no-error.
    if avail bookcod then v-rep%descr1 = bookcod.name.
*/
  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
    if avail bookcod then v-statdescr = bookcod.name.
  find bookcod where bookcod.bookcod = "kdresum" and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name.


      find first kdaffil where kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = '31' no-lock no-error.
      if not avail kdaffil then do:
         create kdaffil. 
         kdaffil.bank = s-ourbank. kdaffil.code = '31'. kdaffil.kdlon = s-kdlon. 
         kdaffil.kdcif = s-kdcif. kdaffil.who = g-ofc. kdaffil.whn = g-today.
         find current kdaffil no-lock no-error.
      end.
      if num-entries(kdaffil.info[1]) ne 0 then do:
       assign r-type_ln = entry(1, kdaffil.info[1])
              r-amount = deci(entry(2, kdaffil.info[1])) 
              v-crc = inte(entry(3, kdaffil.info[1])) 
              r-rate = deci(entry(4, kdaffil.info[1]))
              r-srok = inte(entry(5, kdaffil.info[1]))
              r-goal = entry(6, kdaffil.info[1])
              r-repay = entry(7, kdaffil.info[1])
              r-repay% = entry(8, kdaffil.info[1]) .
       find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = r-type_ln no-lock no-error.
       if avail bookcod then v-insdescr1 = bookcod.name. 
      end.


 displ kdcif.kdcif kdlon.kdlon kdlon.regdt
       kdlon.who kdcif.name kdlon.bank kdlon.sts v-stsdescr
       kdlon.type_ln v-insdescr kdlon.amount kdlon.crc kdlon.rate 
       kdlon.srok kdlon.goal kdlon.repay
       kdlon.repay% 
       r-type_ln v-insdescr1 r-amount v-crc r-rate 
       r-srok r-goal r-repay 
       r-repay% 
       kdlon.lonstat v-statdescr
       kdlon.resume v-resdescr
       with frame kdrisk.

end.
pause 0.


