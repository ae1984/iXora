/* jlcopy.p
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
        07/05/2004 madiar  - добавил запрос причины удаления транзакции
        11/05/2004 madiar  - не выводить запрос причины удаления при пакетном удалении транзакций (под логинами суперпользователей)
        11.05.2004 nadejda - добавила обработку endkey, иначе по F4 отменялось вообще копирование транзакции
        13/05/2004 madiar  - добавил input parameter showreas - выводить или не выводить запрос причины удаления (задается при вызове trxdel -> jlcopy)
*/

{global.i}
def shared var s-jh like jh.jh.
def input parameter showreas as logi.
def var s-info as char init "".

define frame fr skip(1)
       s-info  no-label VIEW-AS EDITOR SIZE 73 by 8 
               help " Введите данные и нажмите F1 для продолжения работы" 
               validate (s-info <> "", " Введите данные! ") skip(1)
       with overlay width 75 side-labels centered row 5
       title " ПРИЧИНА УДАЛЕНИЯ ТРАНЗАКЦИИ ".

find sysc where sysc.sysc = "supusr" no-lock no-error.
if lookup(g-ofc, sysc.chval) = 0 and showreas then 
  /* обязательно с такой обработкой, иначе по F4 откатывается вся процедура и проводка не копируется */
  do on endkey undo, retry:
    update s-info with frame fr.
  end.


        for each jl where jl.jh eq s-jh :
            create deljl.
            deljl.aah = jl.aah.
            deljl.aax = jl.aax.
            deljl.acc = jl.acc.
            deljl.bal = jl.bal.
            deljl.bytim = time.
            deljl.bywhn = today.
            deljl.bywho =
            string(jl.crc,"999") + " " +
            userid('bank') + " " + g-ofc + " " + string(g-today).
            deljl.cam = jl.cam.
            deljl.consol = jl.consol.
            deljl.dam = jl.dam.
            deljl.dc = jl.dc.
            deljl.gl = jl.gl.
            deljl.jdt = jl.jdt.
            deljl.jh = jl.jh.
            deljl.ln = jl.ln.
            deljl.rec = jl.rec.
            deljl.rem[1] = jl.rem[1].
            deljl.rem[2] = jl.rem[2].
            deljl.rem[3] = jl.rem[3].
            deljl.rem[4] = jl.rem[4].
            deljl.rem[5] = jl.rem[5].

            /*

            deljl.crc = jl.crc.

            */



            deljl.sts = jl.sts.
            deljl.teller = jl.teller.
            deljl.tim = jl.tim.
            deljl.whn = jl.whn.
            deljl.who = jl.who.
        end.
        find jh where jh.jh eq s-jh .
        create deljh.
        deljh.bytim = time.
        deljh.bywhn = today.
        deljh.bywho = string(jh.crc,"999") + " " +
        userid('bank') + " " + g-ofc + " " + string(g-today).
        deljh.cif = jh.cif.
        deljh.consol = jh.consol.
        /*
            deljh.crc = jl.crc.
        */
        if s-info <> "" then deljh.del = s-info.
        else deljh.del = jh.del.
        
        deljh.jdt = jh.jdt.
        deljh.jh = jh.jh.
        deljh.party = jh.party.
        deljh.post = jh.post.
        deljh.sts = jh.sts.
        deljh.tim = jh.tim.
        deljh.tty = jh.tty.
        deljh.whn = jh.whn.
        deljh.who = jh.who.
return.
