/* kdlonvew.i  Электронное кредитное досье

     Отражение данных в форме  
               ЭКД

  24.07.03 marinav
  30/04/2004 madiar - Просмотр досье филиалов в ГБ
      30.09.2005 marinav - изменения для бизнес-кредитов
    05/09/06   marinav - добавление индексов

*/


  find kdlon where kdlon.kdcif = s-kdcif and 
                   kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
  if avail kdlon then do:
    find first kdcif where kdcif.kdcif = s-kdcif and (kdcif.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.

 find bookcod where bookcod.bookcod = "kdsts" and bookcod.code = kdlon.sts no-lock no-error.
 if avail bookcod then v-stsdescr = bookcod.name.


  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = kdlon.type_lnz no-lock no-error.
    if avail bookcod then v-insdescr = bookcod.name. 
/*  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repayz no-lock no-error.
    if avail bookcod then v-repdescr = bookcod.name. 
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay%z no-lock no-error.
    if avail bookcod then v-rep%descr = bookcod.name.
*/
  find bookcod where bookcod.bookcod = "kdfintyp" and bookcod.code = kdlon.type_ln no-lock no-error.
    if avail bookcod then v-insdescr1 = bookcod.name. 
/*  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay no-lock no-error.
    if avail bookcod then v-repdescr1 = bookcod.name. 
  find bookcod where bookcod.bookcod = "kdrepay" and bookcod.code = kdlon.repay% no-lock no-error.
    if avail bookcod then v-rep%descr1 = bookcod.name.
*/
  find bookcod where bookcod.bookcod = "kdstat" and bookcod.code = kdlon.lonstat no-lock no-error.
    if avail bookcod then v-statdescr = bookcod.name.
  find bookcod where bookcod.bookcod = "kdresum" and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name.


 displ kdcif.kdcif kdlon.kdlon kdlon.regdt kdlon.manager
       kdlon.who kdcif.name kdlon.bank kdlon.sts v-stsdescr
       kdlon.type_lnz v-insdescr kdlon.amountz kdlon.crcz kdlon.ratez 
       kdlon.srokz kdlon.goalz kdlon.repayz
       kdlon.repay%z 
       kdlon.type_ln v-insdescr1 kdlon.amount kdlon.crc kdlon.rate 
       kdlon.srok kdlon.goal kdlon.repay 
       kdlon.repay% 
       kdlon.lonstat v-statdescr
       kdlon.resume v-resdescr
       with frame kdlon.

end.
pause 0.