/* ibcomjou.i
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


    if joudoc.cracc = "019467476"
    then do: 

        define var kcell-ref as char format "x(10)" init "0".
        define var i_rid as integer.
        define var s_name as char.
        define var i-kcell_phone as integer.
	define var v-kcell_phones as char.

        if joudoc.jh <> 0 and joudoc.jh <> ? then kcell-ref = joudoc.docnum.

        if length(trim(joudoc.rem[2])) = 7 then do:
                                                i-kcell_phone = int(trim(joudoc.rem[2])) no-error.
                                                if i-kcell_phone = 0 then v-kcell_phones = "0000000".
                                                               else v-kcell_phones = trim(joudoc.rem[2]).
                                           end.
                                           else v-kcell_phones = "0000000".
        i_rid = 1.
        s_name = ''.

        run chgsts ("jou", joudoc.docnum, "mb3"). 

        if comm-txb() = "TXB00" then do:                                                                  
           create mobtemp.                                                                                
           assign mobtemp.valdate = today                                                                    
                  mobtemp.cdate = g-today                                                                   
                  mobtemp.ctime = time                                                                    
                  mobtemp.sum = joudoc.cramt
                  mobtemp.who = g-ofc                                                                     
                  mobtemp.state = 3                                                                       
                  mobtemp.phone = v-kcell_phones
                  mobtemp.ref = kcell-ref
                  mobtemp.joudoc = kcell-ref
                  mobtemp.rid = i_rid
                  mobtemp.info = s_name.
                  mobtemp.npl = trim(joudoc.rem[1]) + trim(joudoc.rem[2])
                  no-error.                                                                               
        end.                                                                                              
        else run ibcomtxa (today, g-ofc, kcell-ref, v-kcell_phones, joudoc.cramt, trim(joudoc.rem[1]) + trim(joudoc.rem[2]), i_rid, s_name).

    end.
