/* pril2.p
 * MODULE
        Отчет по распределению платежного оборота  
 * DESCRIPTION
        Отчет по распределению платежного оборота  
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        pril1.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        prildat.p, prilout.p
 * MENU
        8-12-9-12 
 * AUTHOR
        15.04.05 nataly
 * CHANGES
        30.08.06 U00121 добавил -H,-S в параметры конекта в связи с распределнием баз по разным серверам
        14/02/08 - marina - заменила цикл на r-branch
*/

def new shared temp-table  temp2
   field acc as char format 'x(9)'
   field jh  as integer
   field crc as integer
   field bank as char format 'x(3)'
   field bal  as decimal
   field jdt as date
   field col1  as integer
   field priz as char.

def new shared var dt1 as date  .
def new shared var dt2 as date  .

def new shared var v-god as integer format "9999".
def new shared var v-month as integer format "99".

def var i as date .

/* dt2 не должен превышать последний закрытый ОД!!!! */ 
{global.i}
if not g-batch then do:
            update  dt1 label 'Введите начальную дату' validate (dt1 < g-today, 
                " Вводимая дата должна быть меньше даты тек ОД  "  )
              dt2 label 'конечную дату' /* validate (dt2 >= dt1, 
                " Неверно введена конечная дата "  ) */
              with row 8 centered  side-label  frame opt.
end. 
   hide frame  opt.
      

 display '   ЖДИТЕ...   '  with row 5 frame ww centered .

{r-branch.i &proc = "prildat"}
/*
for each comm.txb where comm.txb.consolid = true no-lock:

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + comm.txb.path + " -H " + comm.txb.host + " -S " + comm.txb.service + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password). 
    v-branch =  txb.service .
    run prildat.
end.
    
if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".
*/

v-god = year(dt1).
v-month = month(dt1).


/*----------- печать результатов ------------ */
  run prilout ("pril.htm", false, "", false, "", false).


pause 0.
