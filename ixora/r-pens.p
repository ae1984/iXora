/* r-pens.p
 * MODULE
        Название Программного Модуля
 * DESCRIPTION
        Назначение программы, описание процедур и функций
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
        31/12/99 pragma
 * CHANGES
*/

/* 
  04.06.03 nataly
  отчет по пенсионным платежам за период 

   30.10.2002 nadejda - наименование клиента заменено на форма собств + наименование 
*/

def var v-dat1 as date.
def var v-dat2 as date.
def var v-lbin as cha .
def var v-lbina as cha.
def stream rpt.

def var c1 as char.
def var c-temp as char.
def var i as int.
def var chief as char.
def var sek-ek as char.
def var v-name as char.
{global.i new}

def temp-table temp
    field rmz like remtrz.remtrz
    field cif like cif.cif
    field fname like cif.fname 
    field rdt like remtrz.rdt
    field saaa like aaa.aaa
    field raaa like aaa.aaa
    field ord  like remtrz.ord
    field knp  like remtrz.ord
    field bn  like remtrz.ord
    field rnn1  as char 
    field rnn2  as char 
    field rbank like remtrz.rbank
    field amt as decimal
    field totamt as decimal
    field num as int.


def buffer b-temp for temp.

def var v-ind as integer.
def var naim as char.
def var v-rnn1 as char.
def var v-ind2 as integer.
def var naim2 as char.
def var v-rnn2 as char.
def var v-knp as char.

find last cls no-lock no-error.
g-today = if available cls then cls.cls + 1 else today.

update v-dat1 label ' Укажите период С ..' format '99/99/9999'
       validate(v-dat1 ge 12/19/1999 and v-dat1 le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       v-dat2 label ' ПО ..' format '99/99/9999'
       validate(v-dat2 ge 12/19/1999 and v-dat2 le g-today,
       "Дата должна быть в пределах от 19.12.1999 до текущего дня")
       skip with side-label row 5 centered frame dat .
                     
display '   Ждите...   '  with row 5 frame ww centered .


find first remtrz where remtrz.rdt   >=  v-dat1 and  remtrz.rdt   <=  v-dat2
                    and remtrz.ptype =  '6'
                    and substr(trim(rcvinfo[1]),2,3) = 'PSJ'
                    no-lock no-error.

if not avail remtrz then do.
   message 'За период С ' v-dat1 ' ПО ' v-dat2 ' нет платежей для обработки!'.
   return.
end.                    

output stream rpt to rpt.img.

 put stream rpt  'ОТЧЕТ ПО ПЕНСИОННЫМ ПЛАТЕЖАМ  '  AT 10 
    SKIP ' ЗА ПЕРИОД С ' AT 10 V-DAT1 '  ПО '   V-DAT2   SKIP(2)
     "rmz       |дата валют.2       |сумма   |КНП     |сч.отпр  |наимен.отпр.                                      |РНН отпр.   |сч.получ. |БИК получ.|наим.получат.                                     |РНН получ".
put stream rpt skip fill("-",208) format 'x(208)' .

for each remtrz where     
                  remtrz.valdt2 >=  v-dat1 and  remtrz.valdt2 <=  v-dat2
                   and remtrz.ptype =  '6'
                    and substr(trim(rcvinfo[1]),2,3) = 'PSJ'
                  no-lock break by remtrz.rdt. 

              v-rnn1 = "". v-rnn2 = "". naim = "". naim2 = "". v-knp = "".

  find sub-cod where sub-cod.acc = remtrz.remtrz and sub = 'rmz' no-lock no-error.
   v-knp = substr(rcod,7,3).

if remtrz.tcrc <> 1 or remtrz.fcrc <> 1 then 
       message 'Валюта платежа ' remtrz.remtrz  'не KZT'. 
        
         find aaa where aaa.aaa  = remtrz.sacc no-lock no-error.
          v-ind = index(remtrz.ord, 'RNN').
          naim = substr(remtrz.ord, 1, v-ind - 2). 
          v-rnn1 = substr(remtrz.ord, v-ind + 4 , 15).

          v-ind2 = index(trim(remtrz.bn[1]) + trim(remtrz.bn[2]), 'RNN'). 
          v-ind = index(trim(remtrz.bn[1]) + trim(remtrz.bn[2]), 'IRS'). 

         if v-ind2 > 0 then  v-rnn2 = substr(trim(remtrz.bn[1]) + trim(remtrz.bn[2]), v-ind2 + 4 , 15).
         if v-ind > 0 then  naim2 = substr(trim(remtrz.bn[1]) + trim(remtrz.bn[2]), 1, v-ind - 2). 
         if v-ind = 0 then naim2 = substr(trim(remtrz.bn[1]) + trim(remtrz.bn[2]), 1, v-ind2 - 2). 
          if v-ind2 = 0 then  message remtrz.remtrz remtrz.bn[1] + remtrz.bn[2].

      if available aaa then do:
       find cif where cif.cif = aaa.cif no-lock no-error.
          create temp.
          temp.cif = cif.cif.  temp.fname = cif.fname .
          temp.amt = remtrz.amt .
          temp.saaa = remtrz.sacc. 
          temp.raaa = remtrz.racc. 
          temp.rdt = remtrz.valdt2.
          temp.rmz = remtrz.remtrz.
          temp.knp = v-knp.
          temp.ord = naim.
          temp.rnn1 = v-rnn1.
          temp.rnn2 = v-rnn2.
          temp.bn = naim2.
          temp.rbank = remtrz.rbank.

      end. 
 end. /*for each remtrz*/


  for each temp break by temp.rdt. 

    put stream rpt skip temp.rmz ' '  temp.rdt ' ' 
    temp.amt format '->>>,>>>,>>>,>>9.99' ' '  temp.knp  format 'x(3)' '     '  temp.saaa  ' '  temp.ord  format 'x(50)' ' ' temp.rnn1  format 'x(12)' ' '
    temp.raaa ' ' temp.rbank ' ' temp.bn format 'x(50)' ' ' temp.rnn2  format 'x(12)'.
 end.


put stream rpt skip(2)  '===============КОНЕЦ ФАЙЛА================'. 
output  stream rpt  close.  


if not g-batch then do:
   pause 0 before-hide.                  
   run menu-prt( 'rpt.img' ).
   pause 0 no-message.
   pause before-hide.
 end.

   

