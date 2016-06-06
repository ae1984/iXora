/* pkdog-all.i
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Печать договора Народный кредит
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
        13.02.2007 id00005
 * CHANGES
        24/04/2007 madiyar - веб-анкеты
        06/07/07 marinav -   теперь по 7 схеме , как по 5 и 6
        22/01/2008 madiyar - изменения в договоре
        23.04.2008 alex - добавил параметры для казахского языка.
        04.06.2008 alex - изменения в договоре (валюта кредита)
        10/10/2008 alex - добавил наименование организации рефин. кредита
        15/07/2009 madiyar - изменил заголовки и размер шрифта в заключительной таблице
        02/10/2009 galina - выводим созаемщика
*/


def stream v-out.
def var v-ofile as char no-undo.
def var v-infile as char no-undo.
def var v-str as char no-undo.
def var v-paym as char no-undo.


if s-credtype = '5' then  v-com1 = '0,5 % (ноль целых пять десятых процента)'.
if s-credtype = '6' then  v-com1 = '0,5 % (ноль целых пять десятых процента)'.
if s-credtype = '7' then  v-com1 = '0,5 % (ноль целых пять десятых процента)'.

if s-credtype = '5' then  v-paym = 'Очередных платежей, за 3 (три) полных месяца'.
if s-credtype = '6' then  v-paym = 'Очередных платежей, за 3 (три) полных месяца'.
if s-credtype = '7' then  v-paym = 'Очередных платежей, за 3 (три) полных месяца'.

if v-names <> '' then v-ofile  = "dognks.htm".
else v-ofile  = "dognk.htm".
v-infile = "dog.htm".

output stream v-out to value(v-infile).

/*
run pkdogsgn.
*/

find pksysc where pksysc.credtype = '4' and pksysc.sysc = "dcdocs" no-lock no-error.
if avail pksysc then v-ofile = pksysc.chval + v-ofile.
run upd_field.
run pkendtable2(v-infile, "БАНК", "ЗАЕМЩИК", "&#1178;АРЫЗ АЛУШЫ", true, "style=""font-size:12pt""", no, yes, yes).
output stream v-out close.

if v-inet then unix silent value("mv " + v-infile + " /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "; chmod 666 /var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/" + v-infile).
else unix silent value("cptwin " + v-infile + " iexplore").


procedure upd_field.

input from value(v-ofile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  repeat:
    if v-str matches "*\{\&v-dol\}*" then do:
        v-str = replace (v-str, "\{\&v-dol\}", v-dol).
        next.
    end.

    if v-str matches "*\{\&v-dolKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-dolKZ\}", v-dolKZ).
    next.
    end.
    if v-str matches "*\{\&toplogo\}*" then do:
        v-str = replace (v-str, "\{\&toplogo\}", v-toplogo).
        next.
    end.
    if v-str matches "*\{\&v-docnum\}*" then do:
        v-str = replace (v-str, "\{\&v-docnum\}", v-docnum).
        next.
    end.
    if v-str matches "*\{\&v-dognom\}*" then do:
        v-str = replace (v-str, "\{\&v-dognom\}", v-dognom).
        next.
    end.
    if v-str matches "*\{\&v-city\}*" then do:
        v-str = replace (v-str, "\{\&v-city\}", v-city).
        next.
    end.
    if v-str matches "*\{\&v-citykz\}*" then do:
        v-str = replace (v-str, "\{\&v-citykz\}", v-citykz).
        next.
    end.
    if v-str matches "*\{\&v-datastr\}*" then do:
        v-str = replace (v-str, "\{\&v-datastr\}", v-datastr).
        next.
    end.
    if v-str matches "*\{\&v-datastrkz\}*" then do:
        v-str = replace (v-str, "\{\&v-datastrkz\}", v-datastrkz).
        next.
    end.
    if v-str matches "*\{\&v-datadoc\}*" then do:
        v-str = replace (v-str, "\{\&v-datadoc\}", v-datadoc).
        next.
    end.
    if v-str matches "*\{\&v-bankname\}*" then do:
        v-str = replace (v-str, "\{\&v-bankname\}", "<b>&nbsp;" + v-bankname + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-banknamekz\}*" then do:
        v-str = replace (v-str, "\{\&v-banknamekz\}", "<b>&nbsp;" + v-banknamekz + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-bankface\}*" then do:
        v-str = replace (v-str, "\{\&v-bankface\}", "<b>&nbsp;" + v-bankface + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-bankfaceKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-bankfaceKZ\}", "<b>&nbsp;" + v-bankfaceKZ + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-banksuff\}*" then do:
        v-str = replace (v-str, "\{\&v-banksuff\}", v-banksuff).
        next.
    end.
    if v-str matches "*\{\&v-bankosn\}*" then do:
        v-str = replace (v-str, "\{\&v-bankosn\}", "<b>&nbsp;" + v-bankosn + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-bankosnKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-bankosnKZ\}", "<b>&nbsp;" + v-bankosnKZ + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-name\}*" then do:
        v-str = replace (v-str, "\{\&v-name\}", "<b>&nbsp;" + v-name + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-clnames\}*" then do:
        v-str = replace (v-str, "\{\&v-clnames\}", "<b>&nbsp;" + v-names + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-summa\}*" then do:
        v-str = replace (v-str, "\{\&v-summa\}", v-summa).
        next.
    end.
    if v-str matches "*\{\&v-summawrd\}*" then do:
        v-str = replace (v-str, "\{\&v-summawrd\}", v-summawrd).
        next.
    end.
    if v-str matches "*\{\&v-summawrdKZ\}*" then do:
        v-str = replace (v-str, "\{\&v-summawrdKZ\}", v-summawrdKZ).
        next.
    end.
    if v-str matches "*\{\&v-duedt\}*" then do:
        v-str = replace (v-str, "\{\&v-duedt\}", string(v-duedt)).
        next.
    end.
    if v-str matches "*\{\&v-prem\}*" then do:
        v-str = replace (v-str, "\{\&v-prem\}", v-prem).
        next.
    end.
    if v-str matches "*\{\&v-premwrd\}*" then do:
        v-str = replace (v-str, "\{\&v-premwrd\}", v-premwrd).
        next.
    end.
    if v-str matches "*\{\&v-com\}*" then do:
        v-str = replace (v-str, "\{\&v-com\}", v-com).
        next.
    end.
    if v-str matches "*\{\&v-comwrd\}*" then do:
        v-str = replace (v-str, "\{\&v-comwrd\}", v-comwrd).
        next.
    end.
    if v-str matches "*\{\&v-comwrd_kz\}*" then do:
        v-str = replace (v-str, "\{\&v-comwrd_kz\}", v-comwrd_kz).
        next.
    end.
    if v-str matches "*\{\&v-com1\}*" then do:
        v-str = replace (v-str, "\{\&v-com1\}", v-com1).
        next.
    end.
    if v-str matches "*\{\&v-com1wrd\}*" then do:
        v-str = replace (v-str, "\{\&v-com1wrd\}", v-com1wrd).
        next.
    end.
    if v-str matches "*\{\&v-paym\}*" then do:
        v-str = replace (v-str, "\{\&v-paym\}", v-paym).
        next.
    end.
    if v-str matches "*\{\&v-effrate\}*" then do:
        v-str = replace (v-str, "\{\&v-effrate\}", v-effrate).
        next.
    end.
    if v-str matches "*\{\&v-credval\}*" then do:
        v-str = replace (v-str, "\{\&v-credval\}", v-credval).
        next.
    end.
    if v-str matches "*\{\&v-where\}*" then do:
        v-str = replace (v-str, "\{\&v-where\}", v-where).
        next.
    end.
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.

end.