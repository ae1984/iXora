/* asts-jls.p
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

def input parameter v-jh like jl.jh.
def input parameter vv-ast like ast.ast.
def var vbal like jl.dam.
def var vdam like jl.dam.
def var vcam like jl.cam.
def buffer b-jl for jl.
def buffer b-jh for jh.
def buffer b-astjln for astjln.
def var vsts as inte.
def new shared var s-jh like jh.jh.
def new shared var s-aah as int.
def new shared var s-line as int.
def new shared var s-force as log initial false.
def var v-cifname like cif.name.
s-jh = v-jh.

{mainhead.i}

main:
repeat:

{apbra.i
&start = "    find jh where jh.jh = s-jh no-lock.
              vcam = 0.
              vdam = 0.
              vbal = 0.
          for each jl where jl.jh = s-jh use-index jhln no-lock:
              vcam = vcam + jl.cam.
              vdam = vdam + jl.dam.
          end.
              vbal = vdam - vcam.
              disp vbal with frame bal.
              disp vdam vcam with frame tot.
              disp jh.jh jh.jdt jh.who with frame jh.
              disp jh.cif jh.party jh.crc with frame party.
              if jh.cif <> '' then do:
               find cif where cif.cif = jh.cif no-lock no-error.
               v-cifname =trim(trim(cif.prefix) + ' ' + trim(cif.name)).
               if available cif then disp v-cifname @ jh.party with frame party.
              end.
              "
&head = "jl" 
&headkey = "ln" 
&where = "jl.jh = s-jh" 
&index = "jhln"
&addcon = "false"
&deletecon = "false"
&formname = "jhjlj" 
&framename = "jl"
&prechoose = "disp jl.rem with frame rem. {imesg.i 410}."
&predisplay = "find first gl where gl.gl = jl.gl no-lock no-error."
&display = "jl.ln jl.gl gl.sname when available gl jl.crc jl.acc jl.dam jl.cam"
&highlight = "jl.ln"
&postkey = "else if keyfunction(lastkey) = '3' then do transaction:
               run x-jlvou.
               
               if jh.sts <> 6 then do:
                  for each jl of jh:
                   jl.sts = 5.
                  end.
                  jh.sts = 5.
               end.
               next main.
            end.
            else if keyfunction(lastkey) = '4' then do:
/* lll */
     find first b-astjln where b-astjln.ajh>s-jh and b-astjln.aast=vv-ast 
           no-lock no-error.
     if avail b-astjln then do: message ' Удалите oпер.#' + string(b-astjln.ajh).
          pause 4. hide frame rem.  hide frame jl. hide frame tot.
                   hide frame bal. hide frame party. hide frame jh.
          return.
     end.                      
     find first b-astjln where b-astjln.ajh=s-jh and b-astjln.aast<>vv-ast 
        use-index ajh  no-lock no-error. 
     if avail b-astjln then do: vv-ast=b-astjln.aast. 
       find first b-astjln where b-astjln.ajh>s-jh and b-astjln.aast=vv-ast 
           no-lock no-error. 
       if avail b-astjln then do: message ' Удалите опер.#' + string(b-astjln.ajh).
          pause 4. hide frame rem.  hide frame jl. hide frame tot.
                   hide frame bal. hide frame party. hide frame jh.
          return.
       end.  
     end.
/* lll */
               find b-jh where b-jh.jh = v-jh no-lock.
                 vsts = b-jh.sts.
               if b-jh.who ne g-ofc then do:
                   bell. {imesg.i 0602}. next inner.  
                 end.

              find sysc where sysc.sysc eq 'CASHGL' no-lock .
               for each b-jl where b-jl.jh = v-jh no-lock:
                 if vsts < b-jl.sts then vsts = b-jl.sts.
                 if b-jl.jdt<g-today then do:
                   message 'Дата операции ' b-jl.jdt '. Удалить нельзя. Выполните сторно. '.
                             pause 4. next inner.  
                 end.
                 if b-jl.gl eq sysc.inval and vsts > 5 then do:
                    message 'Кассовая операция !!! Обратитесь к администратору '
                    + string(vsts) + ')' chr(7) chr(7) chr(7). pause 5. next inner.
                 end.

               end.
               run x-jlsub22.
               next main.
            end.
            else if keyfunction(lastkey) = '5' then do:
               {imesg.i 6811} update vans.
               if vans then run jl-stmp.
            end."
&end = "leave main."
}

end. /*main*/
hide frame rem.  hide frame jl. 
hide frame tot. hide frame bal. hide frame party. hide frame jh.

