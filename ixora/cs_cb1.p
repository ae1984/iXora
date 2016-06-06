/* cs_cb1.p
 * MODULE
        экспресс кредиты по ПК
 * DESCRIPTION
        Отчет ПКБ
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

def  var s-credtype as char init '10' no-undo.

def shared var v-cifcod   as char no-undo.
def shared var s-ln       as inte no-undo.
def shared var v-bank     as char no-undo.


def var fcb_id as int  no-undo.
def var v-day  as int  no-undo.
def var v-count as int no-undo.
def var v-code as char no-undo.
def var xml_id as int  no-undo.
def var v-select  as inte.

def temp-table cbb no-undo
    field bank    as char
    field sub     as char
    field numdog  as char
    field dbeg    as char
    field dend    as char
    field sum     as char
    field pr      as char
   index idx is primary numdog.

def temp-table t-cbb no-undo
    field bank    as char
    field sub     as char
    field numdog  as char
    field dbeg    as char
    field dend    as char
    field sum     as char
   index idx is primary numdog.

find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.
if not avail pkanketa then do:
   message "Анкета не найдена!" view-as alert-box question buttons ok.
   return.
end.
run sel2 ("Выберите :", " 1. Просмотреть отчет ПКБ | 2. Отправить запрос в ПКБ | 3. Выход ", output v-select).
case v-select:
    when 1 then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
                and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fcbid234" no-lock no-error.
        if not available pkanketh or pkanketh.value1 = "" then do:
           message "Запрос в 1КБ не был отправлен!" view-as alert-box question buttons ok.
           return.
        end.
        fcb_id = int(trim(pkanketh.value1)).

        find first fcb where fcb.fcb_id = fcb_id no-lock no-error.
        if not available fcb then do:
           message "Отчет ПКБ не найден!" view-as alert-box question buttons ok.
           return.
        end.

        displ skip(1) " Ждите идет обработка данных...   " skip(1) with row 8 centered overlay frame f-wait.
        pause 0.
        /*run 1CB_getOverdue(input fcb_id, output v-day, output v-count).*/
        run 1CB_chk(input fcb_id).
        run credcontract1(input fcb_id).

        hide all.
        xml_id = fcb.xml_id.
        if pkanketa.goal = 'Рефинансирование' and pkanketa.rescha[4] = "" then run 1CB_refin(xml_id).

        run savelog('cs_cb1', pkanketa.bank + " " + pkanketa.cif + " " + pkanketa.aaa + " " + string(pkanketa.ln) + " Данные сохранены по экспресс кредитам").
    end.
    when 2 then do:
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
            and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "SaveExp" no-lock no-error.
        if avail pkanketh and lookup(trim(pkanketh.value1),"100,110,120") > 0 then do:
            message "Данные уже сохранены, отправление запроса в ПКБ невозможно!" view-as alert-box  buttons ok.
            return.
        end.
        displ skip(1) " Ждите идет отправление запроса...   " skip(1) with row 8 centered overlay frame f-wait.
        pause 0.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
                and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fcbid234" no-lock no-error.
        if available pkanketh then fcb_id = int(trim(pkanketh.value1)).
        run fcb_send.
        hide frame f-wait.
        find first pkanketh where pkanketh.bank = pkanketa.bank and pkanketh.cif = pkanketa.cif and pkanketh.credtype = "10"
                and pkanketh.ln = pkanketa.ln and pkanketh.kritcod = "fcbid234" no-lock no-error.
        if available pkanketh and pkanketh.value1 <> "" and fcb_id <> int(trim(pkanketh.value1)) then message 'Запрос в ПКБ отправлен' view-as alert-box.
    end.
    when 3 then return.
end.


procedure 1CB_refin:
    def input parameter xml_id as int no-undo.
    def var v-count as int init 0.
    def var vstart as int extent 50.
    def var vend as int extent 50.
    def var ij as int.
    def var v-cbbkod as char.
    def var v-cbbsum as decim.
    def var v-repl as char.
    def var v-val as char.
    def var v-fin as char init "".
    def var cntprol as int init 0.
    def var pcnt as int init 0.
    def var ii as int init 0.
    /* договора */
    for each xml_det where xml_det.xml_id = xml_id and xml_det.par matches "*Contract ContractTypeCode*" no-lock.
       v-count = v-count + 1.
       if v-count > 1 then vend[v-count - 1] = xml_det.line - 1.
       vstart[v-count] = xml_det.line.
    end.

    if v-count > 0 then do:
        find last xml_det where xml_det.xml_id = xml_id  no-lock no-error.
        vend[v-count] = xml_det.line.
        do ij = 1 to v-count:
            /* банк */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract FinancialInstitution value" no-lock no-error.
            if available xml_det then do:
                create cbb.
                cbb.bank = trim(xml_det.val).
            end.
            /* роль субъекта */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract SubjectRole value" no-lock no-error.
            if available xml_det then cbb.sub = trim(xml_det.val).
            /* Номер договора  */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract AgreementNumber value" no-lock no-error.
            if available xml_det then cbb.numdog = trim(xml_det.val).
            /* Дата начала срока действия договора */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract DateOfCreditStart value" no-lock no-error.
            if available xml_det then cbb.dbeg = trim(xml_det.val).
            /* Дата окончания срока действия договора */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract DateOfCreditEnd value" no-lock no-error.
            if available xml_det then cbb.dend = trim(xml_det.val).
            /* Непогашенная сумма по кредиту  */
            find first xml_det where xml_det.xml_id = xml_id and xml_det.line >= vstart[ij] and xml_det.line <= vend[ij] and xml_det.par matches "*Contract OutstandingAmount value" no-lock no-error.
            if available xml_det then cbb.sum = trim(xml_det.val).
        end. /* do ij = 1 to v-count: */
    end. /* if v-count > 0 then do: */

    DEFINE QUERY q-cbb FOR cbb.
    DEFINE BROWSE b-cbb QUERY q-cbb
           DISPLAY cbb.bank label "Кредитор" format "x(20)"
           cbb.numdog label "Номер договора" format "x(20)"
           cbb.dbeg label "Дата нач." format "x(10)"
           cbb.dend label "Дата оконч." format "x(10)"
           cbb.sum label " Непогаш.сумма " format "x(15)"
           WITH  15 DOWN.
    DEFINE FRAME f-cbb b-cbb  WITH overlay 1 COLUMN SIDE-LABELS row 5 COLUMN 1 width 100 title "Контракты для рефинансирования <ENTER>-выбор <F4>-выход".


    on "END-ERROR" of frame f-cbb do:
        hide frame f-cbb.
        APPLY "WINDOW-CLOSE" TO BROWSE b-cbb.
    end.

    define buffer b-cbb for cbb.
    /* исключим одинаковые записи по договорам */
    for each cbb.
        ii = 0.
        for each b-cbb where b-cbb.numdog = cbb.numdog.
            ii = ii + 1.
        end.
        if ii > 1 then do:
            for each b-cbb where b-cbb.numdog = cbb.numdog.
                if b-cbb.sub <> "Заёмщик" and b-cbb.sub <> "Заемщик" then b-cbb.pr = "iskl".
            end.
        end.
    end.
    for each cbb where cbb.pr = "iskl".
        delete cbb.
    end.
    find first cbb no-error.
    if available cbb then do:
        ii = 0.
        repeat:
            OPEN QUERY  q-cbb FOR EACH cbb.
            ENABLE ALL WITH FRAME f-cbb.
            wait-for return of frame f-cbb
            FOCUS b-cbb IN FRAME f-cbb.
            find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif exclusive-lock no-error.
                if ii = 0 then do:
                    pkanketa.rescha[4] = cbb.numdog.
                    pkanketa.rescha[5] = cbb.bank.
                    ii = ii + 1.
                end.
                else do:
                    pkanketa.rescha[4] = trim(pkanketa.rescha[4]) + "," + cbb.numdog.
                    pkanketa.rescha[5] = trim(pkanketa.rescha[5]) + "," + cbb.bank.
                end.
                delete cbb.
            find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.
        end.
    end.
    else message "Нет данных по отчету 1КБ." view-as alert-box.
end procedure.

procedure procSel:
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif exclusive-lock no-error.
    if trim(pkanketa.rescha[4]) = "" then do:
        pkanketa.rescha[4] = cbb.numdog.
        pkanketa.rescha[5] = cbb.bank.
    end.
    else do:
        pkanketa.rescha[4] = trim(pkanketa.rescha[4]) + "," + cbb.numdog.
        pkanketa.rescha[5] = trim(pkanketa.rescha[5]) + "," + cbb.bank.
    end.
    find first pkanketa where pkanketa.bank = v-bank and pkanketa.cif = v-cifcod and pkanketa.ln = s-ln and pkanketa.credtype = "10" use-index bankcif no-lock no-error.
end procedure.