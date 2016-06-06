
/* kdresum0.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Сводный отчет по досье заемщика
 * RUN
        kdresum1
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-5-2 
 * AUTHOR
        30/04/2004 madiar - для подключения к базе филиала
 * CHANGES 
    05/09/06   marinav - добавление индексов

*/

{global.i}
{kd.i}

find first kdlon where kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
 if not avail kdlon then do:   
   message skip " Заявка N" s-kdlon "не найдена !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.

find first kdcif where kdcif.kdcif = kdlon.kdcif no-lock no-error.
 if not avail kdcif then do:
   message skip " Клиент N" kdlon.kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.

find first comm.txb where comm.txb.bank = kdlon.bank and comm.txb.consolid = true no-lock no-error.
connect value(" -db " + comm.txb.path + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

run kdresum1.

if connected ("txb") then disconnect "txb".