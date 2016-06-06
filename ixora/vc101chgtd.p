/* vcmsg101chps.p Валютный контроль
   Выбор одного паспорта сделки из нескольких похожих при загрузке МТ101

   27.12.2002 nadejda
   21.01.2004 nadejda - сортировка ГТД в обратном порядке
*/

{global.i}

def output parameter vdocs like vcdocs.docs.

def shared temp-table t-oldgtd like vcdocs
  index sort contract dntype dndate DESC dnnum DESC docs DESC.

{jabro.i 
&head      =  "t-oldgtd"
&headkey   =  "docs"
&formname  =  "vc101gtd"
&framename =  "f-chgtd"
&where     =  " true "
&index     =  "sort"
&addcon    =  "false"
&deletecon =  "false"
&predisplay = " "
&display   =  " t-oldgtd.dndate t-oldgtd.dnnum t-oldgtd.sum t-oldgtd.pcrc t-oldgtd.payret "
&highlight =  " t-oldgtd.dndate t-oldgtd.dnnum t-oldgtd.sum t-oldgtd.pcrc t-oldgtd.payret "
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                  vdocs = t-oldgtd.docs.
                  leave upper.
                end."
&end =        " hide frame f-chgtd."
}

