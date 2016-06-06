/* cashsp.p
 * MODULE
        Название модуля
 * DESCRIPTION
        Описание
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        02.03.12 Lyubov
 * BASES
        BANK COMM
 * CHANGES
        26.09.2012 Lyubov - некорректно определялся ГК, исправила
        30.09.2013 damir - Внедрено Т.З. № 1496.
*/

def input param p-crc like crc.crc.
def var v-gl like gl.gl.
define shared var vgl as inte.
define shared var bdt as date.
define shared var edt as date.
define shared var tdt as date.

def var ln as inte.

def buffer b-jl for jl.

{cashjl.i}

for each jl no-lock where jl.jdt >= bdt and jl.jdt <= edt and jl.gl eq vgl and jl.crc = p-crc use-index jdt,
    each gl no-lock where gl.gl eq jl.gl,
         jh no-lock where jh.jh eq jl.jh break by gl.gl by jl.crc by jl.cam by jl.dam by jl.jh:

        for each b-jl where b-jl.jh = jl.jh and b-jl.gl ne vgl no-lock break by b-jl.jh:
           if jl.dc = 'D' then ln = jl.ln + 1.
           else ln = jl.ln - 1.
           if b-jl.ln eq ln then v-gl = b-jl.gl.
        end.

        create t-jl.
        t-jl.gl = v-gl.
        t-jl.jh = jl.jh.
        t-jl.dam = jl.dam.
        t-jl.cam = jl.cam.
        t-jl.who = jl.who.
        t-jl.tel = jl.teller.
        t-jl.jdt = jl.jdt.
        t-jl.crc = jl.crc.
        t-jl.tim = jh.tim.
        t-jl.rem[1] = jl.rem[1].
        t-jl.rem[2] = jl.rem[2].
        t-jl.dc = jl.dc.
        if jl.dc = "d" then t-jl.cd = 1.
        else t-jl.cd = 2.
        t-jl.ln = jl.ln.
end.