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
        30/04/2004 madiar - просмотр досье филиалов в ГБ
    05/09/06   marinav - добавление индексов
*/


  find kdlon where kdlon.kdcif = s-kdcif and 
                   kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdlon then do:
    find first kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

 find bookcod where bookcod.bookcod = "kdsts" and bookcod.code = kdlon.sts no-lock no-error.
 if avail bookcod then v-stsdescr = bookcod.name.

  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
    if avail bookcod then v-statdescr = bookcod.name.
  find bookcod where bookcod.bookcod = "kdresum" and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name.


 displ kdcif.kdcif kdlon.kdlon kdlon.regdt
       kdlon.who kdlon.bank kdlon.sts v-stsdescr 
       kdlon.lonstat v-statdescr
       kdlon.resume v-resdescr
       kdcif.name kdcif.urdt 
       kdcif.urdt1 kdcif.regnom kdcif.addr[1]
       kdcif.addr[2] kdcif.tel kdcif.sotr kdcif.chief[1] kdcif.job[1]
       kdcif.docs[1] kdcif.rnn_chief[1] kdcif.chief[2]
       with frame kdzal.

end.
pause 0.