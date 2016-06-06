/* almtvimp.p
 * MODULE
        Коммунальные платежи (Alma TV)
 * DESCRIPTION
        Отправка реестра по Alma TV
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
        16.01.2004 nadejda - отправитель письма по эл.почте изменен на общий адрес abpk@elexnet.kz
        12.04.2004 kanat   - cursfk заменил на 1
        07.05.2004 sasco   - отправка только когда state = 3 (комиссия зачислена)
        29/06/2004 kanat   - отправка платежа осуществлется только после отправки state = 2 
        08/07/2004 kanat   - отправляются все зачисленные на АРП платежи
        10.06.05   marinav - state = 5 безакцепт не обрабатывать
	24.01.06   u00121  - убрал  из рассылки litosh
	14/08/2006 sasco   - добавил проверку на deluid в поиске незачисленных платежей
*/

/* KOVAL настройка для филиалов */
{get-dep.i}
{comm-txb.i}
def var ourbank as char.
def var ourcode as integer.
def var ourlist as char init ''.
ourbank = comm-txb().
ourcode = comm-cod().

function al-right returns char (cl as char,i as integer).
 RETURN fill( " ", i - LENGTH(cl) ) + trim (cl).
end.


def shared var g-today as date.
def var dat as date.
def var out as char.
dat = g-today.
update dat label "Укажите дату".
out = "atv" + string(TIME) + ".txt".

if not can-find(first almatv where almatv.txb = ourcode and dtfk = dat) then do:
    message "Нет платежей для отправки.".
/*    return.*/
end.

if can-find(first almatv no-lock where dtfk = dat and state < 1 and almatv.deluid = ? and almatv.txb=ourcode) then do:
    message "Не все платежи зачислены на счет Алма-ТВ. Отправка файла невозможна!!!".
    return.
end.
        
if can-find(first almatv no-lock where dtfk = dat and state < 2 and almatv.deluid = ? and almatv.txb=ourcode) then do:
    message "Не все платежи отправлены. Отправка файла невозможна!!!".
    return.
end.
        
OUTPUT TO almatv.txt.

/* state = 3 : комиссия зачислена  state = 5 - безакцепт*/
FOR EACH almatv where dtfk = dat and state <> 0 and state <> 5 and almatv.deluid = ? and almatv.txb=ourcode no-lock:
     put
     Ndoc FORMAT "ALMATV99999999" 
     Summ FORMAT "->>>>>>>>>>9.99" 
     al-right(address,120) format "x(120)"
     al-right(house,9) FORMAT "x(9)" 
     al-right(flat,10) FORMAT "x(10)"
     al-right(almatv.f,35) format "x(35)"
     al-right(io,30) format "x(30)"
     accnt FORMAT "999999999" 
     day(Dt) FORMAT "  99"
     month(Dt) FORMAT "99"
     year(Dt) FORMAT "9999" 
     summfk FORMAT "999999999.99" 
     almatv.dtfk format "99/99/99"
     "1"
     skip.
END.
OUTPUT CLOSE.

unix silent value('un-win almatv.txt ' + out).

run mail("export@mail.texakabank.kz,municipal" + ourbank + "@elexnet.kz","abpk@elexnet.kz", "encrypt_for_atv", "", "1", "", out).

unix silent rm -f almatv.txt.
unix silent value("rm -f " + out).

/*
output through value("ftp -nc  192.168.2.6") no-echo.
put unformatted
"user alma_TV D13M06dsws" skip
"put" skip
"almatv.866" skip
"outgoing/" out skip.
output close.
*/
