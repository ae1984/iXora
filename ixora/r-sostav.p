/* r-sostav.p
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
*/

{mainhead.i}

def new shared var v-dat1 as date.
def new shared var v-dat2 as date.
def var v-day as date.
def stream rpt.
def buffer d-sub-cod for sub-cod.
def buffer e-sub-cod for sub-cod.

def var c1 as char.
def var c-temp as char.
def var i as int.
def var chief as char.
def var sek-ek as char.
def var v-name as char.
def var sum1 as integer.
def var sum2 as integer.
def var sum3 as integer.
def var sum4 as integer.

def new shared temp-table cli
      field cif like bank.cif.cif
      field bank as char
      field type as char     /*b-ЮЛ, p-ФЛ*/
      field dep as char
      field sort  as char /*n-новый, o-старый*/
      field inet as char  /*n-новый, o-старый, "a" -  не работает*/
      field shtr as char  /*n-новый, o-старый, "a" -  не работает*/
      field bio as char.  /*n-новый, o-старый, "a" -  не работает*/

def new shared temp-table totcli
      field cif as char
      field bank as char
      field type as char     /*b-ЮЛ, p-ФЛ*/
      field dep as char
      field priz  as char /*bio/sort/shtr/inet*/
      field val as char   /*n-новый, o-старый, "a" -  не работает*/
      field amt as integer /*n-новый, o-старый, "a" -  не работает*/
      field bio as char.   /*n-новый, o-старый, "a" -  не работает*/


def temp-table totcli2
      field type as char     /*b-ЮЛ, p-ФЛ*/
      field bank as char
      field dep as char
      field sort as integer /*n-новый, o-старый*/
      field inet as integer  /*n-новый, o-старый, "a" -  не работает*/
      field shtr as integer  /*n-новый, o-старый, "a" -  не работает*/
      field bio  as integer.  /*n-новый, o-старый, "a" -  не работает*/

def buffer b-totcli for totcli.
def buffer c-totcli for totcli.

def buffer b1-totcli for totcli.
def buffer b2-totcli for totcli.
def buffer b3-totcli for totcli.
def buffer b4-totcli for totcli.
def buffer b5-totcli for totcli.

update v-dat1 label " Укажите период С .." format "99/99/9999" 
       validate(v-dat1 ge 12/19/1999 and v-dat1 le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня") skip
       v-dat2 label "               ПО .." format "99/99/9999"
       validate(v-dat2 ge 12/19/1999 and v-dat2 le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame dat .
                     
display "   Ждите...   "  with row 5 frame ww centered .


 find first cif where cif.regdt >= v-dat1  and cif.regdt <=  v-dat2 no-lock no-error.
if not avail cif then do.
   message "За период С " v-dat1 " ПО " v-dat2 " нет новых клиентов!".
   return.
end.                    

{r-branch.i &proc = "sostav"}

/*клиенты интернет-офиса*/
for each  ib.usr  no-lock .

 find cli where cli.cif = usr.cif  no-error.
  if not avail cli then do: 
/*     message 'Не найден клиент ' usr.cif. pause 300.*/
     next.
  end.
 find first  ib.hist where  ib.hist.idusraff = ib.usr.id 
                       and ib.hist.type1     = 2 
                       and ib.hist.type2     = 1 
                       and ib.hist.procname  = "IBPL_CrUsr" no-lock no-error.
 if avail ib.hist and  ib.hist.wdate >= v-dat1 and ib.hist.wdate <= v-dat2 then cli.inet = 'n'. else cli.inet = 'o'.

end.   
  
def stream rpt.
output stream rpt to 'rpt.img'.

     /*биометрия*/
 for each cli where cli.bio <> 'a' break by cli.type by cli.bank by cli.dep by cli.bio .
  accum cli.cif (count by cli.type).
  accum cli.cif (count by cli.dep).
  accum cli.cif (count by cli.bio).


   put stream rpt skip  cli.bank ' '  cli.dep ' ' cli.cif ' ' 'bio' ' '  cli.bio.
  if last-of(cli.bio) then do: 
    create totcli. 
      totcli.type = cli.type.
      totcli.bank = cli.bank.
      totcli.dep = cli.dep.
      totcli.priz = 'bio'.
      totcli.val  =  cli.bio.
      totcli.amt =  accum count by cli.bio cli.cif .
      totcli.cif = '1'.
 end.
 end. 

     /*новый-старый клиент*/
 for each cli  break by cli.type  by cli.bank by cli.dep by cli.sort.
  accum cli.cif (count by cli.type).
  accum cli.cif (count by cli.dep).
  accum cli.cif (count by cli.sort).

  if last-of(cli.sort) then do: 
    create totcli. 
      totcli.type = cli.type.
      totcli.bank = cli.bank.
      totcli.dep = cli.dep.
      totcli.priz = 'sort'.
      totcli.val  =  cli.sort.
      totcli.amt =  accum count by cli.sort cli.cif .
      totcli.cif = '1'.
 end.
 end.

     /* клиент интернет офиса*/
 for each cli  where cli.inet = 'n' or cli.inet = 'o' break by cli.type by cli.bank by cli.dep by cli.inet.
  accum cli.cif (count by cli.type).
  accum cli.cif (count by cli.dep).
  accum cli.cif (count by cli.inet).

  if last-of(cli.inet) then do: 
    create totcli. 
      totcli.type = cli.type.
      totcli.bank = cli.bank.
      totcli.dep = cli.dep.
      totcli.priz = 'inet'.
      totcli.val  =  cli.inet.
      totcli.amt =  accum count by cli.inet cli.cif .
      totcli.cif = '1'.
 end.
 end.  

     /* клиент со штрих-кодом*/
 for each cli  where cli.shtr = 'n' or cli.shtr = 'o' break by cli.type by cli.bank by cli.dep by cli.shtr.
  accum cli.cif (count by cli.type).
  accum cli.cif (count by cli.dep).
  accum cli.cif (count by cli.shtr).

   put stream rpt skip  cli.bank ' '  cli.dep ' ' cli.cif ' ' 'shtr' ' '  cli.shtr.
  if last-of(cli.shtr) then do: 
    create totcli. 
      totcli.type = cli.type.
      totcli.bank = cli.bank.
      totcli.dep = cli.dep.
      totcli.priz = 'shtr'.
      totcli.val  =  cli.shtr.
      totcli.amt =  accum count by cli.shtr cli.cif .
      totcli.cif = '1'.
 end.
 end.
    /*считаем итоги*/
  for each totcli break by totcli.type by totcli.bank by totcli.dep by totcli.priz.
    accum totcli.cif (count by totcli.type).
    accum totcli.cif (count by totcli.dep).
    accum totcli.amt (total by totcli.priz).


  if last-of(totcli.priz) then  do:

  find totcli2 where totcli2.dep = totcli.dep and totcli2.bank = totcli.bank and totcli2.type =  totcli.type no-lock no-error.
  if not avail totcli2 then do:
      create totcli2. 
       totcli2.dep = totcli.dep.
       totcli2.type = totcli.type.
       totcli2.bank = totcli.bank.
  end.

    if totcli.priz = 'sort' then totcli2.sort = accum total by totcli.priz totcli.amt.
    if totcli.priz = 'inet' then totcli2.inet = accum total by totcli.priz totcli.amt.
    if totcli.priz = 'shtr' then totcli2.shtr = accum total by totcli.priz totcli.amt. 
    if totcli.priz = 'bio' then totcli2.bio = accum total by totcli.priz totcli.amt. 
  end.
  end.

 output stream rpt close.
/*вывод на печать*/
def new shared  stream vcrpt.
def var p-filename as char init "sostav.html".
output stream vcrpt  to value(p-filename).


{html-title.i &stream = " stream vcrpt " &title = " " &size-add = "x-"}


put  stream vcrpt unformatted "<p align=center><b> Количественный состав клиентской базы (количество клиентов, имеющих действующие счета в банке) за период С " v-dat1 " ПО " v-dat2 "<br>" skip 
                "Время " STRING(TIME,'HH:MM:SS') "<br>" skip 
                "Исполнитель " g-ofc "<br>" skip "</b></p>"  skip
    "<TABLE border=""1"" cellspacing=""0"" cellpadding=""9"">" skip.

  put stream vcrpt unformatted
     "<TR align=""center"" style=""font:bold"">" skip 
       "<TD>Наименование СПФ/филиала</TD>" skip
       "<TD>Общее кол-во клиентов</TD>" skip
       "<TD>Кол-во новых за период</TD>" skip
       "<TD>Общее кол-во клиентов по И-офису</TD>" skip
       "<TD>Кол-во подключившихся за период</TD>" skip
       "<TD>Общее кол-во клиентов по штрих-кодир</TD>" skip
       "<TD>Кол-во подключившихся за период</TD>" skip
       "<TD>Общее кол-во клиентов по биометрии</TD>" skip
       "<TD>Кол-во подключившихся за период</TD>" skip
       "</TR>" skip.

 for each totcli2 break by totcli2.type by totcli2.bank by totcli2.dep.

  if first-of(totcli2.type) then 
    put stream vcrpt unformatted "<TR>"
                    "<TD colspan = 9 >"  if totcli2.type = 'b' then "ЮРИДИЧЕСКИЕ ЛИЦА"  else "ФИЗИЧЕСКИЕ ЛИЦА"       " </TD>"
                    "</TR>" skip.

  if first-of(totcli2.bank) then 
    put stream vcrpt unformatted "<TR>"
                    "<TD colspan = 9 >"  totcli2.bank  " </TD>"
                    "</TR>" skip.

    find b1-totcli where b1-totcli.bank = totcli2.bank and  b1-totcli.dep = totcli2.dep and b1-totcli.type = totcli2.type and b1-totcli.priz = 'sort' 
     and     b1-totcli.val = 'n' no-lock no-error. if avail b1-totcli then sum1 = b1-totcli.amt. else sum1 = 0.

    find b2-totcli where b2-totcli.bank = totcli2.bank and b2-totcli.dep = totcli2.dep and b2-totcli.type = totcli2.type and b2-totcli.priz = 'inet' 
     and  b2-totcli.val = 'n' no-lock no-error. if avail b2-totcli then sum2 = b2-totcli.amt. else sum2 = 0.


    find b3-totcli where b3-totcli.bank = totcli2.bank and b3-totcli.dep = totcli2.dep and b3-totcli.type = totcli2.type and b3-totcli.priz = 'shtr' 
     and  b3-totcli.val = 'n' no-lock no-error. if avail b3-totcli then sum3 = b3-totcli.amt. else sum3 = 0.

    find b4-totcli where b4-totcli.bank = totcli2.bank and b4-totcli.dep = totcli2.dep and b4-totcli.type = totcli2.type and b4-totcli.priz = 'bio' 
     and  b4-totcli.val = 'n' no-lock no-error. if avail b4-totcli then sum4 = b4-totcli.amt. else sum4 = 0.

    put stream vcrpt unformatted "<TR>"
                    "<TD>"  totcli2.dep       " </TD>"
                    "<TD>" totcli2.sort       "</TD>" 
                    "<TD>"  sum1       "        </TD>"
                    "<TD>"  totcli2.inet      "</TD>"
                    "<TD>"  sum2       "        </TD>"
                    "<TD>"  totcli2.shtr      "</TD>"
                    "<TD>"  sum3 "             </TD>"
                    "<TD>"  totcli2.bio         "</TD>"
                    "<TD>"   sum4        "   </TD>"
                    "</TR>" skip.
  end. 

put stream vcrpt unformatted
  "</TABLE>" skip.

{html-end.i " stream vcrpt "}

output stream vcrpt close.

unix silent cptwin value(p-filename) excel.
pause 0.

   

