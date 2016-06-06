/* doch_acc.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        Акцептование проводок для таблицы doch
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU

 * AUTHOR
        30.12.2010 Luiza
        18.02.2011 Luiza добавила создание записи в dochhist
        22.02.2011 Изменили проверку формирования списка контролеров
        26.03.2012 damir  - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
        11.04.2012 damir  - добавил signdocum.p.
        10.05.2012 damir  - перекомпиляция.
 * CHANGES

*/


{mainhead.i}
{keysign.i}

def var t-docid as char format "X(9)" no-undo.
def var t-name as char format "X(20)" no-undo.
def var t-rdt as date no-undo.
def var t-rwho as char no-undo.
def var t-crc as int no-undo.
def var t-acc as char no-undo.
def var t-dam as decimal no-undo.
def var t-cam as decimal no-undo.
DEFINE VARIABLE t-rem AS CHARACTER EXTENT 5 no-undo.
def var t-des as char format "x(25)" no-undo.
def var t-doclgl as int format "999999" no-undo.
def var v-templ as char format "x(7)" no-undo. /*шаблон */

def var t-tmpl as char no-undo.
def var t-param as char no-undo.
def var t-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var s-jh like jh.jh no-undo.
def var t-code as int no-undo.
def var t-cods as char no-undo.
def var t-rem1 as char no-undo.
def var t-rem2 as char no-undo.
def var t-rem3 as char no-undo.
def var t-rem4 as char no-undo.
def var t-rem5 as char no-undo.
def var t-ja as logi no-undo format "Да/Нет" init yes.
def var t-rtim as int no-undo.
def var h-docid as char format "X(9)" no-undo.
def var ofc_contr as char no-undo init " ".
/*define shared var g-ofc like ofc.ofc.*/

for each trxdel_control_ofc no-lock.
    if lookup(g-ofc,trxdel_control_ofc.control_ofc) > 0 then do:
        ofc_contr = ofc_contr + "," +  trim(trxdel_control_ofc.dep).
    end.
end.

define temp-table dochhelp like doch.

for each doch where doch.sts = "sen" no-lock:
    find first ofc where ofc.ofc = doch.rwho no-lock no-error.
    if avail ofc then do:
        find first trxdel_control_ofc where trxdel_control_ofc.dep = ofc.titcd no-lock no-error.
        if avail trxdel_control_ofc then do:
            if lookup(g-ofc,trxdel_control_ofc.control_ofc) > 0 then do:
                create dochhelp.
                buffer-copy doch to dochhelp.
            end.
        end.
    end.
end.


define button b1 label "АКЦЕПТОВАТЬ".
define button b2 label "ОТКЛОНИТЬ".
define button b3 label "СЛЕД.ДОКУМЕНТ".
define button b7 label "ВЫХОД".

define frame a2
    b1 b2 b3 /*b4 b5 b6*/ b7
    with side-labels row 4 column 5 no-box.

DEFINE QUERY q_docl FOR docl, gl.

DEFINE BROWSE b_docl QUERY q_docl
    DISPLAY docl.gl label "Г/К   " format "999999"
                gl.sname label "НАЗВАНИЕ СЧЕТА" format "x(20)"
                docl.crc label "ВАЛ" format "9"
                docl.acc label "    СУБСЧЕТ" format "x(20)"
                docl.dam label "ДЕБЕТ" format "zzz,zzz,zzz,zzz,zz9.99"
                docl.cam label  "КРЕДИТ" format "zzz,zzz,zzz,zzz,zz9.99"
                WITH 18 DOWN.

 form
        t-cods label "КОД" format "x(50)" skip
        t-rem1 LABEL "Примечан." format "x(90)" skip
        t-rem2 LABEL "         " format "x(90)" skip
        t-rem3 LABEL "         " format "x(90)" skip
        t-rem4 LABEL "         " format "x(90)" skip
        t-rem5 LABEL "         " format "x(90)" skip
        WITH  overlay row 31 width 105 no-box side-label frame f-rem1.

 form
        t-rem1 LABEL "Примечан." format "x(90)" skip
        t-rem2 LABEL "         " format "x(90)" skip
        t-rem3 LABEL "         " format "x(90)" skip
        t-rem4 LABEL "         " format "x(90)" skip
        t-rem5 LABEL "         " format "x(90)" skip
        WITH  overlay row 31 width 105 no-box side-label frame f-rem2.

DEFINE FRAME f-doch
     t-docid validate(t-docid <> '' and can-find(dochhelp where dochhelp.docid = t-docid no-lock),"НЕТ ДОКУМЕНТА С ТАКИМ НОМЕРОМ НА КОНТРОЛЕ!")
     t-rdt  t-name format "x(20)" v-templ format "x(7)"
     with overlay row 6  col 1  no-label
     title "НОМ-ДОКУМ. ДАТА-ОПЕР. ИСПОЛНИТЕЛЬ       Шаблон ".


DEFINE FRAME f_docl
    b_docl AT ROW 1 COLUMN 1
        WITH overlay width 105 NO-BOX.

/*frame for help */
DEFINE QUERY q-help FOR dochhelp, ofc.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY dochhelp.docid label "НОМ-ДОКУМЕН " dochhelp.rdt label "ДАТА-ОПЕР " ofc.name label "ИСПОЛНИТЕЛЬ " dochhelp.templ label "Шаблон " format "x(7)"
       WITH 10 DOWN.
DEFINE FRAME f-help b-help  WITH overlay 1 COLUMN SIDE-LABELS row 6 COLUMN 20 width 80 NO-BOX.


on end-error of b-help in frame f-help do:
    hide frame f-help.
end.
on end-error of b1, b2, b3 in frame a2 do:
    wait-for return of frame a2
    FOCUS b7 IN FRAME a2.
end.

on end-error of b7 in frame a2 do:
 t-ja = no.
end.

on help of t-docid in frame f-doch do:
   find first dochhelp no-lock no-error.
   if available dochhelp then do:
        OPEN QUERY  q-help FOR EACH dochhelp no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        t-docid = dochhelp.docid.
        hide frame f-help.
        displ t-docid with frame f-doch.
    end.
    else do:
        MESSAGE "НЕТ НОВЫХ ДОКУМЕНТОВ ДЛЯ КОНТРОЛЯ" view-as alert-box.
        t-docid = "".
    end.
end.

on choose of b1 in frame a2 do: /* кнопка акцептовать*/
    do transaction:
        find doch where doch.docid = t-docid EXCLUSIVE-LOCK no-error.
        IF AVAILABLE doch and doch.rwho <> g-ofc then do:
            doch.sts = "acc".
            find current doch no-lock no-error.
            run doch_hist (t-docid).
            find dochhelp where dochhelp.docid = t-docid no-lock no-error.
            if available dochhelp then delete dochhelp.
            MESSAGE "ДОКУМЕНТ АКЦЕПТОВАН." view-as alert-box information.
        end.
        if v-transsign = yes then run signdocum(input "",input t-docid).
    end. /*end transac*/
end. /*конец кнопки акцептовать*/

on choose of b2 in frame a2 do: /* кнопка отказать*/
    do transaction:
        find doch where doch.docid = t-docid EXCLUSIVE-LOCK no-error no-wait.
        if locked doch then do:
            message "ЖДИТЕ ТАБЛИЦА ЗАНЯТА ДРУГИМ ПОЛЬЗОВАТЕЛЕМ." view-as alert-box information.
            pause 3.
            undo, return.
        end.
        IF AVAILABLE doch and doch.rwho <> g-ofc then do:
            doch.sts = "rej".
            find doch where doch.docid = t-docid no-lock no-error.
            run doch_hist (t-docid).
            find dochhelp where dochhelp.docid = t-docid no-lock no-error.
            if available dochhelp then delete dochhelp.
            MESSAGE "ДОКУМЕНТ ОТКЛОНЕН." view-as alert-box information.
         end.
    end. /*end transac*/
end. /*конец кнопки отказать*/

on choose of b7 in frame a2 do:
    t-ja = no.
end. /*конец кнопки следующий*/

repeat:
    if t-ja = no then leave.
    enable all with frame a2.
    clear frame f-doch.
    hide message.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
    t-docid = "".
    update t-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
    find first doch where doch.docid = t-docid no-lock no-error.
    if avail doch then do:
        t-rdt = doch.rdt.
        t-rwho = doch.rwho.
        find ofc where ofc.ofc = t-rwho no-lock.
        if available ofc then t-name = ofc.name.
        t-docid = caps(t-docid).
        displ t-docid t-rdt t-name with frame f-doch.

        OPEN QUERY q_docl FOR EACH docl where docl.docid = t-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
        t-rem1 = docl.rem[1].
        t-rem2 = docl.rem[2].
        t-rem3 = docl.rem[3].
        t-rem4 = docl.rem[4].
        t-rem5 = docl.rem[5].
        t-cods = substrin(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
        enable all with FRAME f_docl.
        if substring(docl.cods,1,2) <> "" then displ t-cods t-rem1 t-rem2 t-rem3 t-rem4 t-rem5 with  frame f-rem1.
        else displ t-rem1 t-rem2 t-rem3 t-rem4 t-rem5 with  frame f-rem2.
        wait-for choose of b7 in frame a2 or choose of b3 in frame a2 or choose of b1 in frame a2 or choose of b2 in frame a2 focus b3.
    end.
    else message "ОШИБКА! ДОКУМЕНТ НЕ НАЙДЕН!" view-as alert-box error.
    hide frame f-doch.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
end. /*end repeat*/

hide frame a2.
hide frame f-doch.
hide FRAME f_docl.
hide frame f-rem1.
hide frame f-rem2.

