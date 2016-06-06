/* x-jlgens.p
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
        25.12.2001 sasco   - после удаления проводки - изменение cashofc
        18.11.2002 sasco   - find first jl - в начале для вывода jl.rem
        24.02.2003 sasco   - добавлена печать через vou_bank
        09.09.2003 sasco   - печать БКС
        02.12.2003 nadejda - запрещен штамп в этом пункте
        27.01.2004 sasco   - убрал today для cashofc
        02.03.2004 kanat   - добавил вызов bks с параметром BWX для карточных транзакций
        19.07.2004 sasco   - убрал cashofc для опции "3" - печать
        21.01.2005 sasco   - убрал весь лишний мусор, связанный с созданием, штампом и удалением проводок
        29.09.2006 u00568 Evgeniy - по тз 469 пусть печатает чек бкс по 100200
        24.11.09 marinav - увеличена форма
        13.01.2012 damir - добавил keyord.i, printord.p, printbks.p
        16.01.2012 damir - добавил vou_bankoperord.p
        06.03.2012 damir - добавил printvouord.p.
        07.03.2012 damir - добавил печать операционного ордера для ДВО, входной параметр в printord.p...
*/


{global.i}
{keyord.i} /*Переход на новые и старые форматы ордеров*/

def buffer t-rem for rem.
def buffer b-bank for bank.
def var vdc like glbal.bal.
def var rnew as log initial false.
def shared var s-jh like jh.jh.
def new shared var s-acc like jl.acc.
def new shared var s-aaa like aaa.aaa.
def new shared var s-gl like gl.gl.
def new shared var s-jl like jl.ln.
def new shared var s-aah  as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def new shared var vcif like cif.cif.
def var vacc like jl.acc.
def var vans as log.
def var vrem like jl.rem.
def var vbal like jl.dam.
def var vdam like vbal.
def var vcam like vbal.

def var vop  as int format "z".
def new shared var vpart as log.
def new shared var vcarry as dec.
define var fv  as cha.
define var inc as int.
define var oldround as log.
def var i as int.
def new shared var rtn as log initial no.

define variable s_payment as char.

{jhjl.f}

find jh where jh.jh eq s-jh.
find first jl where jl.jh eq s-jh no-lock no-error.

main:
repeat:
    pause 0.
    {x-jlvf.i}
    vop = 0.
    message " 3)Печать  6)Ордер  7)БКС   8)Опер. ордер 9) Матричный (Опер. ордер)" update vop.
    if vop eq 3 /* Print */ then do transaction:
        hide all.
        run x-jlvou.
        if jh.sts ne 6 then do :
            for each jl of jh :
                jl.sts = 5.
            end.
            jh.sts = 5.
        end. /* sts ne 6 */
        {x-jlvf.i}
    end. /* 3. Print */
    else if vop eq 6 /* ОРДЕР */ then do:
        if v-noord = no then run vou_bank(2).
        else run printord(s-jh,"").
    end.
    else if vop eq 7 then /* БКС */ do:
        s_payment = ''.
        if jh.sts = 6 then do:
            for each jl where jl.jh = jh.jh and jl.jdt = jh.jdt and (jl.gl = 100100  or jl.gl = 100200  or jl.gl = 100300) no-lock:
                find first crc where crc.crc = jl.crc no-lock no-error.
                s_payment = s_payment + string(jh.jh) + "#" + jl.rem[1] + jl.rem[2] + jl.rem[3] + jl.rem[4] + jl.rem[5] + "#" +
                string(jl.dam + jl.cam) + "#" + "" + "#" + "1" + "#" + crc.code + "|".
            end.
            s_payment = right-trim(s_payment,"|").
            if s_payment <> '' then do:
                if jh.party = "BWX" then do:
                    run bks (s_payment,"BWX").
                end.
                else do:
                    run bks (s_payment,"TRX").
                end.
            end.
        end.
    end.
    else if vop eq 8 then do:
        if v-noord = no then run vou_bankoperord(2). /*Матричный принтер - Операционный ордер*/
        else run printvouord(2). /*WORD Операционный ордер*/
    end.
    else if vop eq 9 then do:
        run vou_bankoperord(2). /*Матричный принтер - Операционный ордер*/ /*ДВО*/
    end.
    {x-jltot.i}

    if vbal ne 0 then do:
        bell.
        {mesg.i 0256}.
    end.
end. /* main */
