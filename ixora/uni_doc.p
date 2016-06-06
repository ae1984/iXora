/* uni_doc.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Перечень пунктов Меню Прагмы
 * AUTHOR
        31/12/99 pragma
 * BASES
        BANK COMM
 * CHANGES
          sasco - для VNB0045, VNB0046 печать внебалансового ордера
       04.06.2002 - проверка свода кассы при удалении проводки
       22.11.02  проверка на сумму в шаблоне uni0057  marinav
       07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
       12.04.2004 nadejda - по просьбе Мессерле выдачи по чеку через кассу проходят контроль в 2.7
       13.05.2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
       23.08.2004 sasco - обработка пакетов доступа
       25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
       13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
       31.05.2005 dpuchkov - Добавил пролонгацию сейфовых ячеек.
       11.07.2005 dpuchkov - добавил формирование корешка
       02.08.2005 dpuchkov - добавил формирование корешка для РКО-шек
       23.11.2005 dpuchkov - не светим на табло в операционном номера по шаблонам VNB0008 и VNB0025
       03.04.2006 dpuchkov - добавил новый алгоритм по расчету ячеек ТЗ-293.
       03/12/08   marinav - upgrate frame and variable size
       29.04.2011 aigul - проверка на красное сальдо
       26.05.2011 damir - если шаблон "uni0023" в поля примечание 1, примечание 2, КНП выводить определенную информацию.
       09.06.2011 damir - стр. 308 убрал false
       12.03.2012 damir - добавил формирование операционных ордеров в WORD,printvouord, отмена на матричный принтер.
       13.03.2012 damir - добавил возможность печати на матричный принтер пользователей которые есть в printofc.
       14.03.2012 damir - перекомпиляция.
       15/03/2013 Luiza - ТЗ 1761 проверка на наличия средств по счету 1052, только если сумма кредитуется
       15/05/2013 Luiza - ТЗ 1826
       18/07/2013 Luiza - ТЗ 1967 проверка на шаблон uni0072
*/

/* uni_doc.p */

{global.i}
{comm-txb.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

define input parameter new_document as logical.

define new shared variable s-jh like jh.jh.

def new shared var vrat as deci decimals 2.

define variable m_sub           as character initial "ujo".

define variable seq_number      like aaa.aaa.
define variable uni_template    as character format "x(7)".
define variable template_des    as character format "x(70)".
define variable nxt_doc_nmbr    as integer.
define variable rcode           as integer.
define variable rdes            as character.
define variable vdel            as character initial "^".
define variable vparam          as character.
define variable templ           as character.
define variable jparr           as character format "x(20)".
define variable sure            as logical.
define variable if_edit         as logical.
define variable if_view         as logical.
define variable v-cash          as logical.
define variable repl_line       as integer initial 1.
define variable repl_value      as integer.
define variable trx_header      as integer.
define stream m-out.
define variable rem like jl.rem.
def var vsum as deci.
def var vcrc as inte.
define button main_menu label "Меню".
def var v-sts like jh.sts.
   def buffer b-acheck FOR acheck.
   def buffer b-ofc for ofc.
   def var cacnt as char.
   def var dacnt as char.
   def var vnm as logical.

define var v-chk as char.
def var mes as char label "Введите счет".
define var v-per like gl.des label "Описание счета".

define var v-ant as char.
find sysc where sysc.sysc= "ANT" no-lock no-error.
if avail sysc then
   v-ant = sysc.chval.


define frame f_templ
    uni_template at 35 label "Код шаблона"
    help "  F2 - ПОМОЩЬ  " skip
    template_des  at 5 no-label
    with row 1 no-box side-labels.

def var var_rem as char format "x(90)".

define frame f_remark
    var_rem
    with row 24 col 2 width 95 overlay no-label no-box.

define temp-table w-par
    field v-d like ujo.docnum
    field v-i as int format "999" label "Nr."
    field v-des as cha format "x(60)" label " Param "
    field v-value as cha format "x(10)" label " Value " .

define temp-table remarks
    field number as integer
    field remark as logical.

define temp-table w-cods
    field number as integer
    field code as logical
    field codfr like trxcdf.codfr.

define temp-table chet
    field number as integer
    field code as logical.

define query q_link for ujolink, w-par scrolling.

define browse b_link query q_link  display
    ujolink.parnum label "N" format "z9"
    w-par.v-des    label "Наименование" format "x(40)"
    ujolink.parval label "Значение" format "x(30)"
    enable ujolink.parval
    with 12 down separators no-assign no-hide.

 define frame get-debs
             mes  skip
             v-per view-as text skip
               with row 5 centered side-labels overlay.

define frame uni_main
"
__________________________________________________________________________________________" skip(1)
    seq_number label "Документ " format 'x(10)'
    ujo.num label "Док.Nr." at 23
    ujo.chk at 48 label "Чек  Nr."
    ujo.jh label "TRX" at 65 skip
    ujo.whn label "Дата документа" skip(1)
    b_link skip(1)
    var_rem at 2 no-label
    skip(2)
    /*b_apply at 53 b_cancel at 63 b_exit at 73*/
    main_menu at 70
    with row 3 width 95 side-labels no-box no-hide.

/*
on end-error of current-window or endkey of current-window anywhere do:
    apply "close" to this-procedure.
end.
  */


on end-error of ujo.num in frame uni_main or
                                    endkey of ujo.num in frame uni_main do:
    if if_edit then disable all with frame uni_main.
end.

on end-error of ujo.chk in frame uni_main or
                                    endkey of ujo.chk in frame uni_main do:
    if if_edit then disable all with frame uni_main.
end.

on end-error of browse b_link or endkey of browse b_link anywhere do:
    apply "close" to this-procedure.
end.

on end-error of main_menu or endkey of main_menu anywhere do:
    if_view = false.
    return no-apply.
end.

on pf3 of current-window anywhere do:
end.


on help of uni_template in frame f_templ do:
   run help-da (g-ofc).
end.

on help of browse b_link anywhere do:
   find first w-cods where w-cods.number = ujolink.parnum no-error.
   if available w-cods and w-cods.code = true then do:
    run uni_help1(w-cods.codfr,'*').
   end.
   else do:
      message "Помощь не доступна !". pause 3.
      hide message.
   end.
end.

on help of seq_number in frame uni_main do:
   run seq-number.
end.


on "u1" of this-procedure do:           /* Edit */
    do transaction on error undo, return:
    if_edit = true.
    find ujo where ujo.docnum eq seq_number no-lock no-error.
        if available ujo then do:
            if not (ujo.jh eq 0 or ujo.jh eq ?) then do:
                message "Документ с транзакцией не редактируется.".
                undo, return.
            end.
        end.
        if ujo.who ne g-ofc then do:
            message substitute (
               "Документ принадлежит &1. Редактировать нельзя.", ujo.who).
            undo, return.
        end.

    find ujo where ujo.docnum eq seq_number exclusive-lock no-error.

    close query q_link.

    open query q_link for each ujolink where ujolink.docnum eq ujo.docnum,
    each w-par where w-par.v-d eq ujolink.docnum and
    w-par.v-i eq ujolink.parnum exclusive-lock.

    browse b_link:read-only = false.
    browse b_link:sensitive = true.

    enable b_link main_menu ujo.num ujo.chk with frame uni_main.
    apply "entry" to browse b_link.
    ujo.whn = today.
    ujo.who = g-ofc.
    ujo.tim = time.
    run chgsts (m_sub, seq_number, "new").
    end.
end.

on "u2" of this-procedure do:       /* View */
    if_view = true.
    disable all with frame uni_main.
    close query q_link.
    open query q_link for each ujolink where ujolink.docnum eq ujo.docnum,
       each w-par where w-par.v-d eq ujolink.docnum and
       w-par.v-i eq ujolink.parnum no-lock.

    browse b_link:read-only = true.
    browse b_link:sensitive = false.
    enable b_link main_menu with frame uni_main.
    apply "entry" to browse b_link.
end.

on "u3" of this-procedure do:       /* Status */
    run substs (m_sub, seq_number).
end.

on choose of main_menu in frame uni_main do:
    if_view = false.
    disable all with frame uni_main.
    hide main_menu in frame uni_main.
end.

on value-changed of mes in frame get-debs do:
   find gl where gl.gl = integer(mes:screen-value) no-lock no-error.
          if avail gl then
                       v-per =  gl.des.
                      else
                       v-per = "Данного счета не существует!".
          displ v-per with frame get-debs.

        end.


on close of this-procedure anywhere do:
    close query q_link.
    ujolink.parval:read-only in browse b_link = true.
    disable all with frame f_link.
    hide frame uni_main.
    hide frame f_templ.
    hide frame f_remark.
    hide frame get-debs.
    if this-procedure:persistent then delete procedure this-procedure.
end.

on row-entry of b_link in frame uni_main do:
do transaction on error undo, retry:
    find first chet where chet.number = ujolink.parnum no-error.
    if chet.code then do:

        update mes go-on (down up) with  frame get-debs

editing:
        readkey.
        apply lastkey.
        if frame-field = "mes" then apply "value-changed" to mes in frame get-debs.

end.
     ujolink.parval:screen-value in browse b_link = mes.
end.
end.

    find first w-cods where w-cods.number = ujolink.parnum no-error.
    if available w-cods and w-cods.code = true then
       message "F2 - Помощь".
    else hide message.

    do transaction on error undo, retry:

    find first remarks where remarks.number eq ujolink.parnum.
        if remarks.remark then do:
            var_rem = ujolink.parval.
            update var_rem go-on (down up) with frame f_remark.
            ujolink.parval:screen-value in browse b_link = var_rem.
        end.
        else var_rem = "".
    end.
end.

on value-changed of b_link in frame uni_main do:

    if if_view then do:
        find first remarks where remarks.number eq ujolink.parnum.
        if remarks.remark then do:
            display ujolink.parval @ var_rem with frame uni_main.
        end.
        else display "" @ var_rem with frame uni_main.
    end.
end.

on row-leave of b_link in frame uni_main do:

    do transaction on error undo, retry:

    find ujolink where ujolink.docnum eq ujo.docnum and
            ujolink.parnum eq remarks.number exclusive-lock.
    if new_document then do:
        if var_rem ne ""  then assign ujolink.parval = var_rem.
        else assign input browse b_link ujolink.parval.
    end.
    else do:
        if b_link:current-row-modified then do:
            message "Значение параметра изменено. Подтвердите."
                view-as alert-box question buttons yes-no
                update choise as logical.

            /*if choise then assign input browse b_link ujolink.parval.*/
            if choise then do:
                if var_rem ne ""  then assign ujolink.parval = var_rem.
                else assign input browse b_link ujolink.parval.
            end.
            else ujolink.parval:screen-value in browse b_link = ujolink.parval.
        end.
    end.
    end.
    release ujolink.
end.

DO TRANSACTION on error undo, return:

if new_document then do:
    if_edit = false.

    run Get_template.

    if keyfunction (lastkey) = "end-error" or uni_template eq "" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.

    nxt_doc_nmbr = next-value (unijou).

    create ujo.
    ujo.sys    = substring (uni_template, 1, 3).
    ujo.code   = substring (uni_template, 4, 4).
    ujo.docnum = string (nxt_doc_nmbr).
    ujo.whn    = today.
    ujo.who    = g-ofc.
    ujo.tim    = time.

    seq_number = ujo.docnum.
    display ujo.docnum @ seq_number ujo.whn with frame uni_main.
    update ujo.num with frame uni_main.
    update ujo.chk with frame uni_main.

    run Ujo_query.
    /*run chgsts (m_sub, seq_number, "new").*/

    open query q_link for each ujolink where ujolink.docnum eq ujo.docnum,
    each w-par where w-par.v-d eq ujolink.docnum and
    w-par.v-i eq ujolink.parnum exclusive-lock.
    enable b_link main_menu ujo.num ujo.chk with frame uni_main.
end.
else do:
    run Update_seq.

    if keyfunction (lastkey) = "end-error" then do:
        hide all.
        if this-procedure:persistent then delete procedure this-procedure.
        return.
    end.

    find ujo where ujo.docnum eq seq_number no-lock no-error.
        if not available ujo then do:
            message "Документ не найден.".
            undo, retry.
        end.

    uni_template = ujo.sys + ujo.code.
    display uni_template with  frame f_templ.
    find trxhead where trxhead.system = substring (uni_template, 1, 3) and
        trxhead.code = integer (substring (uni_template, 4, 4))
                                                        no-lock no-error.
    template_des = fill(" ", 70 - length(trim(trxhead.des))) + trxhead.des.
    display template_des with frame f_templ.

    display ujo.num ujo.chk ujo.jh ujo.whn with frame uni_main.

    run Ujo_query.

    open query q_link for each ujolink where ujolink.docnum eq ujo.docnum,
    each w-par where w-par.v-d eq ujolink.docnum and
    w-par.v-i eq ujolink.parnum no-lock.

end.


END.

wait-for /* choose of main_menu  or   */
    close of this-procedure focus b_link in frame uni_main.


Procedure Update_seq.
    update seq_number with frame uni_main.
end procedure.

Procedure Get_template.
    define variable i   as integer.
    define variable gut as logical.

    update uni_template with  frame f_templ.
    find trxhead where trxhead.system = substring (uni_template, 1, 3) and
        trxhead.code = integer (substring (uni_template, 4, 4))
                                                        no-lock no-error.
    if not available trxhead then do:
        message "Код шаблона не найден.  ".
        undo, retry.
    end.
    else do:
        find ujosec where ujosec.template eq uni_template no-lock no-error.
        if not available ujosec then do:
            message "Шаблон не определен для доступа.".
            undo, retry.
        end.

        /*
        do i = 1 to num-entries (ujosec.officers):
            if entry (i, ujosec.officers) eq g-ofc then do:
                gut = true.
                leave.
            end.
            else gut = false.
        end.

        if not gut then do:
            message "Шаблон не доступен.".
            undo, retry.
        end.
        */
        run ujoseccheck (g-ofc, uni_template).
        if return-value <> "yes" then do:
            message "Шаблон не доступен.".
            undo, retry.
        end.

        template_des = fill(" ", 70 - length(trim(trxhead.des))) + trxhead.des.
        display template_des with frame f_templ.
    end.
end procedure.


Procedure Ujo_line.
    define input parameter refer_number like ujolink.docnum.
    define input parameter param_number like ujolink.parnum.
    define input parameter remark       as logical.

    define input parameter t_des as character.
    define input parameter account as logical.

    do transaction on error undo, retry:

    if new_document then do:
        create ujolink.
        ujolink.docnum = refer_number.
        ujolink.parnum = param_number.

        if uni_template = "uni0023" then do:
            if t_des = "DrCode (spnpl)(Ln= 1)" then ujolink.parval = "840".
            if t_des = "Примечание 1" then ujolink.parval = "Комиссия за".
            if t_des = "Примечание 2" then ujolink.parval = "Комиссия за".
        end.
    end.

    create chet.
    chet.number = param_number.
    chet.code   = account.


    create remarks.
    remarks.number = param_number.
    remarks.remark = remark.

    create w-par.
    w-par.v-d   = refer_number.
    w-par.v-i   = param_number.
    w-par.v-des = t_des.

    end.
end procedure.

Procedure Ujo_query.
    define variable i as integer initial 0.
    define variable j as integer.

    for each trxhead where trxhead.system = substring (uni_template, 1, 3) and
        trxhead.code = integer (substring (uni_template, 4, 4)) no-lock:

    if trxhead.sts-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Статус проводки", false).
    end.
    if trxhead.party-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Заголовок", false).
    end.
    if trxhead.point-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Пункт", false).
    end.
    if trxhead.depart-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Департамент", false).
    end.
    if trxhead.mult-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Коэфф.повтора", false).
        repl_line = i.
    end.
    if trxhead.opt-f eq "r" then do:
        i = i + 1.
        run Ujo_line (ujo.docnum, i, false, "Оптимизация", false).
    end.

    trx_header = i.

    for each trxtmpl where trxtmpl.code eq trxhead.system +
        string (trxhead.code, "9999") no-lock:

        if trxtmpl.amt-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = trxtmpl.code and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "amt-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "DR Amount (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.crc-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crc-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "Currency (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.rate-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "rate-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "Rate (Ln=" + string(trxtmpl.ln,"z9") + ")", false ).
        end.
        if trxtmpl.drgl-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "drgl-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false,trxlabs.des, true).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "Debet G/L (Ln=" + string(trxtmpl.ln,"z9") + ")", true).
        end.
        if trxtmpl.drsub-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "drsub-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "DR subled type (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.dev-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "dev-f"
                                                        no-lock no-error.
            if avail trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "DR subled level (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.dracc-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "dracc-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "DR account (" + trxtmpl.drsub + ") (Ln=" +
                    string(trxtmpl.ln,"z9")  + ")", false).
        end.
        if trxtmpl.crgl-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crgl-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, true).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "CR G/L (Ln=" + string(trxtmpl.ln,"z9") + ")", true).
        end.
        if trxtmpl.crsub-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "crsub-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "CR subled type (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.cev-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "cev-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "CR subled level (Ln=" + string(trxtmpl.ln,"z9") + ")", false).
        end.
        if trxtmpl.cracc-f eq "r" then do:
            i = i + 1.
            find first trxlabs where trxlabs.code = uni_template and
                trxlabs.ln = trxtmpl.ln and trxlabs.fld = "cracc-f"
                                                        no-lock no-error.
            if available trxlabs then
                run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
            else
                run Ujo_line (ujo.docnum, i, false,
                    "CR account (" + trxtmpl.crsub + ")" +
                    "(Ln=" + string(trxtmpl.ln,"z9") + ")" , false).
        end.

        repeat j = 1 to 5:
            if trxtmpl.rem-f[j] eq "r" then do:
                i = i + 1.
                run Ujo_line (ujo.docnum, i, true,
                    /*
                    "Rem["+ string(i,"z9") + "]" + "(Ln=" +
                     string(trxtmpl.ln,"z9") + ")"
                     */
                     "Примечание " + string(j,"9"), false
                     ).
            end.
        end.

        for each trxcdf where trxcdf.trxcode = trxtmpl.code
                          and trxcdf.trxln = trxtmpl.ln:
         if trxcdf.drcod-f eq "r" then do:
             i = i + 1.
             find first trxlabs where trxlabs.code = uni_template
                                  and trxlabs.ln = trxtmpl.ln
                     and trxlabs.fld = trxcdf.codfr + "_Dr" no-lock no-error.
             if available trxlabs then
                 run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
             else
                 run Ujo_line (ujo.docnum, i, false,
                     "DrCode (" + trxcdf.codfr + ")" +
                     "(Ln=" + string(trxtmpl.ln,"z9") + ")" , false).
            create w-cods.
            w-cods.number = i.
            w-cods.code = true.
            w-cods.codfr = trxcdf.codfr.

         end.
         if trxcdf.crcode-f eq "r" then do:
             i = i + 1.
             find first trxlabs where trxlabs.code = uni_template
                                  and trxlabs.ln = trxtmpl.ln
                     and trxlabs.fld = trxcdf.codfr + "_Cr" no-lock no-error.
             if available trxlabs then
                 run Ujo_line (ujo.docnum, i, false, trxlabs.des, false).
             else
                 run Ujo_line (ujo.docnum, i, false,
                     "CrCode (" + trxcdf.codfr + ")" +
                     "(Ln=" + string(trxtmpl.ln,"z9") + ")", false ).
            create w-cods.
            w-cods.number = i.
            w-cods.code = true.
            w-cods.codfr = trxcdf.codfr.
         end.
        end.
    end.
    end.


end procedure.



Procedure Create_Transaction.
    def var v-sum as char.
    def var v-acc as char.
    def var vv-1052 as char init "".
    for each w-par.
        if w-par.v-des matches	("*кредит*") then do:
            find first ujolink where ujolin.docnum = seq_number and ujolin.parnum =  w-par.v-i no-lock no-error.
            if available ujolink and substring(ujolin.parval,10,4) = "1052" then vv-1052 = ujolin.parval.
        end.
    end.
    find first ujolink where ujolin.docnum = seq_number and parnum  = 3 no-lock no-error.
    if avail ujolink then v-acc = ujolink.parval.
    find first ujolink where ujolin.docnum = seq_number and parnum  = 1 no-lock no-error.
    if avail ujolink then v-sum = ujolink.parval.
    find first dfb where dfb.dfb = vv-1052 /*v-acc*/ no-lock no-error.
    if avail dfb then do:
        if  string(dfb.gl) begins "1052" /*dfb.gl = 105210 or dfb.gl = 105220*/ then do:
            if dfb.crc <> 1 and uni_template  = "uni0072" /* шаблон: uni0072  Г/К - dfb с конвертацией  */ then do:
                find first crc where crc.crc = dfb.crc no-lock no-error.
                if available crc then do:
                    if  dfb.dam[1] - dfb.cam[1] - (decimal(v-sum) / crc.rate[1]) < 0 then do:
                        message  "Нехватка средств на счете 1052, транзакция невозможна!" view-as alert-box.
                        return.
                    end.
                end.
            end.
            else do:
                if  dfb.dam[1] - dfb.cam[1] - decimal(v-sum) < 0 then do:
                    message  "Нехватка средств на счете 1052, транзакция невозможна!" view-as alert-box.
                    return.
                end.
            end.
        end.
    end.
    do transaction on error undo, retry:
    find ujo where ujo.docnum eq seq_number exclusive-lock no-error.

    if not (ujo.jh eq 0 or ujo.jh eq ?) then do:
        message "Транзакция уже проведена.".
        undo, retry.
    end.
    if ujo.who ne g-ofc then do:
        message substitute ("Документ принадлежит &1.", ujo.who).
        undo, return.
    end.

    find first ujolink where ujolink.docnum eq seq_number and
        ujolink.parnum eq repl_line no-lock.

    vparam = "".
    for each ujolink where ujolink.docnum eq seq_number no-lock:
        vparam = vparam + ujolink.parval + vdel.
    end.

    templ = ujo.sys + ujo.code.
    s-jh = 0.
/**************************/
    /*Аренда сейфовой ячейки*/
    def var d_sum as decimal init 0.
    def var i_crc as integer init 0.
    def var v_acnt as char.
    def var i_ind as integer init 0.
    def variable v-aaa as char .
    def variable v-sumall as decimal decimals 2.
    if (uni_template = "uni0164") or (uni_template = "vnb0056")  then do:

        if (uni_template = "uni0164") then do:
           v-aaa = string(entry(2,vparam,vdel)).
           v-sumall = decimal(entry(1,vparam,vdel)).
        end.
        if (uni_template = "vnb0056") then do:
           v-aaa = string(entry(3,vparam,vdel)).
           v-sumall = decimal(entry(1,vparam,vdel)).
        end.


        find last aaa where aaa.aaa = v-aaa no-lock no-error.
        if avail aaa then do:
           {seif.i}
            view frame uni_main.
        end.
   end.
/**************************/

    run trxgen (templ, vdel, vparam, m_sub, seq_number, output rcode,
        output rdes, input-output s-jh).
    /*run trxgen (templ, vdel, vparam, output rcode,
        output rdes, input-output s-jh).*/


        if rcode ne 0 then do:
           message rdes.
           pause.
           undo, return.
        end.

    ujo.jh = s-jh.
    disp ujo.jh with frame uni_main.
    /*run chgsts (m_sub, seq_number, "trx").*/






/* Печать корешка*/
 find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
 if comm-txb() = "TXB00" then do: /*Только Алматы ЦО*/

    for each jl where jl.jh = ujo.jh no-lock use-index jhln:
      if jl.dc = "d" then do:
        dacnt = jl.acc.
        if jl.acc = "" then dacnt = string(jl.gl).
      end.
      else do:
        cacnt = jl.acc.
        if jl.acc = "" then cacnt = string(jl.gl).
      end.
      if dacnt <> "" and cacnt <> "" then leave.
    end.
    find sysc where sysc.sysc eq "CASHGL" no-lock.


  if dacnt = string(sysc.inval) or cacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(entry(3,vparam,vdel),v-ant) <> 0)   then do:
     if uni_template <> "VNB0008" and uni_template <> "VNB0025" then do:
       find first acheck where acheck.jh = string(s-jh) and acheck.dt = g-today no-lock no-error.
       if not avail acheck then do:
          v-chk = "".
          v-chk = string(NEXT-VALUE(krnum)).
          create acheck.
                 acheck.jh = string(s-jh).
                 acheck.num = string(day(g-today),"99") + string(month(g-today),"99") + string(year(g-today)) + substr(g-ofc, 4, 3) + v-chk.
                 acheck.dt = g-today.
                 acheck.n1 = v-chk.
          release acheck.
       end.
     end.
  end.
end.
/* Печать корешка */
















    if uni_template = "UNI0057" then do:
       vsum = deci(entry(6,vparam,vdel)).
       vcrc = inte(entry(7,vparam,vdel)).
       find first crc where crc.crc = vcrc no-lock no-error.
       if vsum * crc.rate[1] > 5000000
       then do:
          message "Внимание !!!! На контроль в НБРК !!!".
       end.
     end.

    disable all with frame uni_main.
    end.
end procedure.


Procedure Print_transaction.
    find ujo where ujo.docnum eq seq_number no-lock no-error.
    if ujo.jh eq ? or ujo.jh eq 0 then do:
        message "Транзакция при документе не обнаружена.".
        undo, retry.
    end.
    s-jh = ujo.jh.

    /*run x-jlscrn ("prit", ujo.docnum).*/

    /* Добавлено печать корешка */
    find b-ofc where b-ofc.ofc = g-ofc no-lock no-error.
    if comm-txb() = "txb00" then do: /*Только Алматы ЦО*/
        find last acheck where acheck.jh = string(ujo.jh) and acheck.dt = g-today no-lock no-error.
        if avail acheck then do:
            for each jl where jl.jh = ujo.jh no-lock use-index jhln:
                if jl.dc = "d" then do:
                    dacnt = jl.acc.
                    if jl.acc = "" then dacnt = string(jl.gl).
                end.
                else do:
                    cacnt = jl.acc.
                    if jl.acc = "" then cacnt = string(jl.gl).
                end.
                if dacnt <> "" and cacnt <> "" then leave.
            end.
            find sysc where sysc.sysc eq "CASHGL" no-lock.
            if dacnt = string(sysc.inval) or cacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(dacnt,v-ant) <> 0)
            then do:
                if dacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(dacnt,v-ant) <> 0) then do:
                    if v-noord = yes then do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run uvou_bank2 ("prit", 1, "").
                        else do:
                            run printvouord(2). /*WORD Операционный ордер*/
                            run printord(s-jh,"").
                        end.
                    end.
                    else run uvou_bank2 ("prit", 1, ""). /* приходный */
                end.
                if cacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(cacnt,v-ant) <> 0) then do:
                    if v-noord = yes then do:
                        find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                        lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                        if avail printofc then run uvou_bank2 ("prit", 2, "").
                        else do:
                            run printvouord(2). /*WORD Операционный ордер*/
                            run printord(s-jh,"").
                        end.
                    end.
                    else run uvou_bank2 ("prit", 2, ""). /* расходный */
                end.
            end.
        end. /*печать корешка вопрос*/
        else do:
            if v-noord = yes then do:
                find first printofc where trim(printofc.ofc) = trim(g-ofc) and
                lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
                if avail printofc then run uvou_bank ("prit").
                else do:
                    run printvouord(2). /*WORD Операционный ордер*/
                    run printord(s-jh,"").
                end.
            end.
            else run uvou_bank ("prit").
        end.
    end.
    else do:
        if v-noord = yes then do:
            find first printofc where trim(printofc.ofc) = trim(g-ofc) and lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock
            no-error.
            if avail printofc then run uvou_bank ("prit").
            else do:
                run printvouord(2). /*WORD Операционный ордер*/
                run printord(s-jh,"").
            end.
        end.
        else run uvou_bank ("prit").  /* Добавлено печать корешка */
    end.

    pause 0.

    def var crdec as decimal.
    crdec = 0.

    find jh where jh.jh eq ujo.jh no-lock no-error.
    if available jh and jh.sts ne 6 then do:
        find sysc where sysc.sysc eq "CASHGL" no-lock.
        v-cash = false.
        for each jl where jl.jh eq s-jh no-lock:
            if jl.gl eq sysc.inval then v-cash = true.
        end.

        if v-cash then do:
            run trxsts (input s-jh, input 5, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            if uni_template = "OCK0043" then
            /* 12.04.2004 nadejda - по просьбе Мессерле выдачи по чеку через кассу проходят контроль в 2.7 */
            run chgsts (m_sub, seq_number, "bac").
            else
            run chgsts (m_sub, seq_number, "cas").
        end.
        else do:
            run trxsts (input s-jh, input 6, output rcode, output rdes).
            if rcode ne 0 then do:
                message rdes.
                undo, return.
            end.
            run chgsts (m_sub, seq_number, "rdy").
        end.
    end.
    else if available jh then do:
        find last jl where jl.jh eq s-jh no-lock.
        crdec = crdec + jl.dam + jl.cam.
        rem[1] = jl.rem[1].
        rem[2] = jl.rem[2].
        rem[3] = jl.rem[3].
        rem[4] = jl.rem[4].
        rem[5] = jl.rem[5].
    end.


    /* ###########   by sasco : вывод внебалансового ордера  ###*/
    if uni_template = "VNB0045" then do:
        output stream m-out to vou2.img.
        run Print_vnebal_rashod (input crdec).
        output stream m-out close.
        unix silent prit vou2.img.
        pause 0.
    end.
    if uni_template = "VNB0046" then do:
        output stream m-out to vou2.img.
        run Print_vnebal_prih (input crdec).
        output stream m-out close.
        unix silent prit vou2.img.
        pause 0.
    end.
    /*##########################################################*/

end procedure.


Procedure Delete_transaction.
    do transaction on error undo, retry:

    find ujo where ujo.docnum eq seq_number no-lock no-error.
    if ujo.jh eq 0 or ujo.jh eq ? then do:
        message "Транзакция при документе не обнаружена.".
        undo, retry.
    end.
    if ujo.who ne g-ofc then do:
        message substitute (
            "Документ принадлежит &1. Удалить нельзя.", ujo.who).
        undo, return.
    end.

    s-jh = ujo.jh.
    sure = false.
    find jh where jh.jh eq ujo.jh no-lock no-error.
        if jh.jdt lt g-today then do:
            message substitute ("Дата транзакции &1.  Сторно?",
                jh.jdt) update sure.
                if not sure then undo, return.

            run trxstor(input ujo.jh, input 6,
                output s-jh, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.

            run x-jlvo.
        end.
        else do:
/*
            if jh.sts eq 6 then do:
                find sysc where sysc.sysc eq "cashgl" no-lock no-error.

                v-cash = false.
                for each jl where jl.jh eq s-jh no-lock.
                   if jl.gl eq sysc.inval then v-cash = true.
                end.
                if v-cash then do:
                    message
                      "Кассовая транзакция со статусом 6. Удалять нельзя.".
                    undo, return.
                end.
            end.
*/
                find sysc where sysc.sysc eq "cashgl" no-lock no-error.
                v-cash = false.
                for each jl where jl.jh eq s-jh no-lock.
                   if jl.gl eq sysc.inval then v-cash = true.
                end.

                /* если касса ... */
                if v-cash then do:
                    if jh.sts eq 6 then do:
                       message
                             "Кассовая транзакция со статусом 6. Удалять нельзя.".
                        undo, return.
                    end.

                  /* проверка свода кассы */
                  find sysc where sysc.sysc = 'CASVOD' no-lock no-error.
                  if avail sysc and sysc.daval = g-today then
                  do:
                     if sysc.loval = yes then do:
                        message "Свод кассы завершен, удалить нельзя"
                        view-as alert-box.
                        undo, return.
                     end.
                  end.

                end.


            message "Вы уверены ?" update sure.
                if not sure then undo, return.

            v-sts = jh.sts.
            run trxsts (input ujo.jh, input 0, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    undo, return.
                end.
            run trxdel (input ujo.jh, input true, output rcode, output rdes).
                if rcode ne 0 then do:
                    message rdes.
                    if rcode = 50 then do:
                                       run trxsts (input ujo.jh, input v-sts, output rcode, output rdes).
                                       return.
                                  end.
                    else undo, return.
                end.
        end.

    find ujo where ujo.docnum eq seq_number exclusive-lock
                                                    no-error no-wait.
    ujo.jh   = ?.
    display ujo.jh with frame uni_main.

    run chgsts (m_sub, seq_number, "new").

    end.
end procedure.

/*******************
Procedure Edit_document.

    on choose of b_apply in frame uni_main do:

    end.

    on end-error of frame uni_main anywhere do:
        pause 444.
        /*apply "close" to this-procedure.
        disable all with frame uni_main.    */

    end.


    find ujo where ujo.docnum eq seq_number no-lock no-error.
        if available ujo then do:
            if not (ujo.jh eq 0 or ujo.jh eq ?) then do:
                message "Документ с транзакцией не редактируется.".
                undo, return.
            end.
        end.
    find ujo where ujo.docnum eq seq_number exclusive-lock no-error.

    enable b_link b_apply b_cancel ujo.num ujo.chk with frame uni_main.

    wait-for choose of b_apply in frame uni_main or
        choose of b_cancel in frame uni_main or
        "endkey" of frame uni_main  .

           /* or
        choose of b_apply  in frame uni_main or */
        /*close of this-procedure.*/  /* focus b_link in frame uni_main.*/
end.
**********************/

Procedure Delete_document.
    do transaction on error undo, retry:

    find ujo where ujo.docnum eq seq_number no-lock no-error.
        if available ujo then do:
            if not (ujo.jh eq 0 or ujo.jh eq ?) then do:
                message "Документ с транзакцией не удаляется.".
                undo, return.
            end.
            if ujo.who ne g-ofc then do:
               message substitute (
                  "Документ принадлежит &1. Удалять нельзя.", ujo.who).
               undo, return.
            end.

            sure = false.
            message "Вы уверены ?" update sure.
                if not sure then undo, return.
            find ujo where ujo.docnum eq seq_number exclusive-lock.
            delete ujo.
        end.

    for each ujolink where ujolink.docnum eq seq_number exclusive-lock.
        delete ujolink.
    end.
    apply "close" to this-procedure.
    delete procedure this-procedure.
    hide message.
    hide frame f_remark.
    end.
    return.
end procedure.


Procedure Screen_transaction.
    define variable dest as character.
    define frame frame_dest
        skip(1)
        dest label "Команда печати " format "x(40)"
        with row 13 centered overlay side-labels.

    find ujo where ujo.docnum eq seq_number no-lock no-error.
        if ujo.jh eq ? or ujo.jh eq 0 then do:
            message "Транзакция при документе не обнаружена.".
            undo, retry.
        end.

    s-jh = ujo.jh.

    dest = "joe -rdonly".
    update dest with frame frame_dest.

    /*run x-jlscrn (input dest, ujo.docnum).*/


/*Добавлено печать корешка*/
   find ofc where ofc.ofc = g-ofc no-lock no-error.
   if comm-txb() = "txb00" then do: /*Только Алматы ЦО*/
      find last acheck where acheck.jh = string(ujo.jh) and acheck.dt = g-today no-lock no-error.
      if avail acheck then do:
                         for each jl where jl.jh = ujo.jh no-lock use-index jhln:
                           if jl.dc = "d" then do:
                             dacnt = jl.acc.
                             if jl.acc = "" then dacnt = string(jl.gl).
                           end.
                           else do:
                             cacnt = jl.acc.
                             if jl.acc = "" then cacnt = string(jl.gl).
                           end.
                           if dacnt <> "" and cacnt <> "" then leave.
                         end.
                         find sysc where sysc.sysc eq "CASHGL" no-lock.
                         if dacnt = string(sysc.inval) or cacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(dacnt,v-ant) <> 0) then do:
                            if dacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(dacnt,v-ant) <> 0)  then  run uvou_bank2 (input dest, 1, ""). /* приходный */
                            if cacnt = string(sysc.inval) or (uni_template = "UNI0003" and lookup(cacnt,v-ant) <> 0) then  run uvou_bank2 (input dest, 2, ""). /* расходный */
                         end.
        end.
        else     run uvou_bank (input dest).

    end.
  else
/*Добавлено печать корешка*/
                 run uvou_bank (input dest).
    hide frame frame_dest.
end procedure.

Procedure Codific.
    run subcodj (seq_number, "ujo").
    view frame uni_main.
end procedure.


/*##############################################################*/
/*##############################################################*/

Procedure Print_vnebal_prih.

    def input parameter crdec as decimal.
    def var strAmount as char.
    def var temp as char.
    def var strTemp as char.
    def var str1 as char.
    def var str2 as char.

    put stream m-out skip(2)
    " " format "x(22)" "ПРИХОДНЫЙ ВНЕБАЛАНСОВЫЙ ОРДЕР" skip(2).
    find first ofc where ofc.ofc = g-ofc.

    put stream m-out "Trx.Nr." + string(s-jh) + "      " + ofc.name + "/" +
                    ofc.ofc + "     " + string(ujo.whn) format "x(78)" skip.

    put stream m-out "================================================================" skip.
    put stream m-out "ВАЛЮТА                          ПРИХОД              РАСХОД"
    skip.
    put stream m-out
    "---------------------------------------------------------------" skip.

          put stream m-out "Тенге                       "  crdec
          "                0.00"           skip(1).
          put stream m-out "             ИТОГО ПРИХОД   "  crdec skip(3).

 put stream m-out "Сумма прописью :" skip.
 temp = string (crdec).
 if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    temp = substring(temp, length(temp) - 1, 2).
    if num-entries(temp,".") = 2 then
    temp = substring(temp,2,1) + "0".
 end.
 else temp = "00".

 strTemp = string(truncate(crdec,0)).

 run Sm-vrd(input crdec, output strAmount).
 run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
 strAmount = strAmount + " " + str1 + " " + temp + " " + str2.


 if length(strAmount) > 80
    then do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(0).
    end.
    else  do: put stream m-out unformatted strAmount skip(0). end.

 put stream m-out  skip (2)
        "Менеджер:            Контролер:             Кассир:" format "x(70)"
         skip(2)
        "===============================================================" skip.

 put stream m-out "Примечание:" skip.
 put stream m-out
            "     " rem[1] skip
            "     " rem[2] skip
            "     " rem[3] skip
            "     " rem[4] skip
            "     " rem[5] skip(1).

   if ofc.mday[2] = 1 then
   put stream m-out skip(14).
   else put stream m-out skip(1).
end procedure.


/*##############################################################*/
/*##############################################################*/

Procedure Print_vnebal_rashod.

    def input parameter crdec as decimal.
    def var strAmount as char.
    def var strTemp as char.
    def var temp as char.
    def var str1 as char.
    def var str2 as char.

    put stream m-out skip(2)
    " " format "x(22)" "РАСХОДНЫЙ ВНЕБАЛАНСОВЫЙ ОРДЕР" skip(2).
    find first ofc where ofc.ofc = g-ofc.

    put stream m-out "Trx.Nr." + string(s-jh) + "      " + ofc.name + "/" +
                    ofc.ofc + "     " + string(ujo.whn) format "x(78)" skip.

    put stream m-out "===============================================================" skip.
    put stream m-out "ВАЛЮТА                          ПРИХОД              РАСХОД"
    skip.
    put stream m-out
    "---------------------------------------------------------------" skip.

          put stream m-out "Тенге                             0.00          " crdec           skip(1).
          put stream m-out "             ИТОГО РАСХОД                       "  crdec           skip(3).

 put stream m-out "Сумма прописью :" skip.
 temp = string (crdec).
 if num-entries(temp,".") = 2 then do:  /*если равно, то в сумме есть тиыны*/
    temp = substring(temp, length(temp) - 1, 2).
    if num-entries(temp,".") = 2 then
    temp = substring(temp,2,1) + "0".
 end.
 else temp = "00".

 strTemp = string(truncate(crdec,0)).

 run Sm-vrd(input crdec, output strAmount).
 run sm-wrdcrc(input strTemp,input temp,input 1,output str1,output str2).
 strAmount = strAmount + " " + str1 + " " + temp + " " + str2.


 if length(strAmount) > 80
    then do:
        str1 = substring(strAmount,1,80).
        str2 = substring(strAmount,81,length(strAmount,"CHARACTER") - 80).
        put stream m-out unformatted str1 skip str2 skip(0).
    end.
    else do: put stream m-out unformatted strAmount skip(0). end.


 put stream m-out skip (2)
         "Менеджер:            "
         "Контролер:           "
         "  Кассир:"
           skip(2)
         "===============================================================" skip.

 put stream m-out "Примечание:" skip.
 put stream m-out
            "     " rem[1] skip
            "     " rem[2] skip
            "     " rem[3] skip
            "     " rem[4] skip
            "     " rem[5] skip(1).

   if ofc.mday[2] = 1 then
   put stream m-out skip(14).
   else put stream m-out skip(1).

end procedure.





Procedure DayCount. /*возвращает количество дней за целое число месяцев*/
def input parameter a_start  as date.
def input parameter a_expire as date.
def output parameter iiyear  as integer .
def output parameter iimonth as integer .
def output parameter iiday   as integer .

def var vterm as inte.
def var e_refdate as date.
def var t_date as date.
def var years as inte initial 0.
def var months as inte initial 0.
def var days as inte initial 0.
def var i as inte initial 0.

def var e_fire as logical init False.
def var t-days as date.
def var e_date as date.
iiday = 0. iiyear = 0. iimonth = 0.

e_refdate = a_start.

if a_start = a_expire then do: return. end.

do e_date = a_start to a_expire:
   iiday = iiday + 1.

   if day(e_refdate) = 31 then do:
      if (day(e_date) = 30 and month(e_date) = 4) or
         (day(e_date) = 30 and month(e_date) = 6) or
         (day(e_date) = 30 and month(e_date) = 9) or
         (day(e_date) = 30 and month(e_date) = 11) then do:
      iimonth = iimonth + 1.
      iiday = 0.
      end.
   end.

   if day(e_date) = day(e_refdate) and e_date <> a_start then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.

   /* февраль высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) = 0) and ( day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 29) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.
   /* февраль не высокосный */
   if (month(e_date) = 2 and ((year(e_date) - 2000) modulo 4) <> 0) and ( day(e_refdate) = 29 or day(e_refdate) = 30 or day(e_refdate) = 31)  and (day(e_date) = 28) then do:
      iimonth = iimonth + 1.
      iiday = 0.
   end.


   if iimonth = 12 then do:
      iiyear = iiyear + 1.
      iimonth = 0.
      iiday = 0.
   end.
end.
    if iimonth = 0 and iiyear = 0 then iiday = iiday - 1.
    if iiday < 0 then iiday = 0.

End procedure.
