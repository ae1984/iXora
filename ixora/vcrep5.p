/* vcrep5.p
 * MODULE
        Валютный контроль
 * DESCRIPTION
        Приложение 5 - Информация по паспортам сделок и дополнительным листам к паспортам сделок (МТ111 для НБ)
 * RUN

 * CALLER
        vcrepa5.p, vcrepp5.p, vcrepk5.p
 * SCRIPT

 * INHERIT

 * MENU

 * BASES
         BANK COMM

 * AUTHOR
        20.08.2008 galina
 * CHANGES
         05.09.2008 galina - добавила поле bankokpo во временную таблицу
                             если выбрали добавление информации по паспорту сделки, то не производить поиск
         18/11/2008 galina - добавила поле repdate
         08/10/2010 galina - добавила примечание
         18/11/2010 aigul - сделала отчет по филилама на ЦО
         08.04.2011 damir - новые переменные во временной
         28.04.2011 damir - поставлены ключи. процедура chbin.i
         08.09.2011 damir - В режиме 2) Изменение ранее направленной инфо добавил:
                            1) Дата регистрации/закрытия УНК
                            2) Введите дату, когда была произведена корректировка.
                            3) Добавил входной параметр v-oper при вызове vcrep5dat.p. Добавлены поля field - corrinfo, newval1, newval2,
                            valplnew.
         30.09.2011 damir - добавил okpoprev в  temp-table t-ps.
         06.12.2011 damir - убрал chbin.i
         29.06.2012 damir - field oper_type,avail txb.
         13.08.2013 damir - Внедрено Т.З. № 1559,1308.
         09.10.2013 damir - Т.З. № 1670.
          */
{vc.i}
{global.i}
{comm-txb.i}
{vcshared5.i "new"}

def input parameter p-bank   as char.
def input parameter p-depart as integer.
def input parameter p-option as char.

def var v-name      as char no-undo.
def var v-depname   as char no-undo.
def var v-txbbank   as char.

s-vcourbank = comm-txb().
v-option = p-option.

if p-option = 'rep' then do:
    v-dt = g-today.
    form
        skip(1)
        v-dt label " Дата регистрации/закрытия УНК" format "99/99/9999" skip(1)
    with centered side-label row 5 title "УКАЖИТЕ ДАТУ ОТЧЕТА" frame f-dt.
    update v-dt with frame f-dt.
    displ v-dt with frame f-dt.
    v-dte = v-dt.
end.
if p-option = 'msg' then do:
    v-oper = '1'.
    form
        skip(1)
        v-oper label " 1) Добавление информации  2) Изменение инфо-ии " format '9' validate(index("12", v-oper) > 0, "Неверный тип операции !") skip (1)
    with centered side-label row 5 width 80 title "УКАЖИТЕ ТИП ОПЕРАЦИИ" frame f-oper.
    update v-oper with frame f-oper.
    displ v-oper with frame f-oper.
    pause 0.
    if v-oper = '1' then do:
        v-dt = g-today.
        v-dte = g-today.
        form
            skip(1)
            v-dt label "Начало отчетного периода " format "99/99/9999" skip(1)
            v-dte label "Конец отчетного периода " format "99/99/9999" skip(1)
        with centered side-label row 5 width 80 title "УКАЖИТЕ ДАТУ ОТЧЕТА" frame f-dt1.
        update v-dt with frame f-dt1.
        displ v-dt with frame f-dt1.
        update v-dte with frame f-dt1.
        displ v-dte with frame f-dt1.
    end.
    if v-oper = '2' then do:
        v-dtcorr = g-today.
        v-dtps = g-today.
        form
            skip(1)
            v-dtps label "Дата регистрации УНК" format "99/99/9999" skip
            v-dtcorr label "Введите дату, когда была произведена корректировка" format "99/99/9999" skip
            s-empty label "Сформировать пустую МТ" skip
        with centered side-label row 5 width 80 title "УКАЖИТЕ ДАТЫ" frame f-dt2.
        update v-dtps v-dtcorr s-empty with frame f-dt2.
        displ v-dtps v-dtcorr s-empty with frame f-dt2.
    end.
end.
if p-bank = "all" then p-depart = 0.

{get-dep.i}
if p-depart <> 0 then do:
    p-depart = get-dep(g-ofc, g-today).
    find ppoint where ppoint.depart = p-depart no-lock no-error.
    v-depname = ppoint.name.
end.
v-name = "".

if p-option = "msg" then do:
    for each txb where txb.consolid = true  and (p-bank = "all" or (txb.bank = s-vcourbank)) no-lock:
        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(txb.path,'/data/','/data/b') +  " -ld txb -U " + txb.login + " -P " + txb.password).
        run vcrep5dat.
        if p-bank <> "all" then v-name = txb.name.
    end.
    disconnect "txb".
end.
if p-option = "rep" then do:
    {r-brfilial.i &proc = "vcrep5dat"}
    if p-bank <> "all" and avail txb then v-name = txb.name.
end.

def var v-reptype as integer init 1 no-undo.
if p-option = 'rep' then do:
    if avail txb then v-txbbank = txb.bank.
    else v-txbbank = "".
    run vcrep5out ("vcrep5.htm", (p-bank <> "all"), v-name, (p-depart <> 0), v-depname, true, v-txbbank).
end.
else run vcmsg111out.

