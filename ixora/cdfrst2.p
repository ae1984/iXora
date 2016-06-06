/* cdfrst.p
 * MODULE
        Ценные бумаги
 * DESCRIPTION
        Работа с кодификатором ЦБ 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        11-9-3  
 * BASES
        BANK 
 * AUTHOR
        05.01.04  nataly
 * CHANGES
*/

/* ======================================================================
=                                                                        =
=                        Codificator Settings                                =
=                                                                        =
====================================================================== */



define shared variable g-ofc            as character format "x(20)".
define shared variable g-lang           as character.
define shared variable g-today          as date.
define shared variable g-comp           like cmp.name.
define shared variable g-batch          as logical.

define buffer b_codific for codific.
define buffer b_codfr        for codfr.

define variable ext_codfr        as character.
define variable crecid                as recid.

define variable target        as character initial "prit".        
define new shared variable codfrname         as character.

form
   target format "x(20)" label "Отчет в "
with side-label at row 11 column 2 frame u.   


define variable upd_name as character format "x(125)".

form
codfr.name[1]
codfr.name[2]
codfr.name[3]
codfr.name[4]
codfr.name[5]
with 7 down title "Введите новое значение поля" overlay row 12 column 2 frame upd_form.        

run info.

{jabro.i

&start     =        " "
&head      =         "codific"
&headkey   =         "codific"
&index     =         "codfr_idx"
&formname  =         "f_codific"
&framename =         "f_codific"
&where     =         " codific.codfr = 'secur' "
&addcon    =         "true"
&deletecon =         "false"
&predelete =         "
                   for each codfr where codfr.codfr = codific.codfr.
                     delete codfr.
                   end. 
                " 
&precreate =         " "
&postadd    =         
                "
               /*  update codific.codfr codific.name with frame f_codific.
                 codific.codfr = lc(codific.codfr). 
                 codific.who = g-ofc.
                 codific.whn = g-today.
                 display codific.who codific.whn with frame f_codific.
                 
                 create codfr .
                  codfr.codfr  = codific.codfr.
                  codfr.code = 'msc'.
                  codfr.level = 1.
                  codfr.child = no.
                  codfr.name[1] = 'Остальные'.   
                   */
                "  
&prechoose =         " "
&predisplay =         " "
&display   =         "
                 codific.codfr format 'x(8)'
                 codific.name  format 'x(45)'
                 codific.who   format 'x(8)'
                 codific.whn   format '99/99/99'
                "
&highlight =         "codific.codfr
                 codific.name
                 codific.who
                 codific.whn"
&postkey   =         " 
                 else 
                 if keyfunction(lastkey) = 'return' then do:
                    ext_codfr = codific.codfr.
                    crecid = recid(codific).
                    codfrname = codific.name. 
                    run set_codfr.
                 end.
                 else 
                 if keyfunction(lastkey) = 'о' then do:
                    ext_codfr = codific.codfr.
                    crecid = recid(codific).
                    codfrname = codific.name. 
                    update target with frame u.
                    run cdfrrep.
                    if return-value = '1' then return.
                 end.
                "
&end =                 " 
                 hide frame f_codific. 
                "
}



procedure set_codfr:

{jabro.i

&start     =        " "
&head      =         "codfr"
&headkey   =         "codfr"
&index     =         "main"
&formname  =         "f_codfr"
&framename =         "f_codfr"
&where     =         " codfr.codfr = ext_codfr "
&addcon    =         "true"
&deletecon =         "true"
&predelete =         "
                 if codfr.papa <> 'codfr.code' then do:
                    find first b_codfr where b_codfr.codfr = ext_codfr and
                                             b_codfr.papa = codfr.papa and
                                             recid(b_codfr) <> recid(codfr) no-lock no-error.
                    if not available b_codfr then do:
   find b_codfr where b_codfr.codfr = ext_codfr and b_codfr.code = codfr.papa    exclusive-lock no-error.
                         if available b_codfr then do:
                            b_codfr.child = no. 
                         end.
                    end.                         
                 end.
                " 
&precreate =         " "
&postadd    =         "
                  codfr.codfr = ext_codfr. 
                  update codfr.code with frame f_codfr.
         /*         codfr.papa = codfr.code.
                  update codfr.papa codfr.name[1] with frame f_codfr. */ 
                  
                  codfr.code = lc(codfr.code).
    /*              codfr.papa = lc(codfr.papa).      */
             find first b_codfr where b_codfr.codfr = ext_codfr 
             and b_codfr.code          = codfr.papa exclusive-lock no-error. 
                  if available b_codfr then do: 
 /*                  b_codfr.child = yes.   */ 
                     codfr.level = b_codfr.level + 1.
                     codfr.tree-node = b_codfr.tree-node + CHR(255) +
                        codfr.code.
                  end.   
                  else do: 
                     codfr.level = 1.
                      codfr.tree-node = ext_codfr + CHR(255) + codfr.code.
                  end.   
                  
                  
                " 
&prechoose =         " "
&predisplay =         " "
&display   =         "
       (fill(' ', codfr.level - 1) + codfr.code)  @ codfr.code  format 'x(11)'
              /*   codfr.papa  format 'x(8)'   */ 
            substring(codfr.name[1] + codfr.name[2] + codfr.name[3] + 
                codfr.name[4] + codfr.name[5],1,63) 
                                @ codfr.name[1] format 'x(63)'
                "
&highlight =         "codfr.code"
&postkey   =         "
                 else 
                 if keyfunction(lastkey) = 'return' then do transaction:
                    find codfr where recid(codfr) = crec exclusive-lock.
                    
                    update /* codfr.code codfr.papa */ codfr.name[1] with frame f_codfr.
                    codfr.code = lc(codfr.code).
          /*        codfr.papa = lc(codfr.papa).  */ 
                    display (fill(' ', codfr.level - 1) + codfr.code)  @ codfr.code
                        /*  codfr.papa */ 
                  (substring (codfr.name[1] + codfr.name[2] + codfr.name[3] + codfr.name[4] + codfr.name[5], 1, 63)) @ codfr.name[1] with frame f_codfr.
                  end.
                 else 
                 if keyfunction(lastkey) = 'end-error' then do:
                    leave upper.
                 end.
                "
&end =                 " hide frame f_codfr.
                "
}
 

end.

procedure cdfrrep:

  define variable nju                 as character.
  
  message "Создание отчета ... ".

  output to "rpt.img".

  nju = "x(" + string(length(trim(codfrname))) + ")".
  put skip(1).
  put codfrname format nju " report:" "                          " g-today " at " string(time, "HH:MM").


  display "Code                             Papa     Name".
  display "-------------------------------- -------- ---------------------------------".

  
  for each codfr where codfr.codfr = ext_codfr and codfr.code <> ? no-lock.
     display (fill(' ', codfr.level - 1) + codfr.code)  @ codfr.code  format 'x(32)'
             codfr.papa  format 'x(8)'
             codfr.name[1]  format 'x(33)' with no-label frame bobik.
  end.
  

  display "--- End of report ---------------------------------------------------------" with no-label frame p.
  
  output close.   
  
  message "Создание отчета закончено.".
  pause 1 no-message.
  
  target  = target + " rpt.img". 
  unix silent value (target).
  pause 0 no-message.
  hide frame u.
  
  if target matches ("*joe*") then 
     return "1". 
  else 
     return "0".
end.

procedure info:
  
 display 
   "<Enter>  - Работа с кодификатором " at row 1 column 1
   "<о>       - Создать отчет"         at row 2 column 1
   "<up/down> - Выбор кодификатора"   at row 3 column 1
   "<F4>      - Выход"                         at row 4 column 1        
 with no-label title "Помощь" at row 12 column 2 frame jj.
   
end.
