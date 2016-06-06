/* dcls56.p
 * MODULE
        Закрытие дня
 * DESCRIPTION
        Автоматическое начисление штрафов
 * RUN

 * CALLER
        dayclose.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        11.09.2003 marinav
 * CHANGES
        22.10.2003 nadejda - имя файла формируется с указанием даты
        05/01/2005 madiyar - для потреб.кредитов начисление штрафов простое (штрафы начисляются только на уровни 7 и 9, 16-й не учитывается)
        10/03/2005 madiyar - простые штрафы также для быстрых денег
        19.04.2005 nataly добавлено автоматическое проставление кодов расходов/доходов {cods.i}
        24/01/2006 Natalya D. - добавила начисление штрафов вне баланса(5 уровень), если просрочка больше 30 дней(loncon.sods1 = 0, a loncon.sods2 <> 0)
        23/03/2006 Natalya D. - в лог записис дозаписываются
        27/03/2006 Natalya D. - исправила: vbal5 не зависит от нулевого значения vbal16
        28/03/2006 Natalya D. - добавила на проверку из справочника указателя начисления штрафов(признак lnpen) !пока закоментарила
                                добавила добавление в lon.dam[5] суммы начисленных штрафов за балансом
        29/03/2006 Natalya D. - убрала no-lock по lon
        31/03/2006 Natalya D. - раскоментарила проверку по справочнику lnpen
        28/04/2006 Natalya D. - начислять/не начислять штрафы как в балан, так и внебаланса зависит от признака lnpen
        15/05/2006 Natalya D. - добавила проверку еа существование записи в loncon
        18/05/2006 Natalya D. - исправила проверку в loncon
        02/09/2009 madiyar - по экспресс-кредитам начисление только внесистемное
        09/12/2009 galina - добавила восстановление начисления штрафов по экспресс-кредитам, у которых ранее была введена дата восстновления
        13/05/2010 galina - добавила приостановление начисления неустойки при достижении суммы остатка ОД и восстановление начисления
        14/05/2010 galina - для sub-cod find current только если найдена запись
        18/05/2010 galina - поправила определение ставки по штрафам
        09/06/2010 galina - начисление пени до 7 дней и после 7 дней просрочки по ОД для МСБ
        06/08/2010 galina - записываем текущую % ставку в ln%his
        24/09/2010 galina - начисление пени по ставке penprem7 при закрытии 7-го дня просрочки ОД для МСБ
        03/11/2010 madiyar - 186050 -> 1879xx
        04/11/2010 madiyar - перекомпиляция
        13/01/2011 madiyar - начисление пени только внесистемное
        15/02/2011 madiyar - начисление пени до 7 дней и после 7 дней, дни просрочки - смотрим и на проценты тоже
        30/04/2011 madiyar - ограничение начисления пени
*/


{global.i}
def var v-param    as char no-undo.
def var vdel       as char initial "^".
def var rcode      as int no-undo.
def var rdes       as char no-undo.

def var v-dolg as deci no-undo.
define var vbal16  as deci format ">>>,>>>,>>>,>>9.99" init 0.
define var vbal5   as deci format ">>>,>>>,>>>,>>9.99" init 0.
define var vbal16_1  as deci format ">>>,>>>,>>>,>>9.99" init 0.
define var vbal5_1   as deci format ">>>,>>>,>>>,>>9.99" init 0.
define var vbal16_2  as deci format ">>>,>>>,>>>,>>9.99" init 0.
define var vbal5_2   as deci format ">>>,>>>,>>>,>>9.99" init 0.
def var ndt as date no-undo.
def var dt_border as date no-undo.
def var pen_reset as logi no-undo.
def var fiz as logi no-undo.

define var v-pr    as deci no-undo.
define var sumbal  as deci init 0.
define var sumbal5 as deci init 0.
define new shared  var s-jh  like jh.jh.
def var v-dgl      like gl.gl no-undo.
def var v-cgl      like gl.gl no-undo.
def var v-dgl5     like gl.gl no-undo.
def var v-cgl5     like gl.gl no-undo.
define var coun    as inte init 0.
define var coun5   as inte init 0.
define var vln     as inte no-undo.
define var v-lnpen as logi init yes.
define shared var s-target as date.
define shared var s-bday as log.

def var v-penprem16 as deci no-undo.
def var v-penprem5 as deci no-undo.
def var v-penamt as deci no-undo.
def var bilance as deci no-undo.
def var v-days as integer no-undo.
                                            /*19.04.2005 nataly*/
define var v-code as char.
define var v-dep as char format 'x(3)'.
def buffer bgl for gl.            /*19.04.2005 nataly*/

/*s-bday = false.
g-today = 09/17/03.
s-target = 09/18/03.
*/

/*s-target = g-today + 1.
s-bday = false.*/
define stream penrate.
output stream penrate to value("lonpenrestor.txt" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99")) append.
def var v-penrate as deci no-undo.
def buffer b-lon for lon.
def buffer b-ln%his for ln%his.
def var v-num as integer no-undo.

define stream m-out.
output stream m-out to value("lonpenalty.txt" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99")) append.

find sysc where sysc.sysc eq "penacr" no-lock no-error.
if not available sysc or not sysc.loval then return.

define stream penlim.
output stream penlim to value("lonpenlim.txt" + string(year(g-today), "9999") + string(month(g-today), "99") + string(day(g-today), "99")) append.

/* 186050,490000,718000,818000 */
find first sysc where sysc.sysc = "GLPEN" no-lock no-error.
v-dgl  = int(entry(1,sysc.chval)).
v-cgl  = int(entry(2,sysc.chval)).
v-dgl5 = int(entry(3,sysc.chval)).
v-cgl5 = int(entry(4,sysc.chval)).

do transaction:
    run x-jhnew.
    pause 0.
    find jh where jh.jh = s-jh exclusive-lock.
    jh.crc = 0.
    jh.party = "LON ACCRUED PENALTY TRANSACTION".
    if not s-bday then jh.jdt = s-target.
    find current jh no-lock.
end. /* transaction */
vln = 0.

def var qq as integer.
qq = 0.

for each lon no-lock break by lon.grp:

    qq = qq + 1.
    if first-of(lon.grp) then do:
        assign sumbal = 0 coun = 0 v-dgl = 0.
        find first trxlevgl where trxlevgl.gl = lon.gl and trxlevgl.subled = 'lon' and trxlevgl.level = 16 no-lock no-error.
        if avail trxlevgl then v-dgl = trxlevgl.glr.
    end.

    find first loncon where loncon.lon = lon.lon no-lock no-error.
    find first cif where cif.cif = lon.cif no-lock no-error.
    if avail loncon and v-dgl > 0 and avail cif then do:
        
        fiz = (cif.type = "P").
        
        find sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "lnpen" and sub-cod.ccode = "01" no-lock no-error.
        if (not available sub-cod) and (lon.dam[1] > 0) then do:
            v-days = 0.
            find first londebt where londebt.lon = lon.lon no-lock no-error.
            if avail londebt then do:
                v-days = londebt.days_od.
                if v-days < londebt.days_prc then v-days = londebt.days_prc.
            end.

            if v-days >= 7 then do:
                if loncon.sods1 <> lon.penprem7 then do transaction:
                    v-num = 0.
                    find last ln%his where ln%his.lon = lon.lon no-error.
                    if avail ln%his then v-num = ln%his.f0.
                    create ln%his.
                    assign ln%his.lon = lon.lon
                           ln%his.stdat = g-today
                           ln%his.opnamt = lon.opnamt
                           ln%his.intrate = lon.prem
                           ln%his.rdt = lon.rdt
                           ln%his.cif = lon.cif
                           ln%his.duedt = lon.duedt
                           ln%his.who = g-ofc
                           ln%his.whn = today
                           ln%his.f0 = v-num + 1
                           ln%his.rem = 'Изменение %% ставки по штрафам (Просрочка ОД > 7 дней)'
                           ln%his.pnlt1 = lon.penprem7.

                    find current loncon exclusive-lock.
                    loncon.sods1 = lon.penprem7.
                    find current loncon no-lock.
                end. /* transaction */
            end.
            else do:
                if loncon.sods1 <> lon.penprem then do transaction:
                    v-num = 0.
                    find last ln%his where ln%his.lon = lon.lon no-error.
                    if avail ln%his then v-num = ln%his.f0.
                    create ln%his.
                    assign ln%his.lon = lon.lon
                           ln%his.stdat = g-today
                           ln%his.opnamt = lon.opnamt
                           ln%his.intrate = lon.prem
                           ln%his.rdt = lon.rdt
                           ln%his.cif = lon.cif
                           ln%his.duedt = lon.duedt
                           ln%his.who = g-ofc
                           ln%his.whn = today
                           ln%his.f0 = v-num + 1
                           ln%his.rem = 'Изменение %% ставки по штрафам (Просрочка ОД < 7 дней)'
                           ln%his.pnlt1 = lon.penprem.

                    find current loncon exclusive-lock.
                    loncon.sods1 = lon.penprem.
                    find current loncon no-lock.
                end. /* transaction */
            end.

            /*
            v-penprem16 = 0.
            v-penprem5 = 0.
            if lon.grp = 90 or lon.grp = 92 then do:
                v-penprem5 = loncon.sods1.
                v-penprem16 = 0.
            end.
            else do:
                if v-days_od > 30 then v-penprem5 = loncon.sods1.
                else v-penprem16 = loncon.sods1.
            end.
            */

            /*10% от суммы выданного займа*/
            v-pr = round(lon.opnamt / 10,2).
            
            /* определим, надо ли сбросить накопленную сумму штрафов */
            dt_border = g-today.
            pen_reset = no.
            ndt = date(month(lon.rdt),day(lon.rdt),year(g-today)) no-error.
            if error-status:error then do:
                if day(lon.rdt) = 29 and month(lon.rdt) = 2 then ndt = date(2,28,year(g-today)) no-error.
                else do:
                    put stream penlim unformatted
                            "error lon.rdt: "
                            lon.cif " "
                            lon.lon " "
                            string(lon.rdt,"99/99/9999") " "
                            string(fiz) skip.
                    ndt = 01/01/1900.
                end.
            end.
            if ndt >= g-today and ndt < s-target then do:
                dt_border = ndt.
                pen_reset = yes.
            end.

            if (fiz and ((lon.psum < v-pr) or (pen_reset))) or (not(fiz)) then do:

                v-penprem5 = loncon.sods1.
                v-penprem16 = 0.
                vbal5 = 0. vbal16 = 0.
                vbal5_1 = 0. vbal5_2 = 0. vbal16_1 = 0. vbal16_2 = 0.

                v-dolg = 0.
                find first crc where crc.crc = lon.crc no-lock.

                for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 9 no-lock :
                    v-dolg = v-dolg + (trxbal.dam - trxbal.cam).
                end.
                for each trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 7 no-lock :
                    v-dolg = v-dolg + (trxbal.dam - trxbal.cam).
                end.
                
                /* при переходе из одного кредитного года в другой рассчитаем пеню за закрываемые дни первого кредитного года */
                if dt_border <> g-today then do:
                    vbal5_1  = round(v-dolg * (v-penprem5 / 100) * (dt_border - g-today), 2).
                    vbal16_1 = round(v-dolg * (v-penprem16 / 100) * (dt_border - g-today), 2).
                    
                    if vbal5_1 + vbal16_1 > 0 then do:
                        put stream penlim unformatted
                            "1: "
                            lon.cif " "
                            lon.lon " "
                            string(dt_border,"99/99/9999") " "
                            string(lon.psum,">>>,>>>,>>>,>>9.99") " "
                            string(v-dolg,">>>,>>>,>>>,>>9.99") " "
                            string(vbal5_1,">>>,>>>,>>>,>>9.99") " "
                            string(vbal16_1,">>>,>>>,>>>,>>9.99") " "
                            string(fiz) " "
                            string(pen_reset) skip.
                    end.
                    
                    /* по ФЛ сверим с 10% лимитом */
                    if fiz then do:
                        if lon.psum + vbal16_1 > v-pr then do:
                            vbal16_1 = v-pr - lon.psum.
                            if vbal16_1 < 0 then vbal16_1 = 0.
                        end.
                        if lon.psum + vbal16_1 + vbal5_1 > v-pr then do:
                            vbal5_1 = v-pr - lon.psum - vbal16_1.
                            if vbal5_1 < 0 then vbal5_1 = 0.
                        end.

                        if vbal5_1 + vbal16_1 > 0 then do:
                            put stream penlim unformatted
                                "2: "
                                lon.cif " "
                                lon.lon " "
                                string(dt_border,"99/99/9999") " "
                                string(lon.psum,">>>,>>>,>>>,>>9.99") " "
                                string(v-dolg,">>>,>>>,>>>,>>9.99") " "
                                string(vbal5_1,">>>,>>>,>>>,>>9.99") " "
                                string(vbal16_1,">>>,>>>,>>>,>>9.99") " "
                                string(fiz) " "
                                string(pen_reset) skip.
                        end.
                    end.
                end. /* if dt_border <> g-today */
                
                /* при переходе из одного кредитного года в другой обнулим накопленную сумму штрафов */
                if pen_reset then do transaction:
                    find first b-lon where rowid(b-lon) = rowid(lon) exclusive-lock.
                    b-lon.psum = 0.
                    find current b-lon no-lock.
                end.
                
                /* рассчитаем пеню за закрываемые дни текущего кредитного года */
                vbal5_2  = round(v-dolg * (v-penprem5 / 100) * (s-target - dt_border), 2).
                vbal16_2 = round(v-dolg * (v-penprem16 / 100) * (s-target - dt_border), 2).

                if vbal5_2 + vbal16_2 > 0 then do:
                    put stream penlim unformatted
                        "3: "
                        lon.cif " "
                        lon.lon " "
                        string(dt_border,"99/99/9999") " "
                        string(lon.psum,">>>,>>>,>>>,>>9.99") " "
                        string(v-dolg,">>>,>>>,>>>,>>9.99") " "
                        string(vbal5_2,">>>,>>>,>>>,>>9.99") " "
                        string(vbal16_2,">>>,>>>,>>>,>>9.99") " "
                        string(fiz) " "
                        string(pen_reset) skip.
                end.
                
                /* по ФЛ сверим с 10% лимитом */
                if fiz then do:
                    if lon.psum + vbal16_2 > v-pr then do:
                        vbal16_2 = v-pr - lon.psum.
                        if vbal16_2 < 0 then vbal16_2 = 0.
                    end.
                    if lon.psum + vbal16_2 + vbal5_2 > v-pr then do:
                        vbal5_2 = v-pr - lon.psum - vbal16_2.
                        if vbal5_2 < 0 then vbal5_2 = 0.
                    end.

                    if vbal5_2 + vbal16_2 > 0 then do:
                        put stream penlim unformatted
                            "4: "
                            lon.cif " "
                            lon.lon " "
                            string(dt_border,"99/99/9999") " "
                            string(lon.psum,">>>,>>>,>>>,>>9.99") " "
                            string(v-dolg,">>>,>>>,>>>,>>9.99") " "
                            string(vbal5_2,">>>,>>>,>>>,>>9.99") " "
                            string(vbal16_2,">>>,>>>,>>>,>>9.99") " "
                            string(fiz) " "
                            string(pen_reset) skip.
                    end.
                end.

                vbal16 = vbal16_1 + vbal16_2.
                vbal5 = vbal5_1 + vbal5_2.
                
                /* начисление на 16 уровень */
                if vbal16 > 0 then do transaction:
                    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 16 and trxbal.crc = 1 exclusive-lock no-error.
                    if not available trxbal then do:
                        create trxbal.
                        assign trxbal.subled = "LON"
                               trxbal.acc = lon.lon
                               trxbal.level = 16
                               trxbal.crc = 1
                               trxbal.gl = v-dgl.
                    end.
                    trxbal.dam = trxbal.dam + vbal16 * crc.rate[1].
                    sumbal = sumbal + vbal16 * crc.rate[1].
                    coun = coun + 1.

                    find current trxbal no-lock.

                    put stream m-out "1: " lon.lon "  " lon.cif  " " vbal16 " " vbal16 * crc.rate[1] " " v-penprem16 skip.
                end. /* transaction */

                /* начисление на 5 уровень */
                if vbal5 > 0 then do transaction:
                    find first b-lon where rowid(b-lon) = rowid(lon) exclusive-lock.
                    find first trxbal where trxbal.subled = "LON" and trxbal.acc = lon.lon and trxbal.level = 5 and trxbal.crc = 1 exclusive-lock no-error.
                    if not available trxbal then do:
                        create trxbal.
                        assign trxbal.subled = "LON"
                               trxbal.acc = lon.lon
                               trxbal.level = 5
                               trxbal.crc = 1
                               trxbal.gl = v-dgl5.
                    end.
                    trxbal.dam = trxbal.dam + vbal5 * crc.rate[1].
                    b-lon.dam[5] = b-lon.dam[5] + vbal5 * crc.rate[1].
                    sumbal5 = sumbal5 + vbal5 * crc.rate[1].
                    coun5 = coun5 + 1.

                    find current trxbal no-lock.
                    find current b-lon no-lock.

                    put stream m-out "2: " lon.lon "  " lon.cif  " " vbal5 " " vbal5 * crc.rate[1] " " v-penprem5 skip.
                end. /* transaction */
                
                /* добавляем начисленные штрафы в общую сумму штрафов, начисленных в текущем кредитном году */
                if vbal5_2 + vbal16_2 > 0 then do transaction:
                    find first b-lon where rowid(b-lon) = rowid(lon) exclusive-lock.
                    b-lon.psum = b-lon.psum + vbal5_2 + vbal16_2.
                    find current b-lon no-lock.
                end.
                
                if vbal5 + vbal16 > 0 then do:
                    put stream penlim unformatted
                        "5: "
                        lon.cif " "
                        lon.lon " "
                        string(dt_border,"99/99/9999") " "
                        string(lon.psum,">>>,>>>,>>>,>>9.99") " "
                        string(v-dolg,">>>,>>>,>>>,>>9.99") " "
                        string(vbal5,">>>,>>>,>>>,>>9.99") " "
                        string(vbal16   ,">>>,>>>,>>>,>>9.99") " "
                        string(vbal5_1,">>>,>>>,>>>,>>9.99") " "
                        string(vbal5_2,">>>,>>>,>>>,>>9.99") " "
                        string(vbal16_1,">>>,>>>,>>>,>>9.99") " "
                        string(vbal16_2,">>>,>>>,>>>,>>9.99") " "
                        string(fiz) " "
                        string(pen_reset) skip.
                end.
            end.
        end. /* if (not available sub-cod) and (lon.dam[1] > 0) */
    end. /* if avail loncon */

    if last-of(lon.grp) then do:
        if sumbal > 0 then do transaction:
            put stream m-out "Итого по группе" lon.grp ":" sumbal skip.
            vln = vln + 1.
            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = 1.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.dam = sumbal.
            jl.cam = 0.
            jl.dc = "D".
            jl.gl = v-dgl.
            jl.sub = "LON".
            jl.lev = 16.
            jl.acc = "".
            jl.rem[1] = "Начисление штрафов, группа " + string(lon.grp) + ". Total " + string(coun) + " accounts".
            {cods.i}

            vln = vln + 1.
            create jl.
            jl.jh = jh.jh.
            jl.ln = vln.
            jl.crc = 1.
            jl.who = jh.who.
            jl.jdt = jh.jdt.
            jl.whn = jh.whn.
            jl.dam = 0.
            jl.cam = sumbal.
            jl.dc = "C".
            jl.gl = v-cgl.
            jl.acc = "".
            jl.rem[1] = "Начисление штрафов, группа " + string(lon.grp) + ". Total " + string(coun) + " accounts".
            {cods.i}
        end.
        sumbal = 0.
        coun = 0.
    end.

end. /* for each lon */

if sumbal5 > 0 then do transaction:
    vln = vln + 1.
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = 1.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = sumbal5.
    jl.cam = 0.
    jl.dc = "D".
    jl.gl = v-dgl5.
    jl.sub = "LON".
    jl.lev = 5.
    jl.acc = "".
    jl.rem[1] = "Начисление штрафов за баланс. Total " + string(coun5) + " accounts".

    vln = vln + 1.
    create jl.
    jl.jh = jh.jh.
    jl.ln = vln.
    jl.crc = 1.
    jl.who = jh.who.
    jl.jdt = jh.jdt.
    jl.whn = jh.whn.
    jl.dam = 0.
    jl.cam = sumbal5.
    jl.dc = "C".
    jl.gl = v-cgl5.
    jl.acc = "".
    jl.rem[1] = "Начисление штрафов за баланс. Total " + string(coun5) + " accounts".
end.

put stream m-out s-jh.

output stream m-out close.
output stream penrate close.
output stream penlim close.

