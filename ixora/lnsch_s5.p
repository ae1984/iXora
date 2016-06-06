/* lnsch_s5.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Редактирование графика платежей по 5ой схеме
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
        02/07/2008 madiyar
 * BASES
        BANK COMM
 * CHANGES
        17/07/2008 madiyar - при сохранении отредактированного графика запускаем lnsch-ren lnsci-ren
        16/09/2008 galina - автоматический расчет суммы по процентам при вводе даты погашения
        18/09/2008 galina - за последний день не насчиляем проценты
        19/09/2008 galina - вернула возможность редактирования суммы по процентам
        24/11/2008 galina - не выводить сообщение об ошибочности даты для последнего платежа, когда она равна дате окончания срока кредита
        31/03/2009 madiyar - убрал validate из ввода даты погашения процентов
        21/04/2009 madiyar - реструктуризация
        29/04/2009 madiyar - разрешаем редактировать графики по кредитам со схемой 4
                             подправил реструктуризацию (на случай отсутствия просрочек), печать ордеров по проводкам списания пени
        30/04/2009 madiyar - добавил перенос просроченных платежей
        27/05/2009 madiyar - КК везде одинаковый, добавил наим. филиала; в переносе графиков подправил расчет еще не просроченных %% на 4-ом уровне
        04/08/2009 galina - проставляем признак рефинансирования
        06/08/2009 galina - редактируем внебал.ставку по шрафам
        06/08/2009 madiyar - запрос на списание штрафов
        12/08/2009 madiyar - модифицировал на случай реструктуризации нового кредита
        28/08/2009 madiyar - исправил ошибки, ОД и %% реструктурируются отдельно
        08/09/2009 madiyar - подправил расчет внебалансовых процентов текущего месяца
        09/12/2009 galina - добавила приостановление начисления шрафов
        12/05/2010 galina - поменяла тип данных для переменных v-oldsods и v-oldsods2
        13/05/2010 galina - добавила просталение статуса "C" lnprohis при редактирование ставки по штрафам
        09/06/2010 galina- убрала обнуление внебалансой ставки по штрафам
        14/07/2010 madiyar - 8 (доначисление комиссии)
        15/07/2010 madiyar - указал явно размер фрейма
        17/07/2010 galina - раскомментировала запись даты восстановления ставки в поле loncon.pielikums[10]
        17/07/2010 madiyar - 6 схема позволяет редактировать графики, как 5-я
        28/10/2013 Luiza  - ТЗ 1937 конвертация депозит lon0115
*/

{global.i}
{getdep.i}

def var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

/* функция get-date возвращает дату ровно через указанное число месяцев от исходной */
function get-date returns date (input v-date as date, input v-num as integer).
    def var v-datres as date no-undo.
    def var mm as integer.
    def var yy as integer.
    def var dd as integer.
    if v-num < 0 then v-datres = ?.
    else
    if v-num = 0 then v-datres = v-date.
    else do:
      mm = (month(v-date) + v-num) mod 12.
      if mm = 0 then mm = 12.
      yy = year(v-date) + integer(((month(v-date) + v-num) - mm) / 12).
      run mondays(mm,yy,output dd).
      if day(v-date) < dd then dd = day(v-date).
      v-datres = date(mm,dd,yy).
    end.
    return (v-datres).
end function.

function to_string_date returns char (input dt as date).
    def var mm as char no-undo extent 12 init ['января','февраля','марта','апреля','мая','июня','июля','августа','сентября','октября','ноября','декабря'].
    return string(day(dt),"99") + ' ' + mm[month(dt)] + ' ' + string(year(dt),"9999") + ' г.'.
end function.

procedure rec2log.
    def input parameter p-mess as char no-undo.
    output to value("/data/log/bxcif-del.log") append.
    put unformatted
        string(today,"99/99/9999") " "
        string(time, "hh:mm:ss") " "
        s-ourbank " "
        userid("bank") format "x(8)" " "
        p-mess skip.
    output close.
end procedure.

def shared var s-lon like lnsch.lnn.
def var code as integer no-undo.

define variable dn1 as integer no-undo.
define variable dn2 as decimal no-undo.
def var dt1 as date.
def var dt2 as date.
def var v-last as logical init false.
def var choice as logical no-undo.

find first lon where lon.lon = s-lon no-lock no-error.
if not avail lon then do:
    message "lon не найден!" view-as alert-box error.
    return.
end.

if lon.plan <> 5 and lon.plan <> 4 and lon.plan <> 6 then return.

/* Переменные для реструктуризации */
def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal4tm as deci no-undo.
def var v-bal5 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.
def var v-bal16 as deci no-undo.
def var v-dtpog as date no-undo.
def var v-dtpog2 as date no-undo.
def var v-rem as char no-undo.
def new shared var s-jh as integer.
def var vdel as char no-undo initial "^".
def var rcode as integer no-undo.
def var rdes as char no-undo.
def var v-param as char no-undo.
def var v-code as char no-undo.
def var v-dep as char no-undo.
def buffer bjl for jl.
def var ost as deci no-undo.
def var stdt as date no-undo.
def var newdt as date no-undo.
def var dat_wrk as date no-undo.
def var mnum as integer no-undo.
def var mnuma as integer no-undo.
def var mnum2 as integer no-undo.
def var mnuma2 as integer no-undo.
def var bil1 as deci no-undo.
def var bil2 as deci no-undo.
def var i as integer no-undo.
def var last_month as integer no-undo.
find last cls where cls.del no-lock no-error.
if avail cls then dat_wrk = cls.whn. else dat_wrk = g-today.

def var dt_first as date no-undo.
def var dt_from as date no-undo.
def var dt_to as date no-undo.
def var dt_lev4 as date no-undo.
def var v-name as char no-undo.
def var v-pss as char no-undo.
def var v-rnn as char no-undo.
def var v-dognom as char no-undo.
def var v-sum as char no-undo.
def var v-od as char no-undo.
def var v-srok as char no-undo.

define query qth for lnsch.
define query qti for lnsci.
define buffer b-lnsch for lnsch.
define buffer b-lnsci for lnsci.
def var v-rid as rowid.
def var v-com as deci no-undo.
def var v-com% as deci no-undo.
def var v-com_old as deci no-undo.

/*galina*/
def var v-dn1 as integer.
def var v-dn2 as integer.
def var v-dtpogold as date.
def var v-pen2 as deci no-undo.
def var v-pen2old as deci no-undo.
def var v-num as integer no-undo.
def var v-rempen as char no-undo.
form
  v-pen2 format "zz9.99" label 'Внебал штрафы %%' skip
  v-rempen format "x(40)" label 'Основание' validate(trim(v-rempen) <> '','Введите онование изменения %% ставки по внебал.шрафам!') skip
with frame fpen2  side-label row 3  centered overlay title 'Внебал штрафы %%'.
/**/

def var v-dtrestor as date no-undo.
def var v-oldsods2 as deci no-undo.
def var v-oldsods as deci no-undo.
def var v-remdtrest as char no-undo.

def var v-8com as deci no-undo.
def var v-8rem as char no-undo.
def var v-8ja as logi no-undo.
def var v-8crccode as char no-undo.

form
  v-dtrestor format "99/99/9999" label 'Дата окончания' validate(v-dtrestor >= g-today,'Дата должна быть больше или равна текущей!') skip
  v-remdtrest format "x(40)" label 'Примечание' validate(trim(v-remdtrest) <> '','Введите примечание!') skip
with frame fdtrest  side-label row 3  centered overlay title 'Приостановление неустойки'.


define browse bth query qth
    displ lnsch.f0 label "nn" format ">>9"
          lnsch.stdat label "Дата" format "99/99/9999"
          lnsch.stval label "Сумма" format ">>>,>>>,>>9.99"
          with centered 30 down overlay no-label title " Редактирование графика ОД ".

define browse bti query qti
    displ lnsci.f0 label "nn" format ">>9"
          lnsci.idat label "Дата" format "99/99/9999"
          lnsci.iv-sc label "Сумма" format ">>>,>>>,>>9.99"
          with centered 30 down overlay no-label title " Редактирование графика %% ".

define button btsaveh label "Сохранить".
define button btsavei label "Сохранить".

define frame fth bth help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" skip btsaveh with width 110 row 3 overlay no-box.
define frame fti bti help "<Enter>-Изменить, <Ins>-Ввод, <Ctrl+D>-удаление, <F4>-Выход" skip btsavei with width 110 row 3 overlay no-box.

define frame comfr
    v-com% label " Ком. за обслуживание кредита (%) " format ">9.99" skip
    v-com label " Ком. за обслуживание кредита     " format ">>>,>>>,>>9.99"
    with centered overlay side-labels row 15.

def var v-sel as integer no-undo.
run sel2 (" ВЫБЕРИТЕ: ", " 1. Редактирование графика ОД | 2. Редактирование графика %% | 3. Сумма комиссии за обслуж. кредита | 4. Полный пересчет графика | 5. Реструктуризация | 6. Перенос проср. платежей | 7. Приостановление неустойки | 8. Доначисление комиссии | 9. Выход ", output v-sel).

on "return" of bth in frame fth do:

    bth:set-repositioned-row(bth:focused-row, "always").
    v-rid = rowid(lnsch).

    find first b-lnsch where b-lnsch.lnn = lnsch.lnn and b-lnsch.stdat = lnsch.stdat and b-lnsch.f0 = lnsch.f0 exclusive-lock.
    displ b-lnsch.f0 format ">>9"
          b-lnsch.stdat format "99/99/9999"
          b-lnsch.stval format ">>>,>>>,>>9.99"
    with width 29 no-label overlay row bth:focused-row + 5 column 4 no-box frame fr2.

    update b-lnsch.f0 b-lnsch.stdat b-lnsch.stval with frame fr2.

    open query qth for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock.
    reposition qth to rowid v-rid no-error.
    bth:refresh().

end. /* on "return" of bt */

on "insert-mode" of bth in frame fth do:
    code = 1.
    find last b-lnsch where b-lnsch.lnn = s-lon and b-lnsch.f0 > 0 no-lock no-error.
    if avail b-lnsch then code = b-lnsch.f0 + 1.
    create lnsch.
    lnsch.lnn = s-lon.
    lnsch.f0 = code.
    bth:set-repositioned-row(bth:focused-row, "always").
    v-rid = rowid(lnsch).
    open query qth for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock.
    reposition qth to rowid v-rid no-error.
    bth:refresh().
    apply "return" to bth in frame fth.
end.

on "delete-line" of bth in frame fth do:
    bth:set-repositioned-row(bth:focused-row, "always").
    find first b-lnsch where b-lnsch.lnn = lnsch.lnn and b-lnsch.stdat = lnsch.stdat and b-lnsch.f0 = lnsch.f0 exclusive-lock.
    delete b-lnsch.
    open query qth for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock.
    bth:refresh().
end.

on "return" of bti in frame fti do:

    bti:set-repositioned-row(bti:focused-row, "always").
    v-rid = rowid(lnsci).

    find first b-lnsci where b-lnsci.lni = lnsci.lni and b-lnsci.idat = lnsci.idat and b-lnsci.f0 = lnsci.f0 exclusive-lock.
    displ b-lnsci.f0 format ">>9"
          b-lnsci.idat format "99/99/9999"
          b-lnsci.iv-sc format ">>>,>>>,>>9.99"
    with width 29 no-label overlay row bti:focused-row + 5 column 4 no-box frame fr3.

    dt1 = ?.
    find last lnsci where lnsci.lni = b-lnsci.lni and lnsci.idat < b-lnsci.idat and lnsci.f0 > 0 no-lock no-error.
    if avail lnsci then dt1 = lnsci.idat.
    else dt1 = lon.rdt.

    dt2 = ?.
    find first lnsci where lnsci.lni = b-lnsci.lni and lnsci.idat > b-lnsci.idat and lnsci.f0 > 0 no-lock no-error.
    if avail lnsci then dt2 = lnsci.idat.
    else do:
      dt2 = lon.duedt.
      v-last = true.
    end.

    update /*b-lnsci.f0*/ b-lnsci.idat /*validate(b-lnsci.idat > dt1 and ((v-last = false and b-lnsci.idat < dt2) or (v-last = true and b-lnsci.idat <= dt2)), 'Дата платежа должна быть > предыдущей и < последующей даты платежа' )*/ b-lnsci.iv-sc with frame fr3.


    if b-lnsci.idat entered then do:
       run day-360(dt1,b-lnsci.idat - 1,lon.basedy,output dn1,output dn2).
       b-lnsci.iv-sc = dn1 * lon.opnamt * lon.prem / 360 / 100.
       dt1 = b-lnsci.idat.
       if v-last = false then do:
          find first b-lnsci where b-lnsci.lni = lnsci.lni and b-lnsci.idat = dt2 and b-lnsci.f0 = lnsci.f0 exclusive-lock.
          run day-360(dt1,dt2 - 1,lon.basedy,output dn1,output dn2).
          b-lnsci.iv-sc = round(dn1 * lon.opnamt * lon.prem / 360 / 100,2).
       end.
    end.

    open query qti for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock.
    reposition qti to rowid v-rid no-error.
    bti:refresh().

end. /* on "return" of bt */

on "insert-mode" of bti in frame fti do:
    code = 1.
    find last b-lnsci where b-lnsci.lni = s-lon and b-lnsci.f0 > 0 no-lock no-error.
    if avail b-lnsci then code = b-lnsci.f0 + 1.
    create lnsci.
    lnsci.lni = s-lon.
    lnsci.f0 = code.
    bti:set-repositioned-row(bti:focused-row, "always").
    v-rid = rowid(lnsci).
    open query qti for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock.
    reposition qti to rowid v-rid no-error.
    bti:refresh().
    apply "return" to bti in frame fti.
end.

on "delete-line" of bti in frame fti do:
    bti:set-repositioned-row(bti:focused-row, "always").
    find first b-lnsci where b-lnsci.lni = lnsci.lni and b-lnsci.idat = lnsci.idat and b-lnsci.f0 = lnsci.f0 exclusive-lock.
    delete b-lnsci.
    open query qti for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock.
    bti:refresh().
end.

on choose of btsaveh in frame fth do:
    run lnsch-ren(s-lon).
end.

on choose of btsavei in frame fti do:
    run lnsci-ren(s-lon).
end.

if v-sel = 1 then do:
    open query qth for each lnsch where lnsch.lnn = s-lon and lnsch.f0 > 0 no-lock.
    enable all with frame fth.
    wait-for choose of btsaveh or window-close of current-window.
    pause 0.
end.
else if v-sel = 2 then do:
    open query qti for each lnsci where lnsci.lni = s-lon and lnsci.f0 > 0 no-lock.
    enable all with frame fti.
    wait-for choose of btsavei or window-close of current-window.
    pause 0.
end.
else if v-sel = 3 then do:

    if lon.plan = 6 then do:
        message "Недоступно для кредита с 6-ой схемой!" view-as alert-box error.
        return.
    end.

    find tarif2 where tarif2.str5 = "195" and tarif2.stat = 'r' no-lock no-error.
    if not avail tarif2 then do:
        message "Не найден тариф с кодом 195!" view-as alert-box error.
        return.
    end.

    v-com_old = 0. v-com = 0.
    find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then assign v-com_old = tarifex2.ost v-com = tarifex2.ost.

    v-com% = round(v-com / lon.opnamt * 100,2).

    displ v-com% v-com with frame comfr.
    update v-com% with frame comfr.

    v-com = round(v-com% * lon.opnamt / 100,2).

    displ v-com with frame comfr.
    update v-com with frame comfr.

    if v-com <> v-com_old then do transaction:
        if avail tarifex2 then find current tarifex2 exclusive-lock.
        else do:
            find first tarifex where tarifex.cif = lon.cif and tarifex.str5 = "195" and tarifex.stat = 'r' no-lock no-error.
            if not avail tarifex then do:
                create tarifex.
                assign tarifex.cif    = lon.cif
                       tarifex.kont   = tarif2.kont
                       tarifex.pakalp = "Временно - потреб кредит"
                       tarifex.str5   = "195"
                       tarifex.crc    = 1
                       tarifex.who    = "M" + g-ofc /* признак 'установлено вручную или по временным льготным тарифам' 28.04.2003 nadejda */
                       tarifex.whn    = g-today
                       tarifex.stat   = 'r'
                       tarifex.wtim   = time
                       tarifex.ost  = tarif2.ost
                       tarifex.proc = tarif2.proc
                       tarifex.max1 = tarif2.max1
                       tarifex.min1 = tarif2.min1.
            end.
            create tarifex2.
            assign tarifex2.aaa    = lon.aaa
                   tarifex2.cif    = lon.cif
                   tarifex2.kont   = tarif2.kont
                   tarifex2.pakalp = "Временно - потреб кредит"
                   tarifex2.str5   = "195"
                   tarifex2.crc    = lon.crc
                   tarifex2.who    = "M" + g-ofc /* признак 'установлено вручную или по временным льготным тарифам' 28.04.2003 nadejda */
                   tarifex2.whn    = g-today
                   tarifex2.stat   = 'r'
                   tarifex2.wtim   = time
                   tarifex2.proc = 0
                   tarifex2.max1 = 0
                   tarifex2.min1 = 0.
        end.
        tarifex2.ost = v-com.
    end.
end.
/**автоматическое формирование графика*/
else if v-sel = 4 then do:
    if lon.plan = 6 then do:
        message "Недоступно для кредита с 6-ой схемой!" view-as alert-box error.
        return.
    end.
    run pkmygrf.
end.
else if v-sel = 5 then do:

    if lon.plan = 4 then do:
        message " Кредит со схемой 4! " view-as alert-box error.
        return.
    end.

    if lon.prem = 0 then do:
        message " Процентная ставка = 0! " view-as alert-box error.
        return.
    end.

    assign v-name = ''
           v-pss = ''.

    find first aaa where aaa.aaa = lon.aaa no-lock no-error. /* счет - для upd-dep.i */
    find first cif where cif.cif = lon.cif no-lock no-error.
    if avail cif then do:
        v-rnn = cif.jss.
        v-name = trim(cif.name).
        v-pss = trim(cif.pss).
    end.

    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > g-today no-lock no-error.
    if avail lnsch then v-dtpog = lnsch.stdat.
    else do:
        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > g-today no-lock no-error.
        if avail lnsci then v-dtpog = lnsci.idat.
        else v-dtpog = g-today.
    end.
    v-dtpogold = v-dtpog.
    v-dtpog2 = v-dtpog.
    update v-dtpog format "99/99/9999" label " Дата погашения ОД" validate(can-find(lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-dtpog no-lock),'Нет записи в графике погашения ОД с такой датой!') skip
           v-dtpog2 format "99/99/9999" label " Дата погашения %%" validate(can-find(lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-dtpog2 no-lock),'Нет записи в графике погашения %% с такой датой!')
           with row 15 centered side-labels frame frdt.
    /*
    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-dtpog no-lock no-error.
    if not avail lnsch then do:
        message " Не найдена запись в графике погашения ОД с такой датой! " view-as alert-box error.
        return.
    end.

    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-dtpog no-lock no-error.
    if not avail lnsci then do:
        message " Не найдена запись в графике погашения %% с такой датой! " view-as alert-box error.
        return.
    end.
    */

    run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
    run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
    run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).
    run lonbalcrc('lon',lon.lon,g-today,"5",yes,1,output v-bal5).
    run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
    run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).
    run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-bal16).

    /*
    message "0.... ~n" +
            "v-bal1=" + trim(string(v-bal1,">>>,>>>,>>9.99")) + "~n" +
            "v-bal2=" + trim(string(v-bal2,">>>,>>>,>>9.99")) + "~n" +
            "v-bal4=" + trim(string(v-bal4,">>>,>>>,>>9.99")) + "~n" +
            "v-bal5=" + trim(string(v-bal5,">>>,>>>,>>9.99")) + "~n" +
            "v-bal7=" + trim(string(v-bal7,">>>,>>>,>>9.99")) + "~n" +
            "v-bal9=" + trim(string(v-bal9,">>>,>>>,>>9.99")) + "~n" +
            "v-bal16=" + trim(string(v-bal16,">>>,>>>,>>9.99"))
    view-as alert-box.
    */

    v-bal4tm = 0.
    if v-bal4 > 0 then do:
        dt_lev4 = ?.
        find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock no-error.
        if avail lnsci then dt_lev4 = lnsci.idat.
        else dt_lev4 = lon.rdt.

        run day-360(dt_lev4,g-today - 1,lon.basedy,output dn1,output dn2).
        v-bal4tm = round(dn1 * lon.opnamt * lon.prem / 100 / 360,2). /* эта сумма уже учтена в следующей записи по графику */
        /*
        run lonbalcrc('lon',lon.lon,dt_lev4,"4",no,lon.crc,output v-bal4tm).
        v-bal4tm = v-bal4 - v-bal4tm. -- непросроченные внебалансовые %% - эта сумма уже учтена в следующей записи по графику --
        */
        if v-bal4tm < 0 then v-bal4tm = 0.
        if v-bal4tm < v-bal4 then v-bal4tm = v-bal4.
    end.
    /*
    message "0.... ~n" +
            "v-bal4=" + trim(string(v-bal4,">>>,>>>,>>9.99")) + "~n" +
            "v-bal4tm=" + trim(string(v-bal4tm,">>>,>>>,>>9.99"))
    view-as alert-box.
    */
    /* Проверим, достаточно ли записей в графиках для отсрочки просроченных сумм */
    if v-bal7 > 0 then do:
        /*message " lev7 " view-as alert-box.*/
        ost = 0.
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk no-lock:
            ost = ost + lnsch.stval.
        end.
        if ost < v-bal7 then do:
            message " Нехватка суммы в прошлых платежах по графику ОД для отсрочки просроченного ОД! " view-as alert-box error.
            return.
        end.
    end.
    if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
        /*message " lev9+4-4tm " view-as alert-box.*/
        ost = 0.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock:
            ost = ost + lnsci.iv-sc.
        end.
        if ost < v-bal9 + v-bal4 - v-bal4tm then do:
            message " Нехватка суммы в прошлых платежах по графику %% для отсрочки просроченных %%! " view-as alert-box error.
            return.
        end.
    end.

    /* изменение графика ОД */
    dt_from = ?.
    if v-bal7 > 0 then do:
        /*message " lev7 ... 2 " view-as alert-box.*/
        ost = v-bal7.
        repeat:
            do transaction:
                find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk and lnsch.stval > 0 exclusive-lock no-error.
                /*message "1.... " + string(lnsch.stdat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsch.stval=" + trim(string(lnsch.stval,">>>,>>>,>>9.99")) view-as alert-box.*/
                if lnsch.stval > ost then do:
                    lnsch.stval = lnsch.stval - ost.
                    ost = 0.
                end.
                else do:
                    ost = ost - lnsch.stval.
                    lnsch.stval = 0.
                end.
                find current lnsch no-lock.
            end.
            if ost = 0 then do:
                dt_from = lnsch.stdat.
                leave.
            end.
        end. /* repeat */
    end.

    /* изменение графика %% */
    if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
        /*message " lev9+4-4tm ... 2 " view-as alert-box.*/
        ost = v-bal9 + v-bal4 - v-bal4tm.
        repeat:
            do transaction:
                find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk and lnsci.iv-sc > 0 exclusive-lock no-error.
                /*message "1.... " + string(lnsci.idat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsci.iv-sc=" + trim(string(lnsci.iv-sc,">>>,>>>,>>9.99")) view-as alert-box.*/
                if lnsci.iv-sc > ost then do:
                    lnsci.iv-sc = lnsci.iv-sc - ost.
                    ost = 0.
                end.
                else do:
                    ost = ost - lnsci.iv-sc.
                    lnsci.iv-sc = 0.
                end.
                find current lnsci no-lock.
            end.
            if ost = 0 then do:
                if lnsci.idat < dt_from then dt_from = lnsci.idat.
                leave.
            end.
        end. /* repeat */
    end.

    /*message " dt_from=" + string(dt_from,"99/99/9999") view-as alert-box.*/

    /* если нет просрочек, то dt_from не инициализирован, берем дату из первого следующего графика */
    if dt_from = ? then do:
        find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > dat_wrk no-lock no-error.
        if avail lnsch then dt_from = lnsch.stdat.
        find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk no-lock no-error.
        if avail lnsci and lnsci.idat < dt_from then dt_from = lnsci.idat.
    end.

    last_month = 0.
    find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
    find last b-lnsch where b-lnsch.lnn = lon.lon and b-lnsch.f0 > 0 and b-lnsch.stdat < lnsch.stdat no-lock no-error.
    if avail lnsch and avail b-lnsch then last_month = lnsch.stdat - b-lnsch.stdat.

    /*message " last_month=" + string(last_month,">>>,>>>,>>9") view-as alert-box.*/

    /* запоминаем дату первого платежа по графику */
    dt_first = ?.
    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock no-error.
    if avail lnsch then dt_first = lnsch.stdat.

    /*message " dt_first=" + string(dt_first,"99/99/9999") view-as alert-box.*/

    /* удаляем все следующие графики */
    do transaction:
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > dat_wrk exclusive-lock:
            delete lnsch.
        end.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat > dat_wrk exclusive-lock:
            delete lnsci.
        end.
    end.

    /* строим новые графики */
    stdt = ?.
    if day(v-dtpog) > day(dat_wrk) then stdt = date(month(dat_wrk),day(v-dtpog),year(dat_wrk)).
    else do:
        newdt = get-date(dat_wrk,1).
        stdt = date(month(newdt),day(v-dtpog),year(newdt)).
    end.

    /*message " stdt=" + string(stdt,"99/99/9999") view-as alert-box.*/

    /*
    stdt = ?.
    find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk no-lock no-error.
    if avail lnsch then stdt = lnsch.stdat.
    */
    mnum = 0.
    mnuma = 0.
    mnuma2 = 0.
    do transaction:
        if stdt <> ? then newdt = stdt.
        else newdt = dt_first.
        repeat:
            if newdt > lon.duedt then newdt = lon.duedt.
            else
            if lon.duedt - stdt <= last_month then newdt = lon.duedt.
            /*
            message " newdt=" + string(newdt,"99/99/9999") + '~n'
                    " mnum=" + string(mnum) + '~n'
                    " mnuma=" + string(mnuma) + '~n'
                    " mnuma2=" + string(mnuma2)
                    view-as alert-box.
            */
            create lnsch.
            lnsch.lnn = lon.lon.
            lnsch.stdat = newdt.
            lnsch.f0 = 1.
            create lnsci.
            lnsci.lni = lon.lon.
            lnsci.idat = newdt.
            lnsci.f0 = 1.
            mnum = mnum + 1.
            if newdt >= v-dtpog then mnuma = mnuma + 1.
            if newdt >= v-dtpog2 then mnuma2 = mnuma2 + 1.
            stdt = newdt.
            if stdt = lon.duedt then leave.
            newdt = get-date(stdt,1).
        end.
    end.

    /*message "1111.... mnum=" + string(mnum,">>9") + " mnuma=" + string(mnuma,">>9") + " mnuma2=" + string(mnuma2,">>9") view-as alert-box.*/

    stdt = dat_wrk.
    bil1 = truncate((v-bal1 + v-bal7) / mnuma,0).
    run day-360(g-today,lon.duedt - 1,360,output dn1,output dn2).
    ost = round(dn1 * lon.opnamt * lon.prem / 36000,2).
    bil2 = truncate((v-bal2 + v-bal4tm + v-bal9 + ost) / mnuma2,0).

    /*message "2222.... bil1=" + trim(string(bil1,">>>,>>>,>>9.99")) + " dn1=" + string(dn1,">,>>9") + " ost=" + trim(string(ost,">>>,>>>,>>9.99"))  + " bil2=" + trim(string(bil2,">>>,>>>,>>9.99")) view-as alert-box.*/

    do transaction:
        do i = 1 to mnum:
            find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat > stdt exclusive-lock no-error.
            if avail lnsch then do:
                if lnsch.stdat >= v-dtpog then do:
                    lnsch.stval = bil1.
                    if i = mnum then lnsch.stval = v-bal1 + v-bal7 - bil1 * (mnuma - 1).
                end.
                find current lnsch no-lock.
            end.
            find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = lnsch.stdat exclusive-lock no-error.
            if avail lnsci then do:
                if lnsci.idat >= v-dtpog2 then do:
                    lnsci.iv-sc = bil2.
                    if i = mnum then lnsci.iv-sc = v-bal2 + v-bal4tm + v-bal9 + ost - bil2 * (mnuma2 - 1).
                end.
                find current lnsci no-lock.
            end.
            stdt = lnsch.stdat.
        end.
    end. /* transaction */

    run lnsch-ren(lon.lon).
    release lnsch.

    run lnsci-ren(lon.lon).
    release lnsci.

    /* переносим проценты с 4-го на второй */
    if v-bal4 > 0 then do:
        v-rem = "Реструкт. Перенос %% из начисленных вне баланса в начисленные, " + v-rnn + " " + v-name.
        /*v-param = string(v-bal4) + vdel + lon.lon + vdel + v-rem + vdel + string(v-bal4).*/
        if lon.crc = 1 then v-param = "0" + vdel + lon.lon + vdel +
              v-rem + vdel + "0" + vdel + string(v-bal4) + vdel + lon.lon + vdel +
              v-rem + vdel + string(v-bal4).
        else v-param = string(v-bal4) + vdel + lon.lon + vdel +
              v-rem + vdel + string(v-bal4) + vdel + "0" + vdel + lon.lon + vdel +
              v-rem + vdel + "0".
        s-jh = 0.
        run trxgen ("lon0115", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        {upd-dep.i}
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal4 > 0 */

    choice = yes.
    message "Списать штрафы?" view-as alert-box question buttons yes-no title "Списание штрафов" update choice.
    if choice then do:
        /* списываем 5-ый */
        if v-bal5 > 0 then do:
            v-rem = "Реструкт. Списание внебалансовых штрафов, " + v-rnn + " " + v-name.
            v-param = string(v-bal5) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
            s-jh = 0.
            run trxgen ("lon0116", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                next.
            end.
            run lonresadd(s-jh).
            run vou_bank(1).
        end. /* if v-bal5 > 0 */

        /* списываем 16-ый */
        if v-bal16 > 0 then do:
            v-rem = "Реструкт. Списание штрафов, " + v-rnn + " " + v-name.
            v-param = string(v-bal16) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
            s-jh = 0.
            run trxgen ("lon0063", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause 1000.
                next.
            end.
            run lonresadd(s-jh).
            run vou_bank(1).
        end. /* if v-bal16 > 0 */
    end.

    /* переносим ОД с 7-го на 1-ый */
    if v-bal7 > 0 then do:
        v-rem = "Реструкт. Перенос ОД 7ур.->1ур., " + v-rnn + " " + v-name.
        v-param = string(v-bal7) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel + vdel + "490".
        s-jh = 0.
        run trxgen ("lon0023", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal7 > 0 */

    /* переносим %% с 9-го на 2-ой */
    if v-bal9 > 0 then do:
        /*v-rem = "Реструкт. Перенос %% 9ур.->2ур.".*/
        v-param = string(v-bal9) + vdel + lon.lon.
        s-jh = 0.
        run trxgen ("lon0065", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal9 > 0 */

    /* печать доп. соглашения */
    def stream v-out.
    output stream v-out to dop.htm.
    {html-title.i
     &stream = " stream v-out "
     &title = " "
     &size-add = " "
    }

    assign v-dognom = ''
           v-sum = ''
           v-od = ''
           v-srok = ''.

    find first loncon where loncon.lon = lon.lon no-lock no-error.
    if avail loncon then v-dognom = loncon.lcnt + " от " + string(lon.rdt,"99/99/9999").
    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then do:
        v-sum = replace(trim(string(lon.opnamt,">>>,>>>,>>9.99")),',',' ') + ' ' + crc.code.
        v-od = replace(trim(string(v-bal1 + v-bal7,">>>,>>>,>>9.99")),',',' ') + ' ' + crc.code.
    end.

    run day-360(lon.rdt,lon.duedt - 1,360,output dn1,output dn2).
    v-srok = trim(string(round(dn1 / 30,0),">>9")) + " мес.".
    dt_to = ?.
    find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat < v-dtpog no-lock no-error.
    if avail lnsch then dt_to = lnsch.stdat.
    else do:
        find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat < v-dtpog no-lock no-error.
        if avail lnsci then dt_to = lnsci.idat.
    end.

    find first cmp no-lock no-error.

    put stream v-out unformatted
        "<table width=""98%"" border=""0"" cellspacing=""0"" cellpadding=""1"" align=""center"">" skip
        "<tr><td colspan=""2""><img width=200 height=25 src=""top_logo_bw.jpg""></td></tr>" skip
        "<tr><td style=""font:bold"" align=""center"" colspan=2><br><br>ЛИСТ СОГЛАСОВАНИЯ<br>по программе ""МЕТРОКРЕДИТ""</td></tr>" skip
        "<tr><td align=""right"" colspan=2><br>" to_string_date(g-today) "</td></tr>" skip
        "<tr><td colspan=""2""></td></tr>" skip
        "<tr><td colspan=""2""></td></tr>" skip
        "<tr style=""font:bold""><td><u>Заемщик:</u></td><td>" v-name "</td></tr>" skip
        "<tr><td>Филиал:</td><td>" cmp.name "</td></tr>" skip
        "<tr><td>Уд.личности:</td><td>" v-pss "</td></tr>" skip
        "<tr><td>Номер договора:</td><td>" v-dognom "</td></tr>" skip
        "<tr><td>Сумма кредита:</td><td>" v-sum "</td></tr>" skip
        "<tr><td>Остаток основного долга:</td><td>" v-od "</td></tr>" skip
        "<tr><td>Срок кредита:</td><td>" v-srok "</td></tr>" skip
        "<tr><td colspan=""2""></td></tr>" skip
        "<tr style=""font:bold""><td><u>Рассматриваемый вопрос:</u></td><td>Реструктуризация долга</td></tr>" skip.

    put stream v-out unformatted
        "<tr><td colspan=""2""></td></tr>" skip
        "<tr style=""font:bold""><td colspan=""2"">Принято решение</td></tr>" skip
        "<tr><td colspan=""2"">" skip
        "<ul>" skip
        "<li>Установить дату погашения кредита начиная с " + string(v-dtpog,"99/99/9999") + " г.;</li>" skip
        "<li>Предусмотренные договором платежи с " + string(dt_from,"99/99/9999") + " г. до " + string(dt_to,"99/99/9999") + " г. распределить на оставшийся срок с " + string(v-dtpog,"99/99/9999") + " г. до " + string(lon.duedt,"99/99/9999") + " г.;</li>" skip
        "<li>Списать начисленную неустойку в размере " + replace(trim(string(v-bal5 + v-bal16,">>>,>>>,>>9.99")),',',' ') + " тенге.</li>" skip
        "</ul>" skip
        "</td></tr>" skip
        "<tr><td colspan=""2""></td></tr>" skip
        "<tr><td colspan=""2"">" skip
            "<table width=""100%"" border=""1"" cellspacing=""0"" cellpadding=""5"" align=""center"">" skip
            "<tr align=""center"" style=""font:bold"">" skip
            "<td>Должность</td>" skip
            "<td width=""20%"">ФИО</td>" skip
            "<td width=""13%"">Дата</td>" skip
            "<td width=""13%"">Одобрено</td>" skip
            "<td width=""13%"">Отклонено</td>" skip
            "</tr>" skip.

    put stream v-out unformatted
          "<tr>" skip
          "<td>Председатель Кредитного комитета</td>" skip
          "<td>Бисембиева Г.Т.</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "</tr>" skip
          "<tr>" skip
          "<td>Зам. председателя Кредитного комитета</td>" skip
          "<td>Ергалиева Г.К.</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "</tr>" skip
          "<tr>" skip
          "<td>Член Кредитного комитета</td>" skip
          "<td>Котуков В.А.</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "</tr>" skip
          "<td>Член Кредитного комитета</td>" skip
          "<td>Успангалиев А.С.</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "</tr>" skip
          "<td>Член Кредитного комитета</td>" skip
          "<td>Головлева А.Е.</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "<td>&nbsp;</td>" skip
          "</tr>" skip.

    put unformatted
        "</table>" skip
        "</td></tr>" skip
        "</table>" skip.

    {html-end.i " stream v-out " }

    output stream v-out close.
    unix silent cptwin dop.htm winword.

    /*galina - проставление признака реструктуризации*/
    run day-360(v-dtpogold,v-dtpog - 1,360,output v-dn1,output v-dn2).

    do transact:
        find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = 'LON' and sub-cod.d-cod = 'pkrst' use-index dcod exclusive-lock no-error .
        if not avail sub-cod then do:
            create sub-cod.
            assign sub-cod.acc = lon.lon
                   sub-cod.sub = 'LON'
                   sub-cod.d-cod = 'pkrst'
                   sub-cod.ccod = 'msc'.
        end.
        if sub-cod.ccod <> 'msc' then sub-cod.ccod = '04'.
        else do:
            if v-dn1 / 30 - truncate(v-dn1 / 30,4) = 0 then sub-cod.ccod = string(v-dn1 / 30,'99').
            else do:
                find first codfr where codfr.codfr = "pkrst" and codfr.code = string(round(v-dn1 / 30,0),'99') no-lock no-error.
                if avail codfr then sub-cod.ccod = string(round(v-dn1 / 30,0),'99').
            end.
        end.
    end.
   /**********/

end.
else if v-sel = 6 then do:
    if lon.plan = 4 then do:
        message " Кредит со схемой 4! " view-as alert-box error.
        return.
    end.
    if lon.prem = 0 then do:
        message " Процентная ставка = 0! " view-as alert-box error.
        return.
    end.

    find first aaa where aaa.aaa = lon.aaa no-lock no-error. /* счет - для upd-dep.i */
    find first cif where cif.cif = lon.cif no-lock no-error.
    if avail cif then do:
        v-rnn = cif.jss.
        v-name = trim(cif.name).
    end.

    v-dtpog = get-date(date(month(g-today),1,year(g-today)),1).
    update v-dtpog format "99/99/9999" label " (Перенос) Укажите след. дату погашения" with row 15 centered side-labels frame perfrdt.

    run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
    run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
    run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).
    run lonbalcrc('lon',lon.lon,g-today,"5",yes,1,output v-bal5).
    run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
    run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).
    run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-bal16).

    v-bal4tm = 0.
    if v-bal4 > 0 then do:
        dt_lev4 = ?.
        find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock no-error.
        if avail lnsci then dt_lev4 = lnsci.idat.
        else dt_lev4 = lon.rdt.
        run day-360(dt_lev4,g-today - 1,lon.basedy,output dn1,output dn2).
        v-bal4tm = round(dn1 * lon.opnamt * lon.prem / 100 / 360,2). /* эта сумма уже учтена в следующей записи по графику */
    end.
    /* Проверим, достаточно ли записей в графиках для отсрочки просроченных сумм */
    if v-bal7 > 0 then do:
        ost = 0.
        for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk no-lock:
            ost = ost + lnsch.stval.
        end.
        if ost < v-bal7 then do:
            message " Нехватка суммы в прошлых платежах по графику ОД для отсрочки просроченного ОД! " view-as alert-box error.
            return.
        end.
    end.
    if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
        ost = 0.
        for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock:
            ost = ost + lnsci.iv-sc.
        end.
        if ost < v-bal9 + v-bal4 - v-bal4tm then do:
            message " Нехватка суммы в прошлых платежах по графику %% для отсрочки просроченных %%! " view-as alert-box error.
            return.
        end.
    end.

    /* изменение графика ОД */
    dt_from = ?.
    if v-bal7 > 0 then do:
        ost = v-bal7.
        repeat:
            do transaction:
                find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat <= dat_wrk and lnsch.stval > 0 exclusive-lock no-error.
                if lnsch.stval > ost then do:
                    lnsch.stval = lnsch.stval - ost.
                    ost = 0.
                end.
                else do:
                    ost = ost - lnsch.stval.
                    lnsch.stval = 0.
                end.
                find current lnsch no-lock.
            end.
            if ost = 0 then leave.
        end. /* repeat */
        /* создаем новую запись в графике погашения ОД */
        do transaction:
            find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-dtpog exclusive-lock no-error.
            if not avail lnsch then do:
                create lnsch.
                lnsch.lnn = lon.lon.
                lnsch.stdat = v-dtpog.
                lnsch.f0 = 1.
                lnsch.stval = 0.
            end.
            lnsch.stval = lnsch.stval + v-bal7.
        end. /* transaction */
        run lnsch-ren(lon.lon).
        release lnsch.
    end.

    /* изменение графика %% */
    if v-bal9 + v-bal4 - v-bal4tm > 0 then do:
        ost = v-bal9 + v-bal4 - v-bal4tm.
        repeat:
            do transaction:
                find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk and lnsci.iv-sc > 0 exclusive-lock no-error.
                if lnsci.iv-sc > ost then do:
                    lnsci.iv-sc = lnsci.iv-sc - ost.
                    ost = 0.
                end.
                else do:
                    ost = ost - lnsci.iv-sc.
                    lnsci.iv-sc = 0.
                end.
                find current lnsci no-lock.
            end.
            if ost = 0 then leave.
        end. /* repeat */
        /* создаем новую запись в графике погашения %% */
        do transaction:
            find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-dtpog exclusive-lock no-error.
            if not avail lnsci then do:
                create lnsci.
                lnsci.lni = lon.lon.
                lnsci.idat = v-dtpog.
                lnsci.f0 = 1.
                lnsci.iv-sc = 0.
            end.
            lnsci.iv-sc = lnsci.iv-sc + v-bal9 + v-bal4 - v-bal4tm.
        end. /* transaction */
        run lnsci-ren(lon.lon).
        release lnsci.
    end.

    /* переносим проценты с 4-го на второй */
    if v-bal4 > 0 then do:
        v-rem = "Реструкт. Перенос %% из начисленных вне баланса в начисленные, " + v-rnn + " " + v-name.
        v-param = string(v-bal4) + vdel + lon.lon + vdel + v-rem + vdel + string(v-bal4).
        s-jh = 0.
        run trxgen ("lon0115", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        {upd-dep.i}
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal4 > 0 */

    /* списываем 5-ый */
    if v-bal5 > 0 then do:
        v-rem = "Реструкт. Списание внебалансовых штрафов, " + v-rnn + " " + v-name.
        v-param = string(v-bal5) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
        s-jh = 0.
        run trxgen ("lon0116", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
        run vou_bank(1).
    end. /* if v-bal5 > 0 */

    /* списываем 16-ый */
    if v-bal16 > 0 then do:
        v-rem = "Реструкт. Списание штрафов, " + v-rnn + " " + v-name.
        v-param = string(v-bal16) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel.
        s-jh = 0.
        run trxgen ("lon0063", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
        run vou_bank(1).
    end. /* if v-bal16 > 0 */

    /* переносим ОД с 7-го на 1-ый */
    if v-bal7 > 0 then do:
        v-rem = "Реструкт. Перенос ОД 7ур.->1ур., " + v-rnn + " " + v-name.
        v-param = string(v-bal7) + vdel + lon.lon + vdel + v-rem + vdel + vdel + vdel + vdel + vdel + "490".
        s-jh = 0.
        run trxgen ("lon0023", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal7 > 0 */

    /* переносим %% с 9-го на 2-ой */
    if v-bal9 > 0 then do:
        /*v-rem = "Реструкт. Перенос %% 9ур.->2ур.".*/
        v-param = string(v-bal9) + vdel + lon.lon.
        s-jh = 0.
        run trxgen ("lon0065", vdel, v-param, "lon", lon.lon, output rcode, output rdes, input-output s-jh).
        if rcode ne 0 then do:
            message rdes.
            pause 1000.
            next.
        end.
        run lonresadd(s-jh).
    end. /* if v-bal9 > 0 */
end.
/*else if v-sel = 7 then do:
   find first loncon where loncon.lon = lon.lon no-lock no-error.
   if avail loncon then do:
     if loncon.sods1 = 0 then do:
        v-num = 0.
        v-pen2 = loncon.sods2.
        v-pen2old = loncon.sods2.
        update v-pen2 with frame fpen2.
        if v-pen2 <> v-pen2old then do:
            update v-rempen with frame fpen2.
            do transaction:
              find current loncon exclusive-lock no-error.
              loncon.sods2 = v-pen2.
              find current loncon no-lock.
            end.
            find last ln%his where ln%his.lon = lon.lon no-error.
            if avail ln%his then v-num = ln%his.f0.
            do transaction:
                create ln%his.
                ln%his.lon = lon.lon.
                ln%his.stdat = g-today.
                ln%his.pnlt2 = v-pen2.
                ln%his.rem = v-rempen. --'ручное проставление %% внебал.ставки'.--
                ln%his.opnamt = lon.opnamt.
                ln%his.rdt = lon.rdt.
                ln%his.cif = lon.cif.
                ln%his.duedt = lon.duedt.
                ln%his.who = g-ofc.
                ln%his.whn = today.
                ln%his.f0 = v-num + 1.
            end.

            do transaction:
                find last lnprohis where lnprohis.lon = lon.lon and lnprohis.type = 'pen' and lnprohis.sts = 'A'  use-index lntpsts exclusive-lock no-error.
                if avail lnprohis then lnprohis.sts = 'C'.
            end.
        end.
     end.
     else do:
       message "Процентная ставка по балансовым штрафам не нулевая" view-as alert-box title "ВНИМАНИЕ".
       return.
     end.
   end.
   else do:
       message "Не найдена запись по процентной ставке балансовых шрафов" view-as alert-box title "ВНИМАНИЕ".
       return.
   end.
end.*/
else if v-sel = 7 then do:
   find first loncon where loncon.lon = lon.lon no-lock no-error.
   if avail loncon then do:
      v-dtrestor = ?.

      v-oldsods2 = 0.
      v-oldsods = 0.

      if loncon.pielikums[10] <> '' then do:
        v-dtrestor = date(entry(1,loncon.pielikums[10])).
        v-oldsods = integer(entry(3,loncon.pielikums[10])).
      end.
      else do:
        v-oldsods2 = loncon.sods2.
        v-oldsods = loncon.sods1.

      end.
      update v-dtrestor v-remdtrest with frame fdtrest.
        v-num = 0.
        do transaction:
          find current loncon exclusive-lock no-error.
          if v-oldsods2 <> 0 then loncon.sods2 = 0.
          if v-oldsods <> 0 then loncon.sods1 = 0.
          loncon.pielikums[10] = string(v-dtrestor,'99/99/9999') + ',' + g-ofc.
          if v-oldsods2 <> 0 then loncon.pielikums[10] = loncon.pielikums[10].
          if v-oldsods <> 0 then loncon.pielikums[10] = loncon.pielikums[10].
          find current loncon no-lock.
        end.

        do transaction:
           find sub-cod where sub-cod.acc = lon.lon and sub-cod.sub eq "LON" and sub-cod.d-cod eq "lnpen" exclusive-lock no-error.
           if avail sub-cod then sub-cod.ccode = "01".
           find current sub-cod no-lock.
        end.

        if v-oldsods2 <> 0 then do:
            find last ln%his where ln%his.lon = lon.lon no-error.
            if avail ln%his then v-num = ln%his.f0.
            do transaction:
                create ln%his.
                ln%his.lon = lon.lon.
                ln%his.stdat = g-today.
                ln%his.pnlt2 = 0.
                ln%his.rem = v-remdtrest.
                ln%his.opnamt = lon.opnamt.
                ln%his.rdt = lon.rdt.
                ln%his.cif = lon.cif.
                ln%his.duedt = lon.duedt.
                ln%his.who = g-ofc.
                ln%his.whn = today.
                ln%his.f0 = v-num + 1.
            end.
        end.
        if v-oldsods <> 0 then do:
            find last ln%his where ln%his.lon = lon.lon no-error.
            if avail ln%his then v-num = ln%his.f0.
            do transaction:
                create ln%his.
                ln%his.lon = lon.lon.
                ln%his.stdat = g-today.
                ln%his.pnlt1 = 0.
                ln%his.rem = v-remdtrest.
                ln%his.opnamt = lon.opnamt.
                ln%his.rdt = lon.rdt.
                ln%his.cif = lon.cif.
                ln%his.duedt = lon.duedt.
                ln%his.who = g-ofc.
                ln%his.whn = today.
                ln%his.f0 = v-num + 1.
            end.
        end.
        /*if v-oldsods2 <> 0 or v-oldsods <> 0 then do transaction:
            find last lnprohis where lnprohis.lon = lon.lon and lnprohis.type = 'pen' and lnprohis.sts = 'A'  use-index lntpsts exclusive-lock no-error.
            if avail lnprohis then lnprohis.sts = 'C'.
        end.*/
   end.
   else do:
       message "Не найдена запись по процентной ставке для штрафов" view-as alert-box title "ВНИМАНИЕ".
       return.
   end.
end.
else if v-sel = 8 then do:
    /* доначисление комиссии */
    if lon.plan = 6 then do:
        message "Недоступно для кредита с 6-ой схемой!" view-as alert-box error.
        return.
    end.
    find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
    if avail tarifex2 then v-8com = tarifex2.ost.
    else v-8com = 0.
    v-8ja = no.
    find first cif where cif.cif = lon.cif no-lock no-error.
    find first crc where crc.crc = lon.crc no-lock no-error.
    if avail crc then v-8crccode = crc.code.
    else v-8crccode = ''.
    update skip(1)
           v-8com label "Сумма (в валюте кредита)" format ">>>,>>>,>>9.99" validate(v-8com > 0,"Комиссия должна быть > 0!") skip
           v-8rem label "Примечание              " format "x(300)" view-as fill-in size 70 by 1 skip(1)
           v-8ja label "Произвести доначисление? " format "да/нет" skip(1)
           with centered overlay side-labels row 13 title " Комиссия к доначислению " width 98 frame fr9.
    if v-8ja then do:
        do transaction:
            create bxcif.
            assign bxcif.cif = lon.cif
                   bxcif.aaa = lon.aaa
                   bxcif.crc = lon.crc
                   bxcif.tim = time
                   bxcif.type = '195'
                   bxcif.whn = g-today
                   bxcif.who = if avail cif then cif.fname else ''
                   bxcif.amount = v-8com
                   bxcif.period = string(year(g-today),"9999") + "/" + string(month(g-today),"99")
                   bxcif.rem = trim(v-8rem)
                   bxcif.pref = yes.
            find current bxcif no-lock.
        end.
        run rec2log("(" + g-ofc + ") Доначисление " + bxcif.cif + ' aaa=' + bxcif.aaa +
                    " amount=" + trim(string(bxcif.amount,">>>,>>>,>>>,>>9.99")) + "(" + v-8crccode + ") " + trim(bxcif.rem)).
    end.
end.


