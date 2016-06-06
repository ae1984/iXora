/* doch_order.p
 * MODULE
        Шаблоны видов операций
 * DESCRIPTION
        печать ордера для контроля в doch
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
        22.02.2011 Luiza добавила передачу параметра времени при печати ордера
        07.06.2011 Luiza расширила формат v_codfr до 2 знаков
 * CHANGES

*/

def input parameter v_codfr as char format "x(2)".
def var p-docid as char format "X(9)" no-undo.
def var p-name as char format "X(20)" no-undo.
def var p-rdt as date no-undo.
def var p-rwho as char no-undo.
def var p-crc as int no-undo.
def var p-acc as char no-undo.
def var p-dam as decimal no-undo.
def var p-cam as decimal no-undo.
DEFINE VARIABLE p-rem AS CHARACTER EXTENT 5 no-undo.
def var p-des as char format "x(25)" no-undo.
def var p-doclgl as int format "999999" no-undo.
def var v-templ as char format "x(7)" no-undo.

def var p-tmpl as char no-undo.
def var p-param as char no-undo.
def var p-dt as char  no-undo format "x(20)". /* Дт коррсчет or счет карточка ARP*/
def new shared var s-jh like jh.jh no-undo.
def var p-code as int no-undo.
def var p-cods as char no-undo.
def var p-rem1 as char no-undo.
def var p-ja as logi no-undo format "Да/Нет" init no.
def var p-rtim as int no-undo.
def var h-docid as char format "X(9)" no-undo.
define shared var g-ofc like ofc.ofc.
define var v_codfrn as char init " ".

define temp-table dochhelp like doch.

for each doch where trim(doch.codfr) = trim(v_codfr) and doch.sts = "sen" and doch.rwho = g-ofc no-lock:
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
        p-cods label "КОД" format "x(50)" skip
        p-rem1 LABEL "Примечан. " format "x(90)" skip
        p-ja label "Распечатать ордер?.............."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem1.

 form
        p-rem1 LABEL "Примечан." format "x(90)" skip
        p-ja label "Распечатать ордер?..........."   skip
        WITH  overlay row 35 width 105 no-box side-label frame f-rem2.

DEFINE FRAME f-doch
     p-docid  p-rdt  p-name format "x(20)" v-templ format "x(7)"
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


/*ON VALUE-CHANGED OF b-help DO:
    p-docid = dochhelp.docid.
END.*/
/*----------*/

on end-error of b-help in frame f-help do:
    hide frame f-help.
end.

on help of p-docid in frame f-doch do:
   find first dochhelp no-lock no-error.
   if available dochhelp then do:
        OPEN QUERY  q-help FOR EACH dochhelp no-lock, each ofc where ofc.ofc = dochhelp.rwho no-lock.
        ENABLE ALL WITH FRAME f-help.
        wait-for return of frame f-help
        FOCUS b-help IN FRAME f-help.
        p-docid = dochhelp.docid.
        hide frame f-help.
        displ p-docid with frame f-doch.
    end.
    else do:
        MESSAGE "НЕТ ДОКУМЕНТОВ ДЛЯ КОНТРОЛЯ." view-as alert-box.
        p-docid = "".
    end.
end.

repeat:
    clear frame f-doch.
    hide FRAME f_docl.
    hide frame f-rem1.
    hide frame f-rem2.
    p-docid = "".
     update p-docid help "ВВЕДИТЕ НОМЕР ДОКУМЕНТА,  F2 - Помощь. " with frame f-doch.
     if trim(p-docid) <> "" then do:
        find doch where doch.docid = p-docid no-lock no-error.
        if available doch then do:
            if  doch.codfr <> v_codfr then do:
                find first codfr where trim(codfr.codfr) = "doch" and  trim(codfr.code) = trim(doch.codfr) no-lock.
                if available codfr then v_codfrn = codfr.name[1].
                MESSAGE "ДОКУМЕНТ ОТНОСИТСЯ  К ТИПУ: " + v_codfrn view-as alert-box information.
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
            IF  doch.sts = "acc" then do:
                MESSAGE "ДОКУМЕНТ УЖЕ АКЦЕПТОВАН." view-as alert-box information.
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
             IF  doch.sts = "sen" then do:
                p-rdt = doch.rdt.
                p-rtim = doch.rtim.
                p-rwho = doch.rwho.
                v-templ = doch.templ.
                find ofc where ofc.ofc = p-rwho no-lock.
                if available ofc then p-name = ofc.name.
                p-docid = caps(p-docid).
                displ p-docid p-rdt p-name v-templ with frame f-doch.

                OPEN QUERY q_docl FOR EACH docl where docl.docid = p-docid no-lock, EACH gl where gl.gl = docl.gl no-lock.
                 p-rem1 = docl.rem[1].
                 p-cods = substrin(docl.cods,1,2) + " КБе: " + substring(docl.cods,4,2) + " КНП: " + substring(docl.cods,7,3).
                 enable all with FRAME f_docl.
                 if substring(docl.cods,1,2) <> "" then do:
                    displ p-cods p-rem1 with  frame f-rem1.
                    p-ja = no.
                    update p-ja with  frame f-rem1.
                  end.
                  else do:
                    displ p-rem1 with  frame f-rem2.
                    p-ja = no.
                    update p-ja with  frame f-rem2.
                  end.
                 if p-ja then do:
                    find doch where doch.docid = p-docid no-lock.
                     IF AVAILABLE doch then do:
                        run pr_doch_order(p-docid, p-rdt, p-rtim, p-rwho).
                     end.
                 end. /*end if p-ja */
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
     end. /*trim(p-docid)*/
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


/* печать ордера для акцептования */
/*procedure pr_order.
def input parameter prn_docid as char format "x(9)".
def input parameter dtreg as date format "99/99/9999".
def input parameter dtime as int.

def var numln as int no-undo.
def var prn_des as char format "x(25)" no-undo.
def var prn_gl as int format "999999" no-undo.
def var prn_crc as int no-undo.
def var prn_kzt as char no-undo.
def var prn_amt as decimal no-undo.
def var total-dam as decimal no-undo.
def var total-cam as decimal no-undo.
def var p_name as char no-undo.
def var p_addr as char no-undo.
def var ofc_name as char no-undo.
def var prn_code as char format "x(20)" no-undo.
def var prn_rem as char format "x(30)" no-undo.

for each point no-lock.
    p_name = point.name.
    p_addr =  point.addr[1].
end.
for each ofc where ofc.ofc = g-ofc no-lock.
    ofc_name = ofc.name.
end.

output to value("uni.img") page-size 0.

for each cmp no-lock:
   put space(25) "ОПЕРАЦИОННЫЙ ОРДЕР (для контроля)" skip .
    put  "================================================================================"

        skip
        cmp.name space(23)
        dtreg format "99/99/9999" " " string(dtime,"HH:MM") skip
        "БИН" + cmp.addr[2] + "," + cmp.addr[3] format "x(60)" skip.
    put p_name format "x(50)" skip.
    put p_addr format "x(50)" skip.
    put "Ном.докум. " + prn_docid + "   /" + ofc_name  format "x(78)" skip.
    put  "================================================================================"
        skip.
  end.
    numln = 0.
    total-dam = 0.
    total-cam = 0.
    for  each docl where  docl.docid = prn_docid no-lock.
        numln = numln + 1.
        prn_amt = 0.
        if docl.dc="D" then do:
            prn_amt = docl.dam.
            total-dam = total-dam + docl.dam.
         end.
         else do:
            prn_amt = docl.cam.
            total-cam = total-cam + docl.cam.
         end.
        prn_crc = docl.crc.
        find crc where crc.crc = prn_crc no-lock.
        if available crc then prn_kzt = crc.code.
            else do:
                    message "Ошибка!!! Не найден код валюты".
        end.

        prn_gl = docl.gl.
        find gl where gl.gl = prn_gl no-lock.
        if available gl then do:
            prn_des = gl.sname.
           end.
            else do:
                    message "Ошибка!!! Не найден счет главной книги".
        end.


        put string(numln,"99") + " " + string(docl.gl) + " " + prn_des format "x(25)" " " docl.acc format "x(20)" " " prn_kzt " ".
        put prn_amt format "zzz,zzz,zzz,zzz,zz9.99" + " " docl.dc skip.
        if numln = 1 then do:
            prn_rem =  docl.rem[1].
            prn_code = "КОД " + substring(docl.cods,1,2) + " КБе " + substring(docl.cods,4,2) + " КНП " + substring(docl.cods,7,3).
        end.
    end.

        put  prn_code skip.

    put space (39) "ВСЕГО ДЕБЕТ  " total-dam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
    put space (39) "ВСЕГО КРЕДИТ " total-cam format "zzz,zzz,zzz,zzz,zz9.99" " " prn_kzt skip.
    put      "--------------------------------------------------------------------------------" skip.
    put "Примечан.: " prn_rem format "x(100)"  skip.
     put     "================================================================================" skip(1).
    put "Менеджер:                  Контролер:"
skip(2).

output close.
unix silent prit -t value("uni.img").

end procedure.*/



