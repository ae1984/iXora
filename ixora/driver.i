/* driver.i
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
 * CHANGES
*/


/* --------------------------------- */
/* ССЫЛКИ НА ТЕКУЩИЙ ШАБЛОН И ЯЧЕЙКУ */
/* --------------------------------- */

def shared var g-ofc as char.

def {1} var v-root as int.
def {1} var v-pid as int.
def {1} var v-id as int.
def {1} var v-depth as int.
def {1} var v-rname as char.
def {1} var v-pname as char.
def {1} var v-name as char.
def {1} var v-roundby as int.
def {1} var v-uniq as int.
def {1} var v-maxid as int.
def {1} var v-txb as int.


/* ----------------------------- */
/* СТАНДАРТНЫЕ ПАРАМЕТРЫ ЗАПУСКА */
/* ----------------------------- */

def {1} var v-date1 as date init ?.      /* дата отчета, также - начало периода */ 
def {1} var v-date2 as date init ?.      /* конец периода                       */
def {1} var v-cons as logical init ?.    /* консолидированный отчет или нет     */
def {1} var v-rko as logical init ?.     /* разбивать по РКО или нет            */
def {1} var v-detlog as logical init ?.  /* вести подробный LOG                 */


/* -------------------------- */
/* ПАРАМЕТРЫ ЗАПУСКА DRIVER.P */
/* -------------------------- */

def {1} var pro_res as dec.     /* результат запуска pro() */
def {1} var is_batch as logical init no.

/* ------------------------------- */
/* ВРЕМЕННЫЕ ВНУТРЕННИЕ ПЕРЕМЕННЫЕ */
/* ------------------------------- */

def {1} temp-table tmpvars
               field name as char
               field val as dec.


def buffer b-rephead for rephead.


/* ---------------------------- */
/* ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ      */
/* ---------------------------- */

         /* вернуть uniq по номеру root */
function GET-UNIQ returns integer (vr as int).
    find rephead where rephead.root = vr no-lock no-error.
    if avail rephead then return rephead.uniq.
                     else return ?.
end function.

         /* вернуть uniq по имени root */
function GET-UNIQN returns integer (vrn as char).
    find rephead where rephead.name = vrn no-lock no-error.
    if avail rephead then return rephead.uniq.
                     else return ?.
end function.

         /* вернуть max id в шаблоне по номеру root */
function GET-MAXID returns integer (vr as int).
    def var mmx as int.
    find rephead where rephead.root = vr no-lock no-error.
    if avail rephead then select max(id) into mmx from report where report.root = vr.
                     else mmx = ?.
    return mmx.
end function.

         /* вернуть depth - глубину ячейки в шаблоне */
function GET-DEPTH returns integer (vr as int, vid as int).
    def var mmx as int.
    find rephead where rephead.root = vr no-lock no-error.
    if avail rephead then select max(report.depth) into mmx from report where report.root = vr and report.id = vid.
                     else mmx = ?.
    return mmx.
end function.

/* - - - - - - - - - - - - - - - - - - - - - - - */

         /* может запускать */
function IF-CAN-RUN returns logical.
    find repsec where repsec.type = 1 and repsec.ofc = g-ofc and repsec.root = v-root and repsec.txb = v-txb no-lock no-error.
    if not avail repsec then return no.
                        else return yes.
end function.

         /* может создавать отчеты */
function IF-CAN-CREATE returns logical.
    find repsec where repsec.type = 2 and repsec.ofc = g-ofc and repsec.txb = v-txb no-lock no-error.
    if not avail repsec then return no.
                        else return yes.
end function.

         /* может изменять отчеты */
function IF-CAN-MODIFY returns logical.
    find repsec where repsec.type = 3 and repsec.ofc = g-ofc and repsec.root = v-root and repsec.txb = v-txb no-lock no-error.
    if not avail repsec then return no.
                        else return yes.
end function.

         /* может удалять отчеты */
function IF-CAN-DELETE returns logical.
    find repsec where repsec.type = 4 and repsec.ofc = g-ofc and repsec.txb = v-txb no-lock no-error.
    if not avail repsec then return no.
                        else return yes.
end function.

         /* может редактировать результаты */
function IF-CAN-IRES returns logical.
    find repsec where repsec.type = 5 and repsec.ofc = g-ofc and repsec.root = v-root and repsec.txb = v-txb no-lock no-error.
    if not avail repsec then return no.
                        else return yes.
end function.


/* - - - - - - - - - - - - - - - - - - - - - - - - */
/*  Функции  для  переноса  результатов ячеек      */
/*  параметр ii = номер ID ячейки                  */
/*  параметр set_cando = сбрасывать ли флаг canDo  */
/* - - - - - - - - - - - - - - - - - - - - - - - - */

          /* переменные для переноса */
def var ival as decimal.
def var irnd as decimal.

          /* получить пару значений ival, irnd */
procedure GETVALS.
     def input parameter ii as int.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     no-lock use-index ri no-error.
     if avail ires then assign ival = ires.val
                               irnd = ires.round.
                   else assign ival = 0
                               irnd = 0.
end procedure.
          /* вернуть значение ires.val */
function GETVAL returns decimal (ii as int).
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     no-lock use-index ri no-error.
     if avail ires then return ires.val.
                   else return 0.0.
end function.
          /* вернуть значение ires.round */
function GETRND returns decimal (ii as int).
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     no-lock use-index ri no-error.
     if avail ires then return ires.round.
                   else return 0.0.
end function.

          /* записать пару значений ival, irnd */
procedure PUTVALS.
     def input parameter ii as int.
     def input parameter set_cando as logical.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     use-index ri no-error.
     if avail ires then 
     if ires.cando then do:
              assign ires.val = ival 
                     ires.round = irnd.
              if set_cando then ires.cando = NO.
     end.
end procedure.
          /* записать значение ires.val */
procedure PUTVAL.
     def input parameter ii as int.
     def input parameter vv as decimal.
     def input parameter set_cando as logical.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     use-index ri no-error.
     if avail ires then
     if ires.cando then do:
             ires.val = vv.
             ires.round = round (vv / v-roundBy, 2).
             if set_cando then ires.cando = NO.
     end.
end procedure.
          /* записать значение ires.round */
procedure PUTRND.
     def input parameter ii as int.
     def input parameter vv as decimal.
     def input parameter set_cando as logical.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     use-index ri no-error.
     if avail ires then
     if ires.cando then do:
             ires.round = vv.
             if set_cando then ires.cando = NO.
     end.
end procedure.

          /* скопировать значения ires.val, ires.round */
procedure COPYCELL.
     def input parameter i1 as int.
     def input parameter i2 as int.
     def input parameter set_cando as logical.
     def var iv as decimal.
     def var ir as decimal.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = i1 and ires.ofc = g-ofc
                     no-lock use-index ri no-error.
     if avail ires then do:
        iv = ires.val.
        ir = ires.round.
        find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                        ires.date1 = v-date1 and ires.date2 = v-date2 and
                        ires.id = i2 and ires.ofc = g-ofc
                        use-index ri no-error.
        if avail ires then
        if ires.cando then do:
                ires.val = iv.
                ires.round = ir.
                if set_cando then ires.cando = NO.
        end.
     end.
end procedure.

          /* прибавить значения ires.val, ires.round */
procedure ADDVALS.
     def input parameter ii as int.
     def input parameter set_cando as logical.
     find ires where ires.root = v-root and ires.txb = v-txb and ires.uniq = v-uniq and
                     ires.date1 = v-date1 and ires.date2 = v-date2 and
                     ires.id = ii and ires.ofc = g-ofc
                     use-index ri no-error.
     if avail ires then
     if ires.cando then do:
                ires.val = ires.val + ival.
                ires.round = ires.round + irnd.
                if set_cando then ires.cando = NO.
     end.
end procedure.
