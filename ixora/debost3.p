/* debost2.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        Остатки дебиторов на дату по срокам, у которых истек срок погашения
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
        11/03/04 sasco
 * CHANGES
        03/11/04 tsoy добавил поле в таблицу wrk
        16/08/2005 marinav добавлен фактический срок
        22/08/2005 marinav - отчет переделан под excel
        10/05/06 u00121 - добавил индекс во временную таблицу wjh - формирование отчета сократилось с ~40 минут до ~ 1 минуты 
			- Добавил опцию no-undo в описание переменных и временных таблиц


        01/06/2006 u00600 - согласно ТЗ ї118 от 27.08.2005 (при вычете срока минус 1 убрала) и вывод на экран номера группы и дебитора
*/

{debls.f}

def shared var g-today as date.

def var srok as integer no-undo.
def var strsrok as character no-undo.

def var vlen as int  init 159 no-undo.
def var slen as char init "159" no-undo.
/* def var totost as decimal init 0.0. */
def var grpost as decimal init 0.0 no-undo.
def var v-profitname as char no-undo.

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

hide all. pause 0.

update v-grp with frame get-grp-all.
find debgrp where debgrp.grp = v-grp no-lock no-error.
if avail debgrp then displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

if v-grp <> 0 then do:
update v-ls with frame get-grp-all.
find debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
if avail debls then displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.
end.

v-dat = g-today.

update v-dat with frame get-dat.
hide frame get-dat.
hide frame get-grp-all.


if v-grp = 0 then
   for each debls where debls.grp ne 0 and debls.ls ne 0 no-lock:
       find first debgrp where debgrp.grp = debls.grp no-lock no-error.
       if avail debgrp then do:
       create wrkgrp.
       assign wrkgrp.grp = debls.grp
              wrkgrp.ls = debls.ls
              wrkgrp.arp = debgrp.arp.
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
    run debost-get (wrkgrp.grp, wrkgrp.ls, wrkgrp.arp, v-dat).
end. 

if not can-find (first wrk) then do:
   message "На указанную дату нет остатков!" view-as alert-box.
   return.
end.

output to debost.html.
{html-title.i 
 &stream = " "
 &title = " "
 &size-add = "x-"
}

put unformatted "<P style=""font:bold""> ОСТАТКИ К ПОГАШЕНИЮ НА ДАТУ: " v-dat "</P>" skip
                "<P style=""font:bold""> ГРУППА " string(v-grp) " : " get-grp-des (v-grp) "</P>" skip
                "<P style=""font:bold""> ДЕБИТОР " string(v-ls) " : " get-ls-name (v-grp, v-ls) "</P>" skip(1).

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
              "<TD>Департамент</TD>" skip
              "<TD>Будет</TD>" skip
              "<TD>Истек</TD>" skip
          "</TR>" skip.
       grpost = 0.0.
    end.

    find first codfr where codfr.codfr = "sproftcn" and codfr.code = wrk.attn no-lock no-error.
    if avail codfr then v-profitname = codfr.name[1].
                   else v-profitname = ''.

    put unformatted 
    "<TR><TD>" wrk.date  "</TD>" skip
      "<TD align=""rigth"" >" get-ls-name (wrk.grp, wrk.ls) format 'x(36)' "</TD>" skip
      "<TD>" replace(trim(string(wrk.ost, "->>>>>>>>>>>9.99")),".",",") "</TD>" skip
      "<TD>" wrk.period format "x(14)" "</TD>" skip
      "<TD>" wrk.fsrok format "x(300)" "</TD>" skip
      "<TD>" v-profitname format "x(50)"  "</TD>" skip.

    if substr (wrk.srok, 1, 5) = "month" then assign srok = 38 strsrok = "month".
    else 
    if substr (wrk.srok, 1, 4) = "year" then assign srok = 365 strsrok = "year".

    case SUBSTR (wrk.srok, length(strsrok) + 1): 
         when "s" then do: srok = 365 * 5. end.
         when "0" then do: srok = 0. end.
         otherwise do: srok = srok * INTEGER (SUBSTR (wrk.srok, length(strsrok) + 1)) no-error. end.
    end case.

    if srok = 0 or srok = ? then srok = 3.

    if (wrk.date + srok ) > v-dat then /* срок еще будет */    /*u00600 было if (wrk.date + srok - 1) > v-dat then*/
      put unformatted "<TD>" string (srok - ( v-dat - wrk.date ), "zzzz9") "</TD><TD></TD>" skip.
    else  /* срок подошел */
      put unformatted "<TD></TD><TD>" string (wrk.date + srok , "99/99/99")  "</TD>" skip. /*u00600 было string (wrk.date + srok - 1, "99/99/99")*/

    put unformatted  "</TR>" skip.

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
