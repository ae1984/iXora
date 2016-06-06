/* kdkrvew.i
 * MODULE
        Кредитный  Модуль
 * DESCRIPTION
        Решение кред комитета
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        4-11-7
 * AUTHOR
        17.03.2004 marinav
 * CHANGES
        30/04/2004 madiar - просмотр досье филиалов в ГБ
                          kdaffilcod = 32 для к/к филиалов и = 42 для к/к ГО
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
  find bookcod where bookcod.bookcod = "kdresum" and bookcod.code = kdlon.resume no-lock no-error.
    if avail bookcod then v-resdescr = bookcod.name.

  if kdlon.bank = s-ourbank then kdaffilcod = '32'.
  else kdaffilcod = '36'.
  
     find first kdaffil where /*kdaffil.bank = s-ourbank and*/ 
                              kdaffil.kdcif = s-kdcif and kdaffil.kdlon = s-kdlon and kdaffil.code = kdaffilcod 
                              and kdaffil.dat = kdlon.datkk no-lock no-error.
     if avail kdaffil then do:
                           v-num = kdaffil.uno. 
                           find first bookcod where bookcod.bookcod = 'kdkrkom' and bookcod.code = kdaffil.name no-lock no-error.
                           if avail bookcod then v-krkom = bookcod.name.
                                            else v-krkom = ''.
                      end.
                      else do:
                           create kdaffil.
                           assign kdaffil.bank = s-ourbank 
                                  kdaffil.code = kdaffilcod
                                  kdaffil.dat = kdlon.datkk
                                  kdaffil.kdcif = s-kdcif
                                  kdaffil.kdlon = s-kdlon
                                  kdaffil.uno = 0.
                           v-num = 0.
                      end.
                            

 displ kdcif.kdcif kdlon.kdlon kdlon.regdt
       kdlon.who kdcif.name kdlon.bank kdlon.sts v-stsdescr
       kdlon.type_lnz v-insdescr kdlon.amountz kdlon.crcz kdlon.ratez 
       kdlon.srokz kdlon.goalz kdlon.repayz
       kdlon.repay%z 
       kdlon.type_ln v-insdescr1 kdlon.amount kdlon.crc kdlon.rate 
       kdlon.srok kdlon.goal kdlon.repay 
       kdlon.repay% 
       kdlon.resume v-resdescr
       kdlon.datkk v-num v-krkom kdlon.rescha[1]
       with frame kdkrkom.

end.
pause 0.