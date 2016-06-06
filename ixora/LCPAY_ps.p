/* LCPAY_ps.p
 * MODULE
        Название модуля
 * DESCRIPTION
        уменьшение обязательств по аккредитиву на сумму платежа
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
        24/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
    28/02/2011 id00810 - раскомментировала урегулирование счетов, добавила расчет суммы
    04/03/2011 id00810 - уточнение алгоритма для непокрытых сделок
    21/06/2011 id00810 - уточнение алгоритма (ТЗ-корректировки)
    29/07/2011 id00810 - счет DepAcc вместо 285521 для покрытого PG (c 01/08/2011)
    03/08/2011 id00810 - в случае ошибки в проводке - статус ErrA
    09/11/2001 id00810 - добавлены общие переменные в связи с переносом сообщения в LCstspay.p
    06/01/2012 id00810 - новый тип платежа Payment (uncovered deals - client's funds)
    03/04/2012 id00810 - изменение проводок для PG (ptype = 1,2)
    29.06.2012 Lyubov  - изменила отправку писем, теперь адреса берутся из справ. bookcod, METROCOMBANK заменила на FORTEBANK
    29.06.2012 Lyubov  - письма отправляются только сотрудикам бэк-офиса
    18/10/2012 id00810 - добавлены проводки для ODC (ТЗ 1273)
*/

{global.i}
def new shared var s-lc     like lc.lc.
def new shared var s-paysts like lcpay.sts.
def new shared var s-lcpay  like lcpay.lcpay.
def new shared var s-lcprod   as char.
def new shared var v-lcsumorg as deci.
def new shared var v-lcsumcur as deci.
def new shared var v-lcdtexp  as date.
def new shared var v-cif      as char.
def var v-ptype    as char no-undo.
def var v-sum      as deci no-undo.
def var v-crc      like crc.crc no-undo.
def var vdel       as char no-undo init '^'.
def var v-param    as char no-undo.
def var v-collacc  as char no-undo.
def var v-comacc   as char no-undo.
def var v-accnum   as char no-undo.
def var s-jh       like jh.jh  no-undo.
def var rcode      as int no-undo.
def var rdes       as char no-undo.
def var v-maillist as char no-undo.
def var i          as int  no-undo.
def var v-lccov    as char no-undo.
/*def var v-avlbnk as int.*/
def var v-text     as char no-undo.
def var v-crccode  as char no-undo.
def var VBANK      as char no-undo.
def var v-jh       as char no-undo.
def var v-nazn     as char no-undo.
def var v-date     as char no-undo.
def var v-dacc     as char no-undo.
def var v-cacc     as char no-undo.
def var v-levD     as int  no-undo.
def var v-levC     as int  no-undo.
def var v-trx      as char no-undo.
def var v-numlim   as int  no-undo.
def var v-revolv   as logi no-undo.
def var v-limcrc   as int  no-undo.
def var v-lim-amt  as deci no-undo.
def var v-knp      as char no-undo.
def var v-parm     as char no-undo extent 2.
def var v-num      as int  no-undo.
def var k          as int  no-undo.
def var v-sp       as char no-undo.
def buffer b-crc    for crc.
def buffer b-crchis for crchis.

/* сообщение */
find first bookcod where bookcod.bookcod = 'mdmail' and bookcod.code = 'BO1' no-lock no-error.
if avail bookcod then v-maillist = bookcod.name.

FIND FIRST SYSC WHERE SYSC.SYSC = "OURBNK" NO-LOCK NO-ERROR.
IF AVAIL SYSC AND SYSC.CHVAL <> '' THEN VBANK =  SYSC.CHVAL.
else do:
     run savelog( "LCpay", " Нет параметра ourbnk sysc!").
     return.
end.

for each lcpay where lcpay.bank = vbank and lcpay.sts = 'BO2' no-lock:
    s-lcprod = substr(lcpay.lc,1,index(lcpay.lc,'0') - 1).
    find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'PType' no-lock no-error.
    if avail lcpayh then do:
        if lcpayh.value1 = '5' then next.
        else v-ptype  = lcpayh.value1.
    end.
    assign s-lc      = lcpay.lc
           s-paysts  = lcpay.sts
           s-lcpay   = lcpay.lcpay
           v-lccov   = ''
           v-cif     = ''
           v-collacc = ''
           v-crc     = 0
           v-crccode = ''
           v-sum     = 0.
    find first lc where lc.lc = lcpay.lc no-lock no-error.
    if avail lc then v-cif = lc.cif.

    find first lch where lch.lc = lcpay.lc and lch.kritcode = 'lcCrc' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-crc = integer(lch.value1).
    if v-crc = 0 then do:
        run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет валюты аккредитива!").
        next.
    end.
    else do:
        find first crc where crc.crc = v-crc no-lock no-error.
        if not avail crc then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Неверный код валюты " + string(v-crc)).
            next.
        end.
        else  v-crccode = crc.code.
    end.
    if s-lcprod = 'odc' then do:
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'Scor202' no-lock no-error.
        if avail lcpayh and lcpayh.value1 <> '' then do:
            find first LCswtacc where LCswtacc.accout = lcpayh.value1 and LCswtacc.crc = v-crc no-lock no-error.
            if avail LCswtacc then v-dacc = LCswtacc.acc.
        end.
        find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and not lcpayres.com and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
    end.
    else do:
        find first lch where lch.lc = lcpay.lc and lch.kritcode = 'Cover' no-lock no-error.
        if avail lch then v-lccov = lch.value1.
        if v-lccov = '' then do:
             run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет параметра Cover!").
             next.
        end.

        if s-lcprod = 'pg' then do:
            find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'AccNum' no-lock no-error.
            if avail lcpayh then v-accnum = lcpayh.value1.
            if v-accnum = '' then do:
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета Account Number!").
                next.
            end.
            find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and not lcpayres.com and lcpayres.levD = 1 and lcpayres.dacc = v-accnum no-lock no-error.
        end.
        else do:
            if v-lccov = '0' then find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and not lcpayres.com and lcpayres.levD = 22 no-lock no-error.
                             else find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and not lcpayres.com and lcpayres.levD = 1 and lcpayres.dacc = '185512' no-lock no-error.
        end.
    end.
        if not avail lcpayres then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет первой проводки!").
            next.
        end.

        if v-crc > 1  then do:
            if s-lcprod = 'odc' then do:
                find first remtrz where remtrz.remtrz = lcpayres.info[2] no-lock no-error.
                if avail remtrz and remtrz.jh2 > 0 then do:
                    find current lcpayres exclusive-lock.
                    lcpayres.info[3] = string(remtrz.jh2).
                    find current lcpayres no-lock.
                end.
            end.
            if lcpayres.info[3] = '' then do:
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет проводки списания с коррсчета!").
                next.
            end.
            v-jh = lcpayres.info[3].
        end.

        if s-lcprod = 'odc' then do:
            find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
            if avail lcpayh then v-cacc = lcpayh.value1.
            if v-cacc = '' then do:
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета Drawer's Account!").
                next.
            end.
            find first sysc where sysc.sysc = 'LCARP' no-lock no-error.
            if avail sysc then do:
                if num-entries(sysc.chval) >= v-crc then v-dacc = entry(v-crc,sysc.chval).
                else do:
                    run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет настройки LCARP в SYSC!").
                    next.
                end.
            end.
            if v-dacc = '' then do:
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета в настройке LCARP в SYSC!").
                next.
            end.
            find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.

        end.
        else do:
            if s-lcprod <> 'pg' then do:
                if v-lccov = '0' then do:
                    v-collacc = ''.
                    find first lch where lch.lc = lcpay.lc and lch.kritcode = 'CollAcc' no-lock no-error.
                    if avail lch then v-collacc = lch.value1.
                    if v-collacc = '' then do:
                        run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета покрытия!").
                        next.
                    end.
                end.
                else do:
                    v-comacc = ''.
                    find first lch where lch.lc = lcpay.lc and lch.kritcode = 'ComAcc' no-lock no-error.
                    if avail lch then v-comacc = lch.value1.
                    if v-comacc = '' then do:
                        run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета для снятия комиссии!").
                        next.
                    end.
                end.
            end.

            if v-lccov  = '0' then do:
                if s-lcprod <> 'pg' then find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levC = 23 no-lock no-error.
                else find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levC = 1 and lcpayres.cacc = '605561' no-lock no-error.
            end.
            else do:
                if s-lcprod <> 'pg' then find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levC = 24 no-lock no-error.
                else find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levC = 1 and lcpayres.cacc = '605562' no-lock no-error.
            end.
        end.

        if not avail lcpayres then do:
            v-nazn = 'Оплата по ' + if s-lcprod = 'odc' then 'документарному инкассо ' else if s-lcprod <> 'pg' then 'аккредитиву ' else 'гарантии '.
            v-nazn = v-nazn + s-lc.

            find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'PAmt' no-lock no-error.
            if avail lcpayh and lcpayh.value1 <> '' then assign v-sum = deci(lcpayh.value1).
            if v-sum <= 0 then do:
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Сумма платежа <= 0!").
                next.
            end.

            if s-lcprod = 'odc' then
            assign v-levC  = 1
                   v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + '1' + vdel + v-cacc + vdel + v-nazn
                   v-trx   = 'uni0145'.

            else do:
                if s-lcprod <> 'pg' then
                assign v-dacc  = if v-lccov = '0' then '652000' else '650510'
                       v-cacc  = if v-lccov = '0' then v-collacc else v-comacc
                       v-levC  = if v-lccov = '0' then 23 else 24
                       v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + string(v-levC) + vdel + v-cacc + vdel + v-nazn
                       v-trx   = "cif0018".
                else
                assign v-dacc  = if v-lccov = '0' then '655561' else '655562'
                       v-cacc  = if v-lccov = '0' then '605561' else '605562'
                       v-levC  = 1
                       v-param = string(v-sum) + vdel + string(v-crc) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn
                       v-trx   = "uni0144".
            end.
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , lcpay.lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
               find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
               if avail lcpayh then find current lcpayh exclusive-lock.
               else create lcpayh.
               assign lcpayh.lc       = lcpay.lc
                      lcpayh.lcpay    = lcpay.lcpay
                      lcpayh.kritcode = 'ErrDes'
                      lcpayh.value1   = string(rcode) + ' ' + rdes
                      lcpayh.bank     = vbank.
               find current lcpayh no-lock no-error.
               run LCstspay(s-paysts,'ErrA').
               run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Ошибка проводки 1 " + string(rcode) + ' ' + rdes + ' ' + v-dacc + ' ' + v-cacc).
               next.
            end.

            if s-jh > 0 then do:
                create lcpayres.
                assign lcpayres.lc      = s-lc
                       lcpayres.lcpay   = s-lcpay
                       lcpayres.levD    = 1
                       lcpayres.dacc    = v-dacc
                       lcpayres.levC    = v-levC
                       lcpayres.cacc    = v-cacc
                       lcpayres.trx     = v-trx
                       lcpayres.rem     = v-nazn
                       lcpayres.amt     = v-sum
                       lcpayres.crc     = v-crc
                       lcpayres.com     = no
                       lcpayres.comcode = ''
                       lcpayres.rwho    = g-ofc
                       lcpayres.rwhn    = g-today
                       lcpayres.jh      = s-jh
                       lcpayres.jdt     = g-today
                       lcpayres.bank    = VBANK.
            end.
        end.
    /**/
    find first lch where lch.lc = s-lc and lch.kritcode = 'NLim' no-lock no-error.
    if avail lch then do:
        find first lclimit where lclimit.bank = vbank and lclimit.cif = v-cif and lclimit.number = int(lch.value1) no-lock no-error.
        if avail lclimit then if lclimit.sts = 'FIN' then do:
            v-numlim = lclimit.number.
            find first lclimith where lclimith.bank = vbank and lclimith.cif = v-cif and lclimith.number = v-numlim and lclimith.kritcode = 'revolv' no-lock no-error.
            if avail lclimith then if lclimith.value1 = 'yes' then v-revolv = yes.
        end.
        if v-revolv then do:
        assign v-dacc = '612530'
               v-cacc = '662530'
               v-levD = 1
               v-levC = 1
               .
        find first lcpayres where lcpayres.lc = s-lc and lcpayres.lcpay = s-lcpay and lcpayres.levD = v-levD and lcpayres.dacc = v-dacc no-lock no-error.
        if not avail lcpayres then do:
            find first lclimitres where lclimitres.bank = lclimit.bank and lclimitres.cif = lclimit.cif and lclimitres.number = lclimit.number and lclimitres.lc = s-lc and lclimitres.info[1] = 'create' and lclimitres.jh > 0 no-lock no-error.
            if avail lclimitres then do:
                find first jh where jh.jh = lclimitres.jh no-lock no-error.
                if avail jh then v-limcrc = lclimitres.crc.
                if v-crc = v-limcrc then v-lim-amt = v-sum.
                else do:
                    find last crchis where crchis.crc = v-crc and crchis.rdt < jh.jdt no-lock no-error.
                    find last b-crchis where b-crchis.crc = v-limcrc and b-crchis.rdt < jh.jdt no-lock no-error.
                    if avail b-crchis then v-lim-amt = round((v-sum * crchis.rate[1]) / b-crchis.rate[1],2).
                end.
                assign v-param = string(v-lim-amt) + vdel + string(v-limcrc) + vdel + v-dacc + vdel + v-cacc + vdel + 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc
                       v-trx   = "uni0144".
                s-jh = 0.
                run trxgen (v-trx, vdel, v-param, "cif" , lcpay.lc , output rcode, output rdes, input-output s-jh).
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + '2!!!' +  string(rcode)).
                if rcode ne 0 then do:
                    find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                    if avail lcpayh then find current lcpayh exclusive-lock.
                    else create lcpayh.
                    assign lcpayh.lc       = lcpay.lc
                           lcpayh.lcpay    = lcpay.lcpay
                           lcpayh.kritcode = 'ErrDes'
                           lcpayh.value1   = string(rcode) + ' ' + rdes
                           lcpayh.bank     = vbank.
                    find current lcpayh no-lock no-error.
                    run LCstspay(s-paysts,'ErrA').
                    run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Ошибка проводки 2 " + string(rcode) + ' ' + rdes).
                    next.
                end.

                if s-jh > 0 then do:
                    create lcpayres.
                    assign lcpayres.lc      = s-lc
                           lcpayres.lcpay   = s-lcpay
                           lcpayres.levD    = 1
                           lcpayres.dacc    = v-dacc
                           lcpayres.levC    = 1
                           lcpayres.cacc    = v-cacc
                           lcpayres.trx     = v-trx
                           lcpayres.rem     = 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc
                           lcpayres.amt     = v-lim-amt
                           lcpayres.crc     = v-limcrc
                           lcpayres.com     = no
                           lcpayres.comcode = ''
                           lcpayres.rwho    = g-ofc
                           lcpayres.rwhn    = g-today
                           lcpayres.jh      = s-jh
                           lcpayres.jdt     = g-today
                           lcpayres.bank    = VBANK.

                    create lclimitres.
                    assign lclimitres.cif     = v-cif
                           lclimitres.number  = v-numlim
                           lclimitres.lc      = s-lc
                           lclimitres.dacc    = v-dacc
                           lclimitres.cacc    = v-cacc
                           lclimitres.amt     = v-lim-amt
                           lclimitres.crc     = v-limcrc
                           lclimitres.rwho    = g-ofc
                           lclimitres.rwhn    = g-today
                           lclimitres.jh      = s-jh
                           lclimitres.jdt     = g-today
                           lclimitres.trx     = v-trx
                           lclimitres.rem     = 'Восстановление доступного остатка по возобновляемым кредитам в рамках ТФ, ' + s-lc
                           lclimitres.bank    = VBANK
                           lclimitres.info[1] = 'pay'.
                end.
            end.
        end.
        end.
    end.
    if v-ptype = '3' then do:
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
        if avail lcpayh then v-dacc = lcpayh.value1.
        if v-dacc = '' then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета CollAcc!").
            next.
        end.
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'AccNum' no-lock no-error.
        if not avail lcpayh or lcpayh.value1 = '' then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета Account Number!").
            next.
        end.
        v-cacc = lcpayh.value1.
        find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
        if not avail lcpayres then do:
            assign v-param = string(v-sum) + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn
                   v-trx   = "vnb0058".
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , lcpay.lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                if avail lcpayh then find current lcpayh exclusive-lock.
                else create lcpayh.
                assign lcpayh.lc       = lcpay.lc
                       lcpayh.lcpay    = lcpay.lcpay
                       lcpayh.kritcode = 'ErrDes'
                       lcpayh.value1   = string(rcode) + ' ' + rdes
                       lcpayh.bank     = vbank.
                find current lcpayh no-lock no-error.
                run LCstspay(s-paysts,'ErrA').
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Ошибка проводки 3 " + string(rcode) + ' ' + rdes + ' ' + v-dacc + ' ' + v-cacc).
                next.
            end.

            if s-jh > 0 then do:
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.levD    = 1
                   lcpayres.dacc    = v-dacc
                   lcpayres.levC    = 1
                   lcpayres.cacc    = v-cacc
                   lcpayres.trx     = v-trx
                   lcpayres.rem     = v-nazn
                   lcpayres.amt     = v-sum
                   lcpayres.crc     = v-crc
                   lcpayres.com     = no
                   lcpayres.comcode = ''
                   lcpayres.rwho    = g-ofc
                   lcpayres.rwhn    = g-today
                   lcpayres.jh      = s-jh
                   lcpayres.jdt     = g-today
                   lcpayres.bank    = VBANK.
            end.
        end.
    end.
    if s-lcprod = 'pg' and v-ptype = '1' then do:
        find first lch where lch.lc = s-lc and lch.kritcode = 'DepAcc' no-lock no-error.
        if avail lch then v-dacc = lch.value1.
        /*find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'CollAcc' no-lock no-error.
        if avail lcpayh then v-dacc = lcpayh.value1.*/
        if v-dacc = '' then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета DepAcc!").
            next.
        end.
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'AccNum' no-lock no-error.
        if not avail lcpayh or lcpayh.value1 = '' then do:
            run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Нет счета Account Number!").
            next.
        end.
        v-cacc = lcpayh.value1.
        find first lcpayh where lcpayh.bank = vbank and lcpayh.lc = s-lc and lcpayh.lcpay = s-lcpay and lcpayh.kritcode = 'KNP' no-lock no-error.
        if avail lcpayh and lcpayh.value1 <> '' then v-knp = lcpayh.value1.

        find first lcpayres where lcpayres.lc = lcpay.lc and lcpayres.lcpay = lcpay.lcpay and lcpayres.levD = 1 and lcpayres.dacc = v-dacc no-lock no-error.
        if not avail lcpayres then do:
            assign v-param = string(v-sum) + vdel + string(v-crc) + vdel + '1' + vdel + v-dacc + vdel + v-cacc + vdel + v-nazn + vdel + v-knp
                   v-trx   = "uni0118".
            s-jh = 0.
            run trxgen (v-trx, vdel, v-param, "cif" , lcpay.lc , output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                find first lcpayh where lcpayh.bank = lcpay.bank and lcpayh.lc = lcpay.lc and lcpayh.lcpay = lcpay.lcpay and lcpayh.kritcode = 'ErrDes' no-lock no-error.
                if avail lcpayh then find current lcpayh exclusive-lock.
                else create lcpayh.
                assign lcpayh.lc       = lcpay.lc
                       lcpayh.lcpay    = lcpay.lcpay
                       lcpayh.kritcode = 'ErrDes'
                       lcpayh.value1   = string(rcode) + ' ' + rdes
                       lcpayh.bank     = vbank.
                find current lcpayh no-lock no-error.
                run LCstspay(s-paysts,'ErrA').
                run savelog( "LCpay", lcpay.lc + " " + string(lcpay.lcpay,'>>>9') + " Ошибка проводки 3 " + string(rcode) + ' ' + rdes + ' ' + v-dacc + ' ' + v-cacc).
                next.
            end.

            if s-jh > 0 then do:
            create lcpayres.
            assign lcpayres.lc      = s-lc
                   lcpayres.lcpay   = s-lcpay
                   lcpayres.levD    = 1
                   lcpayres.dacc    = v-dacc
                   lcpayres.levC    = 1
                   lcpayres.cacc    = v-cacc
                   lcpayres.trx     = v-trx
                   lcpayres.rem     = v-nazn
                   lcpayres.amt     = v-sum
                   lcpayres.crc     = v-crc
                   lcpayres.com     = no
                   lcpayres.comcode = ''
                   lcpayres.rwho    = g-ofc
                   lcpayres.rwhn    = g-today
                   lcpayres.jh      = s-jh
                   lcpayres.jdt     = g-today
                   lcpayres.bank    = VBANK.
            end.
        end.
    end.
    /**/

        run LCstspay(s-paysts,'FIN') no-error.

        v-text = ''.
        v-text = "Номер аккредитива/гарантии: " + s-lc + "\n " + "Сумма " + replace(trim(string(v-sum,'>>>>>>>>>>>>>9.99')),'.',',') + ' ' + v-crccode.
        if v-crc > 1 then v-text = v-text + "\n Списание с коррсчета № " + v-jh.
        v-text = v-text + "\n Изменение требований/обязательств № " + string(s-jh).
        if v-maillist <> '' then  run mail(v-maillist ,"METROCOMBANK <abpk@metrocombank.kz>", 'Оплата: автоматические проводки',v-text, "", "","").
    /*end.*/
end.
