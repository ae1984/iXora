/* cods2.i
 * MODULE
        Вставка кодов доходов - расходов 
 * DESCRIPTION
        Вставка кодов доходов - расходов 
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
        01/04/05 nataly
 * CHANGES
        26/05/06 nataly добавила код доходов 
*/
   if substr(string(jl.gl),1,1) = '5'  or substr(string(jl.gl),1,1) = '4' then do:

       find first cods where cods.gl =  gl.gl  no-lock no-error.
       if not avail cods 
        then do:
              v-code = "0000000".   v-dep = "000".
        end.
        else do:
              v-code = cods.code.   v-dep = cods.dep. 
        end.
       create trxcods. 
              assign 
                 trxcods.trxh  = jl.jh
                 trxcods.trxln = jl.ln
                 trxcods.codfr = 'cods'
                 trxcods.code = v-code + v-dep.
    end.  /*drgl = '5'*/
