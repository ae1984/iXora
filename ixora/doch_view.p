/* doch_view.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        просмотр записей  проводок в doch
 * BASES
        BANK
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
       8-9
 * AUTHOR
        01.12.2010 Luiza
        07.06.2011 Luiza расширила формат v_codfr до 2 знаков
 * CHANGES

*/

def input parameter v_codfr as char format "x(2)".
def var v-docid as char format "X(9)" no-undo.
def var v-name as char format "X(20)" no-undo.
def var v-rdt as date no-undo.
def var v-rwho as char no-undo.
def var v-crc as int no-undo.
def var v-acc as char no-undo.
def var v-dam as decimal no-undo.
def var v-cam as decimal no-undo.
DEFINE VARIABLE v-rem AS CHARACTER EXTENT 5 no-undo.
def var v-des as char format "x(25)" no-undo.
def var v-doclgl as int format "999999" no-undo.

def var v-tmpl as char no-undo.
def var v-param as char no-undo.
def var v-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var s-jh like jh.jh no-undo.
def var v-code as int no-undo.
def var v-cods as char no-undo.
def var v-rem1 as char no-undo.
def var v-ja as logi no-undo format "Да/Нет" init no.
def var v-rtim as int no-undo.
def var h-docid as char format "X(9)" no-undo.
def var v-sts as char format "x(3)" no-undo.
def var v-trx as int format "999999" no-undo.
def var v-templ as char format "x(7)" no-undo.
def var beg_date as date no-undo init today.
def var end_date as date no-undo init today.
def var v-exit as logi no-undo format "Да/Нет" init no.
define shared var g-ofc like ofc.ofc.
define var v_codfrn as char init " ".

Form
     beg_date
     end_date
     with overlay row 5  col 80 no-label
     title "   ПЕРИОД   " width 20 FRAME f-date.

on help of beg_date, end_date in frame f-date do:
end.
on end-error of beg_date, end_date in frame f-date do:
    v-exit = yes.
end.
repeat:
    update beg_date  end_date with frame f-date.
    define temp-table dochhelp like doch.
    for each doch where trim(doch.codfr) = trim(v_codfr) and doch.rwho = g-ofc and doch.rdt >= beg_date and doch.rdt <= end_date no-lock:
        create dochhelp.
        buffer-copy doch to dochhelp.
    end.
    leave.
end.
if v-exit then hide frame f-date.
  else do:
    DEFINE QUERY q_docl FOR docl, gl.

    DEFINE BROWSE b_docl QUERY q_docl
        DISPLAY docl.gl label "Г/К   " format "999999"
                    gl.sname label "НАЗВАНИЕ СЧЕТА" format "x(20)"
                    docl.crc label "ВАЛ" format "9"
                    docl.acc label "    СУБСЧЕТ" format "x(20)"
                    docl.dam label "ДЕБЕТ" format "zzz,zzz,zzz,zzz,zz9.99"
                    docl.cam label  "КРЕДИТ" format "zzz,zzz,zzz,zzz,zz9.99"
                    WITH 22 DOWN.

     form
            v-cods label "КОД" format "x(50)" skip
            v-rem1 LABEL "Примечан." format "x(90)" skip
            WITH  overlay row 35 width 105 no-box side-label frame f-rem1.
     form
            v-rem1 LABEL "Примечан." format "x(90)" skip
            WITH  overlay row 35 width 105 no-box side-label frame f-rem2.

    DEFINE FRAME f-doch
         v-docid format "x(9)" v-rdt  v-name format "x(25)" v-sts format "x(3)" v-trx format "zzzzzz9" v-templ format "x(7)"
         with overlay row 6  col 1  no-label
         title "НОМ-ДОКУМ. ДАТА-ОПЕР. ИСПОЛНИТЕЛЬ        СТАТУС НОМ-ПРОВОД Шаблон".


    DEFINE FRAME f_docl
        b_docl AT ROW 1 COLUMN 1
            WITH overlay width 105 NO-BOX.

    /*frame for help */
    DEFINE QUERY q-help FOR dochhelp, ofc.

    DEFINE BROWSE b-help QUERY q-help
           DISPLAY dochhelp.docid label "НОМ-ДОКУМ" dochhelp.rdt label "ДАТА-ОПЕР " trim(ofc.name) label "ИСПОЛНИТЕЛЬ " format "x(23)" dochhelp.sts
           label "СТАТУС" string(dochhelp.jh) label "НОМ-ПРОВОД" format "x(6)" dochhelp.templ label "Шаблон " format "x(7)"
           WITH  10 DOWN .
    DEFINE FRAME f-help   b-help  WITH overlay 1 COLUMN SIDE-LABELS row 7 COLUMN 20 width 80 NO-BOX.


    /*ON VALUE-CHANGED OF b-help DO:
        v-docid = dochhelp.docid.
    END.*/
    /*----------*/

    on end-error of b-help in frame f-help do:
        hide frame f-help.
    end.

    on help of v-docid in frame f-doch do:
       find first dochhelp no-lock no-error.
       if available dochhelp then do:
            OPEN QUERY  q-help FOR EACH dochhelp no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
            ENABLE ALL WITH FRAME f-help.
            wait-for return of frame f-help
            FOCUS b-help IN FRAME f-help.
            v-docid = dochhelp.docid.
            hide frame f-help.
            displ v-docid with frame f-doch.
        end.
        else do:
            MESSAGE "НЕТ ДОКУМЕНТОВ ДЛЯ ПРОСМОТРА, ПРОВЕРЬТЕ ПЕРИОД ДАТЫ ДЛЯ ПРОСМОТРА ДОКУМЕНТОВ." view-as alert-box.
            v-docid = "".
        end.
    end.

    repeat:
        clear frame f-doch.
        hide FRAME f_docl.
        hide frame f-rem1.
        hide frame f-rem2.
        v-docid = "".
         update v-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
         if trim(v-docid) <> "" then do:
            find doch where doch.docid = v-docid no-lock no-error.
            if available doch then do:
                if  doch.codfr <> v_codfr then do:
                    find first codfr where trim(codfr.codfr) = "doch" and  trim(codfr.code) = trim(doch.codfr) no-lock.
                    if available codfr then v_codfrn = codfr.name[1].
                    MESSAGE "ДОКУМЕНТ ОТНОСИТСЯ  К ТИПУ: " + v_codfrn.
                    hide message.
                    hide frame f-doch.
                    undo, return.
                 end.
                    v-rdt = doch.rdt.
                    v-trx = doch.jh.
                    v-rwho = doch.rwho.
                    v-templ = doch.templ.
                    find ofc where ofc.ofc = v-rwho no-lock.
                    if available ofc then v-name = ofc.name.
                    v-docid = caps(v-docid).
                    v-sts = doch.sts.
                    displ v-docid v-rdt v-name v-sts v-trx v-templ with frame f-doch.

                    OPEN QUERY q_docl FOR EACH docl where docl.docid = v-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
                     v-rem1 = docl.rem[1].
                     v-cods = substring(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
                     enable all with FRAME f_docl.
                     if substring(docl.cods,1,2) <> "" then displ v-cods  v-rem1 with  frame f-rem1.
                     else displ v-rem1 with  frame f-rem2.
                     hide frame f-doch.
                     hide FRAME f_docl.
                     hide frame f-rem1.
                     hide frame f-rem2.
             end.
             else do:
                message "ДОКУМЕНТ НЕ НАЙДЕН" view-as alert-box information.
                hide message.
                hide frame f-doch.
             end.
         end. /*trim(v-docid)*/
        else do:
            message "ДОКУМЕНТ НЕ НАЙДЕН, F2 -ПОМОЩЬ." view-as alert-box information.
            hide message.
            hide frame f-doch.
        end.
    end. /*end repeat*/
     hide frame f-date.
     hide frame f-doch.
     hide FRAME f_docl.
     hide frame f-rem1.
     hide frame f-rem2.
end. /*end else for v-exit*/
