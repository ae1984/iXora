/* pkankcls.p
 * MODULE
         Потребит кредитование
 * DESCRIPTION
        Список погашенных кредитов
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
        21/06/2004 madiyar - объединил отчеты по каждому типу кредита (pkankcls) в один
 * CHANGES
        17/11/2005 madiyar - отчет не на дату, а за период
        24/11/2005 madiyar - неправильно формировался отчет за период, исправил
        13/04/2006 madiyar - добавил логин погасившего менеджера
        19/04/2006 madiyar - убрал кредиты, погашенные до datums
        26/04/2006 madiyar - исправил ошибку
*/

{mainhead.i}
{comm-txb.i}
define var s-ourbank as char no-undo.
s-ourbank = comm-txb().

def var cust-list as character no-undo view-as selection-list single size 50 by 15 label " Выберите тип кредита: ".
def var ok-status as logical no-undo.
def var chosen_one as char no-undo.
def var coun as int no-undo.
def var datums as date no-undo format '99/99/9999' label 'С'.
def var datums2 as date no-undo format '99/99/9999' label 'по'.
def var data_ar as char no-undo extent 10.

def var bilance as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var bilance0 as decimal no-undo format '->,>>>,>>>,>>9.99'.
def var v-str as char no-undo.
def var v-delim as char no-undo init "^".

def temp-table wrk no-undo
    field ln       like pkanketa.ln
    field lon      like lon.lon
    field cif      like lon.cif
    field name     like cif.name
    field rdt      like lon.rdt
    field duedt    like lon.rdt
    field dtcls    like lnsch.stdat
    field crc      like crc.code
    field prem     like lon.prem
    field opnamt   like lon.opnamt
    field goal     like pkanketa.goal
    field comiss   like lon.opnamt
    field prem%    like lon.opnamt
    field gl       like lon.gl
    field billsum  like pkanketa.billsum
    field tel      as    char        /* */
    field job      as    char        /* */
    field aliv     as    char        /* */
    field asign    as    char        /* */
    field rnn      like  cif.jss
    field u        as    char.

form
  cust-list
  with frame sel-frame centered.

on default-action of cust-list
   do:
     chosen_one = data_ar[integer(entry(1,cust-list:screen-value,'.'))].
   end.

coun = 1.
for each bookcod where bookcod.bookcod = 'credtype' no-lock use-index bookcod:
  ok-status = cust-list:ADD-LAST(string(coun) + '. ' + bookcod.name).
  data_ar[coun] = bookcod.code.
  coun = coun + 1.
end. /* for each bookcod */

enable cust-list with frame sel-frame.

wait-for default-action of current-window.

datums2 = date(month(g-today),1,year(g-today)) - 1.
datums = date(month(datums2),1,year(datums2)).
update datums format '99/99/9999' validate(datums <= g-today, "Дата не может быть позже текущей!")
       datums2 format '99/99/9999' validate(datums2 <= g-today, "Дата не может быть позже текущей!") skip
       with side-label row 5 centered frame dat.

hide message no-pause.

for each pkanketa no-lock where pkanketa.bank = s-ourbank and pkanketa.credtype = chosen_one and
         pkanketa.lon ne '' and pkanketa.rdt <= datums2 break by pkanketa.ln.
  
  find first lon where lon.lon = pkanketa.lon and lon.rdt <= datums2 no-lock no-error.
  if not avail lon or lon.opnamt <= 0 then next.
  
  if datums2 < 03/01/2004 then run atl-dat1 (lon.lon,datums2,3,output bilance). /* остаток ОД */
  else run lonbalcrc('lon',lon.lon,datums2,"1,2,7,9,13,14",yes,lon.crc,output bilance).
  
  if bilance ne 0 then next.
  
  if lon.rdt < datums then do:
    if datums < 03/01/2004 then run atl-dat1 (lon.lon,datums - 1,3,output bilance0). /* остаток ОД */
    else run lonbalcrc('lon',lon.lon,datums,"1,2,7,9,13,14",no,lon.crc,output bilance0).
    if bilance0 <= 0 then next.
  end.
  
  find cif where cif.cif = lon.cif no-lock.
  find crc where crc.crc = lon.crc no-lock.

  create wrk.
  wrk.lon = lon.lon.
  wrk.ln = pkanketa.ln.
  wrk.cif = lon.cif.
  wrk.name = cif.name.
  wrk.crc = crc.code.
  wrk.prem = lon.prem.
  wrk.opnamt = lon.opnamt.
  wrk.rdt = lon.rdt.
  wrk.duedt = lon.duedt.
  wrk.goal = pkanketa.goal.
  wrk.comiss = pkanketa.sumcom.
  wrk.gl = lon.gl.
  wrk.billsum = pkanketa.billsum.
  for each lnsci where lnsci.lni = pkanketa.lon and lnsci.fpn = 0 and lnsci.flp > 0 and lnsci.idat <= datums no-lock:
     wrk.prem% = wrk.prem% + lnsci.paid-iv.
  end.

  find last lnsch where lnsch.lnn = lon.lon and lnsch.flp > 0 no-lock no-error.
  if avail lnsch then do:
    wrk.dtcls = lnsch.stdat.
    wrk.u = lnsch.who.
  end.

  if avail cif then do:
      wrk.tel = trim(cif.tel) + "," + trim(cif.tlx) + "," + trim(cif.fax) + "," + trim(cif.btel).
      wrk.job = cif.ref[8].
      wrk.rnn = cif.jss.

     if cif.dnb <> "" then do:
       v-str = entry(1, cif.dnb, "|").
       if num-entries(v-str, v-delim) > 1 then wrk.asign =  entry(2, v-str, v-delim).
       if num-entries(v-str, v-delim) > 2 then wrk.asign =  wrk.asign + " д." + entry(3, v-str, v-delim).
       if num-entries(v-str, v-delim) > 3 then wrk.asign =  wrk.asign + " кв."  + entry(4, v-str, v-delim).
       if num-entries(cif.dnb, "|") > 1 then do:
         v-str = entry(2, cif.dnb, "|").
         if num-entries(v-str, v-delim) > 1 then wrk.aliv = entry(2, v-str, v-delim).
         if num-entries(v-str, v-delim) > 2 then wrk.aliv = wrk.aliv + " д." +  entry(3, v-str, v-delim).
         if num-entries(v-str, v-delim) > 3 then wrk.aliv = wrk.aliv + " кв."  + entry(4, v-str, v-delim).
       end.
     end.
  end. /* if avail cif */
end. /* for each pkanketa */

find first cmp no-lock no-error.
define stream m-out.
output stream m-out to srok.htm.

put stream m-out unformatted "<html><head><title>TEXAKABANK</title>" skip
                 "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">" skip
                 "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>"
                 skip.

put stream m-out unformatted "<table border=""0"" cellpadding=""0"" cellspacing=""0""
                 style=""border-collapse: collapse"">"
                 skip.

put stream m-out unformatted "<br><br><tr align=""left""><td><h3>" cmp.name format 'x(79)'
                 "</h3></td></tr><br><br>"
                 skip.

find bookcod where bookcod.bookcod = "credtype" and bookcod.code = chosen_one no-lock no-error.

put stream m-out unformatted "<tr align=""center""><td><h3> Погашенные кредиты с " string(datums,"99/99/9999") " по " string(datums2,"99/99/9999") "</h3></td></tr><BR><BR>" skip
                 "<TR align=""center""><TD><h3>" caps(bookcod.name) format "x(60)" "</h3></TD></TR>" skip
                 "<TR><TD>&nbsp;</TD></TR>" skip(1).

put stream m-out unformatted "<tr><td><table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse"">" skip
                  "<tr style=""font:bold"">"
                  "<td bgcolor=""#C0C0C0"" align=""center"">П/п</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Анкета</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Номер</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Наименование заемщика</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Ссудный счет</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Одобренная сумма</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Валюта</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">% ставка</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата выдачи</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата окончания</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Дата факт погашения</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Погасил</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Обеспечение</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Комиссия</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Сумма оплаченного вознагр</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Счет Г/К</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Оценочная стоимость</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Адрес Прописки</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Адрес Проживания</td>" skip
                  "<td bgcolor=""#C0C0C0"" align=""center"">Телефон</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">Место работы</td>"
                  "<td bgcolor=""#C0C0C0"" align=""center"">РНН</td>"
                  "</tr>" skip.

coun = 1.
for each wrk break by wrk.opnamt desc.

        put stream m-out "<tr align=""right"">" skip
               "<td align=""center""> " coun "</td>"
               "<td align=""center""> " wrk.ln "</td>"
               "<td align=""left""> " wrk.cif "</td>" skip
               "<td align=""left""> " wrk.name format "x(60)" "</td>"
               "<td align=""left"">&nbsp;" wrk.lon format "x(10)" "</td>"
               "<td> " wrk.opnamt format '>>>>>>>>>>>9.99' "</td>"
               "<td align=""left""> " wrk.crc "</td>"
               "<td> " wrk.prem format '>9.99%' "</td>"
               "<td> " wrk.rdt "</td>" skip
               "<td> " wrk.duedt "</td>"
               "<td> " wrk.dtcls "</td>"
               "<td> " wrk.u "</td>"
               "<td> " wrk.goal format 'x(30)' "</td>"
               "<td> " wrk.comiss format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.prem% format '>>>>>>>>>>>9.99' "</td>"
               "<td> " wrk.gl "</td>" skip
               "<td> " wrk.billsum "</td>"
               "<td> " wrk.asign format "x(40)"  "</td>"
               "<td> " wrk.aliv format "x(40)" "</td>"
               "<td> " wrk.tel format "x(40)" "</td>"
               "<td> " wrk.job format "x(40)" "</td>"
               "<td>&nbsp;" wrk.rnn format "x(12)" "</td>" skip
               "</tr>" skip.

         coun = coun + 1.
end.

put stream m-out unformatted "</table></body></html>" skip.
output stream m-out close.

unix silent cptwin srok.htm excel.
