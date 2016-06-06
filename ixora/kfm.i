/* kfm.i
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Общие таблицы, переменные
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
        30/03/2010 madiyar
 * BASES
        BANK COMM
 * CHANGES
        27/05/2010 galina - перекомпиляция
        01/06/2010 galina - добавила no-undo в таблицы
        20/07/2010 galina - добавила переменную s-operType
*/

def {1} shared var kfmres as logi no-undo.
kfmres = no.

def {1} shared var s-ourbank as char no-undo.
find first sysc where sysc.sysc = "ourbnk" no-lock no-error.
if not avail sysc or sysc.chval = "" then do:
   display " There is no record OURBNK in bank.sysc file !!".
   pause.
   return.
end.
s-ourbank = trim(sysc.chval).

def {1} shared temp-table t-kfmoperh no-undo like kfmoperh
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def {1} shared temp-table t-kfmprt no-undo like kfmprt.

def {1} shared temp-table t-kfmprth no-undo like kfmprth
    field showOrder as integer
    field dataName as char
    field dataSpr as char
    field dataValueVis as char
    index idx_sort showOrder.

def {1} shared var v-dopres as logi.
def {1} shared var s-operType as char.

function getVisual returns char (input p-dataCode as char, input p-value as char).
    def var res as char no-undo.
    res = p-value.
    find first kfmkrit where kfmkrit.dataCode = p-dataCode no-lock no-error.
    if avail kfmkrit then do:
        if trim(kfmkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = kfmkrit.dataSpr and codfr.code = p-value no-lock no-error.
            if avail codfr then res = p-value + ' - ' + codfr.name[1].
        end.
        else do:
            if kfmkrit.dataType = 'd' and p-value <> '' then res = string(date(p-value),"99/99/9999") no-error.
        end.
    end.
    return res.
end function.

