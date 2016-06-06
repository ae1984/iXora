/* tk-del.p
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
        19.03.04 nataly добавлено удаление проводок по шаблону ock0018
        13/05/2004 madiar - добавил второй входной пар-р (true/false) в trxdel - показывать запрос причины удаления транзакции или нет.
        25.03.2005 saltanat - удаление занесла в одну транзакцию, внесла выход без отката при rcod=50.
        13.05.2005 saltanat - Внесла проставление старого статуса при передачи на акцепт.
*/

/*edited by Natalya P.
  tickets transaction is deleted and announcement message is displayed  */
{mainhead.i "INTDEL"} 
def new shared var s-jh like jh.jh.

def var rcode as int.
def var rdes as char. 
def var ja as log.
def var v-jdt as date.
def var v-our as log.
def var v-lon as log.
def var v-finish as log.  
def var v-cash as log.
def var vou-count as int.
def var v-cashgl like gl.gl.
def var i as int.
def var v-sts as int.
def var s-jhold like jh.jh.
def var v-trx as log.
def var v-lev2 as log.
def var s-aaa like aaa.aaa.
def var s-trx like jl.trx.
def var sts like jh.sts.

DEFINE VARIABLE v-method AS char FORMAT "x(8)" label "Номер транзакции"
VIEW-AS FILL-IN /* EDITOR size-char 50 by 1 NO-WORD-WRAP */
.
def button btn1 label "Ok".
def button btn2 label "Cancel".

def frame ln1 v-method skip
     btn1 at 10 btn2 at 50 with centered side-label scrollable.


find sysc where sysc.sysc = "cashgl" no-lock.
v-cashgl = sysc.inval.


def var v-s as char.

ja = no.
on choose of btn1 in frame ln1
do :
 v-s = v-method.
 ja = yes.
end.

on choose of btn2 in frame ln1
do :
 v-s = "".
 ja = no.
end.
  
 
 
ON GO OF v-method
DO:
    v-s = v-method.
END.
                     
on return of v-method 
do:
 apply "go" to v-method in frame ln1.
end.

ENABLE v-method btn1 btn2 WITH FRAME ln1.

update v-method validate(can-find(jh where jh.jh eq integer(v-method)),
"Укажите номер транзакции")
with frame ln1 .

wait-for choose of btn1 in frame ln1
or choose of btn2 in frame ln1 .

if not ja then return.

s-jhold = integer(v-method).

if ja then do :
    v-jdt = g-today.
    v-our = yes.
    v-trx = no.
    v-finish = no.
    v-cash = no.
    v-lev2 = no.

    for each jl where jl.jh eq s-jhold no-lock:
        if jl.sts eq 6 then v-finish = yes.  
        if jl.gl eq v-cashgl then v-cash = yes.
        if jl.jdt ne g-today then v-jdt = jl.jdt.
        if jl.who ne g-ofc then v-our = no.
        if jl.trx = 'uni0154' or jl.trx = 'ock0018' then v-trx = yes.
   /*     if jl.lev eq 2 then do:
            find aaa where aaa.aaa eq jl.acc no-lock no-error.
            if available aaa then do:
                v-lev2 = yes.
                s-aaa = aaa.aaa.
                s-trx = jl.trx.
            end.
        end.  */
    end.    

    find jh where jh.jh eq s-jhold no-lock no-error.
    if not v-our then do :
      message "Вы не можете удалить чужую транзакцию."
      VIEW-AS ALERT-BOX INFORMATION BUTTONS OK. 
      return.
    end.
    if v-finish and v-cash then do:
        message "Вы не можете удалить выполненную кассовую транзакцию."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        return.
    end.
    if not v-trx /*or not v-lev2*/ then do:
        message "Транзакция не связана с выплатой по TICKET."
        VIEW-AS ALERT-BOX INFORMATION BUTTONS OK.
        return.
    end.
     
    ja = no.
    if v-jdt ne g-today then do :
        message "Транзакция не текущего дня. Выполнить сторно?"
        VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO update ja.
        if not ja then return.
    end.

    if v-jdt eq g-today then do :
        v-sts = 0.
        sts = jh.sts.
        
        run trxsts(input s-jhold, input v-sts, output rcode, output rdes).
        
       if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            return.
        end.

        run trxdel(input s-jhold, input true, output rcode, output rdes). 
         
      if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            if rcode eq 50 then run trxsts(input s-jhold, input sts, output rcode, output rdes).
            return.
        end. 

         find ticket where ticket.jh2 = s-jhold exclusive-lock no-error.
         ticket.jh2 = 0. ticket.dt2 = ?. 
         release ticket.

   find jl where jl.jh eq s-jhold  no-lock no-error.
       if not available jl  then do :
         message 'Транзакция ' s-jhold ' была успешно удалена'.
         pause 20.
       end.
   end.  /* nataly v-jdt eq g-today - транзакция сегодня */
   else do:
        v-sts = 0.
        run trxstor(input s-jhold, input v-sts, output s-jh,
        output rcode, output rdes).
         
        if rcode ne 0 then do:
            message rdes VIEW-AS ALERT-BOX.
            return.
        end.
         find ticket where ticket.jh2 = s-jhold exclusive-lock no-error.
         ticket.jh2 = 0. ticket.dt2 = ?. 
         release ticket.
    
        /* pechat vauchera */
        ja = no.
        vou-count = 1. /* kolichestvo vaucherov */
        find jh where jh.jh eq s-jh no-lock no-error.
        do on endkey undo:
            message "Печатать ваучер ? " + string(s-jh) view-as alert-box 
            buttons yes-no update ja.
            if ja
            then do:
                 message "Сколько ?" update 
                 /* view-as alert-box set */ vou-count.
                if vou-count > 0 and vou-count < 10 then do:
                    find first jl where jl.jh = s-jh no-error.
                    if available jl 
                    then do:
                        {mesg.i 0933} s-jh.
                        do i = 1 to vou-count:
                            run x-jlvou.
                        end.
                
                        if jh.sts < 5
                        then jh.sts = 5.
                        for each jl of jh:
                            if jl.sts < 5
                            then jl.sts = 5.
                        end.
                    end.  /* if available jl */
                    else do:
                        message 
                        "Can't find transaction " s-jh view-as alert-box.
                        return.
                    end.
                end.  /* if vou-count > 0 */
            end. /* if ja */
            pause 0.
        end.   /* on endkey*/
        pause 0.
        view frame lon.
        view frame ln1.
        ja = no.
        message "Штамповать ?" update ja.
        if ja
        then run jl-stmp.
    end.  /* else do */
end. /*if ja*/

return.           
           
