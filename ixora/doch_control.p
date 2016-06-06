/* doch_control.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        отправить на контроль  проводки  из doch
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
        07.06.2011 Luiza расширила формат v_codfr до 2 знаков

*/
def input parameter v_codfr as char format "x(2)".
def var c-docid as char format "X(9)" no-undo.
def var c-rdt as date no-undo.
def var c-rtim as int no-undo.
def var c-name as char format "X(20)" no-undo.
def var c-rwho as char no-undo.
def var c-crc as int no-undo.
def var c-acc as char no-undo.
def var c-dam as decimal no-undo.
def var c-cam as decimal no-undo.
DEFINE VARIABLE c-rem AS CHARACTER EXTENT 5 no-undo.
def var c-des as char format "x(25)" no-undo.
def var c-doclgl as int format "999999" no-undo.
def var v-templ as char format "x(7)" no-undo.

def var c-tmpl as char no-undo.
def var c-param as char no-undo.
def var c-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var s-jh like jh.jh no-undo.
def var c-code as int no-undo.
def var c-cods as char no-undo.
def var c-rem1 as char no-undo.
def var c-ja as logi no-undo format "Да/Нет" init no.
def var h-docid as char format "X(9)" no-undo.
define shared var g-ofc like ofc.ofc.
define var v_codfrn as char init " ".

define temp-table dochhelp like doch.

for each doch where trim(doch.codfr) = trim(v_codfr) and doch.sts = "new" and doch.rwho = g-ofc no-lock:
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
        c-cods label "КОД" format "x(50)" skip
        c-rem1 LABEL "Примечан. " format "x(90)" skip
        c-ja label "Отправить на контроль?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem1.
 form
        c-rem1 LABEL "Примечан." format "x(90)" skip
        c-ja label "Отправить на контроль?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem2.

DEFINE FRAME f-doch
     c-docid  c-rdt  c-name format "x(20)" v-templ format "x(7)"
     with overlay row 6  col 1  no-label
     title "НОМ-ДОКУМ. ДАТА-ОПЕР. ИСПОЛНИТЕЛЬ       Шаблон ".

DEFINE FRAME f_docl
    b_docl AT ROW 1 COLUMN 1
        WITH overlay  width 105 NO-BOX.

/*frame for help */
DEFINE QUERY q-help FOR dochhelp, ofc.

DEFINE BROWSE b-help QUERY q-help
       DISPLAY dochhelp.docid label "НОМ-ДОКУМЕН " dochhelp.rdt label "ДАТА-ОПЕР " ofc.name label "ИСПОЛНИТЕЛЬ " format "x(20)" dochhelp.templ label "Шаблон " format "x(7)"
       WITH  10 DOWN .
DEFINE FRAME f-help   b-help  WITH overlay 1 COLUMN SIDE-LABELS row 6 COLUMN 20 width 80 NO-BOX.


/*ON VALUE-CHANGED OF b-help DO:
    c-docid = dochhelp.docid.
END.*/
/*----------*/

on end-error of b-help in frame f-help do:
    hide frame f-help.
end.

on help of c-docid in frame f-doch do:
   find first dochhelp no-lock no-error.
   if available dochhelp then do:
        OPEN QUERY  q-help FOR EACH dochhelp  no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        c-docid = dochhelp.docid.
        hide frame f-help.
        displ c-docid with frame f-doch.
    end.
    else do:
        MESSAGE "НЕТ НОВЫХ ДОКУМЕНТОВ." view-as alert-box.
        c-docid = "".
    end.
end.

repeat:
    clear frame f-doch.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
    c-docid = "".
     update c-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
     if trim(c-docid) <> "" then do:
        find doch where doch.docid = c-docid no-lock no-error.
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
            IF  doch.sts = "acc" then do:
                MESSAGE "ДОКУМЕНТ АКЦЕПТОВАН, МОЖНО ПРОВОДИТЬ." view-as alert-box.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
            IF  doch.sts = "sen" then do:
                MESSAGE "ДОКУМЕНТ УЖЕ ОТПРАВЛЕН НА КОНТРОЛЬ." view-as alert-box.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
             IF  doch.sts = "rej" then do:
                MESSAGE "ОТКАЗАНО В ПРОВОДКЕ." view-as alert-box.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
             IF  doch.sts = "del" then do:
                MESSAGE "ДОКУМЕНТ УДАЛЕН." view-as alert-box.
                hide message.
                hide frame f-doch.
                undo, return.
             end.
             IF  doch.sts = "new" then do:
                c-rdt = doch.rdt.
                c-rwho = doch.rwho.
                c-rtim = doch.rtim.
                v-templ = doch.templ.
                find ofc where ofc.ofc = c-rwho no-lock.
                if available ofc then c-name = ofc.name.
                c-docid = caps(c-docid).
                displ c-docid c-rdt c-name v-templ with frame f-doch.

                OPEN QUERY q_docl FOR EACH docl where docl.docid = c-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
                 c-rem1 = docl.rem[1].
                 c-cods = substrin(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
                 enable all with FRAME f_docl.
                 if substring(docl.cods,1,2) <> "" then do:
                    displ c-cods c-rem1 with  frame f-rem1.
                    c-ja = no.
                    update c-ja with  frame f-rem1.
                  end.
                  else do:
                    displ c-rem1 with  frame f-rem2.
                    c-ja = no.
                    update c-ja with  frame f-rem2.
                  end.

                 if c-ja then do:
                     if c-rwho = g-ofc then do:
                        do transaction:
                            find doch where doch.docid = c-docid EXCLUSIVE-LOCK no-error.
                             /*if locked doch then do:
                                message "ЖДИТЕ ТАБЛИЦА ЗАНЯТА ДРУГИМ ПОЛЬЗОВАТЕЛЕМ.".
                                pause 3.
                                undo, return.
                             end.*/
                             IF AVAILABLE doch then doch.sts = "sen".
                            find current doch no-lock no-error.
                            find first dochhist EXCLUSIVE-LOCK no-error.
                            create dochhist.
                            dochhist.docid = c-docid.
                            dochhist.rdt = today.
                            dochhist.rtim = TIME.
                            dochhist.rwho = g-ofc.
                            dochhist.sts = "sen".
                            find current dochhist no-lock no-error.
                            run doch_hist (c-docid).
                            find dochhelp where dochhelp.docid = c-docid no-lock no-error.
                            if available dochhelp then delete dochhelp.
                            run pr_doch_order(c-docid, c-rdt, c-rtim, c-rwho).
                        end. /*end transac*/
                    end. /* end c-rwho = g-ofc*/
                    else do:
                        MESSAGE "НЕ ВАШ ДОКУМЕНТ." view-as alert-box.
                        hide message.
                    end.
                 end. /*end if c-ja */
                 hide frame f-doch.
                 hide FRAME f_docl.
                hide frame f-rem1.
                hide frame f-rem2.
             end. /*end new*/
         end.
         else do:
            message "ДОКУМЕНТ НЕ НАЙДЕН" view-as alert-box.
            hide message.
            hide frame f-doch.
         end.
     end. /*trim(c-docid)*/
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

