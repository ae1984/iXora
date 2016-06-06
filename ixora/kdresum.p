
/* kdresum.p
 * MODULE
        кредитное досье
 * DESCRIPTION
        Сводный отчет по досье заемщика
 * RUN
        kdresum
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        4-11-5-2 
 * AUTHOR
        18.08.2003 marinav  
 * CHANGES 
        27.01.2004 marinav - инфо о поставщиках-потребителях
        16.02.2004 marinav - cross-check в валюту кредита 
        09.03.2004 marinav - добавлен поиск действующих кредитов руков и учредителей
        15.03.2004 marinav - формирование отчета вынесено в отдельную процедуру
        30/04/2004 madiyar - Просмотр отчета в ГБ для досье филиалов
        05/09/2006 marinav - добавление индексов
        23/11/2006 madiyar - добавил -H,-S в параметры коннекта
*/

{global.i}
{kd.i new}

form s-kdcif label ' Укажите номер клиента ' format 'x(10)' skip 
     s-kdlon label ' Укажите его досье     ' format 'x(10)' skip 
           with side-label row 5 centered frame dat .

update s-kdcif with frame dat.
update s-kdlon with frame dat.

find first kdlon where kdlon.kdcif = s-kdcif and  kdlon.kdlon = s-kdlon and (kdlon.bank = s-ourbank or s-ourbank = "TXB00") no-lock no-error.
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
connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

run kdresum1.

if connected ("txb") then disconnect "txb".

