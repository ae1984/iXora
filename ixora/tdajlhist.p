/* tdajlhist.p
 * MODULE
        Депозиты
 * DESCRIPTION
        Просмотр проводок по депозиту TDA
 * RUN
        
 * CALLER
        tdainfo1.p
 * SCRIPT
        
 * INHERIT
        
 * MENU
        1.1, 1.2, 10.7.3
 * AUTHOR
        31/12/99 pragma
 * CHANGES
        20.06.2004 nadejda - переделала на вывод временной таблицы, а то сортировки проводок никакой не было
        02.03.2010  marinav - для 20-значного счета искать историю старого 9-значного
*/

def input parameter vaaa like aaa.aaa.
def shared var g-lang as char.
def buffer b-aaa for aaa.

def temp-table t-jl
  field jh like jl.jh
  field ln like jl.ln
  field jdt like jl.jdt
  field amt like jl.dam
  field dc like jl.dc
  field rem like jl.rem
  index main is primary unique jdt jh ln.

for each jl where jl.acc = vaaa and jl.lev = 1 no-lock use-index acc :
  create t-jl.
  buffer-copy jl to t-jl.
  t-jl.amt = if jl.dc = "D" then jl.dam else jl.cam.
end.

find first b-aaa where b-aaa.aaa20 = vaaa no-lock no-error.
if avail b-aaa then do: 
    for each jl where jl.acc = b-aaa.aaa and jl.lev = 1 no-lock use-index acc :
      create t-jl.
      buffer-copy jl to t-jl.
      t-jl.amt = if jl.dc = "D" then jl.dam else jl.cam.
    end.
end.  

{jabro.i
&start = " "
&head = "t-jl"
&headkey = "jh"
&where = " true "
&index = "main"
&formname = "tdajlhist"
&framename = "jl"
&addcon = "false"
&deletecon = "false"
&viewframe = " "
&predisplay = " "
&display = "t-jl.jh t-jl.ln t-jl.jdt t-jl.amt t-jl.dc t-jl.rem[1]"
&highlight = "t-jl.jh"
&predelete = " "
&precreate = " "
&postadd = " "
&prechoose = " "
&postdelete = " "
&postkey = " "
&end = "hide frame jl. hide message."
}
