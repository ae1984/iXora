/*lccbo2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт второго менеджера бэк-офиса + проводки
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
        16/03/2011 id00810
 * BASES
        BANK COMM
 * CHANGES
        08/04/2011 id00810 - иная комиссия, без тарификатора
        14/04/2011 id00810 - комиссия 997 за счет аппликанта или 997а - за счет бенефициара
        04/05/2011 id00810 - комиссия 996
        11/08/2011 id00810 - новый вид оплаты Chrgs at BNFs expense
        03/11/2011 id00810 - добавлена проверка валюты при выборе шаблона для условия lceventres.comcode = ''
        04/11/2011 id00810 - переменная s-type(тип комиссии)
        23/11/2011 id00810 - добавлено заполнение полей lceventres.com, lceventres.comcode для s-type > 1
        14/12/2011 id00810 - 2 критерия: сумма с НДС и без НДС для s-type = '3'
        30/01/2012 id00810 - для всех типов комиссий формирование проводок на основе lceventres
        08.06.2012 Lyubov  - добавила параметры ЕКНП в транзакции
        28.06.2012 Lyubov  - для гарантий проводки делаются иначе
        23.01.2013 Lyubov  - ТЗ № 1274, для DC не проверяем покрытие
        18.11.2013 Lyubov  - ТЗ № 2180, при выходе по F4 статус не меняется
*/

{global.i}

def shared var v-cif    as char.
def shared var s-lc     like lc.lc.
def shared var s-event  like lcevent.event.
def shared var s-number like lcevent.number.
def shared var s-sts    like lcevent.sts.
def shared var s-type   as char.
def shared var s-lcprod as char.

def var v-lccow   as char no-undo.
def var v-comacc  as char no-undo.
def var v-param   as char no-undo.
def var vdel      as char no-undo initial "^".
def var rcode     as int  no-undo.
def var rdes      as char no-undo.
def var v-st      as logi no-undo.
def var v-sum1    as deci no-undo.
def var v-yes     as logi no-undo.
def var v-trx     as char no-undo.
def var v-dacc    as char no-undo.
def var v-cacc    as char no-undo.
def var v-levD    as int  no-undo.
def var v-levc    as int  no-undo.
def var v-rem     as char no-undo.
def var v-sp      as char no-undo init '996a,997a'.
def var i         as int  no-undo.
def var v-crc     as int  no-undo.
def var v-amt     as deci no-undo.
def var v-amt1    as deci no-undo.
def var v-arp     as char no-undo.
def var v-gar     as logi no-undo.
def var v-rez     as char no-undo.
def var v-sec     as char no-undo.
def var v-comcode as char no-undo.
def new shared var s-jh like jh.jh.
def buffer b-lceventres for lceventres.
pause 0.

{LC.i}
if lookup(s-sts,'BO1,ERR') = 0 then do:
    message "Event status should be BO2 or Err!" view-as alert-box error.
    return.
end.

message 'Do you want to change event status?' VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE ' QUESTION !' update v-yes.
if not v-yes then return.

if s-lcprod = 'pg' then v-gar = yes.
if s-type = '1' then do:
    if s-lcprod <> 'IDC' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
        if avail lch then v-lccow = lch.value1.
        if v-lccow = '' then do:
            message "Field Covered/uncovered is empty!" view-as alert-box error.
            return.
        end.
    end.

    /*check balance*/
    find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
    if avail lch then v-comacc = lch.value1.

    find first aaa where aaa.aaa = v-comacc no-lock no-error.
    if not avail aaa then return.

    v-sum1 = 0.
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.dacc = aaa.aaa and lceventres.jh = 0 no-lock:
        v-sum1 = v-sum1 + lceventres.amt.
    end.

    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.cacc = aaa.aaa and lceventres.jh = 0 no-lock:
        v-sum1 = v-sum1 - lceventres.amt.
    end.

    if v-sum1 > aaa.cbal - aaa.hbal then do:
        message "Lack of the balance of Commissions Debit Account (" + aaa.aaa + ")!" view-as alert-box error.
        return.
    end.

    /*Commission postings*/
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.jh = 0 no-lock:
        if lceventres.amt = 0 then next.
        if lceventres.comcode = '970'
        then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                    v-trx   = if lceventres.levC = 25 then 'cif0011' else 'cif0016'.
        else if lceventres.comcode = '966' then do:
             if lceventres.cacc = '285532' then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + '285532' + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                                                       v-trx   = 'cif0015'.
                                           else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + '285532' + vdel + v-comacc + vdel + 'Возврат комиссионного вознаграждения по гарантии ' + s-lc + ' ' + lceventres.rem
                                                       v-trx   = 'vnb0059'.
        end.
        else if lceventres.comcode = '9990' then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + '461220' + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                                                       v-trx   = 'cif0015'.
        else if lookup(s-lcprod,'PG,EXPG') > 0 then do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            assign v-param = string(lceventres.amt) + vdel + v-comacc + vdel + '286920' + vdel + s-lc + ' ' + lceventres.rem + vdel + string(lceventres.amt) + vdel + string(tarif2.kont)
                   v-trx   = 'cif0023'.
        end.
        else if lceventres.comcode = '' then  do:
            if lceventres.crc > 1 then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.rem + vdel + '1' + vdel + '1' + vdel + '4' + vdel + '4' + vdel + '840' + vdel + '1' + vdel + lceventres.cacc
                                              v-trx   = 'uni0022'.
                                  else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                                              v-trx   = 'uni0144'.

        end.
        else do:
            find first tarif2 where tarif2.str5 = lceventres.comcode and tarif2.stat = 'r' no-lock no-error.
            if not avail tarif2 then return.
            assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + v-comacc + vdel + string(tarif2.kont) + vdel + s-lc + ' ' + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                   v-trx   = 'cif0015'.
        end.

        s-jh = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).

        if rcode ne 0 then do:
           message rdes.
           pause.
           message "The commission posting (" + lceventres.comcode + ") was not done!" view-as alert-box error.
           find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
           if avail lceventh then find current lceventh exclusive-lock.
           if not avail lceventh then create lceventh.
           assign lceventh.lc       = s-lc
                  lceventh.event    = s-event
                  lceventh.number   = s-number
                  lceventh.kritcode = 'ErrDes'
                  lceventh.value1   = string(rcode) + ' ' + rdes
                  lceventh.bank     = s-ourbank.
           run lcstse(s-sts,'Err').
           return.
        end.

        if s-jh > 0 then do:
            find first b-lceventres where rowid(b-lceventres) = rowid(lceventres) exclusive-lock no-error.
            if avail b-lceventres then
            assign b-lceventres.rwho   = g-ofc
                   b-lceventres.rwhn   = g-today
                   b-lceventres.jh     = s-jh
                   b-lceventres.jdt    = g-today
                   b-lceventres.trx    = v-trx.
            v-st = yes.

            find current b-lceventres no-lock no-error.
            if b-lceventres.comcode = '970' or b-lceventres.comcode = '966' then do:
                find first lc where lc.lc = s-lc exclusive-lock no-error.
                if b-lceventres.levC = 25 or b-lceventres.cacc = '285532' then lc.comsum = lc.comsum + b-lceventres.amt.
                else lc.comsum = lc.comsum - b-lceventres.amt.
                find current lc no-lock no-error.
            end.
        end.
        message "The commission posting (" + lceventres.comcode + ") was done!" view-as alert-box info.
    end.

end. /* s-type = '1' */
else do:
    if s-type = '2' or s-type = '5' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'Cover' no-lock no-error.
        if avail lch then v-lccow = lch.value1.
        if v-lccow = '' then do:
            message "Field Covered/uncovered is empty!" view-as alert-box error.
            return.
        end.

        find first lch where lch.lc = s-lc and lch.kritcode = 'ComAcc' no-lock no-error.
        if avail lch then v-comacc = lch.value1.
        if v-comacc = '' then do:
            message "Field ComAcc is empty!" view-as alert-box.
            return.
        end.
    end.
    if s-type = '3' then do:
        find first cif where cif.cif = v-cif no-lock no-error.
        if not avail cif then return.
        v-rez = if substr(cif.geo,3,1) = "1" then "1" else "2".
        find first sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = v-cif and sub-cod.d-cod = 'secek'  no-lock no-error.
        if avail sub-cod then v-sec = sub-cod.ccode.
    end.

    find first lch where lch.lc = s-lc and lch.kritcode = 'LCcrc' no-lock no-error.
    if not avail lch or (avail lch and lch.value1 = '') then do:
            message "Field Currency Code is empty!" view-as alert-box error.
            return.
    end.
    v-crc = int(lch.value1).

    if s-type = '4' then do:
        find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
        if avail sysc then do:
            if num-entries(sysc.chval) >= v-crc then v-arp = entry(v-crc,sysc.chval).
            else do:
                message "The value LCARP in SYSC is empty!" view-as alert-box error.
                return.
            end.
        end.
        if v-arp = '' then do:
            message "The value LCARP in SYSC is empty!" view-as alert-box error.
            return.
        end.
    end.
    for each lceventres where lceventres.lc = s-lc and lceventres.event = s-event and lceventres.number = s-number and lceventres.com and lceventres.jh = 0 no-lock:
    if s-type = '2' then do:
        if not v-gar then do:
            if lceventres.dacc begins '18'
            then assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + '25' + vdel + lceventres.cacc + vdel + lceventres.rem + vdel + ' '
                        v-trx   = 'vnb0070'.
            else assign  v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + '25'  + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                         v-trx   = 'cif0019'.
        end.
        else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                    v-trx   = 'uni0144'.
    end.
    else if s-type = '3'
    then assign v-param = if lceventres.crc = 1 then string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                                                else string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.rem + vdel + v-rez + vdel + v-rez + vdel + v-sec + vdel + v-sec + vdel + '840' + vdel + '1' + vdel + lceventres.cacc
               v-trx   = if v-crc = 1 then 'uni0144' else 'uni0022'.
    else if s-type = '4'
    then assign v-param = if v-crc = 1 then string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem
                                       else string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.rem + vdel + '1' + vdel + lceventres.cacc
                v-trx   = if v-crc = 1 then 'vnb0001' else 'vnb0060'.
    else assign v-param = string(lceventres.amt) + vdel + string(lceventres.crc) + vdel + lceventres.dacc + vdel + lceventres.cacc + vdel + lceventres.rem + vdel + '1' + vdel + '4' + vdel + '840'
                v-trx   = 'cif0015'.

        s-jh    = 0.
        run trxgen (v-trx, vdel, v-param, "cif" , s-lc , output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause.
            message "The commission posting (" + lceventres.comcode + ") was not done!" view-as alert-box error.
            find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
            if avail lceventh then find current lceventh exclusive-lock.
            if not avail lceventh then create lceventh.
            assign  lceventh.lc       = s-lc
                    lceventh.event    = s-event
                    lceventh.number   = s-number
                    lceventh.bank     = s-ourbank
                    lceventh.kritcode = 'ErrDes'
                    lceventh.value1   = string(rcode) + ' ' + rdes
                    lceventh.bank     = s-ourbank.
            run lcstse(s-sts,'Err').
            return.
        end.

        if s-jh > 0 then do:
            find first b-lceventres where rowid(b-lceventres) = rowid(lceventres) exclusive-lock no-error.
            if avail b-lceventres then
            assign b-lceventres.rwho   = g-ofc
                   b-lceventres.rwhn   = g-today
                   b-lceventres.jh     = s-jh
                   b-lceventres.jdt    = g-today
                   b-lceventres.trx    = v-trx.
            v-st = yes.
            find current b-lceventres no-lock no-error.
            if b-lceventres.comcode = '970' or b-lceventres.comcode = '966' then do:
                find first lc where lc.lc = s-lc exclusive-lock no-error.
                if b-lceventres.levC = 25 or b-lceventres.cacc = '285532' then lc.comsum = lc.comsum + b-lceventres.amt.
                else lc.comsum = lc.comsum - b-lceventres.amt.
                find current lc no-lock no-error.
            end.
        end.
        message "The commission posting " + lceventres.comcode + " was done!" view-as alert-box info.
    end.
end.
if (v-st = yes) or (v-st = no and s-sts <> 'FIN') and v-yes then do:
    run lcstse(s-sts,'FIN').
    if s-sts = 'ERR' then do:
        find first lceventh where lceventh.bank = s-ourbank and lceventh.lc = s-lc and lceventh.event = s-event and lceventh.number = s-number and lceventh.kritcode = 'ErrDes' no-lock no-error.
        if avail lceventh then do:
            find current lceventh exclusive-lock no-error.
            lceventh.value1 = ''.
            find current lceventh no-lock no-error.
        end.
    end.
end.

