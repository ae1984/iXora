/* opokk.p
 * MODULE
        Касса
 * DESCRIPTION
        Отчет по остаткам кассы - консолидированный
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
        24/11/2010 evseev
 * BASES
        BANK COMM
 * CHANGES
        25/04/2012 evseev  - rebranding. разбранчевка с учетом банк-мко.
        19.09.2013 dmitriy - ТЗ 1829. запрет возможности формирования консолидированного отчета во всех базах кроме ЦО
*/

{mainhead.i}

define new shared temp-table tbl_opokk
    field txb        as int
    field filialname as char init ''
	field crc        like bank.crc.crc
	field bal        like bank.glday.bal.



def var dt1 as date.

def var v-list-crc as char no-undo.
def var i as int no-undo.

def var v-path as char no-undo.

def stream opokk1.

{gl-utils.i}

/*
def new shared var mesa as char.
mesa = ''.
*/



dt1 = /*date(month(g-today),1,year(g-today))*/ g-today.

update skip(1)
       dt1 label ' Остатки наличности на    ' format '99/99/9999' validate (dt1 <= g-today, " Дата должна быть не позже текущей! ") " " skip(1)
       with side-label row 5 centered frame dates.



find first bank.cmp no-lock no-error.
if not avail bank.cmp then do:
    message " Не найдена запись cmp " view-as alert-box error.
    return.
end.


if bank.cmp.name matches ("*МКО*") then v-path = '/data/'.
else v-path = '/data/b'.

if bank.cmp.code = 0 then do:
    for each comm.txb where comm.txb.consolid = true no-lock:

        if connected ("txb") then disconnect "txb".
        connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

       run  opokk2 (dt1 , comm.txb.txb , comm.txb.info).
    end.
end.
else do:
    find first comm.txb where comm.txb.consolid = true and comm.txb.city = bank.cmp.code no-lock no-error.

    if connected ("txb") then disconnect "txb".
    connect value(" -db " + replace(comm.txb.path,'/data/',v-path) + " -ld txb -U " + comm.txb.login + " -P " + comm.txb.password).

    run  opokk2 (dt1 , comm.txb.txb , comm.txb.info).
end.

if connected ("txb") then disconnect "txb".
if connected ("comm") then disconnect "comm".


/*
for each tbl_opokk:
displ tbl_opokk.
end.
*/

v-list-crc = ''.
for each bank.crc no-lock:
  find first tbl_opokk where tbl_opokk.crc =  bank.crc.crc no-lock no-error.
   if avail tbl_opokk then do:
     v-list-crc = v-list-crc + string(tbl_opokk.crc) + ','.
   end.
end.
/*v-list-crc = trim(v-list-crc).*/
v-list-crc = substring(v-list-crc, 1, (length(v-list-crc) - 1)).



def var return_choice as logical.

/*MESSAGE "Сформировать отчет?" VIEW-AS ALERT-BOX QUESTION BUTTONS YES-NO TITLE "Остатки наличности в филиалах" UPDATE return_choice.*/

/*if return_choice then do:*/
     displ "Ждите..." with row 5 centered no-label frame wfr. pause 0.
     output stream opokk1 to opokk.html.
     {html-title.i
       &stream = " stream opokk1 "
       &size-add = "1"
       &title = "Отчет по остаткам кассы - консолидированный"
     }

     if bank.cmp.code = 0 then do:
         put stream opokk1 unformatted
          "<B>" skip
          "<P align = ""center""><FONT size=""3"" >"
          "Отчет по остаткам кассы - консолидированный <br> на " + string(dt1, '99/99/9999') + "</FONT></P>" skip.
     end.
     else do:
         find first comm.txb where comm.txb.city = bank.cmp.code and comm.txb.consolid = true no-lock no-error.
         put stream opokk1 unformatted
          "<B>" skip
          "<P align = ""center""><FONT size=""3"" >"
          "Отчет по остаткам кассы - " comm.txb.info  "<br> на " + string(dt1, '99/99/9999') + "</FONT></P>" skip.
     end.

     put stream opokk1 unformatted
          "<B>" skip
          "<table border=""1"" cellpadding=""5"" cellspacing=""0"" style=""border-collapse: collapse""><FONT size = ""3"">" skip.

     put stream opokk1 unformatted "<tr><B>"
          "<td align=""center"" bgcolor=""#C0C0C0"">Филиал</td>".

     do i = 1 to num-entries(v-list-crc):
         find first bank.crc where bank.crc.crc = INTEGER(entry(i,v-list-crc)) no-lock no-error.
         if avail bank.crc then do:
            put stream opokk1 unformatted "<td align=""center"" bgcolor=""#C0C0C0"">" + bank.crc.des + "</td>".
         end.
     end.
     put stream opokk1 unformatted  "</FONT></B></tr>" skip.

     put stream opokk1  unformatted "<tr><font size=""3"">".

     if bank.cmp.code = 0 then do:
         for each comm.txb where comm.txb.consolid = true no-lock:
             put stream opokk1 unformatted "<td>" substring(comm.txb.info,3, length(comm.txb.info)) format "X(17)" "&nbsp;" "</td>" skip.

             do i = 1 to num-entries(v-list-crc):
                  find first tbl_opokk where tbl_opokk.txb = comm.txb.txb  and tbl_opokk.crc = INTEGER(entry(i,v-list-crc)) no-lock no-error.
                  if avail tbl_opokk then do:
                      put stream opokk1  unformatted "<td>" replace(trim(string(tbl_opokk.bal,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
                     end.
                  else do:
                      put stream opokk1  unformatted "<td>0</td>" skip.
                  end.
             end.
             put stream opokk1  unformatted "</FONT></tr>" skip.

             put unformatted skip.
         end.
     end.
     else do:
         find first comm.txb where comm.txb.consolid = true and comm.txb.city = bank.cmp.code no-lock no-error.
         put stream opokk1 unformatted "<td>" substring(comm.txb.info,3, length(comm.txb.info)) format "X(17)" "&nbsp;" "</td>" skip.

         do i = 1 to num-entries(v-list-crc):
              find first tbl_opokk where tbl_opokk.txb = comm.txb.txb  and tbl_opokk.crc = INTEGER(entry(i,v-list-crc)) no-lock no-error.
              if avail tbl_opokk then do:
                  put stream opokk1  unformatted "<td>" replace(trim(string(tbl_opokk.bal,'>>>>>>>>>>>>>>>9.99')),'.',',') "</td>" skip.
                 end.
              else do:
                  put stream opokk1  unformatted "<td>0</td>" skip.
              end.
         end.
         put stream opokk1  unformatted "</FONT></tr>" skip.

         put unformatted skip.
     end.

     put stream opokk1 unformatted  "</FONT></table>".
     hide frame wfr no-pause.
     find ofc where ofc.ofc = g-ofc no-lock no-error.
     if avail ofc then  put stream opokk1 unformatted "<P align=""left""><B><font size=""2""><BR>Исполнитель: " ofc.name "</font></B></P>" skip.
     {html-end.i}

     output stream opokk1 close.
     /*unix silent cptwin opokk1.html excel.
     unix silent rm -f opokk1.html.*/

     unix silent value ("cptwin opokk.html excel").
     unix silent value ("rm opokk.html").



/*run menu-prt ('opokk.img')*/

/*end.*/

/*run cr_send.*/

