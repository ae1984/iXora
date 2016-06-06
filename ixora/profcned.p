/* profcned.p
 * MODULE
        справочник профит-центров
 * DESCRIPTION
        справочник профит-центров
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        9-1-2-15 
 * AUTHOR
        18.10.2002 nadejda создан
 * CHANGES
        16.05.05 nataly добавлен код доходов-расходов (codfr.name[4] = codfr.code where codfr.codfr = 'sdep')
        14.06.05 nataly добавлен код департамента модуля ЗАРПЛАТЫ codfr.name[3]
        03.11.06 u00121 увеличил формат поля codfr.name[4] до 6 символов
*/



{mainhead.i PROFCNED}
{comm-txb.i}

define variable s_rowid as rowid.
def var v-title as char init "ПРОФИТ-ЦЕНТРЫ".
def var v-codif as char init "sproftcn".
def var v-bank as char.
   def new shared temp-table v-deps  /*14.06.05 nataly*/
      field dep as char
      field depname as char
        index dep is primary   dep .
   run zatrat0.                      /*14.06.05 nataly*/


v-bank = comm-txb().
/*form cods.des VIEW-AS EDITOR SIZE 60 by 10 
 with frame y  overlay  row 14  centered top-only no-label.
  */
{jabrw.i 
&start     = "displ v-title format 'x(50)' at 16 with row 4 no-box no-label frame pcheader."
&head      = "codfr"
&headkey   = "code"
&index     = "codfr"

&formname  = "profcned"
&framename = "pced"
&where     = " codfr.codfr = v-codif and codfr.code <> 'msc' "

&addcon    = "true"
&deletecon = "true"
&postcreate = "codfr.codfr = v-codif. codfr.level = 1."
&prechoose = "displ 'F4 - выход,  INS - вставка,  F10 - удалить,  P - печать' 
  with centered row 22 no-box frame pcfooter.

  on help of codfr.name[4] in frame pced do:  /* 16.05.05 nataly */
     run help-dep('000'). 
    if return-value <> '' then do: 
      codfr.name[4] = return-value. displ codfr.name[4] with frame pced. end.   end. /* 16.05.05 nataly */
  on help of codfr.name[3] in frame pced do:  /* 14.06.05 nataly */
     run help-attn. 
    if return-value <> '' then do: 
      codfr.name[3] = return-value. displ codfr.name[3] with frame pced. end.   end. /* 14.06.05 nataly */
  on help of codfr.name[5] in frame pced do: run taxnkall. 
    if return-value <> '' then do: 
      codfr.name[5] = return-value. displ codfr.name[5] with frame pced. end. end.  "

&predisplay = " if codfr.name[5] <> '' then do:
                  find taxnk where taxnk.rnn = codfr.name[5] no-lock no-error.
                   if avail taxnk then v-nkname = taxnk.name.
                end. else v-nkname = ''. "

&display   = " codfr.code codfr.name[1] codfr.name[3] codfr.name[4] codfr.name[5] v-nkname "    /* 16.05.05 nataly */

&highlight = " codfr.code codfr.name[1] codfr.name[3] codfr.name[4] codfr.name[5] v-nkname "
&update   = " codfr.code codfr.name[1]                   /*14.06.05 nataly*/
              codfr.name[3] /*validate (сan-find(v-deps where v-deps.dep = codfr.name[3] no-lock) , 'Неверно задан код деп-та модуля ЗАРПЛАТЫ!') */
              codfr.name[4] validate (codfr.name[4] = '000' or 
               can-find(codfr where codfr.codfr = 'sdep' and codfr.code = codfr.name[4] no-lock) , 'Неверно задан код расходов/доходов! ' + codfr.name[4] ) 
              codfr.name[5] "                                                    /* 16.05.05 nataly */
&postupdate = " codfr.codfr = v-codif. codfr.level = 1. 
         codfr.tree-node = codfr.codfr + CHR(255) + codfr.code. 
         if codfr.name[5] <> '' then do:
           find taxnk where taxnk.rnn = codfr.name[5] no-lock no-error.
            if avail taxnk then v-nkname = taxnk.name.
         end. else v-nkname = ''. 
         displ codfr.name[5] v-nkname with frame pced. "

&postkey   = "else if keyfunction(lastkey) = 'P' then 
                      do:
                         s_rowid = rowid(codfr).
                         output to sproftcn.img .
                         for each codfr where codfr.codfr = v-codif no-lock:
                             if codfr.name[5] <> '' then do:
                               find taxnk where taxnk.rnn = codfr.name[5] no-lock no-error.
                                if avail taxnk then  v-nkname = taxnk.name.
                             end. else v-nkname = ''.                                              /* 16.05.05 nataly */
                             display codfr.code codfr.name[1] format 'x(50)' codfr.name[4] format 'x(3)' codfr.name[5] v-nkname format 'x(25)' with width 300.
                         end.
                         output close.
                         output to terminal.
                         run menu-prt('sproftcn.img').
                         find codfr where rowid(codfr) = s_rowid no-lock.
                      end. "

&end = "hide frame pced. hide frame pcheader. hide frame pcfooter."
}
hide message.

