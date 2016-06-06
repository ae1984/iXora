/* dirin.p
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
        25/03/2005 kanat - добавил проверку на уже загруженные remtrz
        28/03/2005 kanat - увеличил диапазон строк для наименования и РНН получателя и отправителя,
                           а также для их секторов экономики и признаков резидентства. 
        31/03/2005 kanat - изменил обработку поля NAME - убрал проверки по спец. символам
        05/04/2005 kanat - v-host = "NTMAIN"
        24/05/2005 kanat - добавил обработку файлов по их расширениям, которые берутся из настроек банков
        02/06/2005 kanat - добавил дополнительную очистку домашнего каталога
        07/06/2005 kanat - добавил дополнительное условие - если пользователь хочет прервать операцию
        04/08/2005 kanat - добавил обнуление информации по гл. бухгалтеру если какой-нибудь банк будет не присылать информацию 
                           по main_bk  
        10/08/2005 kanat - добавил копирование по rcp со СПЭД БТА
        11/08/2005 kanat - добавил предварительную очистку HOME
        13/09/2005 kanat - добавил удаление файла rep.txt после окончания работы программы
        20/03/2006 scuhkov - добавил автоматическую обработку по определенному банку
*/

{global.i}

def temp-table ttmps 
        field mt-remtrz as char
        field mt-amt as char
        field mt-date as date
        field mt-dc as char
        field mt-dracc as char
        field mt-name1 as char
        field mt-rnn1 as char
        field mt-chief as char
        field mt-mainbk as char
        field mt-IRS1 as char
        field mt-SECO1 as char
        field mt-bik1 as char
        field mt-bik11 as char
        field mt-acc11 as char
        field mt-bik2 as char
        field mt-acc as char
        field mt-bik22 as char
        field mt-acc22 as char
        field mt-name2 as char
        field mt-rnn2 as char
        field mt-IRS2 as char
        field mt-SECO2 as char
        field mt-num as char
        field mt-knp as char
        field mt-detail as char
        field mt-filename as char
        field mt-t-sqn as char
        field mt-ref as char.
 
def var v-mt-remtrz as char.
def var v-mt-amt as char.
def var v-mt-dc as char.
def var v-mt-dracc as char.
def var v-mt-name1 as char.
def var v-mt-rnn1 as char.
def var v-mt-chief as char.
def var v-mt-mainbk as char.
def var v-mt-IRS1 as char.
def var v-mt-SECO1 as char.
def var v-mt-bik1 as char.
def var v-mt-bik2 as char.
def var v-mt-acc as char.
def var v-mt-name2 as char.
def var v-mt-rnn2 as char.
def var v-mt-IRS2 as char.
def var v-mt-SECO2 as char.
def var v-mt-num as char.
def var v-mt-date as date.
def var v-mt-knp as char.
def var v-mt-detail as char.
def var v-mt-bik11 as char.
def var v-mt-acc11 as char.
def var v-mt-bik22 as char.
def var v-mt-acc22 as char.
def var v-mt-ref as char.

def var v-result as char.
def var s  as char init ''.
def var s1  as char init ''.
def var v-str  as char init ''.

define stream m-cpfl.
define stream m-infl.
define stream m-cpfldl.

def var v-host as char. 
def var v-path  as char.

def var v-count as integer init 1.
def var v-det-count as integer.

def temp-table tmp-out-ref
    field outref as char.

def temp-table tmp-in-ref
    field inref as char.

def temp-table tmp-tmp-rmz
    field rmz as char.  

def var v-dirdfb as char.
def var v-total as decimal.

define temp-table cms-direct like direct_bank.
define variable v-unibank as char.

define variable cc as char.

define variable v-ext1 as char.
define variable v-ext2 as char.
define variable v-unidir as char.

define variable v-result1 as char.
define variable v-result2 as char.

define variable v-bta-ip as character init "bta".
define variable v-bta-path as character init "/home/pc/branch/in/".

define variable v-unipath as character.
define variable v-resultd as character.

run direct_select.
v-unibank = return-value.

if v-unibank = "" then
return.

find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
if avail direct_bank then do:
v-path = replace(direct_bank.aux_string[2],"/","\\\\").
v-unipath = direct_bank.aux_string[2].
v-dirdfb = trim(direct_bank.bank2).
v-ext1 = trim(direct_bank.ext[1]).
v-ext2 = trim(direct_bank.ext[2]).
end.

/* --------------------------------- */
if v-unibank = "190501319" then do:
input through value ("rm -f *" + v-ext1). 
repeat:
  import v-resultd.
end.

input through value ("rcp " + v-bta-ip + ":" + v-bta-path + "*" + v-ext1 + " ./" + ";echo $?"). 
repeat:
  import v-result1.
end.

if integer(v-result1) <> 0 then do:
message "Произошла ошибка при копировании файлов со СПЭД" view-as alert-box title "Внимание".
return.
end.

v-unidir = "NTMAIN:" + replace(v-unipath,"/","\\\\\\\\").
input through value ("rcp " + "*" + v-ext1 + " " + v-unidir + " ;echo $?" ). 
repeat:
  import v-result2.
end.

if integer(v-result2) <> 0 then do:
message "Произошла ошибка при копировании файлов на NTMAIN" view-as alert-box title "Внимание".
return.
end.
end.
/* --------------------------------- */


v-host =  "NTMAIN".

input through value("rsh " + v-host + " dir /b " + v-path + "*" + v-ext1) no-echo.
/*
input through value("rsh `askhost` dir /b '" + v-path + "*.eks '") no-echo.
*/
repeat:
      import unformatted s.

      v-count = 1.

      input stream m-cpfl through value("rcp " + "NTMAIN:" + replace(v-path,"\\","\\\\") + trim(s) + " " + trim(s) + "; echo $?").
      repeat:
      import stream m-cpfl v-result.
      end.
      input stream m-cpfl close.

      unix silent dos-un value(trim(s)) base.tmp.

            input stream m-infl from base.tmp.
            repeat:
            do transaction:
              import stream m-infl unformatted v-str.
              
              v-str = trim(v-str).

              if trim(v-str) begins ":20:" then do: 
              v-mt-remtrz = entry(3,v-str,":").
/*
              message ":20:" v-count v-mt-remtrz view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":32a:" then do: 
              v-mt-amt = entry(2,v-str,"T").
              v-mt-ref = v-mt-remtrz + entry(3,v-str,":").


   if substr(v-str,6,2) eq substr(string(year(today)),3,2)
       then cc = substr(string(year(today)),1,2).
   else
   if substr(v-str,6,2) lt  substr(string(year(today)),3,2)
       then cc = "20".
   if substr(v-str,6,2) gt  substr(string(year(today)),3,2)
    then cc = "19".
             v-mt-date = date(int(substr(v-str,8,2)), int(substr(v-str,10,2)), int(trim(cc)  +  substr(v-str,6,2))).
/*
              message ":32a:" v-count v-mt-amt view-as alert-box title "Внимание".
*/
              end.



              if trim(v-str) begins ":50:" then do: 
              v-mt-dc = entry(2,v-str,"/").
              v-mt-dracc = entry(3,v-str,"/").
/*
              message ":50:" v-count v-mt-dracc view-as alert-box title "Внимание".
*/
              end.

              if v-count > 4 and v-count < 12 and trim(v-str) begins "/NAME/" then do: 
              v-mt-name1 = replace(trim(v-str),"/NAME/","").
/*
              message "/name1/" v-count v-mt-name1 view-as alert-box title "Внимание".
*/
              end.


              if v-count > 4 and v-count < 12 and trim(v-str) begins "/RNN/" then do: 
              v-mt-rnn1 = entry(3,v-str,"/").
/*
              message "/rnn1/" v-count v-mt-rnn1 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins "/CHIEF/" then do: 
              v-mt-chief = entry(3,v-str,"/").
/*
              message "/chief/" v-count v-mt-chief view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins "/MAINBK/" then do: 
              v-mt-mainbk = entry(3,v-str,"/").
/*
              message "/mainbk/" v-count v-mt-mainbk  view-as alert-box title "Внимание".
*/
              end.


              if v-count > 9 and v-count < 15 and trim(v-str) begins "/IRS/" then do: 
              v-mt-IRS1 = entry(3,v-str,"/").
/*
              message "/irs1/" v-count v-mt-irs1 view-as alert-box title "Внимание".
*/
              end.


              if v-count > 9 and v-count < 15 and trim(v-str) begins "/SECO/" then do: 
              v-mt-SECO1 = entry(3,v-str,"/").
/*
              message "/seco1/" v-count v-mt-seco1 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":52B" then do: 
              v-mt-bik1 = entry(3,v-str,":").
/*
              message ":52b" v-count v-mt-bik1 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":53a" or trim(v-str) begins ":53b" then do: 
              v-mt-bik1 = entry(3,v-str,":").
/*
              message ":53a/b" v-count v-mt-bik1 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":53c" then do: 
              v-mt-bik11 = entry(1,replace(trim(v-str),":53c",""),"/").
              v-mt-acc11 = entry(2,replace(trim(v-str),":53c",""),"/").
/*
              message ":52b" v-count v-mt-bik11 v-mt-acc11 view-as alert-box title "Внимание".
*/
              end.



              if trim(v-str) begins ":54a" or trim(v-str) begins ":54b" then do: 
              v-mt-bik22 = entry(3,v-str,":").
/*
              message ":53a/b" v-count v-mt-bik22 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":54c" then do: 
              v-mt-bik22 = entry(1,replace(trim(v-str),":54c",""),"/").
              v-mt-acc22 = entry(2,replace(trim(v-str),":54c",""),"/").
/*
              message ":52b" v-count v-mt-bik22 v-mt-acc22 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":57B" then do: 
              v-mt-bik2 = entry(3,v-str,":").
/*
              message ":57b" v-count v-mt-bik2 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":59" then do: 
              v-mt-acc = entry(3,v-str,":").
/*
              message ":59" v-count v-mt-acc view-as alert-box title "Внимание".
*/
              end.


              if v-count > 12 and v-count < 22 and trim(v-str) begins "/NAME/" then do: 
              v-mt-name2 = entry(3,v-str,"/").
/*
              message "/name2/" v-count v-mt-name2 view-as alert-box title "Внимание".
*/
              end.


              if v-count > 12 and v-count < 22 and trim(v-str) begins "/RNN/" then do: 
              v-mt-rnn2 = entry(3,v-str,"/").
/*
              message "/rnn2/" v-count v-mt-rnn2 view-as alert-box title "Внимание".
*/
              end.


              if v-count > 12 and v-count < 23 and trim(v-str) begins "/IRS/" then do: 
              v-mt-IRS2 = entry(3,v-str,"/").
/*
              message "/irs2/" v-count v-mt-irs2 view-as alert-box title "Внимание".
*/
              end.


              if v-count > 12 and v-count < 23 and trim(v-str) begins "/SECO/" then do: 
              v-mt-SECO2 = entry(3,v-str,"/").
/*
              message "/seco2/" v-count v-mt-seco2 view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins ":70:/NUM/" then do: 
              v-mt-num = entry(3,v-str,"/").
/*
              message ":70/num/" v-count v-mt-num view-as alert-box title "Внимание".
*/
              end.

/*
              if trim(v-str) begins "/DATE/" then do: 
              v-mt-date = entry(3,v-str,"/").
              message "/date/" v-count v-mt-date view-as alert-box title "Внимание".
              end.
*/


              if trim(v-str) begins "/KNP/" then do: 
              v-mt-knp = entry(3,v-str,"/").
/*
              message "/knp/" v-count v-mt-knp view-as alert-box title "Внимание".
*/
              end.


              if trim(v-str) begins "/ASSIGN/" then do: 
              v-mt-detail = "".
              v-det-count = v-det-count + 1.
/*
              message "/assign/" v-count v-det-count view-as alert-box title "Внимание".
*/
              end.

              if v-det-count >= 1 and not trim(v-str) begins "-}" then do:
              v-mt-detail = v-mt-detail + " " + trim(v-str).    
              v-det-count = v-det-count + 1.
/*
              message v-count v-mt-detail view-as alert-box title "Внимание".
*/
              end.

              if trim(v-str) begins "-}" then do:
              v-det-count = 0.
              v-mt-detail = trim(replace(v-mt-detail,"/ASSIGN/","")).
/*
              message "-}" v-count view-as alert-box title "Внимание".
*/
              end.

              v-count = v-count + 1.    

            end. 
            end. 

        create ttmps.
        update  ttmps.mt-remtrz = v-mt-remtrz
                ttmps.mt-amt = v-mt-amt
                ttmps.mt-dc = v-mt-dc
                ttmps.mt-dracc = v-mt-dracc
                ttmps.mt-name1 = v-mt-name1
                ttmps.mt-rnn1 = v-mt-rnn1
                ttmps.mt-chief = v-mt-chief
                ttmps.mt-mainbk = v-mt-mainbk
                ttmps.mt-IRS1 = v-mt-IRS1
                ttmps.mt-SECO1 = v-mt-SECO1
                ttmps.mt-bik1 = v-mt-bik1
                ttmps.mt-bik11 = v-mt-bik11
                ttmps.mt-bik2 = v-mt-bik2
                ttmps.mt-bik22 = v-mt-bik22
                ttmps.mt-acc = v-mt-acc
                ttmps.mt-acc22 = v-mt-acc22
                ttmps.mt-name2 = v-mt-name2
                ttmps.mt-rnn2 = v-mt-rnn2
                ttmps.mt-IRS2 = v-mt-IRS2
                ttmps.mt-SECO2 = v-mt-SECO2
                ttmps.mt-num = v-mt-num
                ttmps.mt-date = v-mt-date
                ttmps.mt-knp = v-mt-knp
                ttmps.mt-detail = v-mt-detail
                ttmps.mt-filename = trim(s)
                ttmps.mt-ref = v-mt-ref.

                v-mt-chief = "". 
                v-mt-mainbk = "".

            input stream m-infl close.
            input stream m-cpfldl through value("rm  -f *.exp") no-echo.
            input stream m-cpfldl through value("rm  -f base.tmp") no-echo.
end.
input close.

for each ttmps no-lock.
find first remtrz where remtrz.valdt1 = ttmps.mt-date and 
                        remtrz.t_sqn = ttmps.mt-remtrz no-lock no-error.
if not avail remtrz then do:
run dirpl(1,     
          decimal(replace(trim(ttmps.mt-amt), ",", ".")),
          ttmps.mt-date,
          ttmps.mt-bik1,
          ttmps.mt-bik11,
          ttmps.mt-acc11,
          ttmps.mt-dracc,
          ttmps.mt-name1,  
          ttmps.mt-bik2,   
          ttmps.mt-bik22,
          ttmps.mt-acc22,
          ttmps.mt-acc,    
          0,       
          no,  
          ttmps.mt-name2, 
          ttmps.mt-rnn2,             
          ttmps.mt-knp, 
          ttmps.mt-irs1 + ttmps.mt-seco1, 
          ttmps.mt-irs2 + ttmps.mt-seco2, 
          ttmps.mt-detail,             
          "DIRIN", 
          0,            
          1,            
          v-dirdfb,           
          ttmps.mt-chief,
          ttmps.mt-mainbk,
          ttmps.mt-rnn1,
          ttmps.mt-filename,
          ttmps.mt-remtrz,
          ttmps.mt-num,
          ttmps.mt-ref).

   create tmp-tmp-rmz.
   update tmp-tmp-rmz.rmz = trim(return-value).
end.
end.


output to rep.txt.
put unformatted "Система прямых корр. отношений" skip(1).
put unformatted "Корр. счет: " v-dirdfb skip.
find first direct_bank where direct_bank.bank1 = v-unibank no-lock no-error.
put unformatted "Банк отправитель: " direct_bank.aux_string[1] skip.
put unformatted "БИК: " direct_bank.bank1 skip(1).

put unformatted "Отчет по созданным в АБПК PragmaTX входящим платежам за " string(g-today) skip(1).

put unformatted "Референс                Сумма" skip.
put unformatted fill("=",40) skip.
for each tmp-tmp-rmz no-lock.
find first remtrz where remtrz.remtrz = tmp-tmp-rmz.rmz no-lock no-error.
put unformatted remtrz.remtrz format "x(11)" " " remtrz.amt format ">>>,>>>,>>>,>>>,>>9.99" skip.
v-total = v-total + remtrz.amt.
end.
put unformatted fill("=",40) skip.
put unformatted "ИТОГО: " v-total format ">>>,>>>,>>>,>>>,>>9.99" skip.
put unformatted fill("=",40) skip.
output close.
run menu-prt ("rep.txt").
unix silent value("rm -f rep.txt").


if v-total <> 0 then
message "Загрузка платежей завершена" view-as alert-box title "Внимание".

unix silent value("rm -f *" + v-ext1).

/* scuhkov - автоматическая обработка */
if direct_bank.auto then run dirupl(v-unibank).


procedure direct_select.
for each cms-direct:
delete cms-direct.
end.
  
for each direct_bank no-lock:
    do transaction on error undo, next:
        create cms-direct.
        buffer-copy direct_bank to cms-direct.
    end.
end.
        
define query q1 for cms-direct.
define browse b1 
    query q1 no-lock
    display 
        cms-direct.bank1 label "БИК" format "x(10)" 
        cms-direct.bank2 label "Корр. счет" format "x(10)" 
        cms-direct.aux_string[1] label  "Наименование" format 'x(50)'
        with 10 down title "Список банков".
                                         
define frame fr1 
    b1
    with no-labels centered overlay view-as dialog-box.  
on return of b1 in frame fr1
    do: 
        apply "endkey" to frame fr1.
    end.  
                    
open query q1 for each cms-direct.
if num-results("q1") = 0 then
do:
    MESSAGE "Справочник пуст ?!"
    VIEW-AS ALERT-BOX INFORMATION BUTTONS ok
    TITLE "Внимание".
    return.                 
end.

b1:SET-REPOSITIONED-ROW (1, "CONDITIONAL").
ENABLE all with frame fr1.
apply "value-changed" to b1 in frame fr1.
WAIT-FOR endkey of frame fr1.

hide frame fr1.
return cms-direct.bank1.
end.
