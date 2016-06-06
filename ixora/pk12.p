/* pk12.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Розыгрыш 12 кредитов Быстрые деньги - процентов нет
 * RUN
        BANK COMM
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы 
 * AUTHOR
        21.11.05 marinav
 * CHANGES
        02.12.05 marinav - каждый день разыгрывается 1 кредит
*/

{global.i}

DEFINE VARIABLE ln AS INTEGER.
DEFINE VARIABLE ln0 AS INTEGER.
DEFINE new shared VARIABLE lnmin AS INTEGER.
DEFINE new shared VARIABLE lnmax AS INTEGER.
def var v-txb as char.

def new shared temp-table wrk 
     field bank as char 
     field nn as inte 
     field rdt as date 
     field summa as deci 
     field srok as inte 
     field cif like bank.cif.cif
     field name like bank.cif.name
     field nom as inte                                         
     field win as logi init false
     index nn nn.


message "Розыгрыш БЫСТРЫЕ ДЕНЬГИ - ПРОЦЕНТОВ НЕТ!".

define stream m-out.
output stream m-out to rep.html.

put stream m-out "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.


put stream m-out "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 skip. 

put stream m-out "<tr align=""center""><td><h3>БЫСТРЫЕ ДЕНЬГИ - ПРОЦЕНТОВ НЕТ " skip
                 "</h3></td></tr><br><br>"
                 skip(1).

put stream m-out "<tr></tr><tr><td>" g-ofc "     " today " " string(time,'HH:MM') "</td></tr><tr></tr>"
                 skip(1).

       put stream m-out "<br><tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0""
                  style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Анкета</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Срок</td>"
                  "</tr>" 
skip.


lnmax = 0.

{r-branch.i &proc = "rand"}

find first wrk /*where wrk.bank = 'TXB00'*/ use-index nn.
lnmin = wrk.nn.
find last wrk /*where wrk.bank = 'TXB00'*/ use-index nn.
lnmax = wrk.nn.

if lnmax > 1 then do:
   do ln = 1 to 1:
     ln0 = random(lnmin, lnmax).
     find first wrk where nn = ln0. if avail wrk then wrk.win = yes.
   end.
end.

/*  put stream m-out "<tr></tr><tr align=""right"">"
               "<td align=""left"" colspan = ""6""><b> АЛМАТЫ</td></tr>" skip.
 */
  for each wrk where wrk.win = yes .
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " wrk.nom format ">>>>>" "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td > " wrk.rdt "</td>"
               "<td > " replace(trim(string(wrk.summa, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td > " wrk.srok "</td>"
               "</tr>" skip.
  end.
/*
find first wrk where wrk.bank = 'TXB01' use-index nn.
lnmin = wrk.nn.
find last wrk where wrk.bank = 'TXB01' use-index nn.
lnmax = wrk.nn.

if lnmax > 1 then do:
   do ln = 1 to 1:
     ln0 = random(lnmin, lnmax).
     find first wrk where nn = ln0. if avail wrk then wrk.win = yes.
   end.
end.

  put stream m-out "<tr></tr><tr align=""right"">"
               "<td align=""left"" colspan = ""6""><b> АСТАНА</td></tr>" skip.

  for each wrk where wrk.nn >= lnmin and wrk.win = yes .
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " wrk.nom format ">>>>>" "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td > " wrk.rdt "</td>"
               "<td > " replace(trim(string(wrk.summa, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td > " wrk.srok "</td>"
               "</tr>" skip.
  end.

find first wrk where wrk.bank = 'TXB02' use-index nn.
lnmin = wrk.nn.
find last wrk where wrk.bank = 'TXB02' use-index nn.
lnmax = wrk.nn.

if lnmax > 1 then do:
   do ln = 1 to 1:
     ln0 = random(lnmin, lnmax).
     find first wrk where nn = ln0. if avail wrk then wrk.win = yes.
   end.
end.

  put stream m-out "<tr></tr><tr align=""right"">"
               "<td align=""left"" colspan = ""6""><b> УРАЛЬСК</td></tr>" skip.

  for each wrk where wrk.nn >= lnmin and wrk.win = yes .
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " wrk.nom format ">>>>>" "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td > " wrk.rdt "</td>"
               "<td > " replace(trim(string(wrk.summa, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td > " wrk.srok "</td>"
               "</tr>" skip.
  end.

find first wrk where wrk.bank = 'TXB03' use-index nn.
lnmin = wrk.nn.
find last wrk where wrk.bank = 'TXB03' use-index nn.
lnmax = wrk.nn.

if lnmax > 1 then do:
   do ln = 1 to 1:
     ln0 = random(lnmin, lnmax).
     find first wrk where nn = ln0. if avail wrk then wrk.win = yes.
   end.
end.

  put stream m-out "<tr></tr><tr align=""right"">"
               "<td align=""left"" colspan = ""6""><b> АТЫРАУ</td></tr>" skip.

  for each wrk where wrk.nn >= lnmin and wrk.win = yes .
        put stream m-out "<tr align=""right"">"
               "<td align=""center""> " wrk.nom format ">>>>>" "</td>"
               "<td align=""center""> " wrk.cif "</td>"
               "<td align=""left""> " wrk.name "</td>"
               "<td > " wrk.rdt "</td>"
               "<td > " replace(trim(string(wrk.summa, ">>>>>>>>>>>9.99")),".",",") "</td>"
               "<td > " wrk.srok "</td>"
               "</tr>" skip.
  end.
*/


put stream m-out "</table>" skip.
output stream m-out close.
hide message no-pause.
unix silent cptwin rep.html excel.exe.
