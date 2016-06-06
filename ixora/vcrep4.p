/* vcrep4.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 4 - Формирование отчета Информация об исполнении обязательств по паспортам сделок
 * RUN

 * CALLER
        vcrepa4.p, vcrepp4.p, vcrepk4.p
 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        06.05.2008 galina
 * BASES
         BANK COMM
 * CHANGES
        22.12.2010 aigul - добавила в таблицу t-docs поле rdt
        26.01.2011 aigul - сделала отчет консолид и по филиалам
        10.02.2011 aigul - для МТ только консолид
        10.04.2011 damir - новые переменные v-bin,v-iin,v-binben,v-iinben
                           bin,iin,binben,iinben во временную таблицу.
        30.09.2011 damir - добавлены
                           1) a)новые поля в t-docs, fields  - numdc, datedc, numnewps, datenewps, numobyaz, corr. b)temp-table t-docscorr,
                           новые переменные v-dtdoc,v-dtcor.
                           2) при p-option = 'msg' добавил v-oper = "2". Добавил входной параметр отправляемый в vcrep4out.p (vcrep4-1.htm).
        06.12.2011 damir - перекомпиляция
        16.07.2012 damir - добавил input parameter v-txbbank.
        13.08.2013 damir - Внедрено Т.З. № 1559,1308.
 */
{vc.i}
{global.i}
{comm-txb.i}

def input parameter p-bank   as char.
def input parameter p-depart as integer.
def input parameter p-option as char.

{vcshared4.i "new"}

def var s-vcourbank as char.
def var v-name as char no-undo.
def var v-depname as char no-undo.
def var v-ncrccod like ncrc.code no-undo.
def var v-sum like vcdocs.sum no-undo.
def var vi as integer no-undo.
def var v-txbbank as char.

s-vcourbank = comm-txb().
v-option = p-option.

if p-option = 'rep' then message "  Формируется отчет...".
if p-option = 'msg' then do:
    form
    skip(1)
    v-oper label " 1) Добавление информации  2) Изменение ранее направленной информации " format '9'
    validate(index("12", v-oper) > 0, "Неверный тип операции !")
    skip(1)
    with centered side-label row 5 width 80 title "УКАЖИТЕ ТИП ОПЕРАЦИИ" frame f-oper.
    v-oper = '1'.
    displ v-oper with frame f-oper.
    update v-oper with frame f-oper.

    if v-oper = "1" then do:

        v-god = year(g-today).
        v-month = month(g-today).
        if v-month = 1 then do:
            v-month = 12.
            v-god = v-god - 1.
        end.
        else v-month = v-month - 1.

        update skip(1)

        v-month label "     Месяц " skip
        v-god label   "       Год " skip(1)
        with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".

        v-dtb = date(v-month, 1, v-god).

        case v-month:
            when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
            when 4 or when 6 or when 9 or when 11 then vi = 30.
            when 2 then do:
                if v-god mod 4 = 0 then vi = 29.
                else vi = 28.
            end.
        end case.
        v-dte = date(v-month, vi, v-god).
    end.

    if v-oper = "2" then do:
        v-dtdoc = g-today.
        v-dtcor = g-today.
        form
            v-dtdoc label "Введите дату документа" skip
            v-dtcor label "Введиту дату, когда была произведена корректировка" skip
            s-empty label "Сформировать пустую МТ" skip
        with overlay centered side-label row 5 width 80 title "УКАЖИТЕ ТИП ОПЕРАЦИИ" frame f-correct.

        displ v-dtdoc v-dtcor s-empty with frame f-correct.
        update v-dtdoc v-dtcor s-empty with frame f-correct.
        displ v-dtdoc v-dtcor s-empty with frame f-correct.
        v-god = year(g-today).
        v-month = month(g-today).
    end.

    if connected ("txb") then disconnect "txb".
    for each txb where txb.consolid = true  and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
        connect value(" -db " + replace(comm.txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
        run vcrep4dat.
        if p-bank <> "all" then v-name = txb.name.
        disconnect "txb".
    end.
    if connected ("txb") then disconnect "txb".
end.

if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
    p-depart = get-dep(g-ofc, g-today).
    find ppoint where ppoint.depart = p-depart no-lock no-error.
    v-depname = ppoint.name.
end.
v-name = "".

def var v-reptype as integer init 1 no-undo.
if p-option = 'rep' then do:
    v-god = year(g-today).
    v-month = month(g-today).
    if v-month = 1 then do:
        v-month = 12.
        v-god = v-god - 1.
    end.
    else v-month = v-month - 1.
    update skip(1)
        v-month label "     Месяц " skip
        v-god label   "       Год " skip(1)
    with side-label centered row 5 title " ВВЕДИТЕ ПЕРИОД ОТЧЕТА : ".
    v-dtb = date(v-month, 1, v-god).
    case v-month:
        when 1 or when 3 or when 5 or when 7 or when 8 or when 10 or when 12 then vi = 31.
        when 4 or when 6 or when 9 or when 11 then vi = 30.
        when 2 then do:
            if v-god mod 4 = 0 then vi = 29.
            else vi = 28.
        end.
    end case.
    v-dte = date(v-month, vi, v-god).

    {r-brfilial.i &proc = " vcrep4dat"}
    if p-bank <> "all" then v-name = txb.name.
    if p-bank = "all" then do:
        DEF BUTTON but-htm LABEL "    Просмотр отчета    ".
        DEF BUTTON but-msg LABEL "  Файл для статистики  ".

        def frame butframe
            skip(1)
            but-htm skip
            but-msg skip(1)
            with centered row 6 title "ВЫБЕРИТЕ ВАРИАНТ ОТЧЕТА:".

        ON CHOOSE OF but-htm, but-msg do:
        case self:label :
            when "Просмотр отчета" then v-reptype = 1.
            when "Файл для статистики" then v-reptype = 2.
        end case.
    end.
    enable all with frame butframe.

    WAIT-FOR CHOOSE OF but-htm, but-msg.
    hide frame butframe no-pause.
    end.

    if avail comm.txb then v-txbbank = comm.txb.bank.
    else v-txbbank = "".

    if v-reptype = 1 then run vcrep4out.p ("vcrep4.htm", "vcrep4-1.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true,v-txbbank).
    else run vcrep4out.p ("vcrep4.htm", "vcrep4-1.htm", false, "", false, "", false,v-txbbank).
end.
else run vcrep4msg.
hide message no-pause.
pause 0.
