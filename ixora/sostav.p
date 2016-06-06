/* sostav.p
 * MODULE
        Количественный состав клиентской базы 
 * DESCRIPTION
        Количественный состав клиентской базы 
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        1-7-1-16-4 
 * AUTHOR
        01/12/2005 nataly
 * CHANGES
        06/12/05 nataly отброшены клиенты с датой открытия > v-dat2
        12/07/06 u00600 добавлены условия по датам в биометрии - cli.bio
*/

def shared var v-dat1 as date.
def shared var v-dat2 as date.

def shared temp-table cli
      field cif like bank.cif.cif
      field bank as char
      field type as char     /*b-ЮЛ, p-ФЛ*/
      field dep as char
      field sort  as char /*n-новый, o-старый*/
      field inet as char  /*n-новый, o-старый, "a" -  не работает*/
      field shtr as char  /*n-новый, o-старый, "a" -  не работает*/
      field bio as char.  /*n-новый, o-старый, "a" -  не работает*/

def shared temp-table totcli
      field cif as char
      field bank as char
      field type as char     /*b-ЮЛ, p-ФЛ*/
      field dep as char
      field priz  as char /*bio/sort/shtr/inet*/
      field val as char   /*n-новый, o-старый, "a" -  не работает*/
      field amt as integer /*n-новый, o-старый, "a" -  не работает*/
      field bio as char.   /*n-новый, o-старый, "a" -  не работает*/

for each txb.cif /* where integer(substr(cif.cif,2,5)) < 10400*/ no-lock.
     if cif.regdt > v-dat2 then next.
  find first txb.aaa where aaa.cif  = cif.cif and aaa.sta <> 'C' no-lock no-error.
  if not avail txb.aaa then  do:  next. end.

create cli.
    cli.cif = cif.cif.
  
    find txb.sysc where sysc.sysc = 'OURBNK' no-lock no-error.
    if avail sysc then cli.bank = sysc.chval.
    find  comm.txb where txb.bank = cli.bank and consolid = true.  if avail txb then cli.bank = txb.name. 
    if cif.biom = yes then do:  /*u00600*/
      cli.bio = 'o'.
      find last txb.biomprz where txb.biomprz.cif = txb.cif.cif and (txb.biomprz.dt >= v-dat1 and txb.biomprz.dt <= v-dat2) no-lock no-error.
      if avail txb.biomprz and txb.biomprz.sts then cli.bio = 'n'. 
    end.

    else cli.bio = 'a'.
        

 if cif.regdt >=  v-dat1 and  cif.regdt <=  v-dat2 then cli.sort = 'n'. else cli.sort = 'o'.
    cli.type = cif.type. 

    find txb.ppoint where ppoint.depart = (integer(cif.jame) mod 1000) no-lock no-error.
    if avail ppoint then 
       cli.dep = ppoint.name.
    else 
       cli.dep = 'не задан'.
/*          message cli.bank cli.cif cli.dep.*/

  find first txb.sub-cod where 
    sub-cod.d-cod = "scann " and
    sub-cod.sub   = "cln"    and
    sub-cod.acc   = string( cif.cif ) 
    no-lock no-error.
    if avail txb.sub-cod and  sub-cod.ccode = "t"  then do: 
      if sub-cod.rdt >=  v-dat1 and  sub-cod.rdt <=  v-dat2 then cli.shtr = 'n'. 
       else cli.shtr = 'o'.
     end.
    else cli.shtr = "a".

end. /*for each cif*/

