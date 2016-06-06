/* cs_data2.p
 * MODULE
        экспресс кредиты по ПК
 * DESCRIPTION
        Формирование кредитного скоринга
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
        08/11/2013 Luiza ТЗ 1932
 * BASES
        BANK COMM
 * CHANGES
            13/11/2013 Luiza ТЗ 2197 рефинансирование по нескольким кредитам
*/

{global.i}

def var s-credtype as char.

def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-bank     as char no-undo.

def var v-maillist  as char.
def var v-zag       as char.
def var v-str       as char.
def var v-echild as int init 0.
def var v-echildl as int init 0.
def var v-echildn as int init 0.
def var v-maxsumkr as deci init 0.
def var v-sumforte as deci init 0.
def var v-date as date.
def var prkred as deci init 0.
def var prmaxpl as deci init 0.
def var prball as char init "".
def var v-dpkvzp123 as char.
def var v-sum1 as deci init 0.
def var v-ball234 as char.
def var v-pr as logic.
def var v-pr0 as logic. /* нулевой суммы в отчете ПКБ */
def var vamt as decim.
def var v-cifcompany as char init ''.

def var v-ofc as char.
def var v-mid as char.
find first codfr where codfr.codfr = 'clmail' and codfr.code = 'oomail' no-lock no-error.
if not avail codfr then do:
    message 'Не найден список менеджеров ОО. Обратитесь в ДИТ' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-ofc = codfr.name[1].
find first codfr where codfr.codfr = 'clmail' and codfr.code = 'conmail' no-lock no-error.
if not avail codfr then do:
    message 'Не найден список контролеров. Обратитесь в ДИТ.' view-as alert-box button Ok title "Внимание!".
    return.
end.
v-mid = codfr.name[1].

def buffer b-xml_det for xml_det.

def var i as int.
find first codfr where codfr.codfr = 'clmail' and codfr.code = 'conmail' no-lock no-error.
if not avail codfr then do:
    message 'Нет справочника адресов рассылки для контролера' view-as alert-box.
    return.
end.
else do:
    i = 1.
    do i = 1 to num-entries(codfr.name[1],','):
        v-maillist = v-maillist + entry(i,codfr.name[1],',') + '@fortebank.com,'.
    end.
end.

def var v-companyName as char init '' no-undo.
def buffer b-cif for cif.
def var v-credlim as deci init 0 no-undo.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = "10" and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln use-index bankcif no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box  buttons ok.
   return.
end.
if pkanketa.sts = '111' then do:
    message ' Действия по анкете запрещены, по причине - отказ клиента от Экспресс-кредита ' view-as alert-box.
    return.
end.
def new shared var vv-iin as char init '' no-undo.
vv-iin = pkanketa.rnn.
def var fcb_id as int  no-undo.
def var xml_id as int  no-undo.
if pkanketa.goal = 'Рефинансирование' and pkanketa.rescha[4] = "" then do:
   message "Не заполнены данные по рефинансированию!" view-as alert-box  buttons ok.
   return.
end.


/* v-metam  метод погашения(аннуитет или диффер платеж)*/
def var v-metam as char.
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
        and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "emetam" no-lock no-error.
if available pkanketh  then v-metam  = pkanketh.value1.
else do:
   message "Не найден метод погашения" view-as alert-box  buttons ok.
   return.
end.

/*v-sroktr Запраш.срок кред.мес*/
    def var v-sroktr as int.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "esroktr" no-lock no-error.
    if available pkanketh  then v-sroktr  = int(pkanketh.value1).
    else do:
       message "Не найден Запрашиваемый срок кред. (мес)" view-as alert-box  buttons ok.
       return.
    end.
   /*v-gstav  Годовая ставка возн.*/
    def var v-gstav as decim.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "eratrew" no-lock no-error.
    if available pkanketh  then v-gstav  = decim(pkanketh.value1).
    else do:
       message "Не найдена Годовая ставка возн" view-as alert-box  buttons ok.
       return.
    end.
   /*v-sumtr  Запраш.сумма кредита*/
    def var v-sumtr as decim.
    find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "esumtr" no-lock no-error.
    if available pkanketh  then v-sumtr  = decim(pkanketh.value1).
    else do:
       message "Не найдена Запрашиваемая сумма кредита " view-as alert-box  buttons ok.
       return.
    end.


find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
        and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fcbid234" no-lock no-error.
if not available pkanketh or pkanketh.value1 = "" then do:
   message "Запрос в 1КБ не был отправлен!" view-as alert-box  buttons ok.
   return.
end.
fcb_id = int(trim(pkanketh.value1)).
find first fcb where fcb.fcb_id = fcb_id no-lock no-error.
if not available fcb then do:
   message "Отчет ПКБ не найден!" view-as alert-box  buttons ok.
   return.
end.
xml_id = fcb.xml_id.
find first xml_det where xml_det.xml_id = xml_id  no-lock no-error.
if not avail xml_det then do:
    message "Отчет ПКБ не найден, повторите запрос в ПКБ!" view-as alert-box title 'ВНИМАНИЕ'.
    return.
end.

def var v-ExpSave as char init "".
find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
    and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
if available pkanketh then v-ExpSave = pkanketh.value1.

def temp-table t-files
  field name as char format "x(70)"
  field fname as char.

def temp-table cbb no-undo
    field sub     as char
    field pr      as char
    field kod     as char
    field crc     as int
    field rate    as decim
    field sum     as decim
    field sumv    as decim
    field cntpr   as int /* дней просрочек*/
    field cntday  as int /* кол-во раз просрочек*/
    field prol    as int
    field name1    as char
    field codcontr as char. /* код контракта*/

/* кредиты */
def var v-count as int init 0.
def var vstart as int extent 50.
def var vend as int extent 50.
def var ij as int.
def var v-cbbkod as char.
def var v-cbbsum as decim.
def var v-repl as char.
def var v-repl1 as char.
def var v-val as char.
def var v-fin as char init "".
def var cntprol as int init 0.
def var pcnt as int init 0.
def var pcntday as int init 0.
def var ii as int init 0.
def var v-cifexpdt as date.

/* проверка даты обновления отчета*/
v-pr = no.
find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract LastUpdate value" no-lock no-error.
if avail xml_det then do:
    v-date = date(trim(xml_det.val)).
    for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract LastUpdate value" no-lock:
       if v-date > date(trim(xml_det.val)) then v-date = date(trim(xml_det.val)).
    end.
    find first xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Footer DateOfIssue value" no-lock no-error.
    if date(trim(xml_det.val)) - v-date > 30 then v-pr = yes.
end.
/*-----------------------------------------------------------------------*/

for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract ContractTypeCode*" no-lock.
   v-count = v-count + 1.
   if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
   vstart[v-count] = xml_det.line.
end.
v-pr0 = no.
if v-count > 0 then do:
    find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
    vend[v-count] = xml_det.line.
    do ij = 1 to v-count:
        /* Вид финансирования */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract TypeOfFounding value" no-lock no-error.
        if not available xml_det then v-pr0 = yes.
        else v-fin = trim(xml_det.val).

        /* дата окончания */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract DateOfCreditEnd value" no-lock no-error.
        if not available xml_det or trim(xml_det.val) = "" then v-pr0 = yes.

        /* общая сумма */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract TotalAmount value" no-lock no-error.
        if not available xml_det then v-pr0 = yes.
        else do:
            vamt = 0.
            v-repl = "".
            v-repl = replace(trim(xml_det.val),' ','').
            if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
            vamt = decim(v-repl) no-error.
            if trim(xml_det.val) = "" or vamt <= 0 then v-pr0 = yes.
        end.

        /* сумма предст платежа */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract MonthlyInstalmentAmount value" no-lock no-error.
        if not available xml_det then v-pr0 = yes.
        else do:
            vamt = 0.
            v-repl = "".
            v-repl = replace(trim(xml_det.val),' ','').
            if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
            vamt = decim(v-repl) no-error.
            if (trim(xml_det.val) = "" or vamt <= 0) and v-fin <> "Кредитная карта" then v-pr0 = yes.
        end.
        /*find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract MonthlyInstalmentAmount value" no-lock no-error.
        if not available xml_det then v-pr0 = yes.
        else do:
            vamt = 0.
            v-repl = "".
            v-repl = replace(trim(xml_det.val),' ','').
            if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
            vamt = decim(v-repl) no-error.
            if v-fin = "Кредитная карта" and vamt <= 0 then do:
                 общая сумма
                find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract TotalAmount value" no-lock no-error.
                if not available xml_det then v-pr0 = yes.
                else do:
                    vamt = 0.
                    v-repl = "".
                    v-repl = replace(trim(xml_det.val),' ','').
                    if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
                    vamt = decim(v-repl) no-error.
                    if trim(xml_det.val) = "" or vamt <= 0 then v-pr0 = yes.
                end.
            end.
            if trim(xml_det.val) = "" or vamt <= 0 then v-pr0 = yes.
        end.*/

        /* источник информ */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract FinancialInstitution value" no-lock no-error.
        if not available xml_det or trim(xml_det.val) = "" then v-pr0 = yes.

        /* Номер договора  */
        find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract AgreementNumber value" no-lock no-error.
        if available xml_det then do:
            create cbb.
            cbb.kod = trim(xml_det.val).
            /* Код контракта */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract CodeOfContract value" no-lock no-error.
            if available xml_det then cbb.codcontr = trim(xml_det.val).
            /* Источник информации (Кредитор) */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract FinancialInstitution value" no-lock no-error.
            if available xml_det then cbb.name1 = trim(xml_det.val).
            /* роль субъекта */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract SubjectRole value" no-lock no-error.
            if available xml_det then cbb.sub = trim(xml_det.val).
            /* Сумма предстоящего платежа  */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract MonthlyInstalmentAmount value" no-lock no-error.
            if available xml_det and trim(xml_det.val) <> "" then do:
                v-repl = replace(trim(xml_det.val),' ','').
                v-val = "".
                if length(trim(v-repl)) >= 3 then v-val  = substring(trim(v-repl),length(trim(v-repl)) - 2,3).
                if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
                find first crc where crc.code = v-val no-lock no-error.
                if not available crc then do:
                    message "В отчете 1КБ неизвестная валюта " + v-val  + " продолжение невозможно!" view-as alert-box.
                    return.
                end.
                cbb.crc = crc.crc.
                cbb.crc = crc.rate[1].
                v-repl = replace(v-repl,v-val,'').
                v-repl = replace(v-repl,',','.').
                cbb.sumv = decim(v-repl) no-error.
                cbb.sum  = decim(v-repl) * crc.rate[1] no-error.
                /* если вид финансирования  'Кредитная карта' и сумма предстоящего платежа  нулевая,
                   расчет суммы = сумма кредитного лимита*10% ---------------------------------- */
                if decim(v-repl) = 0 and v-fin = "Кредитная карта" then do:
                    find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract TotalAmount value" no-lock no-error.
                    if available xml_det and trim(v-repl) <> "" and decim(v-repl) > 0 then do:
                        v-val = "".
                        if length(trim(v-repl)) >= 3 then v-val  = substring(trim(v-repl),length(trim(v-repl)) - 2,3).
                        if length(trim(v-repl)) >= 3 then v-repl = substring(trim(v-repl),1,length(trim(v-repl)) - 3).
                        find first crc where crc.code = v-val no-lock no-error.
                        if not available crc then do:
                            message "В отчете 1КБ неизвестная валюта " + v-val  + " продолжение невозможно!" view-as alert-box.
                            return.
                        end.
                        cbb.crc = crc.crc.
                        cbb.crc = crc.rate[1].
                        v-repl = replace(v-repl,v-val,'').
                        v-repl = replace(v-repl,',','.').

                        cbb.sumv = decim(v-repl) * 0.1 no-error.
                        cbb.sum  = decim(v-repl) * crc.rate[1] * 0.1 no-error.
                    end.
                end.
               /*-------------------------------------------------------------------------------*/
            end. /* if available xml_det then do:*/
             /*  кол дней просрочек */
            pcnt = 0.
            for each xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*PaymentsCalendar Payment value":
               pcnt = pcnt + 1.
            end.
            pcnt = pcnt - 12. /* только за последние 12 месяцев */
            cntprol = pcnt. /* запомним сколько записей пропустить */

            pcnt = 0.
            for each xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*PaymentsCalendar Payment value":
               pcnt = pcnt + 1.
               if pcnt > cntprol then do: /* кол дней просрочек только за последние 12 месяцев */
                   ii = 0.
                   ii = int(trim(xml_det.val)) no-error.
                   if cbb.cntpr < ii then cbb.cntpr = ii.
                   if ii > 0 then cbb.cntday = cbb.cntday + 1.
               end.
            end.
            /* количество пролонгаций */
            cntprol = 0.
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract ProlongationCount value".
            if avail xml_det then cntprol = int(trim(xml_det.val)) no-error.
            cbb.prol = cntprol.
        end.
    end. /* do ij = 1 to v-count: */
end. /* if v-count > 0 then do: */
define buffer b-cbb for cbb.
/* исключим одинаковые записи по договорам */
for each cbb.
    ii = 0.
    for each b-cbb where b-cbb.kod = cbb.kod.
        ii = ii + 1.
    end.
    if ii > 1 then do:
        for each b-cbb where b-cbb.kod = cbb.kod.
            if b-cbb.sub <> "Заёмщик" and b-cbb.sub <> "Заемщик" then b-cbb.pr = "iskl".
        end.
    end.
end.
for each cbb where cbb.pr = "iskl".
    delete cbb.
end.

/*если рефинансирование выставим признак */
if pkanketa.goal = 'Рефинансирование' then do:
    ii = num-entries(pkanketa.rescha[4]).
    do while ii >= 1:
        find first cbb where cbb.kod = entry(ii,pkanketa.rescha[4]) no-error.
        if available cbb then do:
            cbb.pr = "ref".
            ii = ii - 1.
        end.
    end.
end.
/* выбираем кредиты в АБС ------------------------------------*/
def var v-path as char.
def new shared temp-table wrk3 no-undo
   field dt as date
   field od as deci
   field prc as deci
   field koms as deci
   field crc as int
   field codcontr as char /* код контракта*/
   field bank as char /* код банка*/
   index idx is primary codcontr.

    {r-branch2.i &proc = "ExpCred_txb"}
/*------------------------------------------------------------------*/
for each wrk3 no-lock:
    find first cbb where cbb.name1 matches "*ForteBank*" and substring(trim(cbb.codcontr),length(trim(cbb.codcontr)) - 8,9) = wrk3.codcontr no-lock no-error.
    find first crc where crc.crc = wrk3.crc no-lock no-error.
    if not available cbb and available crc then v-sumforte = v-sumforte + ((wrk3.od + wrk3.prc + wrk3.koms) * crc.rate[1]).
end.
/*------------------------------------------------------------*/
def new shared temp-table wrk2 no-undo
   field lon as char
   field days as int
   field counts as int
   index idx is primary days.

def temp-table temp_cs_data no-undo like pkanketh
    field dttype    as char
    field kritdispl as char
    field kritname  as char
    field kritspr   as char
    field sort1     as int
    index idx is primary sort1 .

def temp-table sort1 no-undo
    field nn as int
    field fl as char.

    create sort1.
    sort1.nn = 1.
    sort1.fl = "FIO123". /*  Фио */

    create sort1.
    sort1.nn = 2.
    sort1.fl = "IIN123". /* иин  */

    create sort1.
    sort1.nn = 3.
    sort1.fl = "regionin123". /* регион обращения  */

    create sort1.
    sort1.nn = 4.
    sort1.fl = "companyyear123". /* сколько лет компания на рынке  */

    create sort1.
    sort1.nn = 5.
    sort1.fl = "experl". /* стаж на посл месте работы  */

    create sort1.
    sort1.nn = 6.
    sort1.fl = "age234". /* возраст  */

    create sort1.
    sort1.nn = 7.
    sort1.fl = "educat". /* образование  */

     create sort1.
    sort1.nn = 8.
    sort1.fl = "emarsts". /* сем положение  */

    create sort1.
    sort1.nn = 9.
    sort1.fl = "ememnum". /*  кол-во членов семьи */

    create sort1.
    sort1.nn = 10.
    sort1.fl = "espwork". /* супруг работает  */

    create sort1.
    sort1.nn = 11.
    sort1.fl = "echildn". /* кол  детей  */
    create sort1.
    sort1.nn = 12.
    sort1.fl = "echildl". /* кол  детей несоверш */

    create sort1.
    sort1.nn = 13.
    sort1.fl = "credhist123". /* кредит история  */

    create sort1.
    sort1.nn = 14.
    sort1.fl = "prol234". /* кол пролонгаций  */

    create sort1.
    sort1.nn = 15.
    sort1.fl = "zp123". /* зп  */

    create sort1.
    sort1.nn = 16.
    sort1.fl = "esumtr". /* запраш сумма кредита  */

    create sort1.
    sort1.nn = 17.
    sort1.fl = "esroktr". /* запраш срок кредита  */

    create sort1.
    sort1.nn = 18.
    sort1.fl = "plattekob123". /* платеж по обязат-в  */

    create sort1.
    sort1.nn = 19.
    sort1.fl = "maxpl234". /* макс платеж по кредиту запрашив условия  */

    create sort1.
    sort1.nn = 20.
    sort1.fl = "dpkvzp123". /* доля платежа в зп  */

    create sort1.
    sort1.nn = 21.
    sort1.fl = "ball234". /* оценка платежеспособности  */

    create sort1.
    sort1.nn = 22.
    sort1.fl = "maxsumkr". /*  макс сумма кредита исходя из доходов */

    create sort1.
    sort1.nn = 23.
    sort1.fl = "maxplkr". /* макс платеж по кредиту  исходя из доходов */

    create sort1.
    sort1.nn = 24.
    sort1.fl = "dol234". /* оценка платежеспособности исходя из доходов  */

    create sort1.
    sort1.nn = 25.
    sort1.fl = "itog123". /*   */

def var v-select as int init 0 no-undo.

/***********процедуры********************************************/
function validVal returns logical (input v-val as char, input v-type as char).
    def var v-res as logi init yes.
    def var i as int.
    if v-type = "Целое число" then do:
       int(v-val) no-error.
       if error-status:error then v-res = no.
       do i = 1 to length(v-val) :
          if lookup(substr(v-val,i,1),'0,1,2,3,4,5,6,7,8,9,-') = 0 then v-res = no.
       end.
    end.
    if v-type = "Вещественное число" then do:
       deci(v-val) no-error.
       if error-status:error then v-res = no.
    end.
    if v-type = "Логический" then do:
       if v-val <> "да" and v-val <> "нет" then  v-res = no.
    end.

    return v-res.
end function.

function validF2 returns logical .
   def var v-res as logi init no.
   if trim(temp_cs_data.kritspr) = "" then v-res = yes. else do:
      if v-select = 0 then v-res = no. else v-res = yes.
   end.
   return v-res.
   /*displ temp_cs_data.kritspr v-select v-res. pause.*/
end function.

function maxpl returns char (input v-txt as char, input v-srkr as int, input v-gst as decim, input v-str as decim).
    /* v-txt  метод погашения(аннуитет или диффер платеж)
       v-srkr Запраш.срок кред.мес
       v-gst  Годовая ставка возн.
       v-str  Запраш.сумма кредита
    */
    def var res as char.
    if v-txt = "Аннуитет" then do:
        res = string(round((v-str * (v-gst / 100 / 12)) / (1 - exp((1 + (v-gst / 100 / 12)),v-srkr * (-1))),0)).
    end.
    else res = string(round((v-str / v-srkr) + (v-str * v-gst / 100 / 360 * 30),0)).
    return res.
end function.

/***********процедуры********************************************/

def button btnSave   label "Сохранить" .
def button btnAccept label "Подтвердить" .
def button btnPrint  label "Печать".
def button btnLogot  label "Логотип".
def button btnExit   label "Выход".

def QUERY q_cs_data  FOR temp_cs_data .
def browse b_cs_data query q_cs_data displ
        temp_cs_data.kritname     format "x(45)"  label 'Критерий'
        temp_cs_data.kritdispl  format "x(40)"  label 'Справочник'
        temp_cs_data.rating  format ">9-"  label 'Балл'
        with 25 down SEPARATORS title "Кредитный скоринг экспресс кредита" overlay.
def frame fMain b_cs_data skip btnSave btnAccept btnPrint btnLogot btnExit  with centered overlay row 3 width 100 top-only.

on "END-ERROR" of frame fMain do:
   return NO-APPLY .
end.

def frame fProp
        temp_cs_data.kritname    format "x(50)"  label '  Критерий' skip
        temp_cs_data.kritdispl   format "x(40)" validate(validF2() ,'Выберите значение через F2') label        'Справочник' skip
        temp_cs_data.rating format ">9-" label        '      Балл' skip
        with side-labels centered row 8.

def temp-table temp_cs_catalog like codfr .
def QUERY q_cs_catalog  FOR temp_cs_catalog.
def browse b_cs_catalog query q_cs_catalog displ
        temp_cs_catalog.name[1]   format "x(50)"  label 'Значение'
        temp_cs_catalog.name[5]  format "x(3)"  label 'Балл'
        with 20 down SEPARATORS title "Справочник" overlay.
def frame fCatalog b_cs_catalog   with centered overlay row 3 width 85 top-only.

on help of temp_cs_data.kritdispl in frame fProp do:
    find first codfr where codfr.codfr = temp_cs_data.kritspr no-lock no-error.
    if avail codfr and trim(temp_cs_data.kritspr) <> "" then do:
        empty temp-table temp_cs_catalog.
        for each codfr where codfr.codfr = temp_cs_data.kritspr no-lock.
          create temp_cs_catalog.
          buffer-copy codfr to temp_cs_catalog.
        end.
        OPEN QUERY q_cs_catalog FOR EACH temp_cs_catalog.
        enable all with frame fCatalog.
        WAIT-FOR RETURN OF frame fCatalog FOCUS b_cs_catalog IN FRAME fCatalog.
        hide frame fCatalog.
        temp_cs_data.kritdispl = temp_cs_catalog.name[1].
        temp_cs_data.value1 = temp_cs_catalog.code.
        temp_cs_data.rating = int(temp_cs_catalog.name[5]).
        displ temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.
        if trim(temp_cs_data.value1) <> "" then v-select = 1.
    end. else message "У критерия нет справочника! Введите значение" view-as alert-box  buttons ok.
end.


on "ENTER" of b_cs_data IN FRAME fMain do:
   v-select = 0.
   run procEdt.
end.

ON CHOOSE OF btnSave IN FRAME fMain do:
   if can-do (v-ofc,g-ofc) then do:
       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
       if avail pkanketh and lookup(trim(pkanketh.value1),"100,110,120") > 0 then do:
          message "Данные уже сохранены!" view-as alert-box  buttons ok.
          return.
       end.
       else  run procSave.
   end.
   else message " Нет доступа к кнопке <СОХРАНИТЬ>! " view-as alert-box.
end.
ON CHOOSE OF btnAccept IN FRAME fMain do:
   if can-do (v-mid,g-ofc) then run procAccept.
   else message " Нет доступа к кнопке <ПОДТВЕРДИТЬ>! " view-as alert-box.
end.
ON CHOOSE OF btnPrint IN FRAME fMain do:
   run procPrint.
end.
ON CHOOSE OF btnLogot IN FRAME fMain do:
   run procLogot.
end.
ON CHOOSE OF btnExit IN FRAME fMain do:
   return.
end.

run procLoadData.
if lookup(trim(v-ExpSave),"100,110,120") <= 0  then do: /* значит данные еще не сохранены */
    run procImportData.
    run procCalcField.
    run procCalcScore.
end.
else do:
   find first cif where cif.cif = pkanketa.cif no-lock no-error.
   if avail cif then do:
      find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod no-lock no-error.
      if avail pcstaff0 then assign v-cifcompany = pcstaff0.cifb .

      if v-cifcompany begins "txb" then v-companyName = "AO 'ForteBank'".
      else do:
          find first b-cif where b-cif.cif = v-cifcompany no-lock no-error.
          if avail b-cif then do:
             v-companyName = b-cif.prefix + " " + b-cif.name.
          end.
      end.
   end.
   v-echild = v-echildn - v-echildl.
end.

OPEN QUERY q_cs_data FOR EACH temp_cs_data.
enable all with frame fMain.
WAIT-FOR CHOOSE OF btnExit.

/***********процедуры********************************************/
    procedure Refresh:
       run procCalcField.
       run procCalcScore.
       browse b_cs_data:refresh().
    end.

    procedure procEdt:
       displ temp_cs_data.kritname with frame fProp.
       /*update  temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.*/
       displ  temp_cs_data.kritdispl temp_cs_data.rating with frame fProp.
       hide frame fProp.
       run Refresh.
    end procedure.

    procedure procSave:
       if lookup(trim(v-ExpSave),"100,110,120") > 0  then do: /* значит данные уже сохранены */
           message "Данные уже сохранены!" view-as alert-box  buttons ok.
           return.
       end.
       find current pkanketa no-lock no-error.
       if v-maxsumkr < 70000 then message "Максимальная сумма кредита (исходя из доходов) не соответствует утвержденным условиям!" view-as alert-box.
       find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10" and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
       if avail pkanketh and pkanketh.value1 = "90" then do:
           message "Документ на контроле!" view-as alert-box  buttons ok.
           return.
       end.
       /* сохраним признак отправки на контроль */
       if not avail pkanketh then do:
           create pkanketh.
           pkanketh.bank = pkanketa.bank.
           pkanketh.cif = pkanketa.cif.
           pkanketh.credtype = '10'.
           pkanketh.ln = pkanketa.ln.
           pkanketh.kritcod = "SaveExp".
           pkanketh.value1 = "90".
       end.
       if avail pkanketh and (pkanketh.value1 = "90" or pkanketh.value1 = "01") then do:

           if pkanketh.value1 = "01" then do:
               find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
                    and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" exclusive-lock no-error.
               assign pkanketh.value1 = "90" pkanketh.value2 = "".
               find current pkanketh no-lock no-error.
           end.

           /* если дата отчета ПКБ > 30 дней или в отчете некоррекные данные по дате оконч, общ сумме, сумме предстоящ платжа или источника информ, то на кред комитет */
           if v-pr  or v-pr0 then do:
                if v-pr0 then do:
                    message "Необходимо рассмотреть вопрос на Кредитном Комитете, дополнительно запросив от клиента справку о наличии обязательств в банке-кредиторе!" view-as alert-box.
                    v-zag = "Бизнес-процесс: Экспресс кредит".
                    v-str = "Здравствуйте! Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента' - проверка заявки и скоринга.~n Клиент: "
                         + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                         + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                         + ', ' + string(time,'hh:mm:ss') + ". ~nБизнес-процесс: Экспресс кредит. Необходимо рассмотреть вопрос на Кредитном Комитете, ~n дополнительно запросив от клиента справку о наличии обязательств в банке-кредиторе!" .
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    /* для менеджера */
                    run mail(g-ofc + "@fortebank.com","FORTEBANK <abpk@fortebank.com>", v-zag,"Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента' .~n Клиент: "
                         + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                         + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                         + ', ' + string(time,'hh:mm:ss') + ". ~nБизнес-процесс: Экспресс кредит. Необходимо рассмотреть вопрос на Кредитном Комитете, ~n дополнительно запросив от клиента справку о наличии обязательств в банке-кредиторе!", "", "","").

                end.
                else do:
                    message "Необходимо рассмотреть вопрос на Кредитном Комитете, дата последнего обновления отчета КБ не соответствует заданному параметру!" view-as alert-box.
                    v-zag = "Бизнес-процесс: Экспресс кредит".
                    v-str = "Здравствуйте! Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента' - проверка заявки и скоринга.~n Клиент: "
                         + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                         + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                         + ', ' + string(time,'hh:mm:ss') + ". ~nБизнес-процесс: Экспресс кредит. Необходимо рассмотреть вопрос на Кредитном Комитете,
                         дата последнего обновления отчета КБ не соответствует заданному параметру!" .
                    run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
                    /* для менеджера */
                    run mail(g-ofc + "@fortebank.com","FORTEBANK <abpk@fortebank.com>", v-zag,"Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента' .~n Клиент: "
                         + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                         + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                         + ', ' + string(time,'hh:mm:ss') + ". ~nБизнес-процесс: Экспресс кредит. Необходимо рассмотреть вопрос на Кредитном Комитете,
                         дата последнего обновления отчета КБ не соответствует заданному параметру!", "", "","").
                end.
           end.
           v-zag = "Бизнес-процесс: Экспресс кредит".
           v-str = "Здравствуйте! Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента' - проверка заявки и скоринга.~n Клиент: "
                 + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                 + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                 + ', ' + string(time,'hh:mm:ss') + ". ~nБизнес-процесс: Экспресс кредит".
           run mail(v-maillist,"FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
           run savelog('cs_data2', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + "Экспресс кредиты Данные на контроле" + g-ofc).
           message "Отправлено уведомление контролеру!" view-as alert-box  buttons ok.
       end.
    end procedure.

    procedure procAccept:
     def var v-reas as char.
     form
     v-reas no-label format "x(98)"
     with frame detpay column 6 row 35 overlay width 100 title "Причина отказа" .
     on END-ERROR of frame detpay do:
       hide frame detpay no-pause.
     end.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10" and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
        if avail pkanketh and pkanketh.value1 = "90" then do:
            if v-maxsumkr < 70000 then message "Максимальная сумма кредита (исходя из доходов) не соответствует утвержденным условиям!" view-as alert-box.
            MESSAGE "Подтердить?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO UPDATE b AS LOGICAL.
            if b then do:
               for each temp_cs_data:
                   find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = temp_cs_data.kritcod exclusive-lock no-error.
                   if not avail pkanketh then do:
                       create pkanketh.
                       buffer-copy temp_cs_data to pkanketh.
                   end.
                    pkanketh.rescha[1] = temp_cs_data.kritdispl.
                    pkanketh.resdec[1] = temp_cs_data.rating.
               end.
              find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10" and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" exclusive-lock no-error.
              find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = "10" and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln use-index bankcif exclusive-lock no-error.
               find first temp_cs_data where temp_cs_data.kritcod = "itog123" no-error.
               v-pr = no.
               if  avail pkanketa and avail temp_cs_data then do:
                   if temp_cs_data.rating = -1 then assign pkanketa.sts = "100" pkanketa.rating = -1 .
                   if temp_cs_data.rating = 0  then do: /*  проверка даты последнего обновления Отчета КБ */
                   /* если дата отчета ПКБ > 30 дней или в отчете некоррекные данные по дате оконч, общ сумме, сумме предстоящ платжа или источника информ, то на кред комитет */
                       if v-pr  or v-pr0 then do:
                           if v-pr then assign pkanketa.sts = "110"  pkanketa.rating = temp_cs_data.rating. /* если дата отчета ПКБ > 30 дней, то на кред комитет */
                           if v-pr0 then assign pkanketa.sts = "110"  pkanketa.rating = 4. /* в отчете некоррекные данные по дате оконч, общ сумме, сумме предстоящ платжа или источника информ, то на кред комитет */
                       end.
                       else assign pkanketa.sts = "120"  pkanketa.rating = temp_cs_data.rating.
                   end.
                   if temp_cs_data.rating > 0  then pkanketa.sts = "110".
                   pkanketa.rating = temp_cs_data.rating.
                   pkanketa.summax = round(v-maxsumkr,0).
                   pkanketa.summa  = if pkanketa.sumq <= pkanketa.summax then pkanketa.sumq else pkanketa.summax.
                   pkanketa.cdt    = g-today.
                   pkanketa.cwho   = g-ofc.
                   find current pkanketa no-lock no-error.
              end.

              find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10" and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" exclusive-lock no-error.
              find first pkanketa where pkanketa.bank = v-bank and pkanketa.credtype = "10" and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln use-index bankcif exclusive-lock no-error.
               if temp_cs_data.rating = -1 then assign pkanketh.value1 = "100" pkanketa.sts = "100" pkanketa.rating = -1 .
               if temp_cs_data.rating = 0  then do:
                   /* если дата отчета ПКБ > 30 дней или в отчете некоррекные данные по дате оконч, общ сумме, сумме предстоящ платжа или источника информ, то на кред комитет */
                   if v-pr  or v-pr0 then do:
                       if v-pr then assign pkanketh.value1 = "110" pkanketa.sts = "110" pkanketa.rating = temp_cs_data.rating .
                       if v-pr0 then assign pkanketa.sts = "110"  pkanketa.rating = 4. /* в отчете некоррекные данные по дате оконч, общ сумме, сумме предстоящ платжа или источника информ, то на кред комитет */
                   end.
                   else assign pkanketh.value1 = "120" pkanketa.sts = "120" pkanketa.rating = temp_cs_data.rating.
               end.
               if temp_cs_data.rating > 0  then assign pkanketh.value1 = "110" pkanketa.sts = "110" pkanketa.rating = temp_cs_data.rating .
                /* если  в доля платежа, оценка платеж не ОК  и суммы нулевые отказ*/
               if (not v-dpkvzp123 matches "*(OK)*"  or  not v-ball234 matches "*(OK)*") and v-maxsumkr <=0 and v-sum1 <= 0 then assign pkanketh.value1 = "100" pkanketa.sts = "100" pkanketa.rating = -1.

               find current pkanketh no-lock no-error.
               find current pkanketa no-lock no-error.

               v-zag = "Бизнес-процесс: Экспресс кредит заявка успешно отконтролирована ".
               v-str = "Здравствуйте! ~nЗаявка и кредитный скоринг отконтролированы, необходимо продолжить процесс. ~n Клиент: "
                     + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                     + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". ~nДата поступления задачи: " + string(today)
                     + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
               run mail(pkanketa.rwho + "@fortebank.com","FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
               run savelog('cs_data2', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + "Экспресс кредиты  Документ отконтролирован " + g-ofc).
               message "Документ отконтролирован!" view-as alert-box  buttons ok.
            end.
            else do:
               update v-reas  with frame detpay.
               hide frame detpay.
               find current pkanketa exclusive-lock no-error.
               pkanketa.rescha[4] = "". /* очищаем банк рефинансирования */
               find current pkanketa no-lock no-error.
               find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10" and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" exclusive-lock no-error.
               pkanketh.value1  = "01".
               pkanketh.value2  = v-reas.
               find current pkanketh no-lock no-error.
               v-zag = "Бизнес-процесс: Экспресс кредит доработка ".
               v-str = "Здравствуйте! Вам назначена задача в АБС ixora в п.м. 3.2.7.1 'Анкета клиента'. Заявка отправлена на доработку по причине: " + trim(v-reas) + ". ~n Клиент: "
                     + pcstaff0.sname + " " + pcstaff0.fname + " " + pcstaff0.mname + ", ИИН: "
                     + pcstaff0.iin + ", код клиента: " + pcstaff0.cif + ", номер анкеты: " + string(pkanketa.ln) + ". Дата поступления задачи: " + string(today)
                     + ', ' + string(time,'hh:mm:ss') + ". Бизнес-процесс: Экспресс кредит".
               run mail(pkanketa.rwho + "@fortebank.com","FORTEBANK <abpk@fortebank.com>", v-zag,v-str, "", "","").
               run savelog('cs_data2', pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + "Экспресс кредиты  Документ отправлен на доработку " + g-ofc).
               message "Документ отправлен на доработку!" view-as alert-box  buttons ok.
            end.
        end.
    end.

    procedure procLoadData:
       for each pkkrit where lookup("10",pkkrit.credtype) > 0 and pkkrit.priz = '1' no-lock:
          create temp_cs_data.
          assign
          temp_cs_data.rating = ?
          temp_cs_data.cif = pkanketa.cif
          temp_cs_data.bank = pkanketa.bank
          temp_cs_data.credtype = '10'
          temp_cs_data.ln = pkanketa.ln
          temp_cs_data.kritcod = pkkrit.kritcod
          temp_cs_data.dttype  = ""
          temp_cs_data.kritname = pkkrit.kritname
          temp_cs_data.kritspr = pkkrit.kritspr.
          find first sort1 where sort1.fl = pkkrit.kritcod no-lock no-error.
          if available sort1 then temp_cs_data.sort1 = sort1.nn.
          else temp_cs_data.sort1 = pkkrit.ln.
          find first pkanketh where pkanketh.bank = pkanketa.bank  and pkanketa.cif = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = pkkrit.kritcod no-lock no-error.
          if avail pkanketh then do:
             if lookup(trim(v-ExpSave),"100,110,120") > 0  then do: /* значит данные уже сохранены */
                temp_cs_data.kritdispl = pkanketh.rescha[1].
                temp_cs_data.rating    = int(pkanketh.resdec[1]).
                if temp_cs_data.kritcod = "echildl"      then  v-echildl = int(temp_cs_data.kritdispl).
                if temp_cs_data.kritcod = "echildn"      then  v-echildn = int(temp_cs_data.kritdispl).
                if temp_cs_data.kritcod = "esumtr"       then  prkred    = decim(temp_cs_data.kritdispl).
                if temp_cs_data.kritcod = "maxpl234"     then  prmaxpl   = decim(temp_cs_data.kritdispl).
                if temp_cs_data.kritcod = "ball234"      then  prball    = temp_cs_data.kritdispl.
             end.
             else do:
                if pkanketh.kritcod = "espwork" then do:
                  if pkanketh.value1 = "yes" or pkanketh.value1 = "да" then temp_cs_data.kritdispl = "Да". /* супруг работает */
                  else temp_cs_data.kritdispl = "Нет". /* супруг не работает */
                end.
                else temp_cs_data.kritdispl = pkanketh.value1.
                temp_cs_data.rating = ?.
            end.
         end.
       end.
    end procedure.

    procedure procImportData:
       def var v-hdt as date init ?.
       def var v-salary as deci init ?.

       def var v-sum as deci init 0.

       def var v-bal7 as deci no-undo init 0.
       def var p-coun as integer no-undo.
       def var fdt as date no-undo.
       def var dayc1 as integer no-undo.

       find first cif where cif.cif = pkanketa.cif no-lock no-error.
       if avail cif then do:
          vv-iin = cif.bin.
          find first pcstaff0 where pcstaff0.bank = v-bank and pcstaff0.cif = v-cifcod no-lock no-error.
          if avail pcstaff0 then assign v-cifcompany = pcstaff0.cifb v-hdt = pcstaff0.hdt v-salary = pcstaff0.salary.

          if v-cifcompany begins "txb" then v-companyName = "AO 'ForteBank'".
          else do:
              find first b-cif where b-cif.cif = v-cifcompany no-lock no-error.
              if avail b-cif then do:
                 v-companyName = b-cif.prefix + " " + b-cif.name.
              end.
          end.
       end.


       for each temp_cs_data:
          /* Платеж по текущим (действующим) обязательствам*/
          if /*temp_cs_data.kritdispl = "" and*/ temp_cs_data.kritcod = "plattekob123" then do:
             v-cbbsum = 0.
            for each cbb where cbb.pr <> "ref".
                v-cbbsum = v-cbbsum + cbb.sum.
            end.
            temp_cs_data.kritdispl = string(round(v-cbbsum + v-sumforte,2)).
          end.

          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "FIO123" then do: /* фио */
             temp_cs_data.kritdispl = pkanketa.name.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "IIN123" then do: /*ИИН */
             find first cif where cif.cif = pkanketa.cif no-lock no-error.
             if avail cif then do:
                temp_cs_data.kritdispl = cif.bin.
             end.
          end.
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "regionin123" then do: /* регион */
             find first codfr where codfr.codfr = "regin234" /*temp_cs_data.kritspr*/ and codfr.name[4] = pkanketa.bank no-lock no-error.
             if avail codfr then do:
                temp_cs_data.value1 = codfr.code.
                temp_cs_data.kritdispl = codfr.name[1].
                temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.
          /* Сколько лет Компания на рынке */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "companyyear123" then do:
             if v-cifcompany begins "txb" then v-cifexpdt = 09/02/2007.
             else do:
                 find first cif where cif.cif = v-cifcompany no-lock no-error.
                 if avail cif then v-cifexpdt = cif.expdt.
                 else do:
                    message "Не найдена дата выдачи регистрационного свид-ва компании" view-as alert-box.
                    return.
                 end.
             end.
            if (today - v-cifexpdt) / 30 < 6 then do:
                 find first codfr where codfr.codfr = "companyyear234" /*temp_cs_data.kritspr*/ and codfr.code = "100" no-lock no-error.
                 if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
            end.
            if (today - v-cifexpdt) / 30 >= 6 and (today - v-cifexpdt) / 30 < 12 then do:
                 find first codfr where codfr.codfr = "companyyear234" /*temp_cs_data.kritspr*/ and codfr.code = "110" no-lock no-error.
                 if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
            end.
            if (today - v-cifexpdt) / 30 >= 12 and (today - v-cifexpdt) / 30 < 36 then do:
                 find first codfr where codfr.codfr = "companyyear234" /*temp_cs_data.kritspr*/ and codfr.code = "120" no-lock no-error.
                 if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
            end.
            if (today - v-cifexpdt) / 30 >= 36 and (today - v-cifexpdt) / 30 < 60 then do:
                 find first codfr where codfr.codfr = "companyyear234" /*temp_cs_data.kritspr*/ and codfr.code = "130" no-lock no-error.
                 if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
            end.
            if (today - v-cifexpdt) / 30 >= 60 then do:
                 find first codfr where codfr.codfr = "companyyear234" /*temp_cs_data.kritspr*/ and codfr.code = "140" no-lock no-error.
                 if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
            end.
          end.
          /* Стаж на последнем месте работы */
          if /*temp_cs_data.kritdispl = "" and*/ temp_cs_data.kritcod = "experl" then do:
            find first pkanketh where pkanketh.bank = v-bank and pkanketh.cif  = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "experl" no-lock no-error.
            if available pkanketh then do:
                 if int(pkanketh.value1) < 6 then do:
                      find first codfr where codfr.codfr = "laststazh234"  and codfr.code = "100" no-lock no-error.
                      if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                 end.
                 else if int(pkanketh.value1) >= 6 and int(pkanketh.value1) < 12 then do:
                      find first codfr where codfr.codfr = "laststazh234"  and codfr.code = "110" no-lock no-error.
                      if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                 end.
                 else if int(pkanketh.value1) >= 12 and int(pkanketh.value1) < 36 then do:
                      find first codfr where codfr.codfr = "laststazh234" and codfr.code = "120" no-lock no-error.
                      if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                 end.
                 else if int(pkanketh.value1) >= 36 and int(pkanketh.value1) < 60 then do:
                      find first codfr where codfr.codfr = "laststazh234"  and codfr.code = "130" no-lock no-error.
                      if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                 end.
                 else if int(pkanketh.value1) >= 60 then do:
                      find first codfr where codfr.codfr = "laststazh234" and codfr.code = "140" no-lock no-error.
                      if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
                 end.
            end.
          end.
          /* Возраст  */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "age234" then do:

             if round(((today -  pcstaff0.birth) / 365),0) < 25 then do:
                  find first codfr where codfr.codfr = "age234" /*temp_cs_data.kritspr*/ and codfr.code = "100" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if round(((today -  pcstaff0.birth) / 365),0) >= 25 and round(((today -  pcstaff0.birth) / 365),0) < 45 then do:
                  find first codfr where codfr.codfr = "age234" /*temp_cs_data.kritspr*/ and codfr.code = "110" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if round(((today -  pcstaff0.birth) / 365),0) >= 45 and round(((today -  pcstaff0.birth) / 365),0) < 56 then do:
                  find first codfr where codfr.codfr = "age234" /*temp_cs_data.kritspr*/ and codfr.code = "120" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if round(((today -  pcstaff0.birth) / 365),0) >= 56 then do:
                  find first codfr where codfr.codfr = "age234" /*temp_cs_data.kritspr*/ and codfr.code = "130" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.

          /* образование */
          if /*temp_cs_data.kritdispl = "" and*/ temp_cs_data.kritcod = "educat" then do:
            find first pkanketh where pkanketh.bank = v-bank and pkanketh.cif  = v-cifcod and pkanketh.credtype = '10' and pkanketh.ln = s-ln and pkanketh.kritcod = "educat" no-lock no-error.
            if available pkanketh then do:
                find first codfr where codfr.codfr = "educat" and codfr.name[1] = pkanketh.value1 no-lock no-error.
                if available codfr then do:
                    assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1].
                    if codfr.code = "1" then temp_cs_data.rating = 0.
                    if codfr.code = "2" then temp_cs_data.rating = 1.
                    if codfr.code = "3" then temp_cs_data.rating = 1.
                    if codfr.code = "4" then temp_cs_data.rating = 2.
                end.
            end.
          end.

          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "emarsts" then temp_cs_data.kritdispl = temp_cs_data.value1. /* семейное положение */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "ememnum" then temp_cs_data.kritdispl = temp_cs_data.value1. /*  кол-во членов семьи */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "espwork" then temp_cs_data.kritdispl = temp_cs_data.value1. /* супруг не работает */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "echildn" then temp_cs_data.kritdispl = temp_cs_data.value1. /* кол  детей */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "echildl" then temp_cs_data.kritdispl = temp_cs_data.value1. /* кол  детей несовершен*/

           /* Кредитная история   */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "credhist123" then do:
             def var cnt as int init 0.
             def var maxcnt as int init 0.

             for each cbb.
                if maxcnt < cbb.cntpr then do:
                    maxcnt = cbb.cntpr.
                    cnt = cbb.cntday.
                end.
             end.

             if (maxcnt >= 0 and  maxcnt < 15 and cnt <= 3) or maxcnt = 0 then do:
                  find first codfr where codfr.codfr = "kip23mbvu"  and codfr.code = "100" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if maxcnt >= 1 and  maxcnt < 15 and cnt > 3 then do:
                  find first codfr where codfr.codfr = "kip23mbvu"  and codfr.code = "110" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if maxcnt >= 15 and  maxcnt <= 30 then do:
                  find first codfr where codfr.codfr = "kip23mbvu"  and codfr.code = "120" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if maxcnt >= 31 then do:
                  find first codfr where codfr.codfr = "kip23mbvu"  and codfr.code = "150" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.

             if avail codfr then do:
                temp_cs_data.value1 = codfr.code.
                temp_cs_data.kritdispl = codfr.name[1].
                temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.

          /* кол пролонгаций  */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "prol234" then do:
             cntprol = 0.
             for each cbb.
                if cntprol < cbb.prol then cntprol = cbb.prol.
             end.
             if cntprol = 0 then do:
                  find first codfr where codfr.codfr = "prol234"  and codfr.code = "100" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if cntprol = 1 then do:
                  find first codfr where codfr.codfr = "prol234"  and codfr.code = "110" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if cntprol = 2 and  maxcnt <= 30 then do:
                  find first codfr where codfr.codfr = "prol234"  and codfr.code = "120" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if cntprol = 3 then do:
                  find first codfr where codfr.codfr = "prol234"  and codfr.code = "130" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.
             if cntprol >= 4 then do:
                  find first codfr where codfr.codfr = "prol234"  and codfr.code = "140" no-lock no-error.
                  if avail codfr then assign temp_cs_data.value1 = codfr.code temp_cs_data.kritdispl = codfr.name[1] temp_cs_data.rating = int(codfr.name[5]).
             end.

             if avail codfr then do:
                temp_cs_data.value1 = codfr.code.
                temp_cs_data.kritdispl = codfr.name[1].
                temp_cs_data.rating = int(codfr.name[5]).
             end.
          end.

          /* зар плата */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "zp123" then temp_cs_data.kritdispl = string(v-salary).
          /* запрашив сумма */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "esumtr" then temp_cs_data.kritdispl = temp_cs_data.value1.
          /* запрашив срок */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "esroktr" then temp_cs_data.kritdispl = temp_cs_data.value1.


          /* макс платеж по кредиту запрашив условия maxpl234 */
          if temp_cs_data.kritdispl = "" and temp_cs_data.kritcod = "maxpl234" then
          temp_cs_data.kritdispl = maxpl(v-metam,v-sroktr,v-gstav,v-sumtr).

         /* доля платежа в зп "dpkvzp123"  */
         /* оценка платежеспособности "ball234" */
         /* макс сумма кредита исходя из доходов "maxsumkr"*/
         /* макс платеж по кредиту  исходя из доходов "maxplkr"*/
         /* оценка платежеспособности исходя из доходов "dol234" */
       end.
    end procedure.

    procedure procCalcField:
        def var v-summa as deci init 0.
        def var v-sum3 as deci init 0.
        def var v-plattekob as deci init 0.
        def var v-mpp as deci init 0.
        def var v-mpp1 as deci init 0.
        def var v-mpp2 as deci init 0.
        def var v-mpp3 as deci init 0.
        def var v-zp as deci init 0.
        def var v-pp as deci init 0.
        def var v-mar as char init "".
        def var v-espwork as char init no.

        find first bookcod where bookcod.bookcod = "MRP" no-lock no-error.
        if not available bookcod or decim(bookcod.name) <= 0  then do:
            message "Не найден размер МРП в п.м. 3.3.3.1 'Общие справочники' - 'MRP'" view-as alert-box.
            return.
        end.
        v-mpp = decim(bookcod.name).
        v-mpp2 = v-mpp.
        v-mpp3 = v-mpp.

        for each temp_cs_data:
            if temp_cs_data.kritcod = "maxpl234"     then  v-summa = deci(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "plattekob123" then  v-plattekob = deci(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "zp123"        then  v-zp = deci(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "emarsts"      then  v-mar = temp_cs_data.kritdispl.
            if temp_cs_data.kritcod = "espwork"      then  v-espwork = temp_cs_data.kritdispl.
            if temp_cs_data.kritcod = "echildl"      then  v-echildl = int(temp_cs_data.kritdispl).
            if temp_cs_data.kritcod = "echildn"      then  v-echildn = int(temp_cs_data.kritdispl).
        end.
        for each temp_cs_data:
          if temp_cs_data.kritcod = "dpkvzp123" then do:  /* доля платежа по кредитам в зар*/
             temp_cs_data.kritdispl = string(round(((v-summa  + v-plattekob) / v-zp * 100),0))  no-error.
             if v-zp <= 65 * v-mpp then v-pp = 50.
             if v-zp > 65 * v-mpp and v-zp <= 90 * v-mpp then v-pp = 60.
             if v-zp > 90 * v-mpp  then v-pp = 70.
             if deci(temp_cs_data.kritdispl) > v-pp then temp_cs_data.kritdispl = temp_cs_data.kritdispl + "% (ДОЛЯ ПЛАТЕЖА ПРЕВЫШЕНА)".
             else temp_cs_data.kritdispl = temp_cs_data.kritdispl + "% (OK)".
             temp_cs_data.rating = ?.
             v-dpkvzp123 = temp_cs_data.kritdispl.
          end.
          if temp_cs_data.kritcod = "ball234" then do: /*оценка платежеспособности запрашив условия*/
             if can-do("TXB16,TXB08,TXB11,TXB12",v-bank) then v-mpp = v-mpp * 15.
             else v-mpp = v-mpp * 10.
             /* для заемщика */
             v-mpp1 = v-mpp .
             /* для супруги */
             if (v-mar = "женат/замужем" or v-mar = "гражданский брак") and (v-espwork = "no" or v-espwork = "нет") then v-mpp1 = v-mpp1 + v-mpp.
             /* для несоверш детей */
             if v-echildl > 0 then v-mpp1 = v-mpp1 + (v-mpp / 2 * v-echildl).
             /* для совершеннолет детей */
             if v-echildn - v-echildl > 0 then v-mpp1 = v-mpp1 + (v-mpp * (v-echildn - v-echildl)).
             if v-plattekob + v-summa + v-mpp1 <= v-zp then temp_cs_data.kritdispl = string(round((v-plattekob + v-summa + v-mpp1),0)) + " (OK)".
             else temp_cs_data.kritdispl = string(round((v-plattekob + v-summa + v-mpp1),0)) + " (НЕ ДОСТАТОЧНО ДОХОДОВ)".
             temp_cs_data.rating = ?.
             v-ball234 = temp_cs_data.kritdispl.
          end.
        end.
        /* макс платеж по кредиту  исходя из доходов "maxplkr"*/
        /*Максимальный платеж по кредиту, исходя из доходов равна Сумма з/п минус прожиточный минимум на Заемщика
        (супругу заемщика при наличии) минус  прожиточный минимум на детей Заемщика минус другие обязательства по кредиту в БВУ.
        прожиточный минимум на каждого члена семьи Заемщика (15 МРП для городов Астана, Алматы, Атырау, Актау и 10 МРП для других регионов),
        прожиточный минимум на супругу/супруга Заемщика (в случае предоставления супругом/супругой документа, отражающего и подтверждающего ежемесячный доход, расходы по прожиточному минимуму на него/нее не учитываются),
        прожиточный минимум на несовершеннолетних детей, не достигших 18 лет (в расчет принимается половина от показателя 15/10 МРП на взрослого в зависимости от региона).
        */
        if can-do("TXB16,TXB08,TXB11,TXB12",v-bank) then v-mpp1 = v-mpp3 * 15.
        else v-mpp1 = v-mpp3 * 10.

        v-sum1 = v-mpp1. /* прожиточный минимум на Заемщика*/
        if (v-mar = "женат/замужем" or v-mar = "гражданский брак") and (v-espwork = "no" or v-espwork = "нет") then v-sum1 = v-sum1 + v-mpp1. /* если супруга не работает */
        if v-echildl > 0 then v-sum1 = v-sum1 + (v-mpp1 / 2 * v-echildl). /* для несоверш детей */
        if v-echildn - v-echildl > 0 then v-sum1 = v-sum1 + (v-mpp1 * (v-echildn - v-echildl)). /* для совершеннолет детей */
        /* =ЕСЛИ((ДОХОД-(прож.минимум на семью))/ДОХОД>60 %;ДОХОД*60%;ЕСЛИ((ДОХОД-(прож.минимум на семью))/ДОХОД<=60%;
        (ДОХОД-(прож.минимум на семью)))) */

         if v-zp <= 65 * v-mpp3 then v-sum3 = /*v-zp **/ 0.5.
         if v-zp > 65 * v-mpp3 and v-zp <= 90 * v-mpp3 then v-sum3 = /*v-zp **/ 0.6.
         if v-zp > 90 * v-mpp3  then v-sum3 = /*v-zp **/ 0.7.
         if (v-zp - v-sum1) / v-zp > v-sum3 then v-sum1 = v-zp * v-sum3.
         else v-sum1 = v-zp - v-sum1.
        v-sum1 = v-sum1 - v-plattekob.  /* обязательства по кредиту в БВУ */
        if v-sum1 < 0 then v-sum1 = 0.
        find first temp_cs_data where temp_cs_data.kritcod = "maxplkr" no-error.
        if available temp_cs_data then temp_cs_data.kritdispl = string(round(v-sum1,0)).

        /* макс сумма кредита исходя из доходов maxsumkr  =  Р/(С/12/(1-1/((1+С/12)^Т))) равн долями = Р*Т/(1+(С*Т/12)) */
        def var a as decim.
        a = exp((1 + (v-gstav / 100) / 12),v-sroktr).
        if v-metam = "Аннуитет" then v-maxsumkr = v-sum1 / (v-gstav / 100 / 12 / (1 - (1 / a))).
        else v-maxsumkr = v-sum1 * v-sroktr / (1 + ((v-gstav / 100) * v-sroktr / 12)).
        /* макс размер Кредита должен быть не 1500000 тенге */
        if v-maxsumkr > 1500000 then v-maxsumkr = 1500000.
        if v-maxsumkr  < 0 then v-maxsumkr = 0.
        find first temp_cs_data where temp_cs_data.kritcod = "maxsumkr" no-error.
        if available temp_cs_data then temp_cs_data.kritdispl = string(round(v-maxsumkr,0)).

         /*оценка платежеспособности исходя из доходов*/
         if can-do("TXB16,TXB08,TXB11,TXB12",v-bank) then v-mpp2 = v-mpp2 * 15.
         else v-mpp2 = v-mpp2 * 10.
         /* для заемщика */
         v-mpp1 = v-mpp2 .
         /* для супруги */
         if (v-mar = "женат/замужем" or v-mar = "гражданский брак") and (v-espwork = "no" or v-espwork = "нет") then v-mpp1 = v-mpp1 + v-mpp2.
         /* для несоверш детей */
         if v-echildl > 0 then v-mpp1 = v-mpp1 + (v-mpp2 / 2 * v-echildl).
         /* для совершеннолет детей */
         if v-echildn - v-echildl > 0 then v-mpp1 = v-mpp1 + (v-mpp2 * (v-echildn - v-echildl)).
         find first temp_cs_data where temp_cs_data.kritcod = "dol234" no-error.
         if v-plattekob + v-sum1 + v-mpp1 <= v-zp then temp_cs_data.kritdispl = string(round((v-plattekob + v-sum1 + v-mpp1),0)) + " (OK)".
         else temp_cs_data.kritdispl = string(round((v-plattekob + v-sum1 + v-mpp1),0)) + " (НЕ ДОСТАТОЧНО ДОХОДОВ)".
         temp_cs_data.rating = ?.
        if v-dpkvzp123 matches "*(OK)*"  and  v-ball234 matches "*(OK)*" then do: /* если  в доля платежа и оценка платеж ОК дальше не надо*/
            prkred = v-sumtr.
            prmaxpl = v-summa.
            prball = v-ball234.
            find first temp_cs_data where temp_cs_data.kritcod = "maxplkr" no-error.
            if available temp_cs_data then temp_cs_data.kritdispl = "".
            find first temp_cs_data where temp_cs_data.kritcod = "maxsumkr" no-error.
            if available temp_cs_data then temp_cs_data.kritdispl = string(round(v-maxsumkr,0)).
            find first temp_cs_data where temp_cs_data.kritcod = "dol234" no-error.
            if available temp_cs_data then temp_cs_data.kritdispl = "".
        end.
        else do:
            prkred = round(v-maxsumkr,0).
            prmaxpl = round(v-sum1,0).
            prball = string(round((v-plattekob + v-sum1 + v-mpp1),0)).
        end.
    end procedure.

    procedure procCalcScore:
        def var i as int.
        def var v-rating as int extent 7.
        def var v-itog as deci.
        for each temp_cs_data:
           if temp_cs_data.kritcod = "regionin123"    then v-rating[1] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "companyyear123" then v-rating[2] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "experl"         then v-rating[3] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "age234"         then v-rating[4] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "educat"         then v-rating[5] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "credhist123"    then v-rating[6] = temp_cs_data.rating.
           if temp_cs_data.kritcod = "prol234"        then v-rating[7] = temp_cs_data.rating.

        end.
        /*=ЕСЛИ(итоговый балл<=0,49999; Стабильный;ЕСЛИ(итоговый балл <=1,4999; Удовлетворительный;
        ЕСЛИ(итоговый балл <=2,4999; Неудовлетворительный;ЕСЛИ(итоговый балл <=3,4999; Нестабильный;
        ЕСЛИ(итоговый балл <=4,4999; Критический;ЕСЛИ(итоговый балл ="отказ"; Критический;
        ЕСЛИ(итоговый балл ="отказ"; Критический;ЕСЛИ(кред.история=2;"Неудовлетворительный";
        ЕСЛИ(балл кол-во пролонгаций=1;"Удовлетворительный";ЕСЛИ(балл кол-во пролонгаций =2;"Неудовлетворительный";
        ЕСЛИ(балл кол-во пролонгаций =3;"Нестабильный")))))))))))
        Стабильный	0
        Удовлетворительный	1
        Неудовлетворительный	2
        Нестабильный	3
        Критический	-1*/

        v-itog = ((v-rating[1] + v-rating[2] + v-rating[3] + v-rating[4] + v-rating[5]) / 5 * 0.4) + ((v-rating[6] + v-rating[7]) / 2 * 0.6).
        do i = 1 to 7:
           if v-rating[i] = -1 then v-itog = -1.
        end.
        if v-itog >= 0 then do:  /* если есть хотя бы один -1,то отказ */
            /* ЕСЛИ(D19=1;"1";ЕСЛИ(D19=2;"2";ЕСЛИ(D19=3;"3";ЕСЛИ(D18=0;B21;ЕСЛИ(D18=1;B21;ЕСЛИ(D18=2;B21;ЕСЛИ(D18=3;B21;ЕСЛИ(D18=3;B21;ЕСЛИ(D18=4;B21;ЕСЛИ(D11=1;B21;ЕСЛИ(D11=2;B21;ЕСЛИ(D11=3;B21;ЕСЛИ(D12=1;B21;ЕСЛИ(D12=2;B21;ЕСЛИ(D12=3;B21;ЕСЛИ(D13=1;B21;ЕСЛИ(D8=0;B21;ЕСЛИ(D8=1;B21;ЕСЛИ(D8=2;B21;ЕСЛИ(D8=3;B21)))))))))))))))))))))))))  */
            case v-rating[7]: /* D19 - пролонгации количество */
                when 1 then v-itog = 1.
                when 2 then v-itog = 2.
                when 3 then v-itog = 3.
            end case.
        end.
        find first temp_cs_data where temp_cs_data.kritcod = "itog123" no-error.
        if avail temp_cs_data then do:
           if int(v-itog) < 0 then temp_cs_data.kritdispl = "Критический ".
           if int(v-itog) >= 0 and int(v-itog) < 1 then temp_cs_data.kritdispl = "Стабильный" .
           if int(v-itog) >= 1  and int(v-itog) < 2  then temp_cs_data.kritdispl = "Удовлетворительный".
           if int(v-itog) >= 2  and int(v-itog) < 3 then temp_cs_data.kritdispl = "Неудовлетворительный" .
           if int(v-itog) >= 3 then temp_cs_data.kritdispl = "Нестабильный" .
           temp_cs_data.rating = int(v-itog).
        end.
    end procedure.

    def stream v-out.
    procedure procPrint:
        def var v-ofile as char.
        def var v-ifile as char.
        def var v-str as char.
        message "Ждите...". pause 0.

        v-echild = v-echildn - v-echildl.
        v-ofile = "efile.htm" .
        v-ifile = "/data/docs/expcs3.htm".
        output stream v-out to value(v-ofile).
        input from value(v-ifile).

        repeat:
            import unformatted v-str.
            v-str = trim(v-str).
            repeat:
              if v-str matches "*org123*" then do:
                 v-str = replace (v-str, "org123", v-companyName).
                 next.
              end.
              if v-str matches "*ddmmyyyy*" then do:
                 v-str = replace (v-str, "ddmmyyyy", string(today)).
                 next.
              end.

              if v-str matches "*FIO123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "FIO123".
                 v-str = replace (v-str, "FIO123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*IIN123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "IIN123".
                 v-str = replace (v-str, "IIN123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*regionin123bal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "regionin123".
                 v-str = replace (v-str, "regionin123bal", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*regionin123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "regionin123".
                 v-str = replace (v-str, "regionin123", string(temp_cs_data.kritdispl)).
                 next.
              end.
             if v-str matches "*companyyear123bal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "companyyear123".
                 v-str = replace (v-str, "companyyear123bal", string(temp_cs_data.rating)).
                 next.
              end.
             if v-str matches "*companyyear123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "companyyear123".
                 v-str = replace (v-str, "companyyear123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*experlbal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "experl".
                 v-str = replace (v-str, "experlbal", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*experl*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "experl".
                 v-str = replace (v-str, "experl", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*rast*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "age234".
                 v-str = replace (v-str, "rast", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*age234*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "age234".
                 v-str = replace (v-str, "age234", string(temp_cs_data.kritdispl)).
                 next.
              end.
             if v-str matches "*educatbal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "educat".
                 v-str = replace (v-str, "educatbal", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*educat*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "educat".
                 v-str = replace (v-str, "educat", string(temp_cs_data.kritdispl)).
                 next.
              end.
             if v-str matches "*emarsts*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "emarsts".
                 v-str = replace (v-str, "emarsts", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*ememnum*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "ememnum".
                 v-str = replace (v-str, "ememnum", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*nesov*" then do:
                 v-str = replace (v-str, "nesov", string(v-echildl)).
                 next.
              end.
              if v-str matches "*koldet*" then do:
                 v-str = replace (v-str, "koldet", string(v-echild)).
                 next.
              end.
             if v-str matches "*espwork*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "espwork".
                 v-str = replace (v-str, "espwork", string(temp_cs_data.kritdispl)).
                 next.
              end.
             if v-str matches "*paste*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "credhist123".
                 v-str = replace (v-str, "paste", string(temp_cs_data.rating)).
                 next.
              end.
              if v-str matches "*credhist123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "credhist123".
                 v-str = replace (v-str, "credhist123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*prol234bal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "prol234".
                 v-str = replace (v-str, "prol234bal", string(temp_cs_data.rating)).
                 next.
              end.
             if v-str matches "*prol234*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "prol234".
                 v-str = replace (v-str, "prol234", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*zp123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "zp123".
                 v-str = replace (v-str, "zp123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*esumtr*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "esumtr".
                 v-str = replace (v-str, "esumtr", string(prkred) /*string(temp_cs_data.kritdispl)*/).
                 next.
              end.
              if v-str matches "*esroktr*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "esroktr".
                 v-str = replace (v-str, "esroktr", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*plattekob123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "plattekob123".
                 v-str = replace (v-str, "plattekob123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              if v-str matches "*maxpl234*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "maxpl234".
                 v-str = replace (v-str, "maxpl234", string(prmaxpl) /*string(temp_cs_data.kritdispl)*/).
                 next.
              end.
             if v-str matches "*ball234*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "ball234".
                 v-str = replace (v-str, "ball234", prball /*string(temp_cs_data.kritdispl)*/).
                 next.
              end.
             if v-str matches "*itog123bal*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "itog123".
                 v-str = replace (v-str, "itog123bal", string(temp_cs_data.rating)).
                 next.
              end.
             if v-str matches "*itog123*" then do:
                 find first temp_cs_data where temp_cs_data.kritcod = "itog123".
                 v-str = replace (v-str, "itog123", string(temp_cs_data.kritdispl)).
                 next.
              end.
              leave.
            end.
           put stream v-out unformatted v-str skip.
        end.

        input close.
        output stream v-out close.
        unix silent cptunkoi value(v-ofile) winword.
    end procedure.

procedure procLogot:
    displ skip(1) "    Ждите идет копирование логотипа...   " skip(1) with row 8 centered overlay frame f-wait.

    def var v-dcpath as char.
    def var v-dcsign as char.
    def var v as char.
    def var v-str2 as char.
    def var s-tempfolder as char.

    /* определение каталога для копий файлов на локальной машине юзера */
    input through localtemp.
    repeat:
      import s-tempfolder.
    end.
    input close.
    pause 5 no-message.
    if substr(s-tempfolder, length(s-tempfolder), 1) <> "\\" then s-tempfolder = s-tempfolder + "\\".

    v-dcpath = "/data/docs/".
    create t-files.
    t-files.name = v-dcpath + "sf1.jpg".
    t-files.fname = "sf1.jpg".
    create t-files.
    t-files.name = v-dcpath + "sf1.jpg".
    t-files.fname = "pkstamp.jpg".
    for each t-files.
        /* копируем файл */
        v-str2 = "".
        input through value("cpy -put " + t-files.name + " " + replace(s-tempfolder, "\\", "/") + ";echo $?").
        repeat:
            import v.
        end.
        input close.
        pause 3 no-message.

        if v <> "0" then do:
            if v-str2 <> "" then v-str2 = v-str2 + "; ".
            v-str2 = v-str2 + t-files.fname.
        end.

        hide frame f-wait no-pause.
        if v-str2 <> "" then do:
          message skip " Во время копирование логотипа произошла ошибка !"
                  skip " Файлы :" v-str2
                  skip(1) " Обратитесь к системному администратору !"
                  skip(1) view-as alert-box title " ОШИБКА ! ".
            return.
        end.
    end.
   message skip " Копирование логотипа завершено !" skip(1) view-as alert-box title "".
   return.

end procedure.
