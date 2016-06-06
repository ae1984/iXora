/* doch_del.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        удаление записей из doch еще не отправленных на контроль
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
        18.02.2011 Luiza добавила создание записи в dochhist
        27.04.2011 Luiza добавила возможность удаления всех док-в кроме проведенных(trx)
 * CHANGES

*/

def input parameter v_codfr as char format "x(1)".
def var d-docid as char format "X(9)" no-undo.
def var d-name as char format "X(20)" no-undo.
def var d-rdt as date no-undo.
def var d-rwho as char no-undo.
def var d-crc as int no-undo.
def var d-acc as char no-undo.
def var d-dam as decimal no-undo.
def var d-cam as decimal no-undo.
DEFINE VARIABLE d-rem AS CHARACTER EXTENT 5 no-undo.
def var d-des as char format "x(25)" no-undo.
def var d-doclgl as int format "999999" no-undo.
def var v-templ as char format "x(7)" no-undo.

def var d-tmpl as char no-undo.
def var d-param as char no-undo.
def var d-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var s-jh like jh.jh no-undo.
def var d-code as int no-undo.
def var d-cods as char no-undo.
def var d-rem1 as char no-undo.
def var d-ja as logi no-undo format "Да/Нет" init no.
def var d-rtim as int no-undo.
def var h-docid as char format "X(9)" no-undo.
define shared var g-ofc like ofc.ofc.
define var v_codfrn as char init " ".

define temp-table dochhelp like doch.

for each doch where trim(doch.codfr) = trim(v_codfr) and (doch.sts = "new" or doch.sts = "sen" or doch.sts = "acc" or doch.sts = "rej")
    and doch.rwho = g-ofc no-lock:
    create dochhelp.
    buffer-copy doch to dochhelp.
end.



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
        d-cods label "КОД" format "x(50)" skip
        d-rem1 LABEL "Примечан. " format "x(90)" skip
        d-ja label "Удалить документ?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem1.

 form
        d-rem1 LABEL "Примечан." format "x(90)" skip
        d-ja label "Удалить документ?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem2.

DEFINE FRAME f-doch
     d-docid  d-rdt  d-name  format "x(20)" v-templ format "x(7)"
     with overlay row 6  col 1  no-label
     title "НОМ-ДОКУМ. ДАТА-ОПЕР. ИСПОЛНИТЕЛЬ       Шаблон ".


DEFINE FRAME f_docl
    b_docl AT ROW 1 COLUMN 1
        WITH overlay width 105 NO-BOX.

/*frame for help */
DEFINE QUERY q-help FOR dochhelp, ofc.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY dochhelp.docid label "НОМ-ДОКУМЕН " dochhelp.rdt label "ДАТА-ОПЕР " ofc.name label "ИСПОЛНИТЕЛЬ" format "x(20)" dochhelp.templ label "Шаблон " format "x(7)"
       WITH  10 DOWN .
DEFINE FRAME f-help   b-help  WITH overlay 1 COLUMN SIDE-LABELS row 6 COLUMN 20 width 80 NO-BOX.


on end-error of b-help in frame f-help do:
    hide frame f-help.
end.

on help of d-docid in frame f-doch do:
   find first dochhelp no-lock no-error.
   if available dochhelp then do:
        OPEN QUERY  q-help FOR EACH dochhelp no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        d-docid = dochhelp.docid.
        hide frame f-help.
        displ d-docid with frame f-doch.
    end.
    else do:
        MESSAGE "НЕТ НОВЫХ ДОКУМЕНТОВ." view-as alert-box.
        d-docid = "".
    end.
end.

repeat:
    clear frame f-doch.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
    d-docid = "".
     update d-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
     if trim(d-docid) <> "" then do:
        find doch where doch.docid = d-docid no-lock no-error.
        if available doch then do:
            if  doch.codfr <> v_codfr then do:
                find first codfr where trim(codfr.codfr) = "doch" and  trim(codfr.code) = trim(doch.codfr) no-lock.
                if available codfr then v_codfrn = codfr.name[1].
                MESSAGE "ДОКУМЕНТ ОТНОСИТСЯ  К ТИПУ: " + v_codfrn.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
            IF  doch.sts = "trx" then do:
                MESSAGE "ДОКУМЕНТ УЖЕ ПРОВЕДЕН, НОМЕР ПРОВОДКИ: " + string(doch.jh) view-as alert-box.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
           /* IF  doch.sts = "acc" then do:
                MESSAGE "ДОКУМЕНТ АКЦЕПТОВАН, МОЖНО ПРОВОДИТЬ."view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
            IF  doch.sts = "sen" then do:
                MESSAGE "ДОКУМЕНТ УЖЕ ОТПРАВЛЕН НА КОНТРОЛЬ." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
             IF  doch.sts = "rej" then do:
                MESSAGE "ОТКАЗАНО В ПРОВОДКЕ." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
             end. */
             IF  doch.sts = "del" then do:
                MESSAGE "ДОКУМЕНТ УДАЛЕН." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
             IF  doch.sts = "new" or doch.sts = "sen" or doch.sts = "acc" or doch.sts = "rej" then do:
                d-rdt = doch.rdt.
                d-rwho = doch.rwho.
                v-templ = doch.templ.
                find ofc where ofc.ofc = d-rwho no-lock.
                if available ofc then d-name = ofc.name.
                d-docid = caps(d-docid).
                displ d-docid d-rdt d-name v-templ with frame f-doch.

                OPEN QUERY q_docl FOR EACH docl where docl.docid = d-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
                 d-rem1 = docl.rem[1].
                 d-cods = substrin(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
                 enable all with FRAME f_docl.
                 if substring(docl.cods,1,2) <> "" then do:
                    displ d-cods d-rem1 with  frame f-rem1.
                    d-ja = no.
                    update d-ja with  frame f-rem1.
                  end.
                  else do:
                    displ d-rem1 with  frame f-rem2.
                    d-ja = no.
                    update d-ja with  frame f-rem2.
                  end.
                 if d-ja then do:
                    if d-rwho = g-ofc then do:
                        do transaction:
                            find doch where doch.docid = d-docid EXCLUSIVE-LOCK no-error.
                             IF AVAILABLE doch then doch.sts = "del".
                            find first doch no-lock no-error.
                           /* find first dochhist EXCLUSIVE-LOCK no-error.
                            create dochhist.
                            dochhist.docid = d-docid.
                            dochhist.rdt = today.
                            dochhist.rtim = TIME.
                            dochhist.rwho = g-ofc.
                            dochhist.sts = "del".
                            find current dochhist no-lock no-error.*/
                            run doch_hist (d-docid).
                            find dochhelp where dochhelp.docid = d-docid no-lock no-error.
                            if available dochhelp then delete dochhelp.
                        end. /*end transac*/
                    end. /* d-rwho = g-ofc */
                    else do:
                        MESSAGE "НЕ ВАШ ДОКУМЕНТ." view-as alert-box information.
                        hide message.
                    end.
                 end. /*end if d-ja */
                 hide frame f-doch.
                 hide FRAME f_docl.
                hide frame f-rem1.
                hide frame f-rem2.
             end. /*end new*/
         end.
         else do:
            message "ДОКУМЕНТ НЕ НАЙДЕН" view-as alert-box information.
            hide message.
            hide frame f-doch.
         end.
     end. /*trim(d-docid)*/
    else do:
        message "ДОКУМЕНТ НЕ НАЙДЕН, F2 -ПОМОЩЬ." view-as alert-box information.
        hide message.
        hide frame f-doch.
    end.
end. /*end repeat*/
 hide frame f-doch.
 hide FRAME f_docl.
hide frame f-rem1.
hide frame f-rem2.

