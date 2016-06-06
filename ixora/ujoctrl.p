/* ujoctrl.p
 * MODULE
        Контроль универсальных операций
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

 * BASES
      BANK COMM
 * CHANGES
       12/10/2011  Luiza
       26.03.2012 damir  - добавил keysign.i, сохранение документов для отображения подписей в ордерах.
       27.03.2012 damir  - перекомпиляция.
       11.04.2012 damir  - добавил signdocum.p.
       13.04.2012 damir  - изменил формат с "yes/no" на "да/нет".
       10.05.2012 damir  - перекомпиляция.
*/



{global.i}
{keysign.i}

def var v-num as char format "x(10)" label "Документ".
def var v-sub as char format "x(3)" label "Признак" init "ujo".
def var ans as log format "да/нет".
def var v-who like ofc.ofc.
define variable uni_template    as character format "x(7)".
define variable repl_line       as integer initial 1.
define variable repl_value      as integer.
define variable trx_header      as integer.
define variable seq_number as char format "x(10)".
define variable v_date as date.
define variable v-fio    as character format "x(50)".


update v-num v-sub validate(can-find(trxsub where trxsub.subled = v-sub) ,
 "Неверный признак") with frame req side-label row 3 centered.

find cursts where cursts.acc = v-num and cursts.sub = v-sub no-lock no-error.
if not avail cursts or (avail cursts and cursts.sts = "e28") then do :
  display cursts.
  message "Нехватка средств для проведения операции!". pause.
  return.
end.
if not avail cursts or (avail cursts and cursts.sts = "err") then do :
  display cursts.
  message "Документ необходимо отредактировать". pause.
  return.
end.

if not avail cursts or (avail cursts and cursts.sts <> "new") then do :
  display cursts.
  message "Документ не подлежит контролю ". pause.
  return.
end.

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

define frame uni_main
"
__________________________________________________________________________________________" skip(1)
    seq_number label "Документ " format 'x(10)'
    v_date label "Дата документа"
    uni_template  label "Шаблон" skip
    v-fio         label "Клиент(наименование/ФИО)" format "x(50)" skip(1)
    b_link skip(1)
    skip(2)
    with row 3 width 95 side-labels no-box no-hide.

if v-sub = "ujo" then do:

    find ujo where ujo.docnum = v-num no-lock no-error.
    if not avail ujo then do :
       message "Документа в системе нет". pause.
       return.
    end.
    v-who = ujo.who.
    uni_template = ujo.sys + ujo.code.
    seq_number = ujo.docnum.
    v_date = ujo.whn.
    v-fio = ujo.info.
    displ seq_number v_date uni_template v-fio with frame uni_main.
    run Ujo_query.

    open query q_link for each ujolink where ujolink.docnum eq ujo.docnum,
    each w-par where w-par.v-d eq ujolink.docnum and
    w-par.v-i eq ujolink.parnum no-lock.
    browse b_link:read-only = true.
    browse b_link:sensitive = false.
    enable b_link with frame uni_main.
    apply "entry" to browse b_link.
end.





Message "Контролировать ? " update ans.

if v-who = g-ofc then do:
   message g-ofc " не может контролировать свои платежи". pause.
   return.
end.


if ans then do:
    run chgsts(input v-sub, v-num, "con").
    if v-transsign = yes then run signdocum(input v-sub,input v-num).
end.

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

Procedure Ujo_line.
    define input parameter refer_number like ujolink.docnum.
    define input parameter param_number like ujolink.parnum.
    define input parameter remark       as logical.

    define input parameter t_des as character.
    define input parameter account as logical.

    do transaction on error undo, retry:

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
