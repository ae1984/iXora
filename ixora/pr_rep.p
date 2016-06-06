 /* pr_rep.p           
 * MODULE
        Тестовый модуль
 * DESCRIPTION

 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU

 * AUTHOR
     11.06.2004 dpuchkov
 * CHANGES
     18.06.2004 dpuchkov добавил вывод заголовков счетов Г.К.
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
*/

{mainhead.i}
{functions-def.i}

def var return_choice as logical.
def var d_date as date.
def var d_date_fin as date.
def var out as char.
def var file1 as char format "x(20)".
def var acctype as logical.
def var v-arp_acc  as integer.
def var v-num as integer.
def var v-glaccnt as char.

def var i as integer.
define new shared var v-indexnumber as integer. /* Индекс инициализации */

  d_date = g-today.
  d_date_fin = g-today.

  update d_date label "Дата с" with centered side-label.
  update d_date_fin label "по" with centered side-label.


  display "......Ж Д И Т Е ......."  with row 12 frame ww centered.
  pause 0.


def new shared stream m-out1.
output stream m-out1 to reprt1.img.
put stream m-out1

FirstLine( 1, 1 ) format 'x(80)' skip(1)
'                 '
'Отчет о счетах доходов и расходов открытых за период с ' skip
'                    '
'             ' string(d_date)  ' по ' string(d_date_fin) skip(1)
FirstLine( 2, 1 ) format 'x(80)' skip.

 
if not connected ("comm") then run conncom.


/* Цикл по счетам доходов по по филиалам */
do i = 0 to 3:
   find first comm.txb where comm.txb.bank = "TXB0" + string(i) no-lock no-error.
   if avail txb then do:
       if connected ("txb") then disconnect "txb".
       if not connected ("txb") then 
       	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    end.
    run rep_fh(i, d_date, d_date_fin, "4").
    if connected ("txb") then disconnect "txb".
end.

v-indexnumber = 0.

/* Цикл по счетам расходов по филиалам */
do i = 0 to 3:
   find first comm.txb where comm.txb.bank = "TXB0" + string(i) no-lock no-error.
    if avail txb then do:
       if connected ("txb") then disconnect "txb".
       if not connected ("txb") then 
       	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    end.
    run rep_fh(i, d_date, d_date_fin, "5").
    if connected ("txb") then disconnect "txb".
end.

output stream m-out1 close.
run menu-prt( 'reprt1.img' ).

hide all.
MESSAGE "Вы хотите посмотреть детальный отчет?" VIEW-AS
        ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
        IF not b then return.


def new shared stream m-out.
output stream m-out to reprt.img.
/* Цикл по счетам доходов по по филиалам */
do i = 0 to 3:
   find first comm.txb where comm.txb.bank = "TXB0" + string(i) no-lock no-error.
   if avail txb then do:
       if connected ("txb") then disconnect "txb".
       if not connected ("txb") then 
       	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    end.
    run rep_fl(i, d_date, d_date_fin, "4").
    if connected ("txb") then disconnect "txb".
end.

v-indexnumber = 0.

/* Цикл по счетам расходов по филиалам */
do i = 0 to 3:
   find first comm.txb where comm.txb.bank = "TXB0" + string(i) no-lock no-error.
    if avail txb then do:
       if connected ("txb") then disconnect "txb".
       if not connected ("txb") then 
       	connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    end.
    run rep_fl(i, d_date, d_date_fin, "5").
    if connected ("txb") then disconnect "txb".
end.


output stream m-out close.
run menu-prt( 'reprt.img' ).
{functions-end.i}

hide all.



