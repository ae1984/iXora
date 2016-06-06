/* almtvimp.p
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
        10/05/2006 dpuchkov
 * CHANGES
        21.06.2006 tsoy     - В связи с письмом Ксении убрал комиссию
        12.02.2007 id00004 добавил alias
        19.03.2007 id00004 Изменил адрес электронной почты.
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


def var v-tarif as decimal init 0.
find first tarif2 where tarif2.num = '5' and tarif2.kod = '83' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then do:
   v-tarif = tarif2.proc.
end.
if v-tarif = 0 then  do:
   message "Внимание: не настроены тарифы".
   return.
end.

def shared var g-today as date.
def var dat as date.
def var out as char.
dat = g-today.
update dat label "Укажите дату".
out = "atv" + string(TIME) + ".txt".

if not can-find(first mobi-almatv where mobi-almatv.dt = dat) then do:
    message "Нет платежей для отправки.".
/*    return.*/
end.

if can-find(first mobi-almatv no-lock where mobi-almatv.dt = dat and mobi-almatv.state < 1) then do:
    message "Не все платежи зачислены на счет Алма-ТВ. Отправка файла невозможна!!!".
    return.
end.
        
if can-find(first mobi-almatv no-lock where mobi-almatv.dt = dat and mobi-almatv.state < 2) then do:
    message "Не все платежи отправлены. Отправка файла невозможна!!!".
    return.
end.
        
OUTPUT TO almatv.txt.

/* state = 3 : комиссия зачислена  state = 5 - безакцепт*/
FOR EACH mobi-almatv where mobi-almatv.dt = dat and mobi-almatv.state <> 0 and mobi-almatv.state <> 5  no-lock:

    find last comm.almatv where comm.almatv.ndoc = mobi-almatv.ndoc use-index ndoc_dt_idx no-lock no-error.

    if avail comm.almatv then do:
     put
     comm.almatv.Ndoc FORMAT "ALMATV99999999" 
     comm.almatv.Summ FORMAT "->>>>>>>>>>9.99" 
     al-right(comm.almatv.address,120) format "x(120)"
     al-right(comm.almatv.house,9) FORMAT "x(9)" 
     al-right(comm.almatv.flat,10) FORMAT "x(10)"
     al-right(comm.almatv.f,35) format "x(35)"
     al-right(comm.almatv.io,30) format "x(30)"
     accnt FORMAT "999999999" 
     day(comm.almatv.Dt) FORMAT "  99"
     month(comm.almatv.Dt) FORMAT "99"
     year(comm.almatv.Dt) FORMAT "9999" 
/*   mobi-almatv.summ - round((mobi-almatv.summ * v-tarif / 100), 2) FORMAT "999999999.99" */
     mobi-almatv.summ  FORMAT "999999999.99" 
     mobi-almatv.dt format "99/99/99"
     "1"
     skip.
end.
END.
OUTPUT CLOSE.

unix silent value('un-win almatv.txt ' + out).

run mail("export@mail.metrobank.kz,municipal" + ourbank + "@metrobank.kz","abpk@metrobank.kz", "encrypt_for_atv", "", "1", "", out). 

unix silent rm -f almatv.txt.
unix silent value("rm -f " + out).

