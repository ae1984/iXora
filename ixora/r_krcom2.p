/* r_krcom2.p
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
        31/12/99 pragma
 * CHANGES
        12.02.2004 nadejda - добавлен обслуживающий менеджер
        01.01.2004 nadejda - сделан выбор филиал/консолид для ЦО, филиалы видят только свои данные
        26/08/2004 madiar  - десятичный разделитель - запятая
        31/08/2004 madiar  - везде в put stream... добавил unformatted
        29/09/2004 madiar  - в таблицу по овердрафтам попадали БД и БК - исправил
*/

/* полный отчет */

{global.i}

def new shared var d1 as date.
def var coun as int init 1.
def var cnt as decimal extent 30.
def var prc as decimal extent 30.
def var srk as decimal extent 30.
def var vsrk as decimal init 0.

/*для расчета риска*/
def new shared var v-otrasl as char.
def new shared var v-otrasl2 as decimal format 'zz9.9%'.
def new shared var v-obes as decimal format 'zz9.9%'.
def new shared var v-osenka as decimal format 'zz9.9%'.

def new shared var v-zalog as decimal.
def new shared var v-zalog2 as decimal.
def new shared var v-obor as decimal.
def new shared var v-obor2 as decimal.
def new shared var  koef_ust as decimal.

def new shared var v-prd as integer.
def new shared var v-srok as decimal.
def new shared var v-history as decimal.
def new shared var optimal as decimal extent 8 initial [80,90,80,80,80,60,70,80].
def new shared var weight as integer extent 8 initial [5,25,15,25,5,5,10,10].
def new shared var mygrp_names as char extent 5 initial ["Кредиты","Автокредиты","Ипотека","Овердрафты","Экспресс-кредиты"].
def new shared var mygrps      as char extent 5 initial ["10,20,50,60","15,25,55,65","27,67","70,80","90,92"].

def shared var prz as deci.


prc[1] = 0. prc[2] = 0.

def new shared temp-table  wrk
    field mygrp  as int
    field lon    like bank.lon.lon
    field urfiz  as integer /*признак ЮР/ФЛ 0-ЮЛ, 1-ФЛ*/
    field pokaz  as decimal extent 10
    field grp    like  bank.lon.grp
    field name   like bank.cif.name
    field gua    like bank.lon.gua
    field amoun  like bank.lon.opnamt
    field balans like bank.lon.opnamt
    field akkr   like bank.lon.opnamt
    field garan  like bank.lon.opnamt
    field crc    like bank.lon.crc
    field prem   like bank.lon.prem
    field dt1    like bank.lon.rdt
    field dt2    like bank.lon.rdt
    field dt3    like bank.lon.rdt
    field duedt  like bank.lon.rdt
    field rez    like bank.lonstat.prc
    field srez   like bank.lon.opnamt
    field zalog  like bank.lon.opnamt
    field srok   as deci
    field num_dog like bank.loncon.lcnt  /* номер договора */
    field otrasl as char                 /* отрасль */
    field rate as decimal                /* курс на день выдачи */
    field obes as char                   /* вид обеспечения */
    field col_prolon as integer          /* кол-во пролонгаций */
    field sum_dolg as decimal            /* сумма просроченной задолженности */
    field ofc as char format "x(70)"     /* обслуживает менеджер */
    index main is primary crc desc balans desc mygrp urfiz.

  

    /*для долларов*/
       cnt[1] = 0.   /*заявленная*/
       cnt[2] = 0.   /*реальная*/
       cnt[3] = 0.   /**/
   /*для тенге*/
       cnt[4] = 0.
       cnt[5] = 0.
       cnt[6] = 0.


d1 = g-today.
update d1 label ' Укажите дату' format '99/99/9999'  
                  skip with side-label row 5 centered frame dat .

message " Формируется отчет...".

/* 01.01.2004 nadejda - сделан выбор филиал/консолид для ЦО, филиалы видят только свои данные */
{r-brfilial.i &proc = "kredkom2 (d1)"}
/**/

/* 01.01.2004 nadejda - переделано на вызов r-brfilial.i
run r_krcom22 (d1).
*/

find last bank.crchis where bank.crchis.crc = 2 and bank.crchis.regdt le d1 no-lock no-error.

define stream m-out.
output stream m-out to rpt.html.

{html-title.i &stream = " stream m-out "}

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">" skip
                "<tr align=""left""><td><h3>Кредитный портфель за "
                 string(d1) "</h3></td></tr>" skip(1)
                 "<tr><td></td></tr><tr><td></td></tr><tr><td></td></tr><tr><td></td></tr>" skip.

/*КРЕДИТЫ*/
/*полный отчет без рейтинга*/
if prz = 2 then
       put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                    "<td>П/п</td>"
                    "<td>Наименование заемщика</td>"
                    "<td>Вид кредита</td>"
                    "<td>Одобренная сумма</td>"
                    "<td>Аккредитив</td>"
                    "<td>Гарантия</td>"
                    "<td>Сумма остатка займа</td>"
                    "<td>Валюта</td>"
                    "<td>% ставка</td>"
                    "<td>Дата выдачи займа</td>"
                    "<td>Дата последней проплаты</td>"
                    "<td>Дата след.проплаты по гр</td>"
                    "<td>Дата погашения займа</td>"
                    "<td>Обеспечение USD</td>"
                    "<td>Резерв %</td>"
                    "<td>Сформированная сумма резервов</td>"
                    "<td>Срок</td>"
                    "<td>Номер договора </td>"
                    "<td>Отрасль</td>"
                    "<td>Вид обеспечения</td>"
                    "<td>Количество пролонгаций</td>"
                    "<td>Курс на день выдачи</td>"
                    "<td>Сумма просроченной задолженности</td>"
                    "<td>Обслуживает менеджер</td>"
                  "</tr>" skip.

else  /*отчет  с рейтингом*/
       put stream m-out unformatted "<tr><td></td></tr><tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Сумма остатка займа</td>"
                  "<td>Валюта</td>"
                  "<td>% ставка</td>"
                  "<td>Дата выдачи займа</td>"
                  "<td>Дата погашения займа</td>"
                  "<td>Резерв %</td>"
                  "<td>Сформированная сумма резервов</td>"
                  "<td>Кредитный рейтинг</td>"
                  "<td>Риск</td>"
                  "<td>Обслуживает менеджер</td>"
                  "</tr>" skip.


for each wrk break by wrk.mygrp by wrk.urfiz by wrk.crc desc by wrk.balans desc. 
   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.
   
   if first-of(wrk.mygrp) then do:
      if prz = 2 then put stream m-out unformatted
                            "<tr style=""font:bold"" bgcolor=""#9BCDFF""><td colspan=""24"">" mygrp_names[wrk.mygrp] "</td></tr>" skip.
   end.

if prz = 3 then do:
 if wrk.urfiz = 0 then 
           put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format 'x(3)' "</td>"
               "<td> " replace(string(wrk.prem, ">>9.99%"),'.',',') "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>" 
               "<TD> =НОРМРАСП("replace(string(pokaz[1] / optimal[1],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[1]"+НОРМРАСП("replace(string( pokaz[2] / optimal[2],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[2]"+НОРМРАСП("replace(string(pokaz[3] / optimal[3],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[3]"+НОРМРАСП("replace(string(pokaz[4] / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"+НОРМРАСП("replace(string(pokaz[5] / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"+НОРМРАСП("replace(string(pokaz[6] / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"+НОРМРАСП("replace(string(pokaz[7] / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"+НОРМРАСП("replace(string(pokaz[8] / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"</TD>" skip
               "<TD> =(100-(НОРМРАСП(" replace(string(pokaz[1] / optimal[1],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[1] "+НОРМРАСП(" replace(string( pokaz[2] / optimal[2],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[2] "+НОРМРАСП(" replace(string(pokaz[3] / optimal[3],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[3] "+НОРМРАСП(" replace(string(pokaz[4] / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"+НОРМРАСП("replace(string(pokaz[5] / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"+НОРМРАСП("replace(string(pokaz[6] / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"+НОРМРАСП("replace(string(pokaz[7] / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"+НОРМРАСП("replace(string(pokaz[8] / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"))/100*" replace(string(wrk.balans,'>>>>>>>>>>9.99'),".",",") "</TD>" skip
               "<td align=""left"">" wrk.ofc "</td>"
             "</tr>" skip.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
   else 
 put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " wrk.gua format "x(3)" "</td>"
               "<td> " replace(string(wrk.amoun, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.akkr, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.garan, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format 'x(3)' "</td>"
               "<td> " replace(string(wrk.prem, ">>9.99%"),'.',',') "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.dt2 "</td>"
               "<td> " wrk.dt3 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.zalog, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>" 
               "<td> " wrk.srok format '->>>9' "</td>" 
               "<td align=""left""> " "`" wrk.num_dog format 'x(15)' "</td>" 
               "<td> " wrk.otrasl format "x(60)" "</td>"
               "<td> " wrk.obes format "x(60)" "</td>"
               "<td> " wrk.col_prolon  format "z9" "</td>"
               "<td> " replace(string(wrk.rate, ">>9.99"),'.',',') format '>>9.99' "</td>"
               "<td> " replace(string(wrk.sum_dolg, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<TD>&nbsp;</TD>" skip
               "<TD>&nbsp;</TD>" skip
               "<td align=""left"">" wrk.ofc "</td>"
               "</tr>" skip.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                
  end.  /*prz = 3*/
 else put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " wrk.gua format "x(3)" "</td>"
               "<td> " replace(string(wrk.amoun, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.akkr, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.garan, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format 'x(3)' "</td>"
               "<td> " wrk.prem format '>9.99%' "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.dt2 "</td>"
               "<td> " wrk.dt3 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.zalog, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>" 
               "<td> " wrk.srok format '->>>9' "</td>" 
               "<td align=""left""> " "`" wrk.num_dog format 'x(15)' "</td>" 
               "<td> " wrk.otrasl format "x(60)" "</td>"
               "<td> " wrk.obes format "x(60)" "</td>"
               "<td> " wrk.col_prolon  format "z9" "</td>"
               "<td> " replace(string(wrk.rate, ">>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.sum_dolg, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left"">" wrk.ofc "</td>"
               "</tr>" skip.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                


    if wrk.crc = 2 then do:             
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.

/*       prc[3] = prc[3] + wrk.balans * wrk.prem.
       prc[4] = prc[4] + wrk.balans * wrk.srok.*/
    end.
    if wrk.crc = 1 then do:             
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
/*       prc[3] = prc[3] + wrk.balans / bank.crchis.rate[1] * wrk.prem.
       prc[4] = prc[4] + wrk.balans / bank.crchis.rate[1] * wrk.srok.*/
    end.

    if wrk.crc = 11 then do:             
       cnt[7] = cnt[7] + wrk.amoun.
       cnt[8] = cnt[8] + wrk.balans.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if last-of (wrk.crc) then
    do:
   if prz = 2 then
     put stream m-out unformatted "<tr align=""right"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td></td><td></td><td></td><td></td>"
               "<td><b> " replace(string(cnt[3], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "<td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td></td><td></td><td><b> " replace(string(cnt[6], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "</tr>" skip.
    else 
     put stream m-out unformatted "<tr align=""right"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td><b> " replace(string(cnt[3], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "<td></td><td></td><td></td><td></td>"
               "<td></td> <td><b> " replace(string(cnt[6], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td><td></td>"
               "</tr>" skip.
     cnt[3] = 0. cnt[6] = 0.
    end.
    coun = coun + 1.
 
end.
put stream m-out unformatted "<tr><td></td></tr><tr><td></td></tr></table>" skip.
put stream m-out unformatted "</table>" skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0"">"
                 skip. 

put stream m-out unformatted "<tr align=""left""><td><h3>Овердрафты "
                 string(d1) "</h3></td></tr><tr><td></td></tr><tr><td></td></tr>"
                 skip(1).
 put stream m-out unformatted "<tr><td></td></tr><tr><td></td></tr><tr></tr>" skip.

/*ОВЕРДРАФТЫ*/
/*полный отчет без рейтинга*/
if prz = 2 then
       put stream m-out unformatted "<tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Вид кредита</td>"
                  "<td>Одобренная сумма</td>"
                  "<td>Аккредитив</td>"
                  "<td>Гарантия</td>"
                  "<td>Сумма остатка займа</td>"
                  "<td>Валюта</td>"
                  "<td>% ставка</td>"
                  "<td>Дата выдачи займа</td>"
                  "<td>Дата последней проплаты</td>"
                  "<td>Дата след.проплаты по гр</td>"
                  "<td>Дата погашения займа</td>"
                  "<td>Обеспечение USD</td>"
                  "<td>Резерв %</td>"
                  "<td>Сформированная сумма резервов</td>"
                  "<td>Срок</td>"
                  "<td>Номер договора </td>"
                  "<td>Отрасль</td>"
                  "<td>Вид обеспечения</td>"
                  "<td>Количество пролонгаций</td>"
                  "<td>Курс на день выдачи</td>"
                  "<td>Сумма просроченной задолженности</td>"
                  "<td>Обслуживает менеджер</td>"
                  "</tr>" skip.
else 
       put stream m-out unformatted "<tr><td></td></tr><tr><td><table width=""100%"" border=""1"" cellpadding=""10"" cellspacing=""0"">" skip
                  "<tr style=""font:bold;font-size:xx-small"" bgcolor=""#C0C0C0"" align=""center"">"
                  "<td>П/п</td>"
                  "<td>Наименование заемщика</td>"
                  "<td>Сумма остатка займа</td>"
                  "<td>Валюта</td>"
                  "<td>% ставка</td>"
                  "<td>Дата выдачи займа</td>"
                  "<td>Дата погашения займа</td>"
                  "<td>Резерв %</td>"
                  "<td>Сформированная сумма резервов</td>"
                  "<td>Кредитный рейтинг</td>"
                  "<td>Риск</td>"
                  "<td>Обслуживает менеджер</td>"
                  "</tr>" skip.

for each wrk where wrk.grp = 70 or wrk.grp = 80 break by wrk.crc desc by wrk.balans desc. 
   find last bank.crc where bank.crc.crc = wrk.crc no-lock no-error.

  
/*полный отчет без рейтинга*/
if prz = 2 then
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left""> " wrk.gua format "x(3)" "</td>"
               "<td> " replace(string(wrk.amoun, ">>>>>>>>>>>9.99" ),'.',',') "</td>"
               "<td> " replace(string(wrk.akkr, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.garan, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.balans, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " bank.crc.code format 'x(3)' "</td>"
               "<td> " replace(string(wrk.prem, ">>9.99%"),'.',',') "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.dt2 "</td>"
               "<td> " wrk.dt3 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.zalog, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>" 
               "<td> " wrk.srok format '->>>9' "</td>" 
               "<td align=""left""> " "`" wrk.num_dog format 'x(10)' "</td>" 
               "<td> " wrk.otrasl format "x(60)" "</td>"
               "<td> " wrk.obes format "x(60)" "</td>"
               "<td> " wrk.col_prolon  format "z9" "</td>"
               "<td> " wrk.rate  "</td>"
               "<td> " replace(string(wrk.sum_dolg, ">>>>>>>>>>>9.99"),'.',',') "</td>"
               "<td align=""left"">" wrk.ofc "</td>"
               "</tr>" skip.
else 
   put stream m-out unformatted "<tr align=""right"">"
               "<td align=""center""> " coun "</td>"
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td> " wrk.balans format '>>>>>>>>>>>9.99' "</td>"
               "<td> " bank.crc.code format 'x(3)' "</td>"
               "<td> " wrk.prem format '>9.99%' "</td>"
               "<td> " wrk.dt1 "</td>"
               "<td> " wrk.duedt "</td>"
               "<td> " replace(string(wrk.rez, ">>9.99%"),'.',',') "</td>"
               "<td> " replace(string(wrk.srez, ">>>>>>>>>>>9.99"),'.',',') "</td>" 
              "<TD>=НОРМРАСП("replace(string(pokaz[1] / optimal[1],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[1]"+НОРМРАСП("replace(string( pokaz[2] / optimal[2],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[2]"+НОРМРАСП("replace(string(pokaz[3] / optimal[3],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[3]"+НОРМРАСП("replace(string(pokaz[4] / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"+НОРМРАСП("replace(string(pokaz[5] / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"+НОРМРАСП("replace(string(pokaz[6] / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"+НОРМРАСП("replace(string(pokaz[7] / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"+НОРМРАСП("replace(string(pokaz[8] / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"</TD>" skip
              "<TD>=(100-(НОРМРАСП(" replace(string(pokaz[1] / optimal[1],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[1] "+НОРМРАСП(" replace(string( pokaz[2] / optimal[2],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[2] "+НОРМРАСП(" replace(string(pokaz[3] / optimal[3],'zzzz9.99'),".",",") ";0,5;0,15;1)*" weight[3] "+НОРМРАСП(" replace(string(pokaz[4] / optimal[4],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[4]"+НОРМРАСП("replace(string(pokaz[5] / optimal[5],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[5]"+НОРМРАСП("replace(string(pokaz[6] / optimal[6],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[6]"+НОРМРАСП("replace(string(pokaz[7] / optimal[7],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[7]"+НОРМРАСП("replace(string(pokaz[8] / optimal[8],'zzzz9.99'),".",",")";0,5;0,15;1)*"weight[8]"))/100*" replace(string(wrk.balans,'>>>>>>>>>>9.99'),".",",") "</TD>" skip
              "<td align=""left"">" wrk.ofc "</td>"
               "</tr>" skip.



    if wrk.crc = 2 then do:             
       cnt[1] = cnt[1] + wrk.amoun.
       cnt[2] = cnt[2] + wrk.balans.
       prc[1] = prc[1] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if wrk.crc = 1 then do:             
       cnt[4] = cnt[4] + wrk.amoun.
       cnt[5] = cnt[5] + wrk.balans.
       prc[2] = prc[2] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if wrk.crc = 11 then do:             
       cnt[7] = cnt[7] + wrk.amoun.
       cnt[8] = cnt[8] + wrk.balans.
       prc[3] = prc[3] + wrk.balans * wrk.prem.
       cnt[3] = cnt[3] + wrk.balans.
       cnt[6] = cnt[6] + wrk.srez.
    end.
    if last-of (wrk.crc) then
    do:
   if prz = 2 then
     put stream m-out unformatted "<tr align=""right"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td></td><td></td><td></td><td></td>"
               "<td><b> " replace(string(cnt[3], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "<td></td><td></td><td></td><td></td><td></td><td></td>"
               "<td></td><td></td><td><b> " replace(string(cnt[6], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "</tr>" skip.
    else 
     put stream m-out unformatted "<tr align=""right"">"
               "<td></td><td align=""left""><b> Итого </b></td>"
               "<td><b> " replace(string(cnt[3], ">>>>>>>>>>>9.99"),'.',',') "</b></td>"
               "<td></td><td></td><td></td><td></td>"
               "<td></td> <td><b> " replace(string(cnt[6], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td><td></td>"
               "</tr>" skip.
     cnt[3] = 0. cnt[6] = 0.
    end.

    coun = coun + 1.
 
end.
put stream m-out "<tr></tr><tr></tr><tr></tr></table>" skip.

put stream m-out unformatted
                 "<table border=""1"" cellpadding=""10"" cellspacing=""0""><tr><td></td></tr><tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ДОЛЛАРАХ США </b></td> <td></td> "
                 "<td align=""right""><b> " replace(string(cnt[1], ">>>>>>>>>>>9.99"),'.',',') "</b></td> " 
                 "<td align=""right""><b> " replace(string(cnt[2], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[1] / cnt[2], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr>" skip.
put stream m-out unformatted
                 "<table border=""1"" cellpadding=""10"" cellspacing=""0""><br><tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ЕВРО </b></td> <td></td> "
                 "<td align=""right""><b> " replace(string(cnt[7], ">>>>>>>>>>>9.99"),'.',',') "</b></td> " 
                 "<td align=""right""><b> " replace(string(cnt[8], ">>>>>>>>>>>9.99"),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[3] / cnt[8], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr>" skip.

put stream m-out unformatted
                 "<br><tr align=""left"">"
                 "<td></td><td><b> ИТОГО В ТЕНГЕ </b></td> <td></td>" 
                 "<td align=""right""><b> " replace(string(cnt[4], '>>>>>>>>>>>9.99'),'.',',') "</b></td> " 
                 "<td align=""right""><b>" replace(string(cnt[5], '>>>>>>>>>>>9.99'),'.',',') "</b></td><td></td>"
                 "<td align=""right""><b> " replace(string(prc[2] / cnt[5], ">>9.99%"),'.',',') "</b></td>"
                 "<td>Средневзвешенная</td>"
                 "</tr></table></td></tr>" skip.

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

hide message no-pause.

unix silent cptwin rpt.html excel.

