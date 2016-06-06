/* debost2.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату (с незакрытыми приходами по срокам)
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
        13/01/04 sasco
 * CHANGES
        15/01/04 sasco исправил формирование таблицы wrkgrp
        15/01/04 sasco вызов вспомогательной процедуры debost-get.p для получения списка остатков
        11/03/04 sasco добавил обработку профит-центра
        03/11/04 tsoy добавил поле в таблицу wrk
        16/08/2005 marinav - добавлен фактический срок
        22/08/2005 marinav - отчет переделан под excel
        10/05/06 u00121 - добавил индекс во временную таблицу wjh - формирование отчета сократилось с ~40 минут до ~ 1 минуты 
			- Добавил опцию no-undo в описание переменных и временных таблиц


        01/06/06 u00600 формирование отчета по одному дебитору с разбивкой по группам
*/

{debls.f}

def shared var g-today as date.

def var vlen as int  init 135 no-undo.
def var slen as char init "135" no-undo.
/* def var totost as decimal init 0.0. */
def var grpost as decimal init 0.0 no-undo.

def temp-table wrkgrp no-undo
         field grp  like debls.grp          label "GRP"
         field ls   like debls.ls           label "NN"
         field arp  like debgrp.arp.

define new shared temp-table wrk no-undo         
         field arp like debgrp.arp
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field ost  like debhis.ost         label "Остаток"
         field date like debhis.date        label "Дата"
         field ctime like debhis.ctime
         field period as character format "x(40)"
         field attn like debop.attn
         field srok as character
         field fsrok as character
         field name as char
         index idx_wrk is primary grp ls date ctime.

define new shared temp-table wjh no-undo
         field grp like debls.grp
         field ls like debls.ls
         field jh like debhis.jh
         field closed like debop.closed initial no
         index idx_wjh grp ls jh  /*10/05/06 u00121*/
         .

define buffer bdebhis for debhis.

def new shared temp-table t-deb
    field grp  as integer format "z9"
    field ls   as integer  format "zzz9"
    field name as char format "x(37)".

def new shared var l_tr as logical. 
def new shared var l_int as int.
def var v-name like debls.name no-undo.
def new shared var ls like debls.ls.

hide all. pause 0.

update v-grp with frame get-grp-all0.
find debgrp where debgrp.grp = v-grp no-lock no-error.
if avail debgrp then displ debgrp.des @ v-grp-des with frame get-grp-all0.
pause 0.

if v-grp <> 0 then do:
  update v-ls with frame get-grp-all0. 
  if l_tr then do: /*группа <> 0, дебитора вводили поиском*/

    find first t-deb no-lock no-error. v-ls = t-deb.ls. 
    find first debls where debls.grp = t-deb.grp and debls.ls = t-deb.ls no-lock no-error.
    if avail debls then disp debls.name @ v-ls-des with frame get-grp-all0.    
    pause 0.
  end.
  else do:
    for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock.
      create t-deb.
      assign t-deb.grp  = debls.grp
             t-deb.ls   = debls.ls
             t-deb.name = debls.name.
     l_tr = true.
    end. 
    find first t-deb no-lock no-error.
    if avail t-deb then displ t-deb.name @ v-ls-des with frame get-grp-all0.  
    pause 0.
  end.
end.
else do:  /*v-grp = 0*/
  update v-ls with frame get-grp-all0.
  if l_tr then do: 
    find first t-deb no-lock no-error. v-ls = t-deb.ls. 
    find first debls where debls.grp = t-deb.grp and debls.ls = t-deb.ls no-lock no-error.
    if avail debls then do:
      if l_int = 1 then disp debls.name @ v-ls-des with frame get-grp-all0.  /*если выбор по наименованию, то выводим наименование*/
      if l_int = 2 then disp "Все дебиторы" @ v-ls-des with frame get-grp-all0. /*если по номеру, то выводим - все дебиторы*/
      pause 0.
    end.
  end.
  else do: /*если группа 0, а дебиторов вводили не поиском*/
    for each debls where debls.ls = v-ls no-lock.
      create t-deb.
      assign t-deb.grp  = debls.grp
             t-deb.ls   = debls.ls
             t-deb.name = debls.name.
     l_tr = true.
    end. 
    displ "Все дебиторы" @ v-ls-des with frame get-grp-all0.  
    pause 0.
  end.
end.

v-dat = g-today.

update v-dat with frame get-dat.
hide frame get-dat.
hide frame get-grp-all0.

if v-grp = 0 then
  if v-ls = 0 then do:  /*14.04.2006 u00600*/
   for each debls where debls.grp ne 0 and debls.ls ne 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.
  end.
  if v-ls <> 0 then do:    /*14.04.2006 u00600*/
    for each t-deb no-lock.
       find first debgrp where debgrp.grp = t-deb.grp no-lock.
       if avail debgrp then do:
         create wrkgrp.
         assign wrkgrp.grp = t-deb.grp
                wrkgrp.ls = t-deb.ls
                wrkgrp.arp = debgrp.arp.
       end.
     end.     
  end.
else

if v-ls = 0 then 
   for each debls where debls.grp = v-grp and debls.ls ne 0  no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.
else
   for each debls where debls.grp = v-grp and debls.ls = v-ls no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
       end.
   end.

define variable v-dtost as date format "99/99/99".

/* сформируем список проводок с остатками */
for each wrkgrp:
    run debost-get.p (wrkgrp.grp, wrkgrp.ls, wrkgrp.arp, v-dat).
end. 

if not can-find (first wrk) then do:
   message "На указанную дату нет остатков!" view-as alert-box.
   return.
end.

/*для вывода на экран/отчет наименований выборки*/
if l_tr  and l_int = 1 then do:
  find first wrk no-lock.
  find first debls where debls.grp = wrk.grp and debls.ls = wrk.ls no-lock no-error.
    if avail debls then v-name = debls.name.
end.
if l_tr and l_int = 2 then v-name = "Все дебиторы".
if l_tr and l_int = 0 and v-grp = 0 and v-ls <> 0 then v-name = "Все дебиторы".
if l_tr and l_int = 0 and v-grp <> 0 and v-ls = 0 then v-name = "Все дебиторы".
if l_tr and v-grp <> 0 and v-ls <> 0 then v-name = get-ls-name (v-grp, v-ls).

output to debost.html.
{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted "<P style=""font:bold""> ОСТАТКИ ПО ДЕБИТОРАМ НА ДАТУ: " v-dat "</P>" skip
                "<P style=""font:bold""> ГРУППА " string(v-grp) " : " if l_tr and v-grp = 0 then "Все группы" else get-grp-des (v-grp) "</P>" skip
                "<P style=""font:bold""> ДЕБИТОР " if l_int = 1 then "0" else string(v-ls) " : " v-name "</P>" skip(1).


for each wrk no-lock use-index idx_wrk break by wrk.grp by wrk.ls:
    if first-of (wrk.grp) then do:
        put unformatted  "<P> ГРУППА  : " get-grp-des (wrk.grp) " (ARP: " wrk.arp ") </P>" skip
          "<TABLE width=""100%"" cellspacing=""0"" cellpadding=""5"" border=""1"">" skip
            "<TR align=""center"" style=""font:bold;font-size:xx-small"">" skip
              "<TD>Дата</TD>" skip
              "<TD>Дебитор</TD>" skip
              "<TD>Остаток</TD>" skip
              "<TD>Срок</TD>" skip
              "<TD>Фактический срок</TD>" skip
              "<TD>Деп</TD>" skip
          "</TR>" skip.
       grpost = 0.0.
    end.

    put unformatted 
    "<TR><TD>" wrk.date  "</TD>" skip
      "<TD align=""rigth"" >" get-ls-name (wrk.grp, wrk.ls) format 'x(36)' "</TD>" skip
      "<TD>" replace(trim(string(wrk.ost, "->>>>>>>>>>>9.99")),".",",") "</TD>" skip
      "<TD>" wrk.period format "x(14)" "</TD>" skip
      "<TD>" wrk.fsrok format "x(300)" "</TD>" skip
      "<TD>" wrk.attn "</TD>" skip
    "</TR>" skip.

    grpost = grpost + wrk.ost.

    if last-of (wrk.grp) then do:
       put unformatted 
       "<TR><TD>ИТОГО ПО ГРУППЕ:</TD>" skip
       "<TD></TD><TD> " replace(trim(string(grpost, "->>>>>>>>>>>9.99")),".",",") "</TD>" skip.
       put unformatted "</TABLE>" skip.
    end.

end.

{html-end.i " "}
output close.

hide message no-pause.

unix silent cptwin debost.html excel.
pause 0.

