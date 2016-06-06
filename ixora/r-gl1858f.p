/* r-gl1858f.p
 * MODULE
        Главная бухгалтерская книга
 * DESCRIPTION
        Проверка счета 1858
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        r-gl1858.p
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT

 * MENU
        Перечень пунктов Меню Прагмы
 * BASES
        BANK COMM TXB
 * AUTHOR
        10/04/2012 id00810
 * CHANGES
        18/05/2012 id00810 - отчет формируется за период
        10/07/2012 id00810 - исправлена ошибка в алгоритме расчета допустимой разницы
        13/08/2012 id00810 - исправление ошибки (описки) в условии поиска
*/

def input parameter v-name as char.
def shared var v-dt1 as date no-undo.
def shared var v-dt2 as date no-undo.
def shared temp-table wrk no-undo
  field bank     as char
  field bankn    as char
  field dt       as date
  field crc      as int
  field crc_code as char
  field jh       as int
  field amtv     as deci
  field amtt     as deci
  field amt      as deci
  field razn     as deci
  field amtdr    as deci
  field razn1    as deci
  field rate     as deci
  field rate_op  as deci
  field ofc      as char
  index idx is primary bank crc jh.

def var s-ourbank  as char no-undo.
def var v-amt1     as deci no-undo.
def var v-amt2     as deci no-undo.
def var v-rate     as deci no-undo.
def var v-rate1    as deci no-undo.
def var v-crc_code as char no-undo.
def var v-dat      as date no-undo.
def buffer b-jl   for txb.jl.
def buffer bb-jl  for txb.jl.

find first txb.sysc where txb.sysc.sysc = "ourbnk" no-lock no-error.
if not avail txb.sysc or txb.sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(txb.sysc.chval).

do v-dat = v-dt1 to v-dt2:
    for each txb.jl where txb.jl.jdt = v-dat
                      and txb.jl.gl = 185800
                      and txb.jl.crc > 1
                      and txb.jl.dam > 0
                      no-lock break by txb.jl.crc by txb.jl.jh .
        if first-of(txb.jl.crc) then do:
            v-rate = 0.
            v-crc_code = ''.
            find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
            if avail txb.crc then v-crc_code = txb.crc.code.
            find last txb.crchis where txb.crchis.crc = txb.jl.crc
                                   and txb.crchis.rdt <= v-dat - 1
                                   no-lock no-error.
            if avail txb.crchis then v-rate = txb.crchis.rate[1].
        end.
        find first b-jl where b-jl.jh  = txb.jl.jh
                          and b-jl.gl  = 185800
                          and b-jl.crc = 1
                          and b-jl.cam > 0
                          and (b-jl.ln = txb.jl.ln - 1
                          or b-jl.ln = txb.jl.ln + 1
                          or b-jl.ln = txb.jl.ln + 3)
                          no-lock no-error.
        if not avail b-jl then do:
            message s-ourbank txb.jl.jh. next.
        end.
        v-rate1 = round(b-jl.cam / txb.jl.dam,2).
        if v-rate1 <> v-rate then do:
            v-amt1 =  txb.jl.dam *  v-rate.
            v-amt2 = round(b-jl.cam - v-amt1,2).
            if abs(v-amt2) <= 0.1  then next.
            if v-amt2 > 0 then
            find first bb-jl where bb-jl.jh = txb.jl.jh
                               and bb-jl.gl >= 453000
                               and bb-jl.gl <= 453099
                               and bb-jl.crc = 1
                               and bb-jl.cam >= v-amt2 - 0.1
                               and bb-jl.cam <= v-amt2 + 0.1
                               no-lock no-error.
            else find first bb-jl where bb-jl.jh = txb.jl.jh
                                    and bb-jl.gl >= 553000
                                    and bb-jl.gl <= 553099
                                    and bb-jl.crc = 1
                                    and bb-jl.dam >= - v-amt2 - 0.1
                                    and bb-jl.dam <= - v-amt2 + 0.1
                                    no-lock no-error.
            if avail bb-jl then do:
                if v-amt2 > 0 and (bb-jl.cam - v-amt2) <= 0.1 then next.
                if v-amt2 < 0 and (bb-jl.dam + v-amt2) <= 0.1 then next.
            end.
            else do:
                if v-amt2 > 0 then
                find first bb-jl where bb-jl.jh = txb.jl.jh
                                   and bb-jl.gl >= 453000
                                   and bb-jl.gl <= 453099
                                   and bb-jl.crc = 1
                                   and bb-jl.cam > 0
                                   no-lock no-error.
                else find first bb-jl where bb-jl.jh = txb.jl.jh
                                        and bb-jl.gl >= 553000
                                        and bb-jl.gl <= 553099
                                        and bb-jl.crc = 1
                                        and bb-jl.dam > 0
                                        no-lock no-error.
            end.
            create wrk.
            assign wrk.bank     = s-ourbank
                   wrk.bankn    = v-name
                   wrk.dt       = v-dat
                   wrk.crc      = txb.jl.crc
                   wrk.crc_code = v-crc_code
                   wrk.jh       = txb.jl.jh
                   wrk.amtv     = txb.jl.dam
                   wrk.amtt     = v-amt1
                   wrk.amt      = b-jl.cam
                   wrk.razn     = v-amt2
                   wrk.amtdr    = if avail bb-jl then (if v-amt2 > 0 then bb-jl.cam else bb-jl.dam) else 0
                   wrk.razn1    = v-amt2 - wrk.amtdr
                   wrk.rate     = v-rate
                   wrk.rate_op  = v-rate1
                   wrk.ofc      = txb.jl.who.
        end.
    end.

    for each txb.jl where txb.jl.jdt = v-dat
                      and txb.jl.gl = 185800
                      and txb.jl.crc > 1
                      and txb.jl.cam > 0
                      no-lock break by txb.jl.crc by txb.jl.jh .
        if first-of(txb.jl.crc) then do:
            v-rate = 0.
            v-crc_code = ''.
            find first txb.crc where txb.crc.crc = txb.jl.crc no-lock no-error.
            if avail txb.crc then v-crc_code = txb.crc.code.
            find last txb.crchis where txb.crchis.crc = txb.jl.crc
                                   and txb.crchis.rdt <= v-dat - 1
                                   no-lock no-error.
            if avail txb.crchis then v-rate = txb.crchis.rate[1].
        end.
        find first b-jl where b-jl.jh  = txb.jl.jh
                          and b-jl.gl  = 185800
                          and b-jl.crc = 1
                          and b-jl.dam > 0
                          and (b-jl.ln = txb.jl.ln - 3
                          or b-jl.ln = txb.jl.ln - 1
                          or b-jl.ln = txb.jl.ln + 1)
                          no-lock no-error.
        if not avail b-jl then do:
            message s-ourbank txb.jl.jh. next.
        end.
        v-rate1 = round(b-jl.dam / txb.jl.cam,2).
        if v-rate1 <> v-rate then do:
            v-amt1 =  txb.jl.cam *  v-rate.
            v-amt2 = round(v-amt1 - b-jl.dam,2).
            if abs(v-amt2) <= 0.1  then next.
            if v-amt2 > 0 then
            find first bb-jl where bb-jl.jh = txb.jl.jh
                               and bb-jl.gl >= 453000
                               and bb-jl.gl <= 453099
                               and bb-jl.crc = 1
                               and bb-jl.cam >= v-amt2 - 0.1
                               and bb-jl.cam <= v-amt2 + 0.1
                               no-lock no-error.
            else find first bb-jl where bb-jl.jh = txb.jl.jh
                                    and bb-jl.gl >= 553000
                                    and bb-jl.gl <= 553099
                                    and bb-jl.crc = 1
                                    and bb-jl.dam >= - v-amt2 - 0.1
                                    and bb-jl.dam <= - v-amt2 + 0.1
                                    no-lock no-error.
            if avail bb-jl then do:
                if v-amt2 > 0 and (bb-jl.cam - v-amt2) <= 0.1 then next.
                if v-amt2 < 0 and (bb-jl.dam + v-amt2) <= 0.1 then next.
            end.
            else do:
                if v-amt2 > 0 then
                find first bb-jl where bb-jl.jh = txb.jl.jh
                                   and bb-jl.gl >= 453000
                                   and bb-jl.gl <= 453099
                                   and bb-jl.crc = 1
                                   and bb-jl.cam > 0
                                   no-lock no-error.
                else find first bb-jl where bb-jl.jh = txb.jl.jh
                                        and bb-jl.gl >= 553000
                                        and bb-jl.gl <= 553099
                                        and bb-jl.crc = 1
                                        and bb-jl.dam > 0
                                        no-lock no-error.
            end.

            create wrk.
            assign wrk.bank    = s-ourbank
                   wrk.bankn   = v-name
                   wrk.dt      = v-dat
                   wrk.crc     = txb.jl.crc
                   wrk.crc_code = v-crc_code
                   wrk.jh      = txb.jl.jh
                   wrk.amtv    = txb.jl.cam
                   wrk.amtt    = v-amt1
                   wrk.amt     = b-jl.dam
                   wrk.razn    = v-amt2
                   wrk.amtdr   = if avail bb-jl then (if v-amt2 < 0 then bb-jl.dam else bb-jl.cam) else 0
                   wrk.razn1   = v-amt2 - wrk.amtdr
                   wrk.rate    = v-rate
                   wrk.rate_op = v-rate1
                   wrk.ofc     = txb.jl.who.
        end.
    end.
end.


