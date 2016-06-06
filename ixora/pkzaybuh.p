/* pkzaybuh.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Печать заявления в бухгалтерию
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
        14.11.03 marinav
 * CHANGES
        08.01.2004 nadejda - добавила обработку параметров &nametxb для прописывания полного названия филиала
        11.01.2004 nadejda - добавила обработку параметров &dognum, &dogdt для прописывания данных договора и подпись менеджера (ТЗ 674)
        07.09.2004 saltanat - добавила вывод в отчет КБЕ и КНП только для Быстрых денег(6).
        21/12/2005 madiyar - электронная печать
        27/12/2005 madiyar - электронная печать должна быть только для ГБ, исправил
        25/08/2006 madiyar - ФИО менеджера
        12/09/2006 madiyar - документы в общей папке; электронная печать, все филиалы
        27/04/2007 madiyar - web-анкета
        07/11/07 marinav -   изменились реквизиты для перечислений денег
        19/01/2010 galina - добавила ИИН
        22/01/2010 galina - поправила шаблон для года на 20___
*/


{global.i}
{pk.i}

/**
s-credtype = "6".
s-pkankln = 100.
*/

if s-pkankln = 0 then return.

find pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and
     pkanketa.ln = s-pkankln no-lock no-error.

if not avail pkanketa then return.

def stream v-out.
def var v-ofile as char.
def var v-ifile as char.
def var v-infile as char.
def var v-str as char.
def var v-acctxb as char.
def var v-nametxb as char.
def var v-name as char.
def var i as integer.
def var v-param as logical.
def var v-dognum as char.
def var v-dogdt as char.
def var v-knp as char init '<BR>КБЕ 19 КНП 421'.
def var v-ofcname as char no-undo.
def var v-datastrkz as char no-undo.

if pkanketa.srok > 12 then v-knp = '<BR>КБЕ 19 КНП 423'.

{sysc.i}
{pk-sysc.i}

def var v-stamp as char no-undo.
if pkanketa.id_org = "inet" then v-stamp = "c:\\tmp\\pkstamp.jpg".
else v-stamp = get-pksysc-char ("dcstmp").

find first cmp no-lock no-error.
if avail cmp then do:
  v-nametxb = cmp.name.
/*  if s-ourbank <> "TXB00" then v-nametxb = "Филиал " + v-nametxb.*/
  v-acctxb = "<BR>" + v-nametxb + "<BR>" + entry(1,cmp.addr[1])  + ", Казахстан<BR>". 
/*    v-acctxb = "<BR>ТОО 'МКО 'Народный кредит' <BR>" + "г. Алматы, Казахстан<BR>".*/
end.

find first point where point.point = 1 no-lock no-error.
if avail point then do:
   v-acctxb =  v-acctxb + 'БИК ' + get-sysc-cha ("clecod") + '<BR>РНН ' + trim(cmp.addr[2])
             + "<BR>ФИО " + pkanketa.name + "<BR>р/сч " + pkanketa.aaa + "<BR>РНН " + pkanketa.rnn .
end.

find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
if avail pkanketh and pkanketh.value1 <> "" then v-acctxb =  v-acctxb + "<BR>ИИН " + pkanketh.value1.
else v-acctxb =  v-acctxb + "<BR>ИИН ".
/* номер и дата договора */
v-dognum = entry(1, pkanketa.rescha[1]).
run pkdefdtstr(pkanketa.docdt, output v-dogdt, output v-datastrkz).
if index (v-dogdt, "г.") = 0 then v-dogdt = v-dogdt + "&nbsp;г.".

v-name = pkanketa.name.

/* печать заявления */

v-ofile = "zayav.htm".
v-infile = "zayavbuh.htm".
output stream v-out to value(v-ofile).


v-ifile = get-pksysc-char ("dcdocs").
if not v-ifile begins "/" then v-ifile = "/" + v-ifile.
if substr (v-ifile, length(v-ifile), 1) <> "/" then v-ifile = v-ifile + "/".
v-ifile = v-ifile + v-infile.

input from value(v-ifile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  /* заменить параметры на данные клиента */
  repeat:
    if v-str matches "*\{\&acctxb\}*" then do:
        v-str = replace (v-str, "\{\&acctxb\}", v-acctxb).
        next.
    end.
    if v-str matches "*\{\&nametxb1\}*" then do:
        v-str = replace (v-str, "\{\&nametxb1\}", replace(v-nametxb, "филиал", "филиале")).
        next.
    end.
    if v-str matches "*\{\&nametxb2\}*" then do:
        v-str = replace (v-str, "\{\&nametxb2\}", replace(v-nametxb, "филиал", "филиалом")).
        next.
    end.

    if v-str matches "*\{\&dognum\}*" then do:
        v-str = replace (v-str, "\{\&dognum\}", v-dognum).
        next.
    end.
    if v-str matches "*\{\&dogdt\}*" then do:
        v-str = replace (v-str, "\{\&dogdt\}", v-dogdt).
        next.
    end.
    
    if v-str matches "*\{\&vname\}*" then do:
        v-str = replace (v-str, "\{\&vname\}", "<u>&nbsp;" + v-name + "&nbsp;</u>").
        next.
    end.
    
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.

input close.

v-ofcname = ''.
find first ofc where ofc.ofc = g-ofc no-lock no-error.
if avail ofc then v-ofcname = trim(ofc.name).

put stream v-out unformatted
  "<TABLE width=""95%"" border=""0"" cellspacing=""0"" cellpadding=""0"" align=""center"" valign=""top"">" skip
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%"">___________________________________ </TD>" skip
      "<TD width=""50%"">_______________________</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"" style=""font-size:xx-small"">" skip
      "<TD width=""50%"">(Ф.И.О. полностью) </TD>" skip
      "<TD width=""50%"">(подпись)</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%""></TD>" skip
      "<TD width=""50%"">________________20_____г</TD>" skip
    "</TR>" skip
    "<TR><TD colspan=""2"">&nbsp;</TD></TR>" skip
    "<TR valign=""top"" align=""left"">" skip
      "<TD colspan=""2"">Менеджер, принявший заявление:</TD>" skip
    "</TR>" skip
    "<TR><TD colspan=""2"">&nbsp;</TD></TR>" skip
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%"">"
      if v-ofcname <> '' then "<u><i>&nbsp;" + v-ofcname + "&nbsp;</i></u>" else "___________________________________"
      "</TD>" skip
      "<TD width=""50%"">_______________________</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"" style=""font-size:xx-small"">" skip
      "<TD width=""50%"">(Ф.И.О. полностью) </TD>" skip
      "<TD width=""50%"">(подпись)</TD>" skip
    "</TR>"
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%""></TD>" skip
      "<TD width=""50%"">________________20_____г</TD>" skip
    "</TR>" skip
    "<TR valign=""top"" align=""center"">" skip
      "<TD width=""50%"">" skip.

 put stream v-out unformatted "<IMG border=""0"" src=""" + v-stamp + """ width=""160"" height=""160"" >" skip.

put stream v-out unformatted
      "</TD>" skip
      "<TD width=""50%""></TD>" skip
    "</TR>" skip
"</TABLE>" skip.

{html-end.i "stream v-out"}

output stream v-out close.

if pkanketa.id_org = "inet" then unix silent value("mv " + v-ofile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-ofile).
else unix silent cptwin value(v-ofile) iexplore.
