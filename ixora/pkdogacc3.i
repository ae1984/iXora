/* pkdogacc3.i
 * MODULE
        ПотребКредит
 * DESCRIPTION
        Печать договора на открытие счета - выдача через платежную карту
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
        10/02/2006 marinav
 * CHANGES
        28/04/2006 madiyar - добавил несколько параметров для замены
        13/09/2006 madiyar - договора - из общей директории /data/docs/
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        22/01/2008 madiyar - изменения в договоре
        23.04.2008 alex - добавил параметры для казахского языка.
        04.06.2008 alex - изменения в договоре (валюта кредита)
*/


define variable v_card as char format "x(16)" .
def stream v-out.
def var v-infile as char.
def var v-str as char.

/*****************************/
find pksysc where pksysc.credtype = '6' and pksysc.sysc = "dcdocs" no-lock no-error.

run pkdogsgn.
v-infile = "bddoc1.htm".

if avail pksysc then  v-infile = pksysc.chval + v-infile.
v_card = pkanketa.rescha[3] .

   run upd_field.

output stream v-out close.
run pkendtable(v-ofile, "БАНК", "КЛИЕНТ", "КЛИЕНТ", false, " style=""FONT-SIZE: 9pt""", no, no, yes).
output stream v-out to value(v-ofile) append.

put stream v-out unformatted
"</P></TD></TR>"
"</TABLE>" skip.


/*****************************/

procedure upd_field.

input from value(v-infile).
repeat:
  import unformatted v-str.
  v-str = trim(v-str).

  repeat:
    if v-str matches "*\{\&v-dol\}*" then do:
        v-str = replace (v-str, "\{\&v-dol\}", v-dol).
        next.
    end.
    if v-str matches "*\{\&v-dolkz\}*" then do:
        v-str = replace (v-str, "\{\&v-dolkz\}", v-dolkz).
        next.
    end.
    if v-str matches "*\{\&v-bankname\}*" then do:
        v-str = replace (v-str, "\{\&v-bankname\}", v-bankname).
        next.
    end.
    if v-str matches "*\{\&v-banknamekz\}*" then do:
        v-str = replace (v-str, "\{\&v-banknamekz\}", v-banknamekz).
        next.
    end.
    if v-str matches "*\{\&v-bankface\}*" then do:
        v-str = replace (v-str, "\{\&v-bankface\}", v-bankface).
        next.
    end.
    if v-str matches "*\{\&v-bankfacekz\}*" then do:
        v-str = replace (v-str, "\{\&v-bankfacekz\}", v-bankfacekz).
        next.
    end.
    if v-str matches "*\{\&v-bankosn\}*" then do:
        v-str = replace (v-str, "\{\&v-bankosn\}", v-bankosn).
        next.
    end. 
    if v-str matches "*\{\&v-bankosnkz\}*" then do:
        v-str = replace (v-str, "\{\&v-bankosnkz\}", v-bankosnkz).
        next.
    end.
    if v-str matches "*\{\&v-banksuff\}*" then do:
        v-str = replace (v-str, "\{\&v-banksuff\}", v-banksuff).
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
    if v-str matches "*\{\&v-dognom\}*" then do:
        v-str = replace (v-str, "\{\&v-dognom\}", v-dognom).
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
    if v-str matches "*\{\&v-card\}*" then do:
        v-str = replace (v-str, "\{\&v-card\}", string(v_card, 'xxxx xxxx xxxx xxxx')).
        next.
    end.
    if v-str matches "*\{\&v-name\}*" then do:
        v-str = replace (v-str, "\{\&v-name\}", "<b>&nbsp;" + v-name + "&nbsp;</b>").
        next.
    end.
    if v-str matches "*\{\&v-iik\}*" then do:
        v-str = replace (v-str, "\{\&v-iik\}", v-iik).
        next.
    end.
    
    if v-iikval ne "" then do:
        if v-str matches "*\{\&jik\}*" then do:
            v-str = replace (v-str, "\{\&jik\}", "<br> ЖИК " + v-iikval + ", Шот валютасы: " + v-credval + ".").
            next.
        end.
        if v-str matches "*\{\&iik\}*" then do:
            v-str = replace (v-str, "\{\&iik\}", "<br> ИИК: " + v-iikval + ", валюта Счета: " + v-credval + ".").
            next.
        end.
    end. 
    else do:
        if v-str matches "*\{\&jik\}*" then do:
            v-str = replace (v-str, "\{\&jik\}", "").
            next.
        end.    
        if v-str matches "*\{\&iik\}*" then do:
            v-str = replace (v-str, "\{\&iik\}", "").
            next.
        end. 
    end.
    
    leave.
  end.

  put stream v-out unformatted v-str skip.
end.
input close.
output stream v-out close.


end.
