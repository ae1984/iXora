/* cods-com.p
 * MODULE
        Вставка кодов доходов - расходов 
 * DESCRIPTION
        Вставка кодов доходов - расходов для коммунальных платежей
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
        30/03/06 marinav
 * CHANGES
*/


def input  param v-gl 	as inte	no-undo. 
def input  param v-depd as char	no-undo. 
def input  param v-type as char	no-undo. 

def shared var s-jh like jh.jh.

for each jl where jl.jh = s-jh no-lock:
    if string(jl.gl) matches "4*" then do:
         find last trxcods where trxcods.trxh = s-jh and trxcods.trxln = jl.ln and trxcods.codfr = 'cods' exclusive-lock no-error. 
         if not avail trxcods then next.

         find first cods where cods.gl = v-gl and cods.arc = no and cods.info[1] = v-type no-lock no-error.
         if avail cods then trxcods.code =  cods.code + v-depd.
         release trxcods.
    end.
end.

