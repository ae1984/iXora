/* LCBO2.p
 * MODULE
        Trade Finance
 * DESCRIPTION
        акцепт второго менеджера бек-оффиса
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
        26/11/2010 galina
 * BASES
        BANK COMM
 * CHANGES
   23/12/2010 Vera   - изменился frame framd (добавлено 1 новое поле)
   06/01/2011 Vera   - обработка статуса Err
   01/03/2011 id00810 - убрала фрейм
   09/08/2011 id00810 - старый статус BO1 (аналогично другим событиям)
*/

{mainhead.i}

def shared var s-lc like LC.LC.
define shared variable s-amdsts like lcamend.sts.
define shared variable s-lcamend like lcamend.lcamend.
def var v-sumamd as deci.
def var v-sumeq as deci. /*сумма эквивалент, после которой необходим доп. контроль */
def var v-crc as int.
def buffer b-crc for crc.

if s-amdsts  = 'BO1' /*'BO2'*/ or s-amdsts  = 'Err' then do:
    v-sumeq = 0.
    find first pksysc where pksysc.sysc = 'ILCsum' no-lock no-error.
    if avail pksysc and pksysc.deval > 0 then v-sumeq = pksysc.deval.

    v-sumamd = 0.
    find first LCamendh where LCamendh.LC = s-lc and LCamendh.LCamend = s-lcamend and LCamendh.kritcode = 'IncAmt' no-lock no-error.
    if avail LCamendh and LCamendh.value1 <> '' then v-sumamd = deci(LCamendh.value1).

    v-crc = 0.
    find first lch where lch.lc = s-lc and lch.kritcode = 'lccrc' no-lock no-error.
    if avail lch and trim(lch.value1) <> '' then v-crc = int(lch.value1).
    /*пересчитываем сумму увеличения в доллары США*/
    if v-crc <> 2 then do:
        find first crc where crc.crc = v-crc no-lock no-error.
        if avail crc then do:
            find first b-crc where b-crc.crc = 2 no-lock no-error.
            if avail b-crc then v-sumamd = v-sumamd * crc.rate[1] /  b-crc.rate[1].
            else do:
                message 'There is no rate for the currency ' string(v-crc) view-as alert-box.
                return.
            end.

        end.
        else do:
            message 'There is no rate for USD currency!' view-as alert-box.
            return.
        end.
    end.

    if v-sumamd >= v-sumeq and v-sumeq > 0 then do:
        pause 0.
        run LCsts2(s-amdsts,'MNG').
        message "This document should be controlled by manager!" view-as alert-box.
        return.
    end.
    else run LC2auth2.
end.
