/* trxoda.p
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

{global.i}
def buffer b-aaa for aaa.
def var bbal like aaa.cbal.
def var abal like aaa.cbal.
def var v-amt like aaa.cbal.
def var v-aaad like aaa.aaa.
def var v-aaac like aaa.aaa.
def var v-param as char.
def var rcode as int.
def var rdes as char. 
def var vdel as char initial "^".
def var v-templ as char.
def var s-jh like jh.jh.
def var v-str1 as char.
def var v-str2 as char.
s-jh = 0.
for each lgr where lgr.led = "DDA" no-lock,
each aaa where aaa.lgr = lgr.lgr no-lock :
    find b-aaa where b-aaa.aaa eq aaa.craccnt no-error.
    if available b-aaa then do:
        abal = aaa.cr[1] - aaa.dr[1].
        bbal = b-aaa.dr[1] - b-aaa.cr[1].
        if (abal eq 0 and bbal ge 0) or (abal ge 0 and bbal eq 0)  then next. 
        v-templ = "CIF0007".
        v-str1 = "".
        v-str2 = "".
        if abal ge 0 and  bbal ge 0 then do :
            v-aaad = aaa.aaa.
            v-aaac = b-aaa.aaa.
            if abal ge bbal then v-amt = bbal.
            else v-amt = abal.
        end.
        else do:
            v-aaad = b-aaa.aaa.
            v-aaac = aaa.aaa.
            if (abal ge 0 and bbal lt 0) or (abal lt 0 and abal gt bbal) 
            then v-amt = - bbal. else v-amt = - abal.
        end.    
        if v-aaad eq aaa.aaa then v-str1 = "O/D PAYMENT".
        else v-str1 = "O/D PROTECT FOR CHECK 0".
        if v-amt ne 0 then do:
            v-param = 
            string(v-amt) + vdel + v-aaad + vdel + v-aaac
            + vdel + v-str1 + vdel +
            string(0) + vdel + b-aaa.aaa + vdel + aaa.aaa + vdel + v-str2.
            run trxgen (v-templ, vdel, v-param, "CIF" , aaa.aaa , 
            output rcode, output rdes, input-output s-jh).
            if rcode ne 0 then do:
                message rdes.
                pause.
                undo, return.
            end.
        end.
    end.
end.
if s-jh ne 0 then run trxsts(s-jh, 6, output rcode, output rdes).
