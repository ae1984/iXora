/* pkcifnew.p
 * MODULE
        Потребительские кредиты
 * DESCRIPTION
        Создать нового клиента
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
        29.01.03 marinav
 * CHANGES
        25.02.03 добавлена схема начисления процентов
        07.03.03 nadejda - добавлен вызов обновления поля lon.lcr
        30.07.03 marinav - изменены признаки кредита (в связи с изменением справочников)
        07.08.03 nadejda - изменила вызов процедуры проставления исключений по тарифам, теперь cif передается как параметр
        20.08.03 nadejda - добавила проставление по коду клиенту справочника пола клиента clnsex
        08.09.03 nadejda - добавила при создании первой проводки проставление jh.sub = "lon"
        22.10.03 nadejda - добавила проставление процента пени по ссудному счету loncon.sods1
        05.10.03 sasco   - проставляется cif.crg - отметка об акцепте CIF клиента
        24.11.03 marinav - в LON прописывается новый признак lnsegm....
        28.01.04 sasco   - вызов pk-trx.p теперь общий для всех видов кредита
        01.02.04 nadejda - запись адресов прописки и фактического проживания в cif.dnb через разделители
                           контактный телефон - cif.btel
                           РНН и адрес места работы - cif.item
        07/06/2004 madiyar - для тестирования 4-ая схема задается пока только в Атырау
        24.06.2004 nadejda - исправлено присваивание отметки о контроле клиента - номер записи для связки с данными о контроле
        28/07/2004 madiyar - день погашения не может быть задан с 25 по 31 число. Если день выдачи кредита приходится
                             на этот период - день сдвигается на начало следующего месяца (25 - 1, 26 - 2, ...)
        08.12.2004 saltanat - берутся тарифы со статусом "r" - рабочий.
        31.12.2004 saltanat - сделано обновление данных cif по данным pkanketa.
        16/05/2005 madiyar - счет ГК для комиссий теперь определяется не по "tarif2", а по "tarfnd"
        10/06/2005 madiyar - при выдаче запись в lnscg создается датой g-today, а не today
        05.07.2005 saltanat - Выборка льгот по счетам.
        03/10/2005 madiyar - перекомпиляция
        21/02/2006 madiyar - проверка номера карты (при наличии такового) и его перенос в ссудный счет, перевод суммы на тр.счет ДПлК для VISA Instant
        07/04/2006 madiyar - проверка наличия фотографий
        11/04/2006 madiyar - биометрический контроль
        12/04/2006 madiyar - биометрический контроль - пока только в Алматы
        17/04/2006 madiyar - отключаем биометрический контроль
        12/05/2006 madiyar - рефинансирование
        16/05/2006 madiyar - рефинансирование: по кредитам с 5 схемой, выданным начиная с 16/05/2005, необходимо доначислять проценты за месяц
        16/06/2006 madiyar - рефинансирование: на филиалах доначисляем проценты по кредитам с 5 схемой, выданным не с 16/05/2005, а с 04/10/2005
        16/10/2006 madiyar - рефинансирование: если день погашения сегодня, то доначислять ничего не нужно
        11/12/2006 madiyar - рефинансирование: автоматическое доначисление процентов
        14/02/2007 madiyar - изменения, связанные с удалением нескольких полей таблицы lon
        15/02/2007 marinav - временно убрала фото
        16/02/2007 madiyar - проставление схемы кредита в зависимости от типа кредита (5 для физ, 4 для ИП)
        05/03/2007 madiyar - изменения в списке параметров временно закомментированной процедуры check_linked_photos
        07/03/2007 madiyar - проставление lon.clnsts
        06/04/2007 madiyar - проставление lon.sts = "A"
        16/04/2007 marinav - признак lnsegm для разных кредитов свой
        24/04/2007 madiyar - веб-анкеты
        06/07/2007 madiyar - изменение программ кредитования (схема ИП = 5)
        11/10/2007 madiyar - все ордера попадают в один документ
        06/01/08 marinav - исправлен путь к базам с /data/9/ на  /data/
        04.06.2008 madiyar - валютный контроль
        05/06/2008 madiyar - ставка по штрафам берется из "lnpen%" pksysc.chval
        05.08.2008 galina - в cif.pss добавляем дату и кем выдано удостоверение
        13/08/08   marinav - изменились справочники lntgt lnopf lonsec
        03/09/2008 galina - отменены изменения справочников lntgt lonsec от 13/08/08
        19.09.2008 galina - проверка наличия действующего договора по спец.уловиям кредитования. проверка соотвествия условий кредитования
        26/05/2009 madiyar - закомментил доначисление процентов при рефинансировании
        22.06.2009 galina - добавила отрытие 20-тизначных счетов
        03/08/2009 galina - поправила валюту для 20-тизначных счетов
        04/08/2009 galina - исправила открытие счетов
        24/08/2009 galina - изменения для полного погашения рефинансируемого кредита
        11/10/2010 galina - формируем график сразу после выдачи
        12/01/2010 galina - меняем статус на 99 после рефинансирования
        19/01/2010 galina - добавила ИИН
        25/02/2010 galina - изменила формат адреса для передачи в cif
        02.07.2010 marinav - удалено открытие 9-зн счета
        25/11/2010 madiyar - записываем ставку по штрафам еще и в поля lon.penprem и lon.penprem7
*/

{global.i}
{pk.i}

{lonlev.i}
{pk-sysc.i}
{pkcifnew.i}
{pkduedt.i}

def new shared variable s-cif like cif.cif.
def new shared var s-lgr like lgr.lgr.
def var v-addr as char no-undo.
def var v-addrfakt as char no-undo.
def var v-addr1 as char no-undo.
def var v-addrfakt1 as char no-undo.
def var v-shifr as char no-undo.
def new shared var s-longrp like longrp.longrp.
def new shared var s-aaa like aaa.aaa.

define new shared variable v_doc as character init "".
define new shared variable s-jh as int.
define variable vdel    as character no-undo initial "^".
define variable rcode   as integer no-undo.
define variable rdes    as character no-undo.
define variable knpln1  as character no-undo init "411".
define variable knpln2  as character no-undo init "890".
define variable vparam  as character no-undo.
define variable totsum  as decimal no-undo.
define variable comsum  as decimal no-undo.
define variable v-sumdplk as decimal no-undo.
def var v-arpcard as char no-undo.
define variable i as int no-undo.

def var v-bal as deci no-undo.
def var v-balt as deci no-undo.
def var v-nxt as int no-undo.
def var v-typ as char no-undo.
def var v-lgr like lgr.lgr no-undo.
def var qaaa like aaa.aaa no-undo.
def var v-profcn as char no-undo.
def var v-sex as char no-undo.
def var v-sts as char no-undo.
def var v-chk as char no-undo format "x(6)".
def var v-file as char no-undo.

def var v-acc20 as char no-undo.
def var v-acc20val as char no-undo.

def buffer b-aaa for aaa.

def new shared var v-resref as integer no-undo.
procedure fmsg-w.
    def input parameter p-bank as char no-undo.
    def input parameter p-credtype as char no-undo.
    def input parameter p-ln as integer no-undo.
    def input parameter p-msg as char no-undo.
    do transaction:
        find first pkanketh where pkanketh.bank = p-bank and pkanketh.credtype = p-credtype and pkanketh.ln = p-ln and pkanketh.kritcod = "fmsg" exclusive-lock no-error.
        pkanketh.value1 = p-msg.
        find current pkanketh no-lock.
    end.
end procedure.

find first pkanketa where pkanketa.bank = s-ourbank and pkanketa.credtype = s-credtype and pkanketa.ln = s-pkankln no-lock no-error.
if not avail pkanketa then leave.

def var v-inet as logi init no.
if pkanketa.id_org = "inet" then v-inet = yes.

if pkanketa.cdt = ? or pkanketa.cwho = "" then do:
   if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Выдача кредита еще не утверждена!").
   else message "Выдача кредита еще не утверждена!" view-as alert-box title "".
   return.
end.

/*02.09.2008 galina проверка наличия действующего договора по спец.уловиям кредитования. проверка соотвествия условий кредитования*/
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = pkanketa.credtype and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "dogorg" no-lock no-error.
if avail pkanketh then do:
    if num-entries(pkanketh.value1) = 1 then do:
        if pkanketh.value1 = "1" then
          message "Ставка по кредиту была проставлена по спец.условиям," +
          "~n указанным в справочнике организаций со спец.условиями кредитования. " +
          "~nСоглашение с организацией истекло до выдачи кредита." +
          "~nКредит не будет выдан. Обратитесь в Департамент потреб.кредитования." view-as alert-box.
        else
          message "Комиссия за выдачу кредита была рассчитана по спец.условиям," +
          "~n указанным в справочнике организаций со спец.условиями кредитования." +
          "~nСоглашение с организацией истекло до выдачи кредита." +
          "~nКредит не будет выдан. Обратитесь в Департамент потреб.кредитования." view-as alert-box.
        return.
    end.
    find last lnpriv where lnpriv.credtype = s-credtype and lnpriv.bank = s-ourbank and lnpriv.rnn = pkanketa.jobrnn no-lock no-error.
    if avail lnpriv and g-today > lnpriv.dte then do:
        message "Кредитная заявка была обработана по спец.условиям," +
          "~n указанным в справочнике организаций со спец.условиями кредитования." +
          "~nСоглашение с организацией истекло до выдачи кредита." +
          "~nКредит не будет выдан. Обратитесь в Департамент потреб.кредитования." view-as alert-box.
          return.
    end.
end.

if pkanketa.sts < "30" then do:
    /* открытие счетов */
    find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "dtchck" no-lock no-error.
    if avail pksysc and pksysc.loval and pkanketa.docdt < g-today then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Дата договора меньше сегодняшней! В выдаче отказано").
        else message "Дата договора меньше сегодняшней!~nВ выдаче отказано" view-as alert-box title "".
        return.
    end.

    find first cif where cif.cif = pkanketa.cif no-lock no-error.
    if not avail cif then do: /* begin not avail cif */
        do transaction on error undo, retry:
            find nmbr where nmbr.code = "cif" exclusive-lock.
            s-cif = string(nmbr.prefix + string(nmbr.nmbr + 1) + nmbr.sufix).
            nmbr.nmbr = nmbr.nmbr + 1.
            release nmbr.
            create cif.
            assign cif.cif = s-cif
                   cif.regdt = g-today
                   cif.who = g-ofc
                   cif.whn = g-today
                   cif.tim = time
                   cif.ofc = g-ofc
                   cif.type = "P".

            create crg.
            crg.crg = string(next-value(crgnum)).
            assign
                 crg.des = s-cif
                 crg.who = g-ofc
                 crg.whn = g-today
                 crg.stn = 1
                 crg.tim = time
                 crg.regdt = g-today.
            cif.crg = string(crg.crg).

            find last ofchis where ofchis.ofc = g-ofc no-lock.
            cif.jame = string(ofchis.point * 1000 + ofchis.dep).
            cif.name = pkanketa.name.

            run pkdefsfio (pkanketa.ln, output cif.sname).
            /* 31.12.2004 saltanat - это было ниже, Т/З.1261 Обновление данных клиента */
            cif.geo = "021".
            cif.cgr = 501.
            cif.stn = 0.
            cif.fname = g-ofc.

            for each sub-dic where sub-dic.sub = "cln" no-lock.
                find first sub-cod where sub-cod.acc = s-cif and sub-cod.sub = "cln" and sub-cod.d-cod = sub-dic.d-cod use-index dcod  no-lock no-error .
                if not avail sub-cod then do:
                    create sub-cod.
                    sub-cod.acc = s-cif.
                    sub-cod.sub = "cln".
                    sub-cod.d-cod = sub-dic.d-cod.
                    sub-cod.ccode = "msc".
                end.
            end.

            find ofc where ofc.ofc = g-ofc no-lock no-error.

            find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "mf" no-lock no-error.
            if avail pkanketh and pkanketh.value1 <> "" then v-sex = trim(pkanketh.value1).

            {pk-sub-cod.i "'cln'" "'sproftcn'" s-cif ofc.titcd }
            {pk-sub-cod.i "'cln'" "'clnsts'"   s-cif "'1'"   }
            {pk-sub-cod.i "'cln'" "'ecdivis'"  s-cif "'98'"  }
            {pk-sub-cod.i "'cln'" "'secek'"    s-cif "'9'"  }
            {pk-sub-cod.i "'cln'" "'clnsex'"   s-cif v-sex }
        end. /* transaction */
    end. /* not avail cif */
    else s-cif = cif.cif.

    /* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ Обновление данных клиента $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */
    /* сборка полного адреса */
    /*v-addr = "".
    if cif.addr[1] <> "" then v-addr = cif.addr[1] + ", ".

    run pkdefadres (s-pkankln, yes, output v-addr, output v-addrfakt, output v-addr1, output v-addrfakt1).*/

    run pkdefadres1 (s-pkankln, output v-addr, output v-addrfakt, output v-addr1, output v-addrfakt1).
    
    do transaction:
        if not avail cif then find first cif where cif.cif = pkanketa.cif exclusive-lock no-error.
        else find current cif exclusive-lock no-error.

        cif.addr[2] = v-addr.
        cif.dnb = v-addr1 + '|' + v-addrfakt1.

        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "bdt" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.expdt = date(pkanketh.value1).

        cif.jss = pkanketa.rnn.
        /* номер удост. */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "numpas" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.pss = pkanketh.value1.
         /* 05.08.08 galina - добавляем дату и кем выдано удостоверение */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "dtpas" no-lock no-error.
        if avail pkanketh then cif.pss = cif.pss + " " + pkanketh.value1.
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "pkdvyd" no-lock no-error.
        if avail pkanketh then do:
            find first pkkrit where pkkrit.kritcod = pkanketh.kritcod no-lock no-error.
            if avail pkkrit then find first bookcod where bookcod.bookcod = pkkrit.kritspr and bookcod.code = pkanketh.value1 no-lock no-error.
            if avail bookcod then cif.pss = cif.pss + " " + bookcod.name.
        end.
        /* 05.08.08 galina - end */
        /* тел.домашний */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then  cif.tel = pkanketh.value1.
        /* тел. раб. */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel2" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then  cif.tlx = pkanketh.value1.
        /* тел.сотовый */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel3" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then  cif.fax = pkanketh.value1.
        /* тел.контактный */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "tel4" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then  cif.btel = pkanketh.value1.
        /* РНН места работы и адрес */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobrnn" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.item = pkanketh.value1.
                                                    else cif.item = "".
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobadd" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.item = cif.item + "|" + pkanketh.value1.
        /* название места работы */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "joborg" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.ref[8] = pkanketh.value1.
        /* должность */
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "jobsn" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.sufix = pkanketh.value1.
        
         /*ИИН*/
        find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "iin" no-lock no-error.
        if avail pkanketh and pkanketh.value1 <> "" then cif.bin = pkanketh.value1.

        /* $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ */

        /* определение группы кредита */
        v-typ = "longr" + (if pkanketa.srok <= 12 then "1" else "2"). /* делим только по сроку - по валюте не надо! */
        s-longrp = get-pksysc-int (v-typ).

        find current cif no-lock no-error.
    end. /* transaction */

    find longrp where longrp.longrp = s-longrp no-lock no-error.
    find gl of longrp no-lock no-error.

    run acng(input gl.gl, false, output s-lon).

    do transaction:
        find lon where lon.lon eq s-lon exclusive-lock.
        assign lon.grp = s-longrp
               lon.cif = s-cif
               lon.gl = longrp.gl
               lon.rdt = g-today
               lon.extdt = today
               lon.base = "F"
               lon.prnmos = 2
               lon.who = g-ofc
               lon.whn = g-today
               lon.prem = pkanketa.rateq
               lon.duedt = pkanketa.duedt
               lon.loncat = 504
               lon.opnamt = pkanketa.summa
               lon.crc = pkanketa.crc
               lon.gua = "LO".
        lon.basedy = get-pksysc-int ("pkbase").

        if s-credtype = '7' then lon.clnsts = 2. /* ИП */
        else lon.clnsts = 1. /* физ. лицо */

        lon.sts = "A".

        create loncon.
        assign loncon.lon = s-lon
               loncon.cif =  s-cif
               loncon.rez-char[9] = cif.jss
               loncon.who = g-ofc
               loncon.whn = g-today
               loncon.objekts = pkanketa.goal
               loncon.lcnt = entry (1, pkanketa.rescha[1], ",").
        loncon.sods1 = deci(entry(pkanketa.crc,get-pksysc-char ("lnpen%"),"|")).
        
        lon.penprem = loncon.sods1.
        lon.penprem7 = loncon.sods1.

        find first lonstat no-lock.
        create lonhar.
        assign lonhar.lon = s-lon
               lonhar.ln = 1
               lonhar.lonstat = lonstat.lonstat
               lonhar.fdt = date(1, 1, 1901)
               lonhar.cif = s-cif
               lonhar.akc = no
               lonhar.who = g-ofc
               lonhar.whn = g-today.

        find first lonhar where lonhar.lon = s-cif no-lock no-error.
        if not available lonhar then do:
            create lonhar.
            assign lonhar.lon = s-cif
                   lonhar.ln = 2
                   lonhar.fdt = date(1, 1, 1901)
                   lonhar.cif = s-cif
                   lonhar.akc = no
                   lonhar.finrez = 999999999999.99
                   lonhar.who = g-ofc
                   lonhar.whn = g-today.
        end.

        find first ln%his where ln%his.lon = s-lon no-lock no-error.
        if not avail ln%his then do:
            create ln%his.
            assign ln%his.stdat = g-today
                   ln%his.who = g-ofc
                   ln%his.whn = g-today
                   ln%his.lon = s-lon
                   ln%his.f0 = 1
                   ln%his.intrate = lon.prem
                   ln%his.opnamt = lon.opnamt
                   ln%his.rdt = g-today
                   ln%his.duedt = lon.duedt
                   ln%his.cif = s-cif
                   ln%his.lcnt = loncon.lcnt
                   ln%his.gua = lon.gua
                   ln%his.grp = lon.grp
                   ln%his.loncat = lon.loncat.
        end.

        create lonsec1.
        assign lonsec1.lon = s-lon
               lonsec1.ln = 1
               lonsec1.fdt = lon.rdt
               lonsec1.tdt = lon.duedt
               lonsec1.secamt = pkanketa.billsum
               lonsec1.crc = lon.crc
               lonsec1.prm = pkanketa.goal
               lonsec1.lonsec = 5.

        for each sub-dic where sub-dic.sub = "lon" no-lock.
            find first sub-cod where sub-cod.acc = s-lon and sub-cod.sub = "lon" and sub-cod.d-cod = sub-dic.d-cod use-index dcod  no-lock no-error .
            if not avail sub-cod then do:
                create sub-cod.
                sub-cod.acc = s-lon.
                sub-cod.sub = "lon".
                sub-cod.d-cod = sub-dic.d-cod .
                sub-cod.ccode = "msc" .
            end.
        end.

        find ofc where ofc.ofc = g-ofc no-lock no-error.

        {pk-sub-cod.i "'lon'" "'sproftcn'" s-lon ofc.titcd }
        {pk-sub-cod.i "'lon'" "'ecdivis'"  s-lon "'98'" }
        {pk-sub-cod.i "'lon'" "'secek'"    s-lon "'9'"  }
        {pk-sub-cod.i "'lon'" "'flagl'"    s-lon "'02'" }
        {pk-sub-cod.i "'lon'" "'lneko'"    s-lon "'92'" }
        {pk-sub-cod.i "'lon'" "'lngrp'"    s-lon "'90'" }
        {pk-sub-cod.i "'lon'" "'lnhld'"    s-lon "'15'" }
        /* {pk-sub-cod.i "'lon'" "'lnopf'"    s-lon "'30'" }*/
        {pk-sub-cod.i "'lon'" "'lonkb'"    s-lon "'01'"  }

        /* определение шифра в зависимости от валюты - тенге = 1, СКВ = 3, ДВВ = 5 */
        if pkanketa.crc = 1 then do:
            if pkanketa.srok <= 12 then v-shifr = "05".
                                   else v-shifr = "06".
        end.
        else do:
            find crchs where crchs.crc = pkanketa.crc no-lock no-error.
            if avail crchs and crchs.Hs = "H" then do:
                if pkanketa.srok <= 12 then v-shifr = "13".
                                       else v-shifr = "14".
            end.
            else v-shifr = "".
        end.

        {pk-sub-cod.i "'lon'" "'lnshifr'"  s-lon v-shifr }
        {pk-sub-cod.i "'lon'" "'lntgt'"    s-lon "'15'" }
        if s-credtype = '6' then {pk-sub-cod.i "'lon'" "'lnsegm'"    s-lon "'01'" }
        if s-credtype = '5' then {pk-sub-cod.i "'lon'" "'lnsegm'"    s-lon "'02'" }
        if s-credtype = '7' then {pk-sub-cod.i "'lon'" "'lnsegm'"    s-lon "'03'" }

        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 30   then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'01'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 90   then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'02'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 180  then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'03'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 360  then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'04'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 1080 then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'05'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 1800 then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'06'"} end.
        else
        if ABS ((round((lon.duedt - lon.rdt) * 12 / 365 , 0)) * 30) <= 3600 then do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'07'"} end.
        else do: {pk-sub-cod.i "'lon'" "'lnsrok'"   s-lon "'08'"} end.
    end. /* transaction */

    /**** Текущий счет ТЕНГОВЫЙ ****************/

    /* определение группы счета в ТЕНГЕ - из справочника допустимых валют pkankcrc */
    find first crc where crc.crc = 1 no-lock no-error.
    find first bookcod where bookcod.bookcod = "pkankcrc" and bookcod.code = crc.code no-lock no-error.

    s-lgr = trim(bookcod.info[1]).

    find first lgr where lgr.lgr eq s-lgr no-lock no-error.
    find first led where led.led eq lgr.led no-lock no-error.
    find first crc where crc.crc = lgr.crc no-lock no-error.

    
        /*20-тизначный счет*/
    run acc_gen(input lgr.gl, 1, s-cif, '', false, output s-aaa).
    
    do transaction:
        find first aaa where aaa.aaa eq s-aaa exclusive-lock.

        aaa.cif = s-cif.
        aaa.name = trim(cif.name).
        aaa.gl = lgr.gl.
        aaa.lgr = s-lgr.

        find sysc where sysc.sysc = "branch" no-error.
        if available sysc then aaa.bra = sysc.inval.

        aaa.regdt = g-today.
        aaa.stadt = g-today.
        aaa.stmdt = aaa.regdt - 1.
        aaa.tim = time .
        aaa.who = g-ofc.
        aaa.pass = lgr.type.
        aaa.pri = lgr.pri.
        aaa.rate = lgr.rate.
        aaa.complex = lgr.complex.
        aaa.base = lgr.base.
        aaa.sta = "N".
        aaa.minbal[1] = 9999999999999.99.
        aaa.crc = lgr.crc.
        aaa.base = lgr.base.
        aaa.grp = integer(lgr.alt).
        aaa.sec = false.
        find current aaa no-lock.
    end.

    /* период выписок */
    run stnacc(aaa.cif, s-aaa, 0).
       
/*    run acng(input lgr.gl, false, output s-aaa).  
    do transaction:
        find first aaa where aaa.aaa eq s-aaa exclusive-lock.

        aaa.cif = s-cif.
        aaa.name = trim(cif.name).
        aaa.gl = lgr.gl.
        aaa.lgr = s-lgr.

        find sysc where sysc.sysc = "branch" no-error.
        if available sysc then aaa.bra = sysc.inval.

        aaa.regdt = g-today.
        aaa.stadt = g-today.
        aaa.stmdt = aaa.regdt - 1.
        aaa.tim = time .
        aaa.who = g-ofc.
        aaa.pass = lgr.type.
        aaa.pri = lgr.pri.
        aaa.rate = lgr.rate.
        aaa.complex = lgr.complex.
        aaa.base = lgr.base.
        aaa.sta = "N".
        aaa.minbal[1] = 9999999999999.99.
        aaa.crc = lgr.crc.
        aaa.base = lgr.base.
        aaa.grp = integer(lgr.alt).
        aaa.sec = false.
        aaa.aaa20 = v-acc20.
        find current aaa no-lock.
    end.
    run stnacc(aaa.cif, s-aaa, 0).
  */  
    /* счет в ТЕНГЕ открыт */

    do transaction:
        find current pkanketa exclusive-lock.
        assign pkanketa.lon = s-lon
               pkanketa.aaa = s-aaa /* здесь всегда счет в тенге! */
               pkanketa.cif = s-cif.
        find current pkanketa no-lock.

        if lon.crc = 1 then lon.aaa = s-aaa.
        else do:
            /**** Текущий счет В ВАЛЮТЕ КРЕДИТА, если это не тенге ****************/
            /* определение группы счета в ВАЛЮТЕ - из справочника допустимых валют pkankcrc */
            find crc where crc.crc = pkanketa.crc no-lock no-error.
            find bookcod where bookcod.bookcod = "pkankcrc" and bookcod.code = crc.code no-lock no-error.

            s-lgr = trim(bookcod.info[1]).

            find lgr where lgr.lgr eq s-lgr no-lock no-error.
            find led where led.led eq lgr.led no-lock no-error.
            find crc where crc.crc = lgr.crc no-lock no-error.

            /*20-тизначный счет*/
            run acc_gen(input lgr.gl, lon.crc, s-cif, '', false, output s-aaa).
            
            find aaa where aaa.aaa eq s-aaa exclusive-lock.

            aaa.cif = s-cif.
            aaa.name = trim(cif.name).
            aaa.gl = lgr.gl.
            aaa.lgr = s-lgr.

            find sysc where sysc.sysc = "branch" no-error.
            if available sysc then aaa.bra = sysc.inval.

            aaa.regdt = g-today.
            aaa.stadt = g-today.
            aaa.stmdt = aaa.regdt - 1.
            aaa.tim = time .
            aaa.who = g-ofc.
            aaa.pass = lgr.type.
            aaa.pri = lgr.pri.
            aaa.rate = lgr.rate.
            aaa.complex = lgr.complex.
            aaa.base = lgr.base.
            aaa.sta = "N".
            aaa.minbal[1] = 9999999999999.99.
            aaa.crc = lgr.crc.
            aaa.base = lgr.base.
            aaa.grp = integer(lgr.alt).
            aaa.sec = false.
            find current aaa no-lock.

            /* период выписок */
            run stnacc(aaa.cif, s-aaa, 0).
            
/*            run acng(input lgr.gl, false, output s-aaa).
            find aaa where aaa.aaa eq s-aaa exclusive-lock.

            aaa.cif = s-cif.
            aaa.name = trim(cif.name).
            aaa.gl = lgr.gl.
            aaa.lgr = s-lgr.

            find sysc where sysc.sysc = "branch" no-error.
            if available sysc then aaa.bra = sysc.inval.

            aaa.regdt = g-today.
            aaa.stadt = g-today.
            aaa.stmdt = aaa.regdt - 1.
            aaa.tim = time .
            aaa.who = g-ofc.
            aaa.pass = lgr.type.
            aaa.pri = lgr.pri.
            aaa.rate = lgr.rate.
            aaa.complex = lgr.complex.
            aaa.base = lgr.base.
            aaa.sta = "N".
            aaa.minbal[1] = 9999999999999.99.
            aaa.crc = lgr.crc.
            aaa.base = lgr.base.
            aaa.grp = integer(lgr.alt).
            aaa.sec = false.
            aaa.aaa20 = v-acc20val.
            find current aaa no-lock.

            run stnacc(aaa.cif, s-aaa, 0).
        */
            /* открыт счет в валюте кредита - если не тенге */
            
            lon.aaa = s-aaa.
            find current pkanketa exclusive-lock.
            pkanketa.aaaval = s-aaa.
            find current pkanketa no-lock.
        end.
        /* станд и льготная - 5ая схема, ИП - 4ая, с 09.07.07 - 5ая для всех */
        lon.plan = get-pksysc-int ("pkplan").
    end. /* transaction */

    /* проставить исключения по тарифам */
    if pkanketa.crc = 1 then run pk-tarif-ex (pkanketa.aaa, pkanketa.cif, yes).
    else do:
        run pk-tarif-ex (pkanketa.aaa, pkanketa.cif, no).
        run pk-tarif-ex (pkanketa.aaaval, pkanketa.cif, yes).
    end.

    do transaction:
        find current pkanketa exclusive-lock.
        pkanketa.sts = "30".
        find current pkanketa no-lock.
    end. /* transaction */

    release lon.
end.  /* статус < 30 */

s-cif = pkanketa.cif.
s-lon = pkanketa.lon.

/* если прошла только первая проводка (sts=40) */
/* -  пропустить и идти на вторую (sts=50) */
if pkanketa.sts = "30" then do transaction:
    s-jh = 0.
    v_doc = "LON0052".

    /*strsum = pk-strsum (pkanketa.sumq). страховки пока нет */
    totsum = pkanketa.summa.
    comsum = 0. /* pkanketa.sumcom - комиссия теперь снимается при второй проводке */

    /* первая проводка делается со ссудного счета на счет в ВАЛЮТЕ КРЕДИТА */
    if pkanketa.crc = 1 then qaaa = pkanketa.aaa.
                        else qaaa = pkanketa.aaaval.

    /* выбор КНП выдачи в зависимости от срока кредита */
    knpln1 = entry(if pkanketa.srok <= 12 then 1 else 2, get-pksysc-char ("knplon")).
    knpln2 = string(get-pksysc-int ("knpcom")).

    find first pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "tarfnd" no-lock no-error.
    if not avail pksysc then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Не настроена переменная tarfnd в pksysc!").
        else message "Не настроена переменная tarfnd в pksysc!" view-as alert-box title "".
        return.
    end.

    find first tarif2 where tarif2.num  = string(pksysc.inval) and tarif2.kod  = trim(pksysc.chval) and tarif2.stat = 'r' no-lock no-error.
    if not avail tarif2 or (avail tarif2 and not (can-find (gl where gl.gl = tarif2.kont no-lock))) then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Не могу найти счет Г/К для снятия комиссии!").
        else message "Не могу найти счет Г/К для снятия комиссии!" view-as alert-box title "".
        return.
    end.

    /* -- при выдаче кредита картой - закидываем сумму номинала карты на транзитный счет ДПлК */
    v-sumdplk = 0.
    if pkanketa.rescha[3] <> '' then v-sumdplk = pkanketa.sumq.
    find first sysc where sysc.sysc = "CRDCMM" no-lock no-error.
    if avail sysc and num-entries(sysc.chval) > 1 then v-arpcard = entry(2,sysc.chval).
    else v-arpcard = "003904152".
    /* -- end */

    vparam = string (totsum) + vdel +
             string (pkanketa.lon) + vdel +
             string (qaaa) + vdel +
             "Выдача кредита ФЛ" + vdel +
             knpln1 + vdel +
             string (comsum) + vdel +
             string(tarif2.kont) /*'442900'*/ + vdel +
             knpln2 + vdel +
             string(v-sumdplk) + vdel +
             v-arpcard.

    run trxgen (v_doc, vdel, vparam, "", "", output rcode, output rdes, input-output s-jh).

    if rcode <> 0 then do: message rcode rdes. pause 100. return. end.

    if s-jh ne 0 then do:
        v-nxt = 0.
        for each lnscg where lnscg.lng eq pkanketa.lon and lnscg.f0 eq 0 and lnscg.flp gt 0 no-lock:
            v-nxt = lnscg.flp.
        end.

        create lnscg.

        lnscg.lng = pkanketa.lon.
        lnscg.f0 = 1.
        lnscg.paid = totsum.
        lnscg.stdat = g-today.
        lnscg.jh = s-jh.
        lnscg.whn = g-today.
        lnscg.who = g-ofc.
        lnscg.schn = "  1. .   " + string(lnscg.flp,"zzzz").
        lnscg.stval = totsum.
        lnscg.flp = 1.

        create lnscg.
        lnscg.lng = pkanketa.lon.
        lnscg.f0 = 1.
        lnscg.paid = totsum.
        lnscg.stdat = g-today.
        lnscg.schn = "  1. .   " + string(lnscg.flp,"zzzz").
        lnscg.stval = totsum.

        run lonresadd(s-jh).

        def var v-n as int.
        def var v-prtorder as logical init "yes" format "да/нет".
        if v-inet then v-n = 0.
        else do:
            message " Печатать ОПЕРАЦИОННЫЙ ордер? " update v-prtorder.
            if v-prtorder then v-n = 1.
            else v-n = 0.
        end.

        do i = 1 to get-pksysc-int ("kolord"):
            run vou_bank(v-n). pause 0.
        end.

        if v-inet then do:
            v-file = "/var/www/html/docs/" + s-credtype + "/" + string(s-pkankln) + "/oporderp.htm".
            unix silent value("echo '<!-- Ордера (перевод, комиссия, касса) -->' > " + v-file + ";echo '<pre>' >> " + v-file + ";cat vou.img >> " + v-file + ";echo '</pre>' >> " + v-file).
            unix silent value("chmod 666 " + v-file).
        end.

        /* если требуется дополнительный контроль - ставим заморозку, статус 35 и ждем контроля */
        find pksysc where pksysc.credtype = s-credtype and pksysc.sysc = "conjh1" no-lock no-error.
        if avail pksysc and pksysc.loval then do:
            run jou-aasnew (qaaa, totsum, s-jh).
            v-sts = "35".
        end.
        else do:
            /* если не требуется контроль - штампуем и ставим статус 40 */
            run chgsts("lon", s-jh, "lon").
            run jl-stmp.
            v-sts = "40".
        end.

        /* запишем номер проводки */
        find current pkanketa exclusive-lock.
        pkanketa.trx1 = s-jh.
        pkanketa.sts = v-sts.
        find current pkanketa no-lock.
    end. /* s-jh <> 0 */
end. /* do transaction */

run pk-trx.

if pkanketa.sts = "50" then run pklongrf(yes).

/* запрос на способ погашения кредита - автоматически при закрытии дня или вручную менеджером */
/* run pklonlcr. */

do transaction on error undo, retry:
    find lon where lon.lon = pkanketa.lon exclusive-lock no-error.
    if lon.lcr = "" then lon.lcr = "M".
    if not v-inet then displ lon.lcr with frame pkank.
    release lon.
end.

/* рефинансирование */
rdes = ''.
find first pkanketh where pkanketh.bank = s-ourbank and pkanketh.credtype = s-credtype and pkanketh.ln = s-pkankln and pkanketh.kritcod = "rnn" no-lock no-error.
if avail pkanketh and pkanketh.rescha[1] <> "" and pkanketh.resdec[1] > 0 then do:
    v-resref = 0.
    run pk-reftrx(output rdes).
    if trim(rdes) <> '' then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Произошла ошибка.~n " + rdes).
        else message " Произошла ошибка.~n " + rdes view-as alert-box error.
    end.
    if trim(rdes) = '' and v-resref = 0 then do:
        if v-inet then run fmsg-w(pkanketa.bank,pkanketa.credtype,pkanketa.ln,"Операции по рефинансированию произведены успешно").
        message " Операции по рефинансированию произведены успешно " view-as alert-box error.
    end.
end.

do transaction:
run value ("pkaftertrx-" + s-credtype).
end.