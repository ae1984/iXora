/* kfm.i
 * MODULE
        Финансовый мониторинг
 * DESCRIPTION
        Функции валидации
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
*/

function validkrtype returns logi (input p-dataCode as char, input p-value as char).
    def var res as logi no-undo init yes.
    def var v-dt as date no-undo.
    def var v-i as integer no-undo.
    def var v-r as decimal no-undo.
    def var v-l as logical no-undo.
    /*def var v-logs as char init "yes,y,no,n,true,t,false,f,да,д,нет,н,0,1".*/
    def var v-logs as char init "yes,no,y,n,да,нет,д,н,0,1".
    find first kfmkrit where kfmkrit.dataCode = p-dataCode no-lock no-error.
    if avail kfmkrit then do:
        case kfmkrit.dataType:
            when 'i' then do:
                v-i = integer(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'r' then do:
                v-r = deci(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'd' then do:
                v-dt = date(p-value) no-error.
                if error-status:error then res = no.
            end.
            when 'l' then do:
                if lookup(p-value, v-logs) = 0 then res = no.
            end.
        end case.
    end.
    return res.
end function.

function validh returns logi (input p-dataCode as char, input p-value as char, output p-errMsg as char).
    def var res as logi no-undo init yes.
    find first kfmkrit where kfmkrit.dataCode = p-dataCode no-lock no-error.
    if avail kfmkrit then do:
        if trim(kfmkrit.dataSpr) <> '' then do:
            find first codfr where codfr.codfr = trim(kfmkrit.dataSpr) and codfr.code = p-value no-lock no-error.
            if not avail codfr then assign res = no p-errMsg = "Значение отсутствует в справочнике!".
        end.
        else do:
            if trim(kfmkrit.valProc) <> '' then do:
                run value(trim(kfmkrit.valProc)) (p-value,output res, output p-errMsg).
            end.
            else do:
                res = validkrtype(p-dataCode,p-value).
                if not res then p-errMsg = "Введено некорректное значение!".
            end.
        end.
    end.
    return res.
end function.


/*############ функции валидации ###############################*/

/* поле "Наим/ФИО уч. (от имени/по поруч)" - в режим редактирования пускает только при выборе в поле "Вид участника (по фин. влиянию)" вариантов
   "от имени" или "по поручению", а выйти не введя значение не разрешает */
procedure validPrtFrom.
    def input parameter p-value as char no-undo.
    def output parameter p-res as logi no-undo.
    def output parameter p-errMsg as char no-undo.
    if trim(p-value) = '' then assign p-res = no p-errMsg = "Введите ФИО/наименование участника (от имени/по поручению)!".
    else p-res = yes.
end procedure.

procedure val-digit.
    def input parameter p-val as char no-undo.
    def output parameter p-res as logi no-undo.
    def output parameter p-mess as char no-undo.
    def var i as integer no-undo.
    def var v-digit as char init "0123456789".
    p-res = yes.
    do i = 1 to length(p-val):
        if index(v-digit, substr(p-val, i, 1)) = 0 then do:
            p-res = no.
            leave.
        end.
    end.
    if not p-res then p-mess = "Введены нецифровые символы!".
end.

{chk12_innbin.i}

procedure validIIN.
    def input parameter p-value as char no-undo.
    def output parameter p-res as logi no-undo.
    def output parameter p-errMsg as char no-undo.
    p-res = chk12_innbin(p-value).
    if not p-res then p-errMsg = "Некорректный ИИН/БИН!".
end procedure.

procedure validRNN.
    def input parameter p-value as char no-undo.
    def output parameter p-errRes as logi no-undo.
    def output parameter p-errMsg as char no-undo.
    def var v-len as integer init 12.

    p-errMsg = "".

    if p-value = "" then do:
        assign p-errRes = no p-errMsg = "Введите РНН!".
        return.
    end.

    find first sysc where sysc.sysc = "rnnlen" no-lock no-error.
    if avail sysc then v-len = sysc.inval.
    if length(p-value) <> v-len then do:
        assign p-errRes = no p-errMsg = "РНН должен иметь длину " + string(v-len) + " символов!".
        return.
    end.

    run val-digit (p-value, output p-errRes, output p-errMsg).
    if not p-errRes then return.

    def var v-l as logi init no.
    run rnnchk(p-value, output v-l).
    if v-l then do:
        p-errRes = no.
        p-errMsg = "Неверный контрольный ключ РНН!".
    end.
end procedure.
