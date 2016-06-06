    /* lnpro_2.p
 * MODULE
        Потребительское кредитование
 * DESCRIPTION
        Изменение графика экспресс-кредита без проводок
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
        01/08/2011 dmitriy (разделил lnpro на 2 части: 1 - Пролонгация без проводок, 2 - Проводки по выбранным параметрам)
 * BASES
        BANK COMM
 * CHANGES
        06/10/11 dmitriy - заменил переменные v-dka и v-viewOnly на входные параметры
                         - добавил условие, если нет просрочек, то проводки делаются в ПролДКА или Пролонг
        31/10/11 kapar - в связи с возможным принятием решений Кредитного Комитета по экспресс-кредитам по пролонгации займов на срок более 31.12.2014.

*/

{global.i}
{pk.i}
{getdep.i}

/*
message "Операция временно недоступна!~nЗа более подробной информацией обращайтесь в Кредитный департамент." view-as alert-box.
return.
*/

def input parameter v-dka as logi no-undo.
def input parameter v-viewOnly as logi no-undo.

/*def var v-dka as logi no-undo.
def var v-viewOnly as logi no-undo.

v-dka = yes.
v-viewOnly = no.*/


def var v-mess as char no-undo.
def var v-protype as integer no-undo.
def var v-protype_list as char no-undo extent 4.
v-protype_list[1] = "Пролонгация кредита без отсрочки".
v-protype_list[2] = "Пролонгация кредита с отсрочкой".
v-protype_list[3] = "Предоставление отсрочки с распределением отсроченных платежей без пролонгации".
v-protype_list[4] = "Только перенос пени в отсроченную".
/*
v-protype (тип операции)
1 - Пролонгация кредита без отсрочки
2 - Пролонгация кредита с отсрочкой
3 - стд реструктуризация (предоставление отсрочки с распределением отсроченных платежей без пролонгации)
4 - только перенос пени в отсроченную
*/
def new shared var v-deltype as integer no-undo.
/*
v-deltype (тип отсрочки)
0 - без отсрочки
1 - отсрочка только ОД
2 - отсрочка ОД и %%
*/


def var v-till as integer no-undo.
v-till = 4.

def new shared temp-table t-lnsch no-undo
  field stdat as date
  field stval as deci
  field pcom as deci
  field odleft as deci
  index idx is primary stdat.

def new shared temp-table t-lnsci no-undo
  field idat as date
  field iv-sc as deci
  field prcpure as deci
  field prcadd as deci
  field prcleft as deci
  index idx is primary idat.

def buffer b-tlnsch for t-lnsch.
def buffer b-tlnsci for t-lnsci.

def var choice as logi no-undo.
def var ch as logi no-undo.
def var v-select as integer no-undo.

def new shared var v-dtend as date no-undo.
def new shared var v-dtpog as date no-undo.
def new shared var v-dtpog2 as date no-undo.
def var v-dtpogold as date no-undo.
def var v-perrate1 as deci no-undo.
def var v-perrate2 as deci no-undo.
def var v-com as deci no-undo.
def var v-comrate1 as deci no-undo.
def var v-comrate2 as deci no-undo.

def var v-sumcom1 as deci no-undo.
def var v-sumcom2 as deci no-undo.
def var v-sumcomd as deci no-undo.

def var v-bal1 as deci no-undo.
def var v-bal2 as deci no-undo.
def var v-bal4 as deci no-undo.
def var v-bal4tm as deci no-undo.

def new shared var v-balprc_raspr as deci no-undo.

def var v-bal5 as deci no-undo.
def var v-bal7 as deci no-undo.
def var v-bal9 as deci no-undo.

def var v-bal16 as deci no-undo.
def var v-bal16_1 as deci no-undo.
def var v-bal16_2 as deci no-undo.
def var v-bal16_3 as deci no-undo.
def var v-bal16_old as deci no-undo.
def var v-bal16_new as deci no-undo.

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
def var bil2_raspr as deci no-undo.
def var i as integer no-undo.
def var last_month as integer no-undo.
find last cls where cls.del no-lock no-error.
if avail cls then dat_wrk = cls.whn. else dat_wrk = g-today.

def var dt_lev4 as date no-undo.
def var dt_first as date no-undo.

def var v-rem as char no-undo.
def var dn1 as integer no-undo.
def var dn2 as decimal no-undo.
def new shared var s-jh as integer.
def var vdel as char no-undo initial "^".
def var rcode as integer no-undo.
def var rdes as char no-undo.
def var v-param as char no-undo.
def var v-code as char no-undo.
def var v-dep as char no-undo.
def buffer bjl for jl.

def var v-pensum as deci no-undo.
def var v-penspis as deci no-undo.
def var sum as deci.

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

function checkDtEnd returns logi (input v-date as date, input v-n as integer, output v-msg as char).
    def var v-res as logi no-undo.
    def var v-dtlim as date no-undo.
    def var pdn1 as integer no-undo.
    def var pdn2 as decimal no-undo.
    v-res = yes.
    if v-date <= g-today then assign v-res = no v-msg = "Дата окончания срока кредита раньше текущей!".
    else
    if v-date < lon.duedt then assign v-res = no v-msg = "Дата окончания кредита раньше уже установленной!".
    else
    if day(v-date) <> day(lon.duedt) then assign v-res = no v-msg = "День даты окончания кредита должен совпадать с днем даты выдачи!".
    else
    /*if v-date > 12/31/2014 then assign v-res = no v-msg = "Дата окончания кредита должна быть не позже 31/12/2014!".
    else*/
    if v-n > 0 then do:
        v-dtlim = get-date(lon.duedt,v-n).
        if v-date > v-dtlim then assign v-res = no v-msg = "Пролонгация не может быть более " + string(v-n) + " месяцев!".
    end.
    else do:
        if substring(string(lon.gl),1,4) = "1411" then do:
            run day-360(lon.rdt,v-date - 1,lon.basedy,output pdn1,output pdn2).
            if pdn1 > 360 then do:
                if v-dka then message "Кредит краткосрочный, срок кредита не может быть более 1 года!" view-as alert-box warning.
                else assign v-res = no v-msg = "Кредит краткосрочный, срок кредита не может быть более 1 года!~nОбратитесь в ДКА!".
            end.
        end.
    end.
    return (v-res).
end function.

function checkDtPogOd returns logi (input v-date as date, input v-n as integer, output v-msg as char).
    def var v-res as logi no-undo.
    def var v-dtlim as date no-undo.
    def var v-day as integer no-undo.
    v-res = yes.
    find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat = v-date no-lock no-error.
    if not avail lnsch then do:
        if v-date > lon.duedt and v-date <= v-dtend then do:
            v-day = 0.
            find last lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat < lon.duedt no-lock no-error.
            if avail lnsch then v-day = day(lnsch.stdat).
            if v-day = 0 then assign v-res = no v-msg = "Ошибка определения дня погашения ОД!".
            else do:
                if day(v-date) <> v-day then assign v-res = no v-msg = "День даты погашения ОД не совпадает с днем погашения кредита!".
            end.
        end.
        else assign v-res = no v-msg = "День даты погашения ОД не совпадает с днем погашения кредита!".
    end.

    if v-res then do:
        if v-n > 0 then do:
            find first lnsch where lnsch.lnn = lon.lon and lnsch.stdat >= g-today no-lock no-error.
            if not avail lnsch then assign v-res = no v-msg = "Ошибка - некорректный график погашения ОД!".
            else do:
                v-dtlim = get-date(lnsch.stdat,v-n).
                if v-date > v-dtlim then assign v-res = no v-msg = "Количество месяцев отсрочки не может быть более " + string(v-n) + "!".
            end.
        end.
    end.

    return (v-res).
end function.

function checkDtPogPrc returns logi (input v-date as date, input v-n as integer, output v-msg as char).
    def var v-res as logi no-undo.
    def var v-dtlim as date no-undo.
    def var v-day as integer no-undo.
    v-res = yes.
    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat = v-date no-lock no-error.
    if not avail lnsci then do:
        if v-date > lon.duedt and v-date <= v-dtend then do:
            v-day = 0.
            find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat < lon.duedt no-lock no-error.
            if avail lnsci then v-day = day(lnsci.idat).
            if v-day = 0 then assign v-res = no v-msg = "Ошибка определения дня погашения %%!".
            else do:
                if day(v-date) <> v-day then assign v-res = no v-msg = "День даты погашения %% не совпадает с днем погашения кредита!".
            end.
        end.
        else assign v-res = no v-msg = "День даты погашения %% не совпадает с днем погашения кредита!".
    end.

    if v-res then do:
        if v-n > 0 then do:
            find first lnsci where lnsci.lni = lon.lon and lnsci.idat >= g-today no-lock no-error.
            if not avail lnsci then assign v-res = no v-msg = "Ошибка - некорректный график погашения %%!".
            else do:
                v-dtlim = get-date(lnsci.idat,v-n).
                if v-date > v-dtlim then assign v-res = no v-msg = "Количество месяцев отсрочки не может быть более " + string(v-n) + "!".
            end.
        end.
    end.

    if v-res then do:
        /*message "v-date=" + string(v-date) + " v-dtpog=" + string(v-dtpog) view-as alert-box.*/
        if v-date > v-dtpog then assign v-res = no v-msg = "Отсрочка ОД не может быть меньше отсрочки %%!".
    end.

    if v-res then do:
        if v-dtpog = v-dtpogold and v-date <> v-dtpogold then assign v-res = no v-msg = "Не может быть отсрочки %% без отсрочки ОД!".
    end.

    return (v-res).
end function.

if s-pkankln = 0 then return.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then do:
    message skip " Анкета N" s-pkankln "не найдена! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first lon where lon.lon = pkanketa.lon no-lock no-error.
if not avail lon then do:
    message skip " Ссудный счет " + pkanketa.lon + " не найден! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal1).
if v-bal1 <= 0 then do:
    message skip " Кредит " + pkanketa.lon + " уже погашен! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first loncon where loncon.lon = lon.lon no-lock no-error.
if not avail loncon then do:
    message skip " Не найдена запись loncon по ссудному счету " + pkanketa.lon + "! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

find first cif where cif.cif = lon.cif no-lock no-error.
if not avail cif then do:
    message " Не найдена клиентская запись! " view-as alert-box error.
    return.
end.

if not v-dka then do:
    find first lnprohis where lnprohis.lon = lon.lon and lnprohis.type = "prolong" no-lock no-error.
    if avail lnprohis then do:
        message " По данному кредиту операция уже проводилась! " view-as alert-box error.
        return.
    end.
    run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output v-bal1).
    if lon.crc <> 1 then do:
        find first crc where crc.crc = lon.crc no-lock no-error.
        if avail crc then v-bal1 = v-bal1 * crc.rate[1].
        else do:
            message " Не найдена валюта в справочнике валют! " view-as alert-box error.
            return.
        end.
    end.
    if v-bal1 > 500000 then do:
        message " Основной долг по кредиту больше 500 000 тенге! ~n Обратитесь в Департамент кредитного администрирования! " view-as alert-box error.
        return.
    end.
end.

/* найдем текущий счет (только для upd-dep.i) */
find first aaa where aaa.aaa = lon.aaa no-lock no-error.
if not avail aaa then do:
    message skip " Текущий счет " + lon.aaa + " не найден! " skip(1) view-as alert-box buttons ok title " ОШИБКА ! ".
    return.
end.

if lon.plan = 4 then do:
    message " Кредит со схемой 4, пролонгация невозможна! " view-as alert-box error.
    return.
end.

find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "flagl" and sub-cod.ccode = '01' use-index dcod no-lock no-error.
if avail sub-cod then do:
    message " Начисление процентов выключено! Обратитесь в Кредитное Администрирование. " view-as alert-box error.
    return.
end.
find first sub-cod where sub-cod.acc = lon.lon and sub-cod.sub = "LON" and sub-cod.d-cod = "lnpen" and sub-cod.ccode = '01' use-index dcod no-lock no-error.
if avail sub-cod then do:
    message " Начисление штрафов выключено! Обратитесь в Кредитное Администрирование. " view-as alert-box error.
    return.
end.

/*
find first lnprohis where lnprohis.lon = lon.lon no-lock no-error.
if avail lnprohis then do:
    message " Внимание! По данному кредиту пролонгация уже производилась! " view-as alert-box error.
    if not v-dka then return.
end.
*/


def var v-rnn as char no-undo.
def var v-name as char no-undo.
v-rnn = cif.jss.
v-name = trim(cif.name).

v-dtend = lon.duedt.

v-dtpog = ?.
find first lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 and lnsch.stdat >= g-today no-lock no-error.
if avail lnsch then v-dtpog = lnsch.stdat.
else do:
    find first lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat >= g-today no-lock no-error.
    if avail lnsci then v-dtpog = lnsci.idat.
    else v-dtpog = g-today.
end.
v-dtpogold = v-dtpog.
v-dtpog2 = v-dtpog.

if lon.prem > 0 then v-perrate1 = lon.prem.
else do:
    if lon.prem1 > 0 then do:
        choice = no.
        message "По данному кредиту начисление %% производится внесистемно.~nПосле проведения продонгации начисление %% будет производиться в баланс.~nПродолжить?" view-as alert-box question buttons yes-no title "" update choice.
        if choice then v-perrate1 = lon.prem1.
        else return.
    end.
    else do:
        message "Процентные ставки по балансовым и внесистемным процентам = 0!~nОбратитесь в Деп-т Кредитного Администрирования." view-as alert-box error.
        return.
    end.
end.

if loncon.sods1 = 0 and loncon.sods2 = 0 then do:
    message "Ставки по балансовым и внесистемным штрафам = 0!~nОбратитесь в Деп-т Кредитного Администрирования." view-as alert-box error.
    return.
end.

v-perrate2 = v-perrate1.

v-com = 0. v-comrate1 = 0. v-comrate2 = 0.
find first tarifex2 where tarifex2.aaa = lon.aaa and tarifex2.cif = lon.cif and tarifex2.str5 = "195" and tarifex2.stat = 'r' no-lock no-error.
if avail tarifex2 then v-com = tarifex2.ost.

if v-com > 0 then v-comrate1 = round(v-com / lon.opnamt * 100,2).
else v-comrate1 = 0.

v-comrate2 = v-comrate1.

if lon.duedt <= g-today then do:
    message "Срок кредита истек! Возможен только перенос пени на отсрочку!" view-as alert-box warning.
    v-protype = 4.
    v-deltype = 0.
end.
else do:
    if v-dka then do:
        displ skip
              v-dtend format "99/99/9999"  label " Дата окончания срока кредита" " " skip
              v-dtpog format "99/99/9999"  label " Дата погашения ОД..........." " " skip
              v-dtpog2 format "99/99/9999" label " Дата погашения %%..........." " " skip
              v-perrate2 format ">9.99"    label " Ставка по вознагр. (%)......" " " skip
              v-comrate2 format ">9.99"    label " Ставка по комиссии (%)......" " " skip(1)
              with row 10 centered side-labels overlay frame frdt_dka.

        update v-dtend validate(checkDtEnd(v-dtend,0,output v-mess),v-mess) with frame frdt_dka.
        update v-dtpog validate(checkDtPogOd(v-dtpog,0,output v-mess),v-mess) with frame frdt_dka.
        update v-dtpog2 validate(checkDtPogPrc(v-dtpog2,0,output v-mess),v-mess) with frame frdt_dka.
        update v-perrate2 validate(v-perrate2 > 0,'Некорректное значение!') with frame frdt_dka.
        update v-comrate2 with frame frdt_dka.
        hide frame frdt_dka.
    end.
    else do:
        displ skip
              v-dtend format "99/99/9999"  label " Дата окончания срока кредита" " " skip
              v-dtpog format "99/99/9999"  label " Дата погашения ОД..........." " " skip
              v-dtpog2 format "99/99/9999" label " Дата погашения %%..........." " " skip(1)
        with row 15 centered side-labels frame frdt.

        update v-dtend validate(checkDtEnd(v-dtend,12,output v-mess),v-mess) with frame frdt.
        update v-dtpog validate(checkDtPogOd(v-dtpog,3,output v-mess),v-mess) with frame frdt.
        update v-dtpog2 validate(checkDtPogPrc(v-dtpog2,3,output v-mess),v-mess) with frame frdt.
        hide frame frdt.
    end.

    /*----- dmitriy -----*/
    find first pktrans where pktrans.pkank = s-pkankln exclusive-lock no-error.
        if not avail pktrans then do:
            create pktrans.
            pktrans.pkank = s-pkankln.
            pktrans.londt = v-dtend.
            pktrans.oddt = v-dtpog.
            pktrans.percdt = v-dtpog2.
            pktrans.bonus = v-perrate2.
            pktrans.commis = v-comrate2.
            pktrans.trans_dt = today.
        end.
        else do:
            pktrans.londt = v-dtend.
            pktrans.oddt = v-dtpog.
            pktrans.percdt = v-dtpog2.
            pktrans.bonus = v-perrate2.
            pktrans.commis = v-comrate2.
            pktrans.trans_dt = today.
        end.

    find first pktrans where pktrans.pkank = s-pkankln no-lock no-error.
    /*-------------------*/

    v-protype = 0.
    if v-dtend = lon.duedt then do:
        if (v-dtpog = v-dtpogold) and (v-dtpog2 = v-dtpogold) then v-protype = 4. /* данные не менялись, уточнить */
        else v-protype = 3. /* отсрочка без пролонгации */
    end.
    else do:
        if (v-dtpog = v-dtpogold) and (v-dtpog2 = v-dtpogold) then v-protype = 1. /* Пролонгация кредита без отсрочки */
        else v-protype = 2. /* Пролонгация кредита с отсрочкой */
    end.

    if v-protype = 0 then do:
        message "Некорректный вид операции!" view-as alert-box error.
        return.
    end.

    if (v-dtpog = v-dtpogold) and (v-dtpog2 = v-dtpogold) then v-deltype = 0.
    else
    if (v-dtpog > v-dtpogold) and (v-dtpog2 = v-dtpogold) then v-deltype = 1.
    else
    if (v-dtpog > v-dtpogold) and (v-dtpog2 > v-dtpogold) then v-deltype = 2.
    else do:
        message "Введены некорректные данные по датам отсрочки!" view-as alert-box error.
        return.
    end.

    if v-protype < 4 then message v-protype_list[v-protype] view-as alert-box information.
    else
    if v-protype = 4 then do:
        run sel2 (" Выбор: ", " 1. Распред. просроч. сумм + отсрочка пени | 2. Только перенос пени на отсрочку | 3. ВЫХОД ", output v-select).
        if v-select = 1 then v-protype = 3.
        else
        if v-select = 2 then v-protype = 4.
        else return.
    end.

    if v-protype = 4 then do:
        if (v-perrate2 <> v-perrate1) or (v-comrate2 <> v-comrate1) then do:
            message "Изменения ставок будут проигнорированы!" view-as alert-box warning.
            assign v-perrate2 = v-perrate1 v-comrate2 = v-comrate1.
        end.
    end.
    else do:
        if v-dtend <= g-today then do:
            message "Дата окончания срока кредита раньше текущей!~nВозможен только перенос пени на отсрочку!" view-as alert-box error.
            return.
        end.
    end.

end.

v-sumcom1 = round(lon.opnamt * v-comrate1 / 100,2).
v-sumcom2 = round(lon.opnamt * v-comrate2 / 100,2).

v-sumcomd = 0.
for each bxcif where bxcif.cif = lon.cif and bxcif.type = '195' and bxcif.aaa = lon.aaa and bxcif.crc = lon.crc no-lock:
    v-sumcomd = v-sumcomd + bxcif.amount.
end.

run lonbalcrc('lon',lon.lon,g-today,"1",yes,lon.crc,output v-bal1).
run lonbalcrc('lon',lon.lon,g-today,"2",yes,lon.crc,output v-bal2).
run lonbalcrc('lon',lon.lon,g-today,"4",yes,lon.crc,output v-bal4).
run lonbalcrc('lon',lon.lon,g-today,"5",yes,1,output v-bal5).
run lonbalcrc('lon',lon.lon,g-today,"7",yes,lon.crc,output v-bal7).
run lonbalcrc('lon',lon.lon,g-today,"9",yes,lon.crc,output v-bal9).
run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-bal16).

assign v-bal16_1 = 0
       v-bal16_2 = 0
       v-bal16_3 = 0
       v-bal16_old = 0
       v-bal16_new = 0.
if v-bal16 > 0 then do:
    /* вычислим штрафы прошлых лет и этого года */
    run lonbalcrc('lon',lon.lon,date(1,1,year(g-today)),"16",no,1,output v-bal16_1).
    run lonbalcrc('lon',lon.lon,g-today,"16",yes,1,output v-bal16_2).
    v-bal16_3 = 0.
    for each lonres where lonres.lon = lon.lon and lonres.jdt >= date(1,1,year(g-today)) and lonres.lev = 16 and lonres.dc = "C" no-lock:
        v-bal16_3 = v-bal16_3 + lonres.amt.
    end.
    if v-bal16_3 >= v-bal16_1 then assign v-bal16_old = 0 v-bal16_new = v-bal16.
    else do:
        v-bal16_old = v-bal16_1 - v-bal16_3.
        if v-bal16_old <= v-bal16_2 then v-bal16_new = v-bal16_2 - v-bal16_old.
        else do:
            message " Ошибка расчета штрафов, начисленных в текущем/прошлых годах! ~n Обратитесь в Кредитное Администрирование." view-as alert-box error.
            return.
        end.
    end.
end.

if v-protype <> 4 then do:

    empty temp-table t-lnsch.
    empty temp-table t-lnsci.
    /* копия графика ОД */
    for each lnsch where lnsch.lnn = lon.lon and lnsch.f0 > 0 no-lock:
        create t-lnsch.
        t-lnsch.stdat = lnsch.stdat.
        t-lnsch.stval = lnsch.stval.
    end.

    /* добавим в графики суммы по комиссии */
    for each t-lnsch no-lock:
        ch = no.
        if day(t-lnsch.stdat) > v-till then ch = yes.
        else do:
            find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
            if (not avail b-tlnsch) or (day(b-tlnsch.stdat) <> day(t-lnsch.stdat)) then ch = yes.
            else do:
                find first b-tlnsch where b-tlnsch.stdat > t-lnsch.stdat no-lock no-error.
                if (not avail b-tlnsch) or (day(b-tlnsch.stdat) <> day(t-lnsch.stdat)) then ch = yes.
            end.
        end.
        if ch then do:
            if t-lnsch.stdat <= dat_wrk then t-lnsch.pcom = v-sumcom1.
            else t-lnsch.pcom = v-sumcom2.
        end.
    end.

    /* копия графика %% */
    for each lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 no-lock:
        create t-lnsci.
        t-lnsci.idat = lnsci.idat.
        t-lnsci.iv-sc = lnsci.iv-sc.
    end.

    v-bal4tm = 0.
    if v-bal4 > 0 then do:
        dt_lev4 = ?.
        find last lnsci where lnsci.lni = lon.lon and lnsci.f0 > 0 and lnsci.idat <= dat_wrk no-lock no-error.
        if avail lnsci then dt_lev4 = lnsci.idat.
        else dt_lev4 = lon.rdt.
        run day-360(dt_lev4,g-today - 1,lon.basedy,output dn1,output dn2).
        v-bal4tm = round(dn1 * lon.opnamt * v-perrate1 / 100 / 360,2). /* эта сумма уже учтена в следующей записи по графику */

        /*
        run lonbalcrc('lon',lon.lon,dt_lev4,"4",no,lon.crc,output v-bal4tm).
        v-bal4tm = v-bal4 - v-bal4tm. -- непросроченные внебалансовые %% - эта сумма уже учтена в следующей записи по графику --
        */
        if v-bal4tm < 0 then v-bal4tm = 0.
        if v-bal4tm > v-bal4 then v-bal4tm = v-bal4.
    end.

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
    if v-bal7 > 0 then do:
        /*message " lev7 ... 2 " view-as alert-box.*/
        ost = v-bal7.
        repeat:
            find last t-lnsch where t-lnsch.stdat <= dat_wrk and t-lnsch.stval > 0 no-error.
            /*message "1.... " + string(lnsch.stdat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsch.stval=" + trim(string(lnsch.stval,">>>,>>>,>>9.99")) view-as alert-box.*/
            if t-lnsch.stval > ost then do:
                t-lnsch.stval = t-lnsch.stval - ost.
                ost = 0.
            end.
            else do:
                ost = ost - t-lnsch.stval.
                t-lnsch.stval = 0.
            end.
            if ost = 0 then leave.
        end. /* repeat */
    end.

    /* изменение графика %% */
    v-balprc_raspr = v-bal9 + v-bal4 - v-bal4tm.
    if v-balprc_raspr > 0 then do:
        /*message " lev9+4-4tm ... 2 " view-as alert-box.*/
        ost = v-balprc_raspr.
        repeat:
            find last t-lnsci where t-lnsci.idat <= dat_wrk and t-lnsci.iv-sc > 0 no-error.
            /*message "1.... " + string(lnsci.idat,"99/99/9999") + " ost=" + trim(string(ost,">>>,>>>,>>9.99")) + " lnsci.iv-sc=" + trim(string(lnsci.iv-sc,">>>,>>>,>>9.99")) view-as alert-box.*/
            if t-lnsci.iv-sc > ost then do:
                t-lnsci.iv-sc = t-lnsci.iv-sc - ost.
                ost = 0.
            end.
            else do:
                ost = ost - t-lnsci.iv-sc.
                t-lnsci.iv-sc = 0.
            end.
            if ost = 0 then leave.
        end. /* repeat */
    end.

    last_month = 0.
    find last t-lnsch no-lock no-error.
    find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
    if avail t-lnsch and avail b-tlnsch then do:
        run day-360(b-tlnsch.stdat,t-lnsch.stdat - 1,360,output dn1,output dn2).
        /*last_month = t-lnsch.stdat - b-tlnsch.stdat.*/
        last_month = dn1.
    end.

    /* message " last_month=" + string(last_month,">>>,>>>,>>9") view-as alert-box. */

    /* проверка на случай, если платежи переносят на последний платеж по графику */
    if last_month <> 30 then do:
        find last t-lnsch no-lock no-error.
        if avail t-lnsch and v-dtpog = t-lnsch.stdat then do:
            find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
            if avail b-tlnsch then v-dtpog = get-date(b-tlnsch.stdat,1).
        end.
        find last t-lnsci no-lock no-error.
        if avail t-lnsci and v-dtpog2 = t-lnsci.idat then do:
            find last b-tlnsci where b-tlnsci.idat < t-lnsci.idat no-lock no-error.
            if avail b-tlnsci then v-dtpog2 = get-date(b-tlnsci.idat,1).
        end.
    end.

    find last b-tlnsch where b-tlnsch.stdat < t-lnsch.stdat no-lock no-error.
    if avail b-tlnsch then do:
        run day-360(b-tlnsch.stdat,t-lnsch.stdat - 1,360,output dn1,output dn2).
        /*last_month = t-lnsch.stdat - b-tlnsch.stdat.*/
        last_month = dn1.
    end.

    /* запоминаем дату первого платежа по графику */
    dt_first = ?.
    find first t-lnsch no-lock no-error.
    if avail t-lnsch then dt_first = t-lnsch.stdat.

    /*message " dt_first=" + string(dt_first,"99/99/9999") view-as alert-box.*/

    /* удаляем все следующие графики */
    for each t-lnsch where t-lnsch.stdat > dat_wrk:
        delete t-lnsch.
    end.
    for each t-lnsci where t-lnsci.idat > dat_wrk:
        delete t-lnsci.
    end.

    /* строим новые графики */
    stdt = ?.
    if day(v-dtpog) > day(dat_wrk) then stdt = date(month(dat_wrk),day(v-dtpog),year(dat_wrk)).
    else do:
        newdt = get-date(dat_wrk,1).
        stdt = date(month(newdt),day(v-dtpog),year(newdt)).
    end.

    /*message " stdt=" + string(stdt,"99/99/9999") view-as alert-box.*/

    mnum = 0.
    mnuma = 0.
    mnuma2 = 0.
    if stdt <> ? then newdt = stdt.
    else newdt = dt_first.
    repeat:
        if newdt > v-dtend then newdt = v-dtend.
        else do:
            /*if v-dtend - stdt <= last_month then newdt = v-dtend.*/
            run day-360(stdt,v-dtend - 1,360,output dn1,output dn2).
            if dn1 <= last_month then newdt = v-dtend.
        end.
        /*
        message " newdt=" + string(newdt,"99/99/9999") + '~n'
                " mnum=" + string(mnum) + '~n'
                " mnuma=" + string(mnuma) + '~n'
                " mnuma2=" + string(mnuma2)
                view-as alert-box.
        */
        create t-lnsch.
        t-lnsch.stdat = newdt.
        t-lnsch.pcom = v-sumcom2.
        create t-lnsci.
        t-lnsci.idat = newdt.
        mnum = mnum + 1.
        if newdt >= v-dtpog then mnuma = mnuma + 1.
        if newdt >= v-dtpog2 then mnuma2 = mnuma2 + 1.
        stdt = newdt.
        if stdt = v-dtend then leave.
        newdt = get-date(stdt,1).
    end.

    /*message "1111.... mnum=" + string(mnum,">>9") + " mnuma=" + string(mnuma,">>9") + " mnuma2=" + string(mnuma2,">>9") view-as alert-box.*/

    stdt = dat_wrk.
    bil1 = truncate((v-bal1 + v-bal7) / mnuma,0).
    run day-360(g-today,v-dtend - 1,360,output dn1,output dn2).
    ost = round(dn1 * lon.opnamt * v-perrate2 / 36000,2).
    bil2 = truncate((v-bal2 + v-bal4 + v-bal9 + ost) / mnuma2,0).

    bil2_raspr = truncate(v-balprc_raspr / mnuma2,0).

    /*message "2222.... bil1=" + trim(string(bil1,">>>,>>>,>>9.99")) + " dn1=" + string(dn1,">,>>9") + " ost=" + trim(string(ost,">>>,>>>,>>9.99"))  + " bil2=" + trim(string(bil2,">>>,>>>,>>9.99")) view-as alert-box.*/

    do i = 1 to mnum:
        find first t-lnsch where t-lnsch.stdat > stdt no-error.
        if avail t-lnsch then do:
            if t-lnsch.stdat >= v-dtpog then do:
                t-lnsch.stval = bil1.
                if i = mnum then t-lnsch.stval = v-bal1 + v-bal7 - bil1 * (mnuma - 1).
            end.
        end.
        find first t-lnsci where t-lnsci.idat = t-lnsch.stdat no-error.
        if avail t-lnsci then do:
            if t-lnsci.idat >= v-dtpog2 then do:
                if i < mnum then do:
                    t-lnsci.iv-sc = bil2.
                    t-lnsci.prcadd = bil2_raspr.
                    t-lnsci.prcpure = bil2 - bil2_raspr.
                end.
                else do:
                    t-lnsci.iv-sc = v-bal2 + v-bal4 + v-bal9 + ost - bil2 * (mnuma2 - 1).
                    t-lnsci.prcadd = v-balprc_raspr - bil2_raspr * (mnuma2 - 1).
                    t-lnsci.prcpure = t-lnsci.iv-sc - t-lnsci.prcadd.
                end.
            end.
        end.
        stdt = t-lnsch.stdat.
    end.

    /* выведем график для проверки правильности реструктуризации */
    def stream rep.
    output stream rep to rep.htm.
    put stream rep unformatted
        "<html><head>" skip
        "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251""/>" skip
        "<META HTTP-EQUIV=""Content-Language"" content=""ru""/>" skip
        "<STYLE TYPE=""text/css"" ID=""default""> table \{font:Times New Roman Cyr, Verdana, sans; font-size: 12" skip
        "small; border-collapse: collapse; text-valign:top\}</STYLE>" skip
        "</head><body>" skip.

    find first crc where crc.crc = lon.crc no-lock no-error.
    put stream rep unformatted
        "Наименование/имя заемщика (код): " cif.name " (" cif.cif ")<BR>" skip
        "Ссудный счет: " lon.lon "<BR>" skip
        "Сумма кредита: " lon.opnamt " " crc.code "<BR><BR>" skip.

    put stream rep unformatted
        "<h2>График погашения основного долга</h2>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td width=30>N</td>" skip
        "<td width=100>Дата</td>" skip
        "<td width=100>Сумма</td>" skip
        "<td width=100>Сумма комиссии</td>" skip
        "</tr>" skip.

    i = 1.
    for each t-lnsch no-lock:
        put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">" i "</td>" skip
                 "<td align=""center"">" t-lnsch.stdat "</td>" skip
                 "<td align=""right"">" replace(trim(string(t-lnsch.stval,">>>>>>>>9.99")),'.',',') "</td>" skip
                 "<td align=""right"">" replace(trim(string(t-lnsch.pcom,">>>>>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip.
        i = i + 1.
    end.
    put stream rep unformatted "</table><BR><BR>" skip.

    put stream rep unformatted
        "<h2>График погашения процентов</h2>" skip
        "<table border=1 cellpadding=0 cellspacing=0>" skip
        "<tr style=""font:bold;font-size:xx-medium"" bgcolor=""#C0C0C0"" align=""center"">" skip
        "<td width=30>N</td>" skip
        "<td width=100>Дата</td>" skip
        "<td width=100>Сумма</td>" skip
        "</tr>" skip.

    i = 1.
    for each t-lnsci no-lock:
        put stream rep unformatted
                 "<tr>" skip
                 "<td align=""center"">" i "</td>" skip
                 "<td align=""center"">" t-lnsci.idat "</td>" skip
                 "<td align=""right"">" replace(trim(string(t-lnsci.iv-sc,">>>>>>>>9.99")),'.',',') "</td>" skip
                 "</tr>" skip.
        i = i + 1.
    end.
    put stream rep unformatted "</table></body></html>" skip.

    output stream rep close.
    unix silent cptwin rep.htm excel.

    /* дорисуем в график долг по комиссии */
    if v-sumcomd > 0 then do:
        find first t-lnsch where t-lnsch.stdat > dat_wrk no-error.
        if avail t-lnsch then t-lnsch.pcom = t-lnsch.pcom + v-sumcomd.
    end.

    /* дорисуем в графики остаток ОД и остаток отсроченных распределенных процентов */
    ost = v-bal1 + v-bal7.
    for each t-lnsch where t-lnsch.stdat > dat_wrk:
        ost = ost - t-lnsch.stval.
        t-lnsch.odleft = ost.
    end.

    ost = v-balprc_raspr.
    for each t-lnsci where t-lnsci.idat > dat_wrk:
        ost = ost - t-lnsci.prcadd.
        t-lnsci.prcleft = ost.
    end.

end. /* if v-protype <> 4 */

if v-viewOnly then return.

run value("lnprodop" + string(v-protype)).

sum = v-bal4 + v-bal5 + v-bal7 + v-bal9 + v-bal16.

if sum = 0 then do:
    if v-dka = yes then do: run lnpro_r1. end.
    if v-dka = no  then do: run lnpro_r0. end.
end.
