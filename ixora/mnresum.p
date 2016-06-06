
/* mnresum.p
 * MODULE
        кредитное досье Мониторинг
 * DESCRIPTION
        Сводный отчет по досье заемщика
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
          mnresum1
 * MENU
        4-11-5- 
 * AUTHOR
        14.03.2005 marinav  
 * CHANGES 
    05/09/06   marinav - добавление индексов
    15/09/06   U00121 - добавил -H -S для конекта к доп.базе и txb 
*/

{global.i}
{kd.i new}

form s-kdcif label ' Укажите номер клиента ' format 'x(10)' skip 
           with side-label row 5 centered frame dat .

update s-kdcif with frame dat.

     {itemlist.i 
       &file = "kdaffilh"
       &frame = "  row 5 centered scroll 1 10 down overlay title ' МОНИТОРИНГ ' "
       &where = " kdaffilh.kdcif = s-kdcif and kdaffilh.code = '18' "
       &flddisp = "kdaffilh.nom 
                   kdaffilh.kdcif FORMAT 'x(9)' 
                   kdaffilh.datres[1] 
                   kdaffilh.datres[2] " 
       &chkey = "nom "
       &chtype = "integer"
       &index  = "cifnom" }

s-nom = kdaffilh.nom . 

find first kdcifhis where kdcifhis.kdcif = s-kdcif and kdcifhis.nom = s-nom no-lock no-error.
 if not avail kdcifhis then do:
   message skip " Клиент N" s-kdcif "не найден !" skip(1)
     view-as alert-box buttons ok title " ОШИБКА ! ".
   return.
 end.


find first comm.txb where comm.txb.bank = kdcifhis.bank and comm.txb.consolid = true no-lock no-error.
connect value(" -db " + comm.txb.path + " -ld txb " +  " -H " + comm.txb.host + " -S " + comm.txb.service + " -U " + comm.txb.login + " -P " + comm.txb.password).

run mnresum1.

if connected ("txb") then disconnect "txb".

