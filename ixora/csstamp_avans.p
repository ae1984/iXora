/* csstamp1.p
 * MODULE
        Кассовый модуль
 * DESCRIPTION
        Штамп пополнения ЭК
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
        26/02/2011 marina
 * BASES
        BANK COMM
 * CHANGES

                20/06/2012 Luiza - заменила слово ТЕМПО-КАССА на МИНИКАССУ
*/


{mainhead.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).
define new shared variable s-jh      like jh.jh.
define variable v-deb          like gl.gl no-undo.
define variable v-cre          like gl.gl no-undo.
define variable v-arp          like arp.arp no-undo.
define variable v-nomer        like cslist.nomer no-undo.
define variable v-id           as character no-undo.
define variable v-dispensedAmt as decimal   no-undo.
define variable v-acceptedAmt  as decimal   no-undo.
define variable v-auxOut       as character no-undo.
define variable v-tmpl    as character no-undo.
define variable v-sum     as decimal   no-undo.
define variable v-sumarp  as decimal   no-undo.
define variable v-crc     like crc.crc.
define variable v-crc_val as character no-undo format "xxx".
define variable v-dc      as character no-undo.
define variable v-rem     as character no-undo .
define variable sumstr    as character.
define variable v_trx     as integer   no-undo.
define variable v-joudoc  as character format "x(10)" no-undo.
define variable v-kod     as character no-undo init "14".
define variable v-kbe     as character no-undo init "14".
define variable v-knp     as character no-undo init "890".
define variable v-ja      as logi      no-undo format "yes/no".
define variable v-glrem   as character no-undo.
define variable v-param   as character no-undo.
define variable vdel      as character no-undo initial "^".
define variable rcode     as integer   no-undo.
define variable rdes      as character no-undo.
define variable v-select  as integer   no-undo.
define variable v_title   as character no-undo. /*наименование платежа */
define variable sure      as log       init false.
define variable v-jh      like jh.jh.
define variable v-sts     like jh.sts.
{keyord.i}

format
    v-joudoc label " Документ        " format "x(10)"  v_trx label "  ТРН " format "zzzzzzzzz"      skip
    v-nomer  label " Номер ЭК        " validate(can-find(cslist where cslist.nomer = v-nomer and cslist.bank = s-ourbank no-lock), " ЭК не вашего филиала! ") skip
    v-crc    label " Валюта          " validate(can-find(crc where crc.crc = v-crc no-lock), " Введите валюту! F2 - помощь.") help "F2 - справочник" v-crc_val no-labels skip
    v-arp    label " Дебет   100500  " skip
    v-sum    label " Сумма           " validate(v-sum > 0, "Hеверное значение суммы") format ">>>,>>>,>>>,>>>,>>9.99" skip
    v-rem    label " Примечание      " format "x(50)" skip
    v-kod    label " Код             " format "x(2)" skip
    v-kbe    label " Кбе             " format "x(2)" skip
    v-knp    label " КНП             " format "x(3)" skip(1)
    v-ja     label " Штамповать транзакцию?   "
    with  side-labels centered row 7 title v_title width 80 frame f_main.

format v-jh label "Транзакция" with centered side-label frame vvv .
format v-jh label "Транзакция" with centered side-label frame vvv1 .

define query q-trx for joudoc,joudop,jh,jl.
define browse b-trx query q-trx
    display jh.party label "Документ " format "x(10)" jl.jh format "9999999" label "Транзакц"  jl.sts label "Статус" format "9"
    jl.rem[1] label "Описание " format "x(30)" jl.who label "Исполнитель" format "x(7)" WITH  15 DOWN.
define frame f-trx b-trx  with overlay 1 column side-labels row 11 column 10 width 100 no-box.

on help of v-jh in frame vvv
    do:
            open query  q-trx for each joudoc where joudoc.whn = g-today no-lock, each joudop where joudop.docnum = joudoc.docnum and joudop.type = "VTK2" ,
                each jh where jh.jh = joudoc.jh and jh.sts = 5 no-lock, each jl where jl.jh = jh.jh and jl.trx = "jou0066"
                and jl.dc = "D" no-lock.
        enable all with frame f-trx.
        wait-for return of frame f-trx
            focus b-trx in frame f-trx.
        v-jh = jh.jh.
        hide frame f-trx.
        display v-jh with frame vvv.
    end.
on help of v-jh in frame vvv1
    do:
            open query  q-trx for each joudoc where joudoc.whn = g-today no-lock, each joudop where joudop.docnum = joudoc.docnum and joudop.type = "PTK2" ,
                each jh where jh.jh = joudoc.jh and jh.sts = 5 no-lock, each jl where jl.jh = jh.jh and  jl.trx = "jou0067"
                and jl.dc = "C" no-lock.
        enable all with frame f-trx.
        wait-for return of frame f-trx
            focus b-trx in frame f-trx.
        v-jh = jh.jh.
        hide frame f-trx.
        display v-jh with frame vvv1.
    end.
on "END-ERROR" of frame f-trx
    do:
        hide frame f-trx no-pause.
    end.


v-select = 0.
run sel2 (" КОНТРОЛЬ ", "1. КОНТРОЛЬ ВЫДАЧИ В ТЕМПО-КАССУ |2. КОНТРОЛЬ ПРИЕМА ИЗ ТЕМПО-КАССЫ  |3. ВЫХОД ", output v-select).
if (v-select < 1) or (v-select > 2) then return.
if v-select = 1 then v_title = "Контроль выдачи в миникассу". else v_title = "Контроль приема из миникассы ".
v-jh = 0.
display v_title no-labels format "x(30)" with centered row 5 frame sss.

if v-select  = 1 then update v-jh label "Транзакция" with frame vvv .
else update v-jh label "Транзакция" with frame vvv1 .


find jh where jh.jh eq v-jh no-lock no-error.
find first jl where jl.jh = jh.jh no-error .

if not available jl then
do:
    message " Транзакция не найдена " view-as alert-box.
    return.
end.
find first joudoc where joudoc.jh = jh.jh no-lock no-error.
if not available joudoc then
do:
    message "не найден jou документ" view-as alert-box.
    return.
end.
find first joudop where joudop.docnum = joudoc.docnum no-lock no-error.
if not available joudop then
do:
    message "не найдена запись в таблице joudop" view-as alert-box.
    return.
end.
if v-select  = 1 and joudop.type <> "VTK2" and joudop.type <> "PTK2" then
do:
    message " Документ не относится к типу выдача в миникассу" view-as alert-box.
    undo, return.
end.
if v-select = 2 and joudop.type <> "VTK2" and joudop.type <> "PTK2" then
do:
    message " Документ не относится к типу прием из миникассы" view-as alert-box.
    undo, return.
end.
if jl.sts = 6 then
do:
    message " Транзакция уже отштампована! " view-as alert-box.
    return.
end.


find first jl where jl.jh = v-jh and jl.gl = 100500 no-lock no-error.
if available jl then assign v-arp = jl.acc v-crc = jl.crc v-sum = jl.dam + jl.cam v-rem = jl.rem[1] v-dc = jl.dc.

find first crc where crc.crc = v-crc no-lock no-error.
if available crc then v-crc_val = crc.code.

v-joudoc = jh.party.
display v-joudoc with frame f_main.

v-nomer = joudop.doc1.
v-crc = joudoc.drcur.
if v-select = 1 then v-arp = joudoc.dracc. else  v-arp = joudoc.cracc.
v-sum = joudoc.dramt.
v-rem = joudoc.remark[1].
v_trx = joudoc.jh.
find first crc where crc.crc = v-crc no-lock no-error.
if available crc then v-crc_val = crc.code.
display v_trx v-nomer v-crc v-crc_val v-arp  v-sum v-rem v-kod v-kbe v-knp with frame f_main.

update  v-ja with frame f_main.


if v-ja then do:
    do transaction on error undo, retry:
        if g-ofc = joudop.lname then do:


         run trxsts(v-jh,6,output rcode, output rdes).
         if rcode <> 0 then do:
            message rdes view-as alert-box.
            return.
         end.



            find first sysc where sysc.sysc = 'CASHGL500' no-lock no-error.
            for each jl where jl.jh = v-jh no-lock:
             if jl.gl = sysc.inval then do:
               find first cashofc where cashofc.whn eq g-today and cashofc.crc eq jl.crc and cashofc.sts eq 2 and cashofc.ofc = g-ofc no-error.
               if available cashofc then cashofc.amt = cashofc.amt + jl.dam - jl.cam.
               else do:
                  create cashofc.
                  cashofc.who = jl.who.
                  cashofc.ofc = g-ofc.
                  cashofc.whn = g-today.
                  cashofc.crc = jl.crc.
                  cashofc.sts = 2.
                  cashofc.amt = jl.dam - jl.cam.
               end.  /* else do */
             end.
            end.

            /*
            if v-noord = no then run vou_bankt(1, 1, joudoc.info).
            else run printord(v-jh,"").
            */
            message v_title "завершен успешно!~nПроводка " v-jh " отштампована" view-as alert-box.


        end.
        else do:
          message "Проводку должен штамповать " joudop.lname view-as alert-box.
          return.
        end.


    end.


end.  /* if v-ja*/
