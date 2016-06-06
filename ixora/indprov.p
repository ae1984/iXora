/* indprov.p
 * MODULE
        Операции
 * DESCRIPTION
        Форма для открытия новых гарантий с информацией по кредитору
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
        23/04/2013 Sayat(id01143) - ТЗ 1753 от 07/03/2013 "Новый алгоритм рассчета провизий МСФО"
 * BASES
        BANK
 * CHANGES

*/
def shared var g-today as date.
def var v-dt        as date.
def var v-cif       like cif.cif init ''.
def var v-name      as char init ''.
def var v-lon       like lon.lon init ''.
def var v-sumprov   as deci init 0.
def var v-crcname   as char init ''.
def var v-numdog    as char init ''.
def var v-crc       as int.
def var nd          as int.
def var v-select    as int init 0.
def var v-bal       as decimal.
def var v-prs       as deci.
def var v-pen       as decimal.
def var v-dayc_prc  as int.
def var v-dayc_od   as int.
def var v-daymax    as int.
def var v-restr     as int.
def var v-allsum    as deci.
def var v-choice    as logi init 'false'.
def var v-tsum      as deci.
def var v-daymax1   as int.
def var v-restr1    as int.
def var rates       as deci extent 20.

def buffer b-lon for lon.

run mondays(month(g-today), year(g-today), output nd).
v-dt = date(month(g-today), nd, year(g-today)) + 1.

for each crc no-lock:
    rates[crc.crc] = crc.rate[1].
end.

define temp-table wrkip like indprov.

define button b1      label "НОВЫЙ".
define button b2      label "ПРОСМОТР".
define button b3      label "УДАЛИТЬ".
define button b-ext   label "ВЫХОД".

form
     v-dt      label "Дата                      " format "99/99/9999" skip
     v-cif     label "Код клиента               " format "x(6)" validate(can-find(cif where cif.cif = v-cif no-lock), " Клиент не найден! ") help "F2 - помощь" '     ' v-name   no-label format "x(60)" skip
     v-lon     label "Ссудный счет              " validate(can-find(lon where lon.lon = v-lon and lon.cif = v-cif no-lock), " Счет клиента не найден! ") help "F2 - помощь" ' ' v-crc label "Валюта"  v-crcname no-label format 'x(3)' skip
     v-numdog  label "Номер договора            " format "x(30)" skip
     v-sumprov label "Сумма провизий            " format ">>>,>>>,>>>,>>9.99" skip
with side-label row 5 centered title " Индивидуальные провизии " overlay width 110 frame indprov0 .

on help of v-lon in frame indprov0 do:
    find first lon where lon.cif = v-cif and lon.clmain = '' no-lock no-error.
    if avail lon then do:
        {itemlist.i
            &file = "lon"
            &frame = "row 6 centered scroll 1 20 down overlay "
            &where = " lon.cif = v-cif and lon.clmain = '' "
            &findadd = " v-crcname = '' .
                         v-crc = lon.crc.
                         find first crc where crc.crc = lon.crc no-lock no-error.
                         if avail crc then v-crcname = crc.code. else v-crcname = ''.
                         v-numdog = '' .
                         find first loncon where loncon.lon = lon.lon no-lock no-error.
                         if avail loncon then v-numdog = loncon.lcnt. else v-numdog = ''.
                       "
            &flddisp = " lon.lon label 'Счет' v-crcname label 'Валюта' lon.gua label 'Вид' lon.opnamt label 'Сумма открытия' v-numdog label '№ договора' format 'x(30)' "
            &chkey = "lon"
            &index  = "lon"
            &end = "if keyfunction(lastkey) = 'end-error' then return."
        }
        v-lon = lon.lon.
        displ v-lon with frame indprov0.
    end.
end.

repeat:
    hide frame indprov0.
    v-select = 0.
    run sel2 ("ВЫБЕРИТЕ :"," 1. НОВЫЙ | 2. ПРОСМОТР | 3. УДАЛИТЬ | 4. ВЫХОД", output v-select).
    case v-select :
        when 1 then do:
            assign  v-cif = ''
                    v-name = ''
                    v-lon = ''
                    v-crc = 0
                    v-crcname = ''
                    v-numdog = ''
                    v-sumprov = 0.
            displ v-dt v-cif v-name v-lon v-crc v-crcname v-numdog v-sumprov with frame indprov0.
            update v-cif with frame indprov0.
            find first cif where cif.cif = v-cif no-lock no-error.
            if avail cif then do:
                v-cif = cif.cif.
                v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
                display v-name with frame indprov0.
            end.
            update v-lon with frame indprov0.
            find first lon where lon.lon = v-lon no-lock no-error.
            v-crc = lon.crc.
            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crcname = crc.code.
            find first loncon where loncon.lon = v-lon no-lock no-error.
            if avail loncon then v-numdog = loncon.lcnt.
            displ v-lon v-crc v-crcname v-numdog with frame indprov0.
            message "Сумма должна быть в " + v-crcname + "!" VIEW-AS ALERT-BOX TITLE " ВНИМАНИЕ ".
            update v-sumprov with frame indprov0.


            empty temp-table wrkip.

            find first b-lon where b-lon.lon = v-lon and b-lon.cif = v-cif and b-lon.lon = v-lon no-lock no-error.
            v-allsum = 0.
            v-restr1 = 0. v-daymax1 = 0.
            for each lon where lon.cif = b-lon.cif no-lock:
                run lonbalcrc('lon',lon.lon,g-today,"1,7,2,9,49,50,42",yes,lon.crc,output v-bal).
                run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-pen).
                v-bal = v-bal + round(v-pen / rates[lon.crc],2).
                v-dayc_prc = 0. v-dayc_od = 0. v-restr = 0.
                run lndayspr(lon.lon,g-today,yes,output v-dayc_od,output v-dayc_prc).
                if v-dayc_prc > v-dayc_od then v-daymax = v-dayc_prc. else v-daymax = v-dayc_od.
                find first sub-cod where sub-cod.sub = 'lon' and sub-cod.acc = lon.lon and sub-cod.d-cod = 'lnrestr' no-lock no-error.
                if avail sub-cod and sub-cod.ccode = '01' then v-restr = 1.

                if v-restr = 1 then v-restr1 = 1.
                if v-daymax > v-daymax1 then v-daymax1 = v-daymax.

                if (b-lon.gua = 'CL' and lon.clmain = b-lon.lon) or (b-lon.gua <> 'CL' and lon.lon = b-lon.lon) then do:

                    find first wrkip where wrkip.dt = v-dt and wrkip.cif = lon.cif and wrkip.lon = lon.lon exclusive-lock no-error.
                    if not avail wrkip then do:
                        create wrkip.
                        assign  wrkip.dt = v-dt
                                wrkip.cif = v-cif
                                wrkip.lon = lon.lon.
                    end.
                    wrkip.sum = v-bal.
                    v-allsum = v-allsum + v-bal.
                    wrkip.allprovsum = v-sumprov.
                    wrkip.daypr = v-daymax.
                    wrkip.restr = v-restr.
                    wrkip.clmain = lon.clmain.
                end.
            end.
            v-daymax = 0. v-restr = 0.
            for each wrkip exclusive-lock:
                wrkip.allsum = v-allsum.
                v-tsum = wrkip.sum.
                wrkip.provsum = v-sumprov * (v-tsum / v-allsum).
                if wrkip.daypr > v-daymax then v-daymax = wrkip.daypr.
                if wrkip.restr = 1 then v-restr = 1.
            end.
            if v-cif <> 'A12001' and v-restr1 = 0 and v-daymax1 <= 180 then do:
                message "Индивидуальное резервирование невозможно, т.к. по клиенту просрочка не превышает 180 дней и не производилась реструктуризация!" view-as alert-box.
                next.
            end.
            else do:
                for each wrkip no-lock:
                    find first indprov where indprov.dt = wrkip.dt and indprov.cif = wrkip.cif and indprov.lon = wrkip.lon exclusive-lock no-error.
                    if not avail indprov then do:
                        create indprov.
                        assign  indprov.dt = wrkip.dt
                                indprov.cif = wrkip.cif
                                indprov.lon = wrkip.lon.
                    end.
                    assign
                        indprov.clmain = wrkip.clmain
                        indprov.sum = wrkip.sum
                        indprov.provsum = wrkip.provsum
                        indprov.allsum = wrkip.allsum
                        indprov.allprovsum = wrkip.allprovsum
                        indprov.daypr = wrkip.daypr
                        indprov.restr = wrkip.restr.
                end.
            end.
        end.
        when 2 then do:
            run indprovrep.
        end.
        when 3 then do:
            assign  v-cif = ''
                    v-name = ''
                    v-lon = ''
                    v-crc = 0
                    v-crcname = ''
                    v-numdog = ''
                    v-sumprov = 0.
            displ v-dt v-cif v-name v-lon v-crc v-crcname v-numdog v-sumprov with frame indprov0.
            update v-cif with frame indprov0.
            find first cif where cif.cif = v-cif no-lock no-error.
            if avail cif then do:
                v-cif = cif.cif.
                v-name = trim(trim(cif.prefix) + " " + trim(cif.name)).
                display v-name with frame indprov0.
            end.
            update v-lon with frame indprov0.
            find first lon where lon.lon = v-lon no-lock no-error.
            v-crc = lon.crc.
            find first crc where crc.crc = v-crc no-lock no-error.
            if avail crc then v-crcname = crc.code.
            find first loncon where loncon.lon = v-lon no-lock no-error.
            if avail loncon then v-numdog = loncon.lcnt.
            displ v-lon v-crc v-crcname v-numdog with frame indprov0.
            find first b-lon where b-lon.lon = v-lon no-lock no-error.
            if b-lon.gua = 'CL' then find first indprov where indprov.dt = v-dt and indprov.cif = v-cif and indprov.clmain = v-lon no-lock no-error.
            else find first indprov where indprov.dt = v-dt and indprov.cif = v-cif and indprov.lon = v-lon no-lock no-error.
            if avail indprov then do:
                v-sumprov = indprov.allprovsum.
                displ v-sumprov with frame indprov0.
            end.
            else do:
                message "Данный займ в списке отсутствует!" view-as alert-box.
                next.
            end.
            v-choice = false.
            MESSAGE skip " Вы уверены что хотите удалить данный займ из списка? " VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE " ВНИМАНИЕ " UPDATE v-choice.
            if not v-choice then next.
            else do:
                for each indprov where indprov.dt = v-dt and indprov.cif = v-cif and (indprov.lon = v-lon or indprov.clmain = v-lon) exclusive-lock:
                    delete indprov.
                end.
            end.
        end.
        when 4 then do:
            return.
        end.
    end.
end.

