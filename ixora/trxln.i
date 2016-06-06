/* trxln.i
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

def {1} shared var jl-gl like gl.gl.
def {1} shared var jl-crc like jl.crc.
def {1} shared var jl-acc like jl.acc.
def {1} shared var jl-dam like jl.dam.
def {1} shared var jl-cam like jl.cam.
def {1} shared var jl-rem like jl.rem.
def {1} shared var s-jh like jh.jh.
def {1} shared var rcode as logi.
def {1} shared var rdes as char format "x(60)".
def {1} shared var s-consol like jh.consol.
def {1} shared var s-line as inte.
def {1} shared var s-force as logi initial false.
