/* v-rmtrxv.p
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
     11.07.2005 dpuchkov- добавил формирование корешка
     13.01.2012 damir - добавил keyord.i, printord.p
     07.03.2012 damir - добавил входной параметр в printord.p.
     12.03.2012 damir - добавил печать операционного ордера в WORD.
*/

/* checked */
/* v-remout.p
   print outward remittance voucher
   01/02/92 by john d. seo
*/
{global.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

define new shared var s-jh like jh.jh.
define shared var s-remtrz like remtrz.remtrz.

def var Yesno as logi.

find remtrz where remtrz.remtrz eq s-remtrz no-error.
find first jh where jh.jh = remtrz.jh1 no-lock no-error .
if not avail jh then do :
    run x-vou(input remtrz.remtrz, "rmz").
    return .
end.
s-jh = remtrz.jh1.
hide all.
{mesg.i 0809}.

if v-noord = no then run yn('','Печатать ','Операционный ордер ? ','',output Yesno ).
else Yesno = yes.

if Yesno then do:

    if v-noord = yes then run printvouord(2). /*WORD Операционный ордер*/

    /* Добавлено печать корешка */
    find first acheck where acheck.jh = string(remtrz.jh1) and acheck.dt = g-today  no-lock no-error.
    if avail acheck then do:
        find first jl where jl.jh = s-jh and jl.gl = 100100  no-lock no-error.
        if avail jl and dc = 'd' then do:
            if v-noord = no then run vou_bank2(1,1, "").
            else run printord(s-jh,"").
        end.
        else if avail jl and dc = 'c' then do:
            if v-noord = no then run vou_bank2(1,2, "").
            else run printord(s-jh,"").
        end.
        else do:
            if v-noord = no then run vou_bank2(1, 1, "").
            else run printord(s-jh,"").
        end.
    end.
    else do:
        /* Добавлено печать корешка */
        if v-noord = no then run vou_bank(1).
        else run printord(s-jh,"").
    end.
end.
pause 0 .
run yn('','Печатать','ордер на перевод (RMZ) ?','',output Yesno ).

if Yesno then run x-jlvouP.
pause 0.

find jh where jh.jh eq remtrz.jh1.
for each jl of jh.
    if jl.sts < 5 then  do:
        jl.sts = 5.
        jl.teller = userid('bank').
    end.
end.
if jh.sts < 5 then jh.sts = 5.
