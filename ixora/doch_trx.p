/* doch_trx.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        формирование проводок в jh для акцептованных записей в doch
 * BASES
        BANK COMM
 * RUN

 * CALLER

 * SCRIPT

 * INHERIT

 * MENU
        8-9
 * AUTHOR
        01.12.2010 Luiza
        18.02.2011 Luiza добавила создание записи в dochhist
        14.04.2011 Luiza добавила изменение статуса на 6 jh и jl.
        06.06.2011 Luiza добавила возможность выбора кода кассплана для кассовых проводок
        07.06.2011 Luiza расширила формат v_codfr до 2 знаков
        18.06.2012 damir - добавил printvouord.p,keyord.i.
 * CHANGES

*/

{keyord.i}

def input parameter v_codfr as char format "x(2)".
def var a-docid as char format "X(9)" no-undo.
def var a-name as char format "X(20)" no-undo.
def var a-rdt as date no-undo.
def var a-rwho as char no-undo.
def var a-rtim as int no-undo.
def var a-crc as int no-undo.
def var a-acc as char no-undo.
def var a-dam as decimal no-undo.
def var a-cam as decimal no-undo.
DEFINE VARIABLE a-rem AS CHARACTER EXTENT 5 no-undo.
def var a-des as char format "x(25)" no-undo.
def var a-doclgl as int format "999999" no-undo.
def var adel as char no-undo.
def var acode as int no-undo.
def var ades as char no-undo.
def var a-tmpl as char no-undo.
def var a-param as char no-undo.
def var a-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var v-jh like jh.jh no-undo.
def var a-code as int no-undo.
def var a-cods as char no-undo.
def var a-rem1 as char no-undo.
def var a-ja as logi no-undo format "Да/Нет" init no.
def var h-docid as char format "X(9)" no-undo.
define shared var g-ofc like ofc.ofc.
def var v-templ as char format "x(7)" no-undo.
define var v_codfrn as char init " ".
define variable v-cash   as logical no-undo.
def var rcode as int no-undo.
def var rdes as char no-undo.
def new shared var s-jh like jh.jh.


define temp-table dochhelp like doch.

for each doch where trim(doch.codfr) = trim(v_codfr) and doch.sts = "acc" and doch.rwho = g-ofc no-lock:
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
        a-cods label "КОД" format "x(50)" skip
        a-rem1 LABEL "Примечан. " format "x(90)" skip
        a-ja label "Формировать проводку?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem1.

 form
        a-rem1 LABEL "Примечан." format "x(90)" skip
        a-ja label "Формировать проводку?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem2.

DEFINE FRAME f-doch
     a-docid  a-rdt  a-name format "x(20)" v-templ format "x(7)"
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

on help of a-docid in frame f-doch do:
   find first dochhelp no-lock no-error.
   if available dochhelp then do:
        OPEN QUERY  q-help FOR EACH dochhelp no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        a-docid = dochhelp.docid.
        hide frame f-help.
        displ a-docid with frame f-doch.
    end.
    else do:
        MESSAGE "НЕТ ДОКУМЕНТОВ ДЛЯ ТРАНЗАКЦИЙ." view-as alert-box.
        a-docid = "".
    end.
end.

repeat:
    clear frame f-doch.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
    a-docid = "".
     update a-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
     if trim(a-docid) <> "" then do:
        find doch where doch.docid = a-docid no-lock no-error.
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
                MESSAGE "ДОКУМЕНТ УЖЕ ПРОВЕДЕН, НОМЕР ПРОВОДКИ: " + string(doch.jh) view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
            end.
            IF  doch.sts = "new" then do:
                MESSAGE "ДОКУМЕНТ НЕ ОТПРАВЛЕН НА КОНТРОЛЬ." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
            end.
            IF  doch.sts = "sen" then do:
                MESSAGE "ДОКУМЕНТ ЕЩЕ НЕ АКЦЕПТОВАН." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
            end.
            IF  doch.sts = "rej" then do:
                MESSAGE "ОТКАЗАНО В ПРОВОДКЕ." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
            end.
            IF  doch.sts = "del" then do:
                MESSAGE "ДОКУМЕНТ УДАЛЕН." view-as alert-box information.
                hide message.
                hide frame f-doch.
                undo, return.
            end.
             IF  doch.sts = "acc" then do:
                a-rdt = doch.rdt.
                a-rwho = doch.rwho.
                a-rtim = doch.rtim.
                v-templ = doch.templ.
                find ofc where ofc.ofc = a-rwho no-lock.
                if available ofc then a-name = ofc.name.
                a-docid = caps(a-docid).
                displ a-docid a-rdt a-name v-templ with frame f-doch.

                OPEN QUERY q_docl FOR EACH docl where docl.docid = a-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
                 a-rem1 = docl.rem[1].
                 a-cods = substrin(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
                 enable all with FRAME f_docl.
                 if substring(docl.cods,1,2) <> "" then do:
                    displ a-cods a-rem1 with  frame f-rem1.
                    a-ja = no.
                    update a-ja with  frame f-rem1.
                  end.
                  else do:
                    displ a-rem1 with  frame f-rem2.
                    a-ja = no.
                    update a-ja with  frame f-rem2.
                  end.
                 if a-ja then do:
                    if a-rwho = g-ofc then do:
                         do transaction:
                                find doch where doch.docid = a-docid no-lock.
                            IF AVAILABLE doch then do:
                                a-tmpl = doch.templ.
                                adel = doch.delim.
                                a-param = doch.param1.
                                a-dt = doch.acc.
                                v-jh = 0.
                                run trxgen (a-tmpl, adel, a-param, "ARP", a-docid, output acode, output ades, input-output v-jh).
                                if acode ne 0 then do:
                                    a-ja = no.
                                    message ades.
                                    pause 1000.
                                    undo.
                                    next.
                                end.
                                s-jh = v-jh.
                                find doch where doch.docid = a-docid  no-error.
                                if available doch then do:
                                    doch.jh = v-jh.
                                    doch.sts = "trx".
                                end.
                                find current doch NO-LOCK.
                                run doch_hist (a-docid).
                                /* проставляем статус 6 в jh jl*/

                                find sysc where sysc.sysc eq "CASHGL" no-lock no-error.
                                v-cash = false.
                                for each jl where jl.jh eq v-jh no-lock:
                                    if jl.gl eq sysc.inval then v-cash = true.
                                end.

                                if v-cash then do:
                                    run trxsts (input v-jh, input 5, output rcode, output rdes).
                                    if rcode ne 0 then do:
                                        message rdes.
                                        undo, return.
                                    end.
                                    pause 0.
        hide all no-pause.
                                    run x0-cont1.
        hide all no-pause.

                                    run chgsts("ARP", a-docid, "cas").
                                    find first jh where jh.jh = v-jh EXCLUSIVE-LOCK no-error.
                                    if available jh then do:
                                        jh.party = a-docid.
                                    end.
                                    find first jh NO-LOCK.
                                end.
                                else do:
                                    find first jh where jh.jh = v-jh EXCLUSIVE-LOCK no-error.
                                    if available jh then do:
                                        jh.party = a-docid.
                                        jh.sts = 6.
                                    end.
                                    find first jh NO-LOCK.
                                    for each jl where jl.jh = v-jh  EXCLUSIVE-LOCK.
                                        jl.sts = 6.
                                    end.
                                    find first jl no-lock.
                                 end.
                                /*---------------------------------------*/
                                MESSAGE "ДОКУМЕНТ СФОРМИРОВАН, НОМЕР ПРОВОДКИ: " + string(v-jh) view-as alert-box information.
                                hide message no-pause.
                                hide frame f-doch.
                                hide FRAME f_docl.
                                hide frame f-rem1.
                                hide frame f-rem2.
                            end. /*end if do---*/
                            find dochhelp where dochhelp.docid = a-docid no-lock no-error.
                            if available dochhelp then delete dochhelp.
                            if v-noord = no then run  vou_bank(2).
                            else run printvouord(2).
                        end. /*end transac*/
                    return.
                end. /*a-rwho = g-ofc  */
                else do:
                    MESSAGE "НЕ ВАШ ДОКУМЕНТ." view-as alert-box information.
                    hide message no-pause.
                end.
             end. /*end if a-ja */
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
     end. /*trim(a-docid)*/
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

