/* jl-prca.p
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
        06.03.2012 damir - переход на новые форматы, нередактируемые документы.
        13.03.2012 damir - добавил возможность печати на матричный принтер пользователей которые есть в printofc.
        14.03.2012 damir - перекомпиляция.
*/

{global.i}
{keyord.i} /*Переход на новые и старые форматы форм*/

def shared var s-jh like jh.jh.
def var xin  as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ВЗНОС   ".
def var xout as dec decimals 2 format "-z,zzz,zzz,zzz,zz9.99" label "ВЫПЛАТА ".
def var intot  like xin.
def var outtot like xout.

def stream v-out.
def stream v-out2.

def var v-file  as char init "Rep1.htm".
def var v-file2 as char init "Rep2.htm".
def var v-inputfile as char init "/data/export/report.htm".
def var v-str       as char.

output stream v-out  to value(v-file).
output stream v-out2 to value(v-file2).

input from value(v-inputfile).
repeat:
    import unformatted v-str.
    v-str = trim(v-str).
    put stream v-out unformatted v-str.
end.
input close.

find jh where jh.jh eq s-jh.
xin  = 0.
xout = 0.
output to vou.img page-size 0.

{jl-prca.f}

output close.

if v-noord = no then do:
    unix silent prit -t vou.img.
end.
else do:
    find first printofc where trim(printofc.ofc) = trim(g-ofc) and lookup(trim(g-fname),trim(printofc.fname)) > 0  no-lock no-error.
    if avail printofc then unix silent prit -t vou.img.
    else unix silent cptwin value(v-file2) winword.
end.

pause 0.
