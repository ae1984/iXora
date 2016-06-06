/* vcmsg101chps.p Валютный контроль
   Выбор одного паспорта сделки из нескольких похожих при загрузке МТ101

   27.12.2002 nadejda
   21.01.2004 nadejda - сортировка ПС в обратном порядке
*/

{global.i}

def output parameter vps like vcps.ps.

def shared temp-table t-ps
  field contract like vccontrs.contract
  field ps like vcps.ps
  field dndate like vcps.dndate
  field dnnum like vcps.dnnum
  field sum like vcps.sum
  field ncrccod as char
  field expimp as char
  index main is primary dndate DESC dnnum DESC ps DESC.

{jabro.i 
&head      =  "t-ps"
&headkey   =  "ps"
&formname  =  "vc101psc"
&framename =  "f-ps"
&where     =  " true "
&index     =  "main"
&addcon    =  "false"
&deletecon =  "false"
&predisplay = " "
&display   =  " t-ps.dndate t-ps.dnnum t-ps.sum t-ps.ncrccod t-ps.expimp "
&highlight =  " t-ps.dndate t-ps.dnnum t-ps.sum t-ps.ncrccod t-ps.expimp "
&postkey   =  " else if keyfunction(lastkey) = 'return' then do:
                  vps = t-ps.contract.
                  leave upper.
                end."
&end =        " hide frame f-ps."
}

