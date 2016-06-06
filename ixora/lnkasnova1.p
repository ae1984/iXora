/* lnkasnova1.p
 * MODULE
        Кредитный модуль
 * DESCRIPTION
        Оплата кредита КассаНова через кассу
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункет меню
 * AUTHOR
        12/05/2010 marina
 * BASES
        BANK COMM
 * CHANGES
        08.12.10 marinav - комиссия в тенге, потому ищем счет кассы в пути в тенге
        11.12.10 marinav - новый шаблон с Кбе jou0027
        01.02.2012 lyubov - изменила символ кассплана (150 на 090 и 200 на 100)
        12.03.2012 damir - отменил печать операционных и кассовых ордеров на матричный принтер,keyord.i, передаю v-benname.
*/

{mainhead.i}
{keyord.i} /*Переход на новые и старые форматы выходных форм*/

def var s_account_a as char no-undo.
def var s_account_b1 as char no-undo.
def var s_account_b2 as char no-undo.
def var c-gl like gl.gl no-undo.
def var c-gl1002 like gl.gl no-undo.
def var v-rmz  like remtrz.remtrz no-undo.
define new shared var s-remtrz like remtrz.remtrz.

find last sysc where sysc.sysc = "cashgl" no-lock no-error.
if avail sysc then
	c-gl = sysc.inval.
else
	c-gl = 100100.
find last sysc where sysc.sysc = "904kas" no-lock no-error.
if avail sysc then
	c-gl1002 = sysc.inval.
else
	c-gl1002 = 100200.

def var v-yn 	as log init false 	no-undo. /*получаем признак работы касса/касса в пути*/
def var v-err	as log init false 	no-undo. /*получаем признак возникновения ошибки*/

def var v-tmpl as char no-undo.

def var s-ourbank as char.
find sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
    display " There is no record OURBNK in bank.sysc file !!".
    pause.
    return.
end.
s-ourbank = trim(sysc.chval).
if s-ourbank = 'TXB00' then do:
   message "Для ЦО эта операция недоступна !" view-as alert-box.
   return.
end.

find sysc where sysc.sysc = "transf" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " В настройках нет записи transf  !!".   pause.   return.
end.

find first cmp no-lock no-error.

def temp-table t-ln no-undo
    field code like codfr.code
    field name as char
    index main is primary code.

    create t-ln.
    t-ln.code = "421".
    t-ln.name = "Погашение краткосрочного займа".
    create t-ln.
    t-ln.code = "423".
    t-ln.name = "Погашение долгосрочного займа".

def temp-table t-ben no-undo
    field code as char
    field name as char
    index main is primary code.

    create t-ben.
    t-ben.code = "1".
    t-ben.name = "ТОО МКО KASSA-1".
    create t-ben.
    t-ben.code = "2".
    t-ben.name = "ТОО МКО KASSA-2".
    create t-ben.
    t-ben.code = "3".
    t-ben.name = "ТОО МКО KASSA-3".
    create t-ben.
    t-ben.code = "4".
    t-ben.name = "ТОО МКО KASSA-4".

def var v-sum as deci no-undo.
def var v-crc like crc.crc.
def var v-crc_val as char no-undo format "xxx".
def var v-ben as char no-undo.
def var v-benname as char no-undo .
def var v-iik like aaa.aaa.
def var v-kod as char no-undo init "19".
def var v-kbe as char no-undo init "15".
def var v-knp as char no-undo.
def var v-codename as char no-undo .
def var v-sum_com as deci no-undo.
def var v-fio as char no-undo format "x(60)".
def var v-rnn like cif.jss.
def var v-dog as char no-undo format "x(10)".
def var v-acc like aaa.aaa.
def var v-rnnb as char init "".
def var v-bank as char init "Филиал АО 'АТФ Банк' г.Алматы".
def var v-bik as char init "ALMNKZKA".

def var v-ja as logi no-undo format "Да/Нет" init no.

def new shared var s-jh like jh.jh.
def var v-glrem as char no-undo.
def var v-param as char no-undo.
def var vdel as char no-undo initial "^".
def var rcode as int no-undo.
def var rdes as char no-undo.

def new shared var v_doc as char.



form  skip(1)
    v-sum label "Сумма          " format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-crc label "Валюта         " v-crc_val no-label skip
    v-ben label "Бенефициар     " format "x(3)" validate(lookup(v-ben,"1,2,3,4") > 0 , "Введите номер! См. справочник (F2)") help "F2 - справочник"  v-benname no-label format "x(40)" skip
    v-iik label "ИИК            " format "x(20)" skip
    v-rnnb label "РНН            " format "x(12)" skip
    v-bank label "Банк бенефиц   " format "x(30)" skip
    v-bik label "БИК Банка      " format "x(8)" skip
    v-kod label "Код            " format "x(2)" skip
    v-kbe label "Кбе            " format "x(2)" skip
    v-knp label "КНП            " format "x(3)" validate(v-knp = "421" or v-knp = "423", "Введите КНП! См. справочник (F2)") help "F2 - справочник" v-codename no-label format "x(40)" skip
    v-sum_com label "Сумма комиссии " format ">>>,>>9.99"  "(код комиссии 431)" skip(2)
  '----------------------------Назначение платежа---------------------------' at 5 skip
    v-fio label "ФИО       " format "x(60)" validate(trim(v-fio) ne "", "Введите данные по плательщику!") skip
    v-rnn label "РНН       " validate(trim(v-rnn) ne "", "Введите РНН плательщика!") skip
    v-dog label "Номер и дата договора " format "x(45)" validate(trim(v-dog) ne "", "Введите данные по договору") skip(1)
    v-ja label "Формировать транзакцию?   " skip(1)
with centered side-label row 7 width 80 overlay  title 'Погашение кредитов Банка Kassa Nova' frame fr1.

on help of v-knp in frame fr1 do:
    {itemlist.i
       &file = "t-ln"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ln.code label 'КОД' format 'x(3)'  t-ln.name label 'НАЗВАНИЕ' format 'x(30)' "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
    }
    v-knp = t-ln.code.
    displ v-knp with frame fr1.
end.

on help of v-ben in frame fr1 do:
    {itemlist.i
       &file = "t-ben"
       &frame = "row 6 centered scroll 1 12 down overlay "
       &where = " true "
       &flddisp = " t-ben.code label 'КОД' format 'x(3)'  t-ben.name label 'НАЗВАНИЕ' format 'x(30)' "
       &chkey = "code"
       &chtype = "string"
       &index  = "main"
       &end = "if keyfunction(lastkey) eq 'end-error' then return."
    }
    v-ben = t-ben.code.
    displ v-ben with frame fr1.
end.

v-crc = 1.
find first crc where crc.crc = v-crc no-lock no-error.
if avail crc then v-crc_val = crc.code.
else do:
    message "Ошибка определения валюты кредита" view-as alert-box error.
    return.
end.
find first tarif2 where tarif2.str5 = '431' and tarif2.stat = 'r' no-lock no-error.
if avail tarif2 then v-sum_com = tarif2.ost.
displ v-crc v-crc_val v-kod v-kbe v-fio v-sum_com v-ja with frame fr1.
update v-sum with frame fr1.

update v-ben with frame fr1.
find first t-ben where t-ben.code = v-ben no-lock no-error.
if avail t-ben then v-benname = t-ben.name.
displ v-benname with frame fr1.

find pksysc where pksysc.sysc = "kasnva" no-lock no-error.
if not avail pksysc or pksysc.chval = "" then do:
    display " В настройках нет записи kasnov  !!".
    pause.
    return.
end.
v-iik = entry(integer(v-ben),trim(pksysc.chval)).

find pksysc where pksysc.sysc = "kasnvr" no-lock no-error.
if not avail pksysc or pksysc.chval = "" then do:
    display " В настройках нет записи kasnov  !!".
    pause.
    return.
end.
v-rnnb = entry(integer(v-ben),trim(pksysc.chval)).

displ v-iik v-rnnb v-bank v-bik with frame fr1.
update v-knp with frame fr1.
find first t-ln where t-ln.code = v-knp no-lock no-error.
if avail t-ln then v-codename = "(" + t-ln.name + ")".
displ v-codename with frame fr1.
update v-fio v-rnn v-dog with frame fr1.
v-ja = no.
update v-ja with frame fr1.

run get100200arp(input g-ofc, input v-crc, output v-yn, output s_account_b1, output v-err).
if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
do:
    v-err = not v-err.
    message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip "произошла ошибка!" view-as alert-box error.
    return.
end.

if v-yn then s_account_a = "".
else do:
    s_account_a = string(c-gl).
    s_account_b1 = "".
end.
run get100200arp(input g-ofc, input 1, output v-yn, output s_account_b2, output v-err).
if v-err then /*если ошибка имела место, то еще раз скажем об этом пользователю*/
do:
    v-err = not v-err.
    message "В процессе определения режима работы - 'КАССА'/'КАССА В ПУТИ'" skip "произошла ошибка!" view-as alert-box error.
    return.
end.

if v-yn then s_account_a = "".
else do:
    s_account_a = string(c-gl).
    s_account_b2 = "".
end.

/*********************************************************************/

if v-ja then do:

    v-glrem = "Погашение кредита " + v-fio + " РНН " + v-rnn + " по договору займа " + v-dog.


    if s_account_a = string(c-gl) and s_account_b1 = '' then do:
        v-tmpl = "jou0027".
        v-param = string(v-sum) + vdel + string(v-crc) + vdel + entry(v-crc,trim(sysc.chval)) + vdel + v-glrem + vdel +
                         "1" + vdel + "1" + vdel + "9" + vdel + "4" + vdel + v-knp .
    end.
    else do:
        v-tmpl = "jou0036".
        v-param = "" + vdel + string(v-sum) + vdel + string(v-crc) + vdel + s_account_b1 + vdel + entry(v-crc,trim(sysc.chval)) + vdel + v-glrem + vdel +
                     "1" + vdel + "1" + vdel + v-knp .
    end.

    s-jh = 0.
    run trxgen (v-tmpl, vdel, v-param, "arp", "" , output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.  pause 1000.  next.
    end.
    run jou.
    v_doc = return-value.
    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v_doc.

    if jh.sts < 5 then jh.sts = 5.
    for each jl of jh:
        if jl.sts < 5 then jl.sts = 5.
    end.
    find current jh no-lock.
    run setcsymb (s-jh, 090).
    find first joudoc where joudoc.docnum = v_doc no-error.
    if avail joudoc then do:
        joudoc.info = v-fio . joudoc.perkod = v-rnn.
    end.

    define var v-chk as char no-undo.
    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
    if not avail acheck then do:
        v-chk = "".
        v-chk = string(NEXT-VALUE(krnum)).
        create acheck.
        assign acheck.jh  = string(s-jh)
              acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
              acheck.dt = g-today
              acheck.n1 = v-chk.
        release acheck.
    end.

    if v-noord = no then run vou_bank2(2,1, joudoc.info).
    else run printord(s-jh,v-benname).

    /*       run vou_bank(2).*/

    /*Комиссия*/
    if s_account_a = string(c-gl) and s_account_b1 = '' then do:
        v-tmpl = "jou0025".
        v-param = "" + vdel + string(v-sum_com) + vdel + "1" + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp + vdel +
                         "1" + vdel + "9" .
    end.
    else do:
        v-tmpl = "jou0021".
        v-param = "" + vdel + string(v-sum_com) + vdel + "1" + vdel + s_account_b2 + vdel + string(tarif2.kont) + vdel + "Комиссия " + tarif2.pakalp .
    end.

    s-jh = 0.
    run trxgen (v-tmpl, vdel, v-param, "", "" , output rcode, output rdes, input-output s-jh).
    if rcode ne 0 then do:
        message rdes.  pause 1000.  next.
    end.
    run jou.
    v_doc = return-value.
    find first jh where jh.jh = s-jh exclusive-lock.
    jh.party = v_doc.

    if jh.sts < 5 then jh.sts = 5.
    for each jl of jh:
        if jl.sts < 5 then jl.sts = 5.
    end.
    find current jh no-lock.
    run setcsymb (s-jh, 100).
    find first joudoc where joudoc.docnum = v_doc no-error.
    if avail joudoc then do:
          joudoc.info = v-fio . joudoc.perkod = v-rnn.
    end.
    find last acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
    if not avail acheck then do:
        v-chk = "".
        v-chk = string(NEXT-VALUE(krnum)).
        create acheck.
        assign acheck.jh  = string(s-jh)
              acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk
              acheck.dt = g-today
              acheck.n1 = v-chk.
        release acheck.
    end.

    if v-noord = no then run vou_bank2(2,1, joudoc.info).
    else run printord(s-jh,v-benname).
    /* run vou_bank(2).*/


    /* rmz в головной */
    find first arp where arp.arp = entry(v-crc,trim(sysc.chval)) no-lock no-error.
    run rmzcre (
    1    ,
    v-sum     ,
    entry(v-crc,trim(sysc.chval)) ,
    v-rnn         ,
    v-fio         ,
    v-bik         ,
    v-iik         ,
    v-benname     ,
    v-rnnb        ,
    '0'           ,
    no            ,
    v-knp         ,
    '19'          ,
    '15'          ,
    v-glrem       ,
    'P'          ,
    1             ,
    1             ,
    g-today        ) .

    v-rmz = return-value.
    find first remtrz where remtrz.remtrz = v-rmz exclusive-lock no-error.
    if avail remtrz then do:
        remtrz.source = 'P'.
        remtrz.ordins[1] = " ".
        remtrz.ordins[2] = " ".
        remtrz.valdt1 = g-today.
        remtrz.valdt2 = g-today.
    end.
    s-remtrz = v-rmz.
    run v-rmtrxv.
end.


