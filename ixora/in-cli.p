/* in-cli.p
 * MODULE
        Отчеты по клиентам
 * DESCRIPTION
        Отчет по внешним клиентам входящих платежей  - ГО и Астана 
 * RUN
        
 * CALLER
        
 * SCRIPT
        
 * INHERIT
        
 * MENU
        8-12-8
 * AUTHOR
        15.10.01 pragma
 * CHANGES
        24.02.2004 nadejda - добавлены сведения об получателе - клиенте нашего банка
        17.06.2004 nadejda - добавлена валюта, референс платежа и отбор по списку клиентов
*/


{mainhead.i}

def var v-type like remtrz.ptype. 
find first cmp no-lock no-error.
if cmp.code = 0 then v-type = "7". /*тип Вход док-тов для Алматы */
                else v-type = "3".  /*тип вход док-тов для Астаны */

                
{in-cli.i &bank = "sbank" &gl = "crgl" &sbank = "sbank"}

if v-cif <> "" then do:
  for each temp:
    find aaa where aaa.aaa = temp.racc no-lock no-error.
    if not avail aaa or lookup(aaa.cif, v-cif) = 0 then delete temp.
  end.
end.


for each temp break by temp.acc:
  accumulate temp.amt (sub-total by temp.acc).
  if last-of(temp.acc) then do:
    create t-total.
    t-total.acc = temp.acc.
    t-total.total = accum sub-total by temp.acc temp.amt.
  end.
end.


output stream  nur to rpt.txt.
put stream nur skip
  string( today, "99/99/9999" ) + ", " +
  string( time, "HH:MM:SS" ) + ", " +
  trim(cmp.name) format "x(79)" at 02 skip(1).

put stream nur skip 
  " СПИСОК ВНЕШНИХ КЛИЕНТОВ, СО СЧЕТОВ КОТОРЫХ БЫЛИ ПЕРЕВОДЫ В TEXAKABANK" SKIP 
  "С " v-dt1 " ПО " v-dt2 " НА СУММУ ОТ " v-amt 
  " ТЕНГЕ И ВЫШЕ" skip.


put stream nur skip(2) space(3) "МФО" format "x(9)" space(1) 
    "Счет отправ-ля" format "x(9)" space(2) 
    "РНН отправит-ля" format "x(12)" space(10)
    "Сумма платежа" format "x(15)" space(3)
    "Вал" format "xxx" space(1)
    "Наименование отправителя" format "x(50)" space(1) 
    "Дата плат." format "x(10)" space(1) 
    "Референс" format "x(10)" space(1) 
    "Счет получ." format "x(12)" space(1) 
    "РНН получ." format "x(12)" space(2)
    "Наименование клиента-получателя" format "x(50)" skip.

put stream nur fill( "-", 200 ) format "x(200)" skip.

for each t-total :
  for each temp where temp.acc = t-total.acc:
    find crc where crc.crc = temp.crc no-lock no-error.
    put stream nur 
       temp.mfo  format "x(12)" space(1)
       temp.acc  format "x(10)" space(1)
       temp.rnn format "x(13)" space(2)
       temp.amt format "zzz,zzz,zzz,zzz,zz9.99" space(3)
       crc.code format "xxx" space(1)
       temp.des  format "x(50)" space(1)
       temp.dt format "99/99/9999" space(1)
       temp.remtrz format "x(10)" space(1)
       temp.racc  format "x(10)" space(1)
       temp.rrnn  format "x(13)" space(2)
       temp.rname  format "x(50)" 
       skip.
  end.

  put stream nur fill( "-", 200 ) format "x(200)" skip 
     "ИТОГО ПО СЧЕТУ " at 25 t-total.total format "zzz,zzz,zzz,zzz,zz9.99" skip
     fill( "-", 200 ) format "x(200)" skip(1).
end. 

output stream nur close.

if not g-batch then do:
   pause 0 before-hide.                  
   run menu-prt( "rpt.txt" ).
   pause 0 no-message.
   pause before-hide.
 end.
                     
