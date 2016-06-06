/* lngrfch.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Раскидка платежей из промежуточной таблицы lnrkc по текущим счетам
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
        06/12/2007 madiyar
 * BASES
        BANK COMM
 * CHANGES
        10/12/2007 madiyar - неправильно обрабатывались кредиты коммерсантам, исправил; не учитывались выходные дни, исправил
        11/12/2007 madiyar - подтверждение
*/

{global.i}

def shared var s-lon like lon.lon.

def var v-bal_pod as deci no-undo.
def var v-bal_nod as deci no-undo.
def var v-bal_ppr as deci no-undo.
def var v-bal_npr as deci no-undo.
def var v-dat as date no-undo.
def var dat_wrk as date no-undo.
def var v-sum as deci.
def var v-datborder as date no-undo init 01/01/2008.
def buffer b-lnsch for lnsch.
def buffer b-lnsci for lnsci.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then next.

find last cls where cls.del no-lock no-error.
dat_wrk = cls.whn.

run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal_pod).
run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal_ppr).

if v-bal_pod <= 0 and v-bal_ppr <= 0 then do:
     message "Просрочки нет" view-as alert-box information.
     return.
end.

def var v-ok as logi init no.
message "Пересчитать график?" view-as alert-box question buttons yes-no title "" update v-ok.

if not v-ok then return.

do transaction:
    
    if v-bal_pod > 0 then do:
        v-dat = dat_wrk. /*g-today.*/
        v-sum = v-bal_pod.
        repeat:
            find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= v-dat no-lock no-error.
            if avail lnsch then do:
                if lnsch.stval > v-sum then do:
                   find b-lnsch where b-lnsch.lnn = lon.lon and b-lnsch.f0 > 0 and b-lnsch.stdat = lnsch.stdat exclusive-lock.
                   b-lnsch.stval = b-lnsch.stval - v-sum.
                   v-sum = 0. v-dat = lnsch.stdat.
                end.
                else do:
                   v-sum = v-sum - lnsch.stval.
                   v-dat = lnsch.stdat.
                   find b-lnsch where b-lnsch.lnn = lon.lon and b-lnsch.f0 > 0 and b-lnsch.stdat = lnsch.stdat exclusive-lock.
                   delete b-lnsch.
                end.
                if v-sum = 0 then leave.
            end.
            else do:
                message "Ошибка! Не найдена запись в графике ОД!" view-as alert-box error.
                undo. return.
            end.
        end. /* repeat */
        if v-sum > 0 then do:
            message "Произошла ошибка при редактировании графика погашения ОД" view-as alert-box error.
            undo. return.
        end.
        v-bal_nod = 0.
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > dat_wrk and lnsch.stdat < v-datborder exclusive-lock:
            v-bal_nod = v-bal_nod + lnsch.stval.
            delete lnsch.
        end.
        
        find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= v-datborder exclusive-lock no-error.
        if avail lnsch then do:
            lnsch.stval = lnsch.stval + v-bal_pod + v-bal_nod.
            find current lnsch no-lock.
        end.
        else do:
            message "Ошибка! Не найдена первая в след. году запись в графике ОД!" view-as alert-box error.
            undo. return.
        end.
    end. /* if v-bal_pod > 0 */
    
    run lnsch-ren(lon.lon).
    
    if v-bal_ppr > 0 then do:
        v-dat = dat_wrk. /*g-today.*/
        v-sum = v-bal_ppr.
        repeat:
            find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock no-error.
            if avail lnsci then do:
                if lnsci.iv-sc > v-sum then do:
                   find b-lnsci where b-lnsci.lni = lon.lon and b-lnsci.f0 > 0 and b-lnsci.idat = lnsci.idat exclusive-lock.
                   b-lnsci.iv-sc = b-lnsci.iv-sc - v-sum.
                   v-sum = 0. v-dat = lnsci.idat.
                end.
                else do:
                   v-sum = v-sum - lnsci.iv-sc.
                   v-dat = lnsci.idat.
                   find b-lnsci where b-lnsci.lni = lon.lon and b-lnsci.f0 > 0 and b-lnsci.idat = lnsci.idat exclusive-lock.
                   delete b-lnsci.
                end.
                if v-sum = 0 then leave.
            end.
            else do:
                message "Ошибка! Не найдена запись в графике процентов!" view-as alert-box error.
                undo. return.
            end.
        end. /* repeat */
        if v-sum > 0 then do:
            message "Произошла ошибка при редактировании графика погашения процентов" view-as alert-box error.
            undo. return.
        end.
        v-bal_npr = 0.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk and lnsci.idat < v-datborder exclusive-lock:
            v-bal_npr = v-bal_npr + lnsci.iv-sc.
            delete lnsci.
        end.
        
        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat >= v-datborder exclusive-lock no-error.
        if avail lnsci then do:
            lnsci.iv-sc = lnsci.iv-sc + v-bal_ppr + v-bal_npr.
            find current lnsci no-lock.
        end.
        else do:
            if lon.plan = 4 then do:
                find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= v-datborder no-lock no-error.
                if avail lnsch then do:
                    create lnsci.
                    lnsci.lni = lon.lon.
                    lnsci.f0 = lnsch.f0.
                    lnsci.idat = lnsch.stdat.
                    lnsci.iv-sc = v-bal_ppr + v-bal_npr.
                    find current lnsci no-lock.
                end.
                else do:
                    message "Ошибка! Невозможно создать запись в графике процентов в след. году!" view-as alert-box error.
                    undo. return.
                end.
            end.
            else do:
                message "Ошибка! Не найдена первая в след. году запись в графике процентов!" view-as alert-box error.
                undo. return.
            end.
        end.
    end. /* if v-bal_ppr > 0 */
    
end. /* transaction */

run lnsci-ren(lon.lon).

message "Пересчет графика произведен успешно" view-as alert-box information.


