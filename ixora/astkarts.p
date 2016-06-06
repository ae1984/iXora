/* astkarts.p
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

/* 11.04.2003 Sasco - запись перемещения по департаментам в историю */

/* k-parsk.p */ 

define new shared variable v-attnn like ast.name.
define new shared var v-ast like ast.ast format "x(8)".

define shared var g-ofc as char.
define shared var g-today as date.

define var v-codfr like codfr.codfr.
define var v-fil as char.
define var old-attn as char.
define var old-inv as char.

define buffer b-ast for ast.

{astp2.f}

hide all.
main:
repeat:

 hide all no-pause. 
 clear frame astp.
    prompt ast.ast with frame astp.
    find ast using ast.ast no-lock no-error.
    v-ast=ast.ast.
    if not available ast then do:
        bell. message "AST КАРТ. НЕТ".  undo, retry.
    end.

 find ast where ast.ast=v-ast no-lock.

 find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.  
   if available codfr then v-attnn = codfr.name[1].

 find sub-cod where sub-cod.acc = v-ast and sub-cod.sub= "ast" 
       and d-cod = "brnchs" no-lock no-error. 
 if avail sub-cod then  v-fil = sub-cod.ccode. else v-fil="".   
 
 display ast.ast ast.addr[2] ast.name ast.attn v-attnn
         with frame astp.

    pause 0.
    find ast where ast.ast=v-ast exclusive-lock.


    /* инвентарный номер */
    old-inv = ast.addr[2].
    update  ast.addr[2] validate (not can-find (first b-ast where b-ast.addr[2] = ast.addr[2] no-lock),
                                  'Такой инвентарный номер уже существует!')
                                  with frame astp.


    /* место расположения */
    old-attn = ast.attn.
    update ast.attn validate(can-find(codfr where codfr.codfr = "sproftcn" and 
        codfr.code = ast.attn and codfr.code matches "..."),
             "Кода " + ast.attn + " нет в словаре") with frame astp.
    find codfr where codfr.codfr = "sproftcn" and codfr.code = ast.attn no-lock no-error.  
    if available codfr then 
    do: 
      v-attnn = codfr.name[1]. 
      displ v-attnn with frame astp. 
      if ast.attn <> old-attn then do:
        create hist.
        assign hist.date = g-today
               hist.who = g-ofc
               hist.ctime = time
               hist.pkey = "AST"
               hist.skey = ast.ast
               hist.op = "MOVEDEP"
               hist.chval[1] = ast.attn     /* новый деп. */
               hist.chval[2] = old-attn     /* старый деп. */
               hist.chval[3] = old-inv      /* старый инв.н. */
               hist.chval[4] = ast.addr[2]. /* новый инв.н. */
      end.
    end. 

    find ast where ast.ast=v-ast no-lock.

end.
