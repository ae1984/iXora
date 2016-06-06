/* rnnfind.p
 * MODULE
        PRAGMA
 * DESCRIPTION
        Отчет по клиентам, у которых было движение по счету с заданной 
        даты по сегодняшний день 01.10.01 п.п.8-12-6
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        8-12-6 
 * AUTHOR
        08.12.2003 nataly
 * CHANGES
        01.10.02 nadejda - наименование клиента заменено на форма собств + наименование 
        24.02.04 tsoy    - добавил 4 поля  телефоны и адреса для рассылки писем
*/


def stream  nur.
def var flg as log init false.
def var lastday$ as date /*format 'dd/mm/yyyy'*/. 
def var sek-ek as char. 
def var chief as char.
def var account as char.

def var count1 as  integer init 1.
output stream  nur to rpt.csv .

def temp-table temp
  field cif as char
  field name as char 
  field chief as char
  field account as char
  field obor as decimal
  field adrr1  as char
  field adrr2  as char
  field phone1 as char
  field phone2 as char.

{global.i}

find first cmp no-lock no-error.
lastday$ = g-today - 1.
if not g-batch then do:
    update lastday$ label ' Введите начальную дату отчета ' format '99/99/9999' skip
        with side-label row 5 centered frame dat .
        end.
        else lastday$ = g-today.
        
display '   Ждите...   '  with row 5 frame ww centered .
put stream nur skip
string( today, '99/99/9999' ) + ', ' +
string( time, 'HH:MM:SS' ) + ', ' +
trim( cmp.name )                               format 'x(79)' at 02 skip(1).

put stream nur skip 
" СПИСОК КЛИЕНТОВ, У КОТОРЫХ БЫЛО ДВИЖЕНИЕ ПО СЧЕТУ С " lastday$ " ПО " g-today skip.

put stream nur ' ' fill( '-', 807 ) format 'x(77)' skip(1).

for each cif  no-lock break by cif.type: 
  flg = false.
/*put stream nur lastday$ skip. */
for each aaa no-lock where cif.cif = aaa.cif and  
(ddt >= lastday$ or cdt >= lastday$) and aaa.sta <> 'C'
and substr(aaa.aaa,4,3) <> '140' : 

 find sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
       sub-cod.d-cod = 'clnsts' no-lock no-error.
 if not avail sub-cod or sub-cod.ccode <> '0' then next.
  
find crc where crc.crc = aaa.crc.
 find sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
       sub-cod.d-cod matches '*clnc*' no-lock no-error.
 if available sub-cod then  chief = sub-cod.rcode. 

/*chief accountant*/
 find sub-cod where  sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
       sub-cod.d-cod = 'clnbk' no-lock no-error.
 if available sub-cod then  account = sub-cod.rcode. 

 find  sub-cod where sub-cod.sub = 'cln' and sub-cod.acc = cif.cif and
      sub-cod.d-cod matches '*ecdi*' no-lock no-error.
   if available sub-cod then sek-ek = sub-cod.ccode. 

find codf where codf.codfr = 'ecdivis' and codf.code = sek-ek.  
            
  if  flg = false then do:
/* put stream nur skip count1  format 'zzzz' ';' trim(trim(cif.prefix) + " " + trim(cif.name))  
 format 'x(65)' ';'  cif.addr[1]  format 'x(65)' ';'  'Тел.' 
 space(2) cif.tel  format 'x(30)' ';' chief format 'x(30)' ';'.  
  */
  create temp. 
  temp.cif = cif.cif. temp.chief = chief. temp.account = account.
  temp.name = trim(trim(cif.prefix) + " " + trim(cif.name)).
  temp.adrr1  = cif.addr[1].
  temp.adrr2  = cif.addr[2].
  temp.phone1 = cif.tel.
  temp.phone2 =  cif.tlx.
  flg = true. count1 = count1 + 1.

    end.  /*flg*/
   end. /*aaa*/
 end. /*cif*/

def var v-dam as decimal.
def var v-cam as decimal.
def var v-dat as date.

for each temp break by temp.cif.
 v-dam = 0. v-cam = 0.
 for each aaa where aaa.cif = temp.cif.
  do v-dat = lastday$ to g-today.
   for each jl no-lock where jl.acc = aaa.aaa and jl.jdt = v-dat .
       find last crchis where crchis.crc = jl.crc and crchis.regdt <= jl.jdt no-lock no-error.
       v-dam =  v-dam + jl.dam * crchis.rate[1].
       v-cam =  v-cam + jl.cam * crchis.rate[1].
   end. /*jl*/
  end. /*v-dat*/
 end.  /*aaa*/
   temp.obor = max(v-dam, v-cam).
end.  /*temp*/

count1 = 1.
for each temp break by temp.obor desc.
   put stream nur skip count1  format 'zzzz' ';' temp.name 
   format 'x(65)' ';'  temp.chief format 'x(30)' ';'  temp.account format 'x(30)' ';' temp.obor format 'zzzzzzzzzzzzzzzzz9.99' ';' temp.adrr1 format 'x(30)' ';' temp.adrr2 format 'x(30)' ';' temp.phone1 format 'x(30)' ';' temp.phone2 format 'x(30)'.  
   count1 = count1 + 1.
end.

output stream nur close.

if not g-batch then do:
   pause 0 before-hide.                  
   run menu-prt( 'rpt.csv' ).
   pause 0 no-message.
   pause before-hide.
 end.
                     
/*run menu-prt('rpt.csv'). */



