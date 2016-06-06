/* depport.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        26/10/2011 evseev 
 * BASES
        BANK
 * CHANGES
        25/04/2012 evseev  - rebranding. Название банка из sysc или изменил проверку банка или рко
*/
{nbankBik.i}
{global.i}

def new shared var dt as date.
def var period as char.
def new shared var typerep as integer.


def new shared temp-table tbl no-undo
    field period  as char
    field period1    as char
	field gl   like aaa.gl
	field gl2   like aaa.gl
    field filial as char
    field aaa like aaa.aaa
    field clname as char
    field crc like aaa.crc
    field rdt like aaa.regdt
    field edt like aaa.expdt
    field rate like aaa.rate
    field opnamt like aaa.opnamt
    field ostcrc as decimal
    field ostkzt as decimal
    field sumcrc as decimal
    field sumkzt as decimal
    field kurs like crchis.rate[1]
    field depname as char
    field str1 as char
    field str2 as char
    field str3 as char
    field paydate as date
    field paysumcrc as decimal
    field paysumkzt as decimal.



dt = g-today.
typerep = 1.
period = "Все периоды".

define frame frm
   dt format '99/99/9999' label "Дата        " skip
   period format "x(20)"  label "Период      " validate(period <> "" and lookup(period,"Все периоды,До 7 дней,До 1 месяца,До 3 месяцев,До 6 месяцев,До 1 года,До 3 лет,Свыше 3 лет") > 0 , "Неверный период (Используйте F2)") skip
   typerep                label "Тип отчета  " validate(typerep <> 0 and (typerep = 1 or typerep = 2 or typerep = 3), "Неверный тип отчета (Используйте F2)") skip
with side-labels centered row 8.

on help of typerep in frame frm do:
   run sel ("Выберите тип отчета", "все|юр. лица|физ. лица").
   typerep = int(return-value).
   displ typerep with frame frm.
end.


on help of period in frame frm do:
   run sel ("Выберите период", "Все периоды|До 7 дней|До 1 месяца|До 3 месяцев|До 6 месяцев|До 1 года|До 3 лет|Свыше 3 лет").
   if int(return-value) = 1 then period = "все периоды" . else
   if int(return-value) = 2 then period = "до 7 дней"   . else
   if int(return-value) = 3 then period = "до 1 месяца" . else
   if int(return-value) = 4 then period = "до 3 месяцев". else
   if int(return-value) = 5 then period = "до 6 месяцев". else
   if int(return-value) = 6 then period = "до 1 года"   . else
   if int(return-value) = 7 then period = "до 3 лет"    . else
   if int(return-value) = 8 then period = "свыше 3 лет" .
   displ period with frame frm.
end.

update dt period typerep with frame frm.

def new shared var d1 as integer.
def new shared var d2 as integer.
case period:
  when "Все периоды"  then do: d1 = 0.    d2 = 9999999. end.
  when "до 7 дней"    then do: d1 = 0.    d2 = 6.     end.
  when "до 1 месяца"  then do: d1 = 7.    d2 = 30.    end.
  when "до 3 месяцев" then do: d1 = 31.   d2 = 92.    end.
  when "до 6 месяцев" then do: d1 = 93.   d2 = 182.   end.
  when "до 1 года"    then do: d1 = 183.  d2 = 365.   end.
  when "до 3 лет"     then do: d1 = 366.  d2 = 1095.  end.
  when "свыше 3 лет"  then do: d1 = 1096. d2 = 9999999. end.
end.

empty temp-table tbl.

def var vv-path as char.
find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.

displ "Ждите..." with row 5 centered no-label frame wfr. pause 0.

if bank.cmp.name matches "*МКО*" then vv-path = '/data/'.
else vv-path = '/data/b'.
for each comm.txb where comm.txb.consolid = true no-lock:
    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',vv-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).
    run depport_data(comm.txb.info).
end.
if connected ("txb") then disconnect "txb".



def stream depport1.
output stream depport1 to value ("depport1.html").

{html-title.i
  &stream = " stream depport1 "
  &size-add = "1"
  &title = "Депозитный портфель " + v-nbankru
}
/*
     put stream depport1 unformatted
           "<HTML>" skip
           "<HEAD>" skip
           "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
           "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
           "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: " skip.
*/
put stream depport1 unformatted
  "<P align=""left"" style=""font:bold"">Время создания: " string(today, "99/99/9999")" " string(time,"HH:MM") "</P>" skip
  "<P align=""left"" style=""font:bold"">Депозитный портфель " + v-nbankru + " за " string(dt, "99/99/9999") " </P>" skip
  "<P align=""left"" style=""font:bold"">Консолидированный (" entry(typerep,"все|юр. лица|физ. лица", "|") ")</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
      "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
        "<TD>Период</TD>" skip
        "<TD>Счет ГК</TD>" skip
        "<TD>Филиал</TD>" skip
        "<TD>Счет</TD>" skip
        "<TD>Клиент</TD>" skip
        "<TD>Валю<br>та</TD>" skip
        "<TD>Дата<br>открытия</TD>" skip
        "<TD>Дата<br>закрытия</TD>" skip
        "<TD>Ста<br>вка<br>(%)</TD>" skip
        "<TD>Сумма по<br>договору</TD>" skip
        "<TD>Несниж<br>остаток в<br>валюте<br>счета</TD>" skip
        "<TD>Несниж<br>остаток в<br>тенге</TD>" skip
        "<TD>Сумма в <br>валюте<br>счета</TD>" skip
        "<TD>Сумма<br>конверт. в<br>тенге</TD>" skip
        "<TD>Курс конверт.<br>в тенге</TD>" skip
        "<TD>Группа депозита</TD>" skip
        "<TD>Признак 'Лица <br> связанные с банком <br>особыми <br>отношениями'</TD>" skip
        "<TD>Условине<br>обслуживания</TD>" skip
        "<TD>Основание</TD>" skip
      "</TR>" skip.

for each tbl no-lock:
    if period <> "Все периоды" then do:
       if tbl.period <> period then next.
    end.
    if tbl.sumcrc <> 0 then do:
        put stream depport1 unformatted
          "<TR>" skip
            "<TD> " tbl.period "</TD>" skip
            "<TD> " tbl.gl "</TD>" skip
            "<TD> " tbl.filial "</TD>" skip
            "<TD> " tbl.aaa "</TD>" skip
            "<TD> " tbl.clname "</TD>" skip
            "<TD> " string(tbl.crc) "</TD>" skip
            "<TD> " string(tbl.rdt,"99/99/9999") "</TD>" skip
            "<TD> " string(tbl.edt,"99/99/9999") "</TD>" skip
            "<TD> " replace(string(tbl.rate, "->9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.opnamt, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.ostcrc, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.ostkzt, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.sumcrc, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.sumkzt, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.kurs, ">>>9.99"), ".", ",") "</TD>" skip
            "<TD> " tbl.depname "</TD>" skip
            "<TD> " tbl.str1 "</TD>" skip
            "<TD> " tbl.str2 "</TD>" skip
            "<TD> " tbl.str3 "</TD>" skip
          "</TR>" skip.
    end.
end.

put stream depport1 unformatted  "</TABLE>" skip.




{html-end.i}

output stream depport1 close.



def stream depport2.
output stream depport2 to value ("depport2.html").

{html-title.i
  &stream = " stream depport2 "
  &size-add = "1"
  &title = "Расходы, связанные с выплатой вознаграждения - консолидированный"
}


put stream depport2 unformatted
  "<P align=""left"" style=""font:bold"">Расходы, связанные с выплатой вознаграждения за " string(dt, "99/99/9999") " </P>" skip
  "<P align=""left"" style=""font:bold"">Консолидированный (" entry(typerep,"все|юр. лица|физ. лица", "|") ")</P>" skip
  "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""0"" border=""1"">" skip
      "<TR align=""center"" style=""font:bold;font-size:8pt"">" skip
        "<TD>Период</TD>" skip
        "<TD>Счет ГК</TD>" skip
        "<TD>Филиал</TD>" skip
        "<TD>Клиент</TD>" skip
        "<TD>Валюта</TD>" skip
        "<TD>Ставка<br>(%)</TD>" skip
        "<TD>Дата выплаты<br>вознаграждения</TD>" skip
        "<TD>Начисл. вознагр. в<br>валюте</TD>" skip
        "<TD>Начисл. вознагр.<br>в тенге</TD>" skip
        "<TD>Курс конверт.<br>в тенге</TD>" skip
        "<TD>Группа депозита</TD>" skip
      "</TR>" skip.
for each tbl no-lock:
    if period <> "Все периоды" then do:
       if tbl.period1 <> period then next.
    end.
    if tbl.paysumcrc <> 0 then do:
        put stream depport2 unformatted
          "<TR>" skip
            "<TD> " tbl.period1 "</TD>" skip
            "<TD> " tbl.gl2 "</TD>" skip
            "<TD> " tbl.filial "</TD>" skip
            "<TD> " tbl.clname "</TD>" skip
            "<TD> " string(tbl.crc) "</TD>" skip
            "<TD> " replace(string(tbl.rate, "->9.99"), ".", ",") "</TD>" skip
            "<TD> " string(tbl.paydate,"99/99/9999") "</TD>" skip
            "<TD> " replace(string(tbl.paysumcrc, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.paysumkzt, "->>>>>>>>>>>9.99"), ".", ",") "</TD>" skip
            "<TD> " replace(string(tbl.kurs, ">>>9.99"), ".", ",") "</TD>" skip
            "<TD> " tbl.depname "</TD>" skip
          "</TR>" skip.
    end.
end.

put stream depport2 unformatted  "</TABLE>" skip.


{html-end.i}

output stream depport2 close.

hide frame wfr no-pause.

unix silent value ("cptwin depport1.html excel").
unix silent value ("rm depport1.html").

unix silent value ("cptwin depport2.html excel").
unix silent value ("rm depport2.html").

