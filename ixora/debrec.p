/* debrec.p
 * MODULE
        Дебиторы
 * DESCRIPTION
        отчет акт сверки
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
 * BASES
        BANK
 * AUTHOR
        12/06/2013 Luiza ТЗ 1801 создан по примеру debhist.p
 * CHANGES
*/


{debls.f}

def shared var g-today as date.
def var vlen as int  init 116.
def var slen as char init "116".

def var grpcam as decimal init 0.0.
def var grpdam as decimal init 0.0.

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
         index idx_wjh grp ls jh.

def temp-table wrk1
         field grp   like debls.grp          label "GRP"
         field ls    like debls.ls           label "NN"
         field ost   like debhis.ost         label "Остаток"
         field cam   as   decimal
         field dam   as   decimal
         field type  like debhis.type        label "Тип"
         field date  like debhis.date        label "Дата"
         field rem   as   char               label "ПРИМЕЧАНИЕ"
         field ctime like debhis.ctime       label "Время"
         field arp   like debgrp.arp
         field jh    like debhis.jh          label "Проводка"
         field gl    as char format "x(6)"
         field ind   as int.

def temp-table wost
         field grp    like debhis.grp
         field ls     like debhis.ls
         field ost    like debhis.ost.


hide all.

def var oldjh like debhis.jh.
def var numlin as int.
def var jllin as int.
def var damcam as char.
def var i as int.
def var xx as int.
def var fname as char.
def var begost as decim init 0.

oldjh = 0.
numlin = 0.
xx = 0.


update v-grp with frame get-grp-all.
find first debgrp where debgrp.grp = v-grp no-lock no-error.
if v-grp = 0 then do:
   message "Группа не найдена!" view-as alert-box.
   undo.
end.
displ debgrp.des @ v-grp-des with frame get-grp-all.
pause 0.

update v-ls with frame get-grp-all.
find first debls where debls.grp = v-grp and debls.ls = v-ls no-lock no-error.
if v-ls = 0 then do:
   message "Дебитор не найден!" view-as alert-box.
   undo.
end.
fname = debls.name.
displ debls.name @ v-ls-des with frame get-grp-all.
pause 0.

v-d1 = g-today.
v-d2 = g-today.

update v-d1 v-d2 with frame get-dates.
hide frame get-dates.
hide frame get-grp-all.

/* сформируем  остатки */
   create wrkgrp.
   assign wrkgrp.grp = debls.grp
          wrkgrp.ls = debls.ls
          wrkgrp.arp = debgrp.arp.

find first wrkgrp.
run debost-get.p (wrkgrp.grp, wrkgrp.ls, wrkgrp.arp, v-d1).

find first wrk no-lock no-error.
if available wrk then begost = wrk.ost.
else begost = 0.

for each debhis where debhis.date >= v-d1 and debhis.date <= v-d2 no-lock:

    xx = xx + 1.
    create wrk1.
    find first debgrp where debgrp.grp = debhis.grp no-lock.
    assign wrk1.grp = debhis.grp
           wrk1.ls = debhis.ls
           wrk1.ost = debhis.ost
           wrk1.date = debhis.date
           wrk1.ctime = debhis.ctime
           wrk1.rem = trim (debhis.rem[1]) + trim (debhis.rem[2]) + trim (debhis.rem[3])
           wrk1.arp = debgrp.arp
           wrk1.jh = debhis.jh
           wrk1.gl = "      "
           wrk1.ind = xx.

    if debhis.jh <> 0 and debhis.type >= 3 then do: /* списание или закрытие */

    /* найдем первое вхождение счета в проводку */
    find first jl where jl.jh = debhis.jh and jl.acc = debgrp.arp no-lock no-error.

    if oldjh <> debhis.jh then do: oldjh = debhis.jh. numlin = 0. end.
                          else numlin = numlin + 1.

    /* найдем линию проводки : numlin = сколько есть еще линий кроме первой */
    do i = 1 to numlin:
       find next jl where jl.jh = debhis.jh and jl.acc = debgrp.arp no-lock no-error.
    end.

    if avail jl then
    do:

       if jl.dc = "D" then damcam = "C".
                      else damcam = "D".

       if jl.ln mod 2 = 1 then jllin = jl.ln + 1.
                          else jllin = jl.ln - 1.
       find jl where jl.jh = debhis.jh and jl.dc = damcam and jl.ln = jllin no-lock no-error.
       if avail jl then wrk1.gl = string(jl.gl).

    end.

    end. /* списание */

    if debhis.type < 3 then do: wrk1.dam = 0.          wrk1.cam = debhis.amt. end.
                       else do: wrk1.dam = debhis.amt. wrk1.cam = 0.          end.

end.


if v-grp <> 0 then
for each wrk1 where wrk1.grp <> v-grp:
    delete wrk1.
end.

if v-ls <> 0 then
for each wrk1 where wrk1.ls <> v-ls:
    delete wrk1.
end.

for each wrk1:
   if wrk1.jh <> 0 and wrk1.jh <> ? then wrk1.rem = "(" + trim(string(wrk1.jh)) + ") " + wrk1.rem.
end.

if not can-find (first wrk1) then do:
   message "За указанный период данных нет!" view-as alert-box.
   return.
end.

def stream r-out.
    output stream r-out to fin.htm.
    put stream r-out unformatted "<html><head><title></title>"
                     "<META HTTP-EQUIV=""Content-Type"" content=""text/html; charset=windows-1251"">"
                     "<META HTTP-EQUIV=""Content-Language"" content=""ru""></head><body>" skip.
    put stream r-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""style=""font:bold;font-size:20"" >".
    put stream r-out unformatted '<tr><td colspan=2>  АО "ForteBank" </td></tr>' skip.
    put stream r-out unformatted '<tr><td >   </td></tr>' skip.
    put stream r-out unformatted "<tr><td colspan=7 align=""center"">  Акт сверки за период с " string(v-d1) " по " string(v-d2) "</td></tr>" skip.
    put stream r-out unformatted '<tr><td >   </td></tr>' skip.
    put stream r-out unformatted "</table>" skip.
    put stream r-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""style=""font-size:16"" >".
    put stream r-out unformatted "<tr> <td colspan=8>  Мы, нижеподписавшиеся </td> </tr>" skip.
    put stream r-out unformatted '<tr> <td colspan=8> АО "ForteBank" в лице Главного Бухгалтера Оспановой Г.А. с одной стороны и ' + fname  + ' в лице________________________  </td> </tr>' skip.
    put stream r-out unformatted '<tr> <td colspan=8> ИИН______________, с другой стороны, составили настоящий акт о том, что сего числа произвели сверку взаимных расчетов по  </td> </tr>' skip.
    put stream r-out unformatted '<tr> <td colspan=8> состоянию на ' + string(g-today) + 'г.,  причем в результате сверки выявлены расхождения, которые следует допровести:  </td> </tr> ' skip.
    put stream r-out unformatted "</table>" skip.
    put stream r-out unformatted "<br> <br>" skip.

    put stream r-out unformatted "<table border=""1"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""style=""font-size:15"">"
      "<tr>"
      "<td rowspan=2 align=""center"" valign=""center""> &nbsp &nbsp &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
       Текст записи &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp
       &nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp </td>"
      "<td colspan=2 align=""center"" valign=""center""> АО ForteBank </td>"
      "<td colspan=2 align=""center"" valign=""center"">" fname "</td> </tr>"
      "<tr> <td align=""center"" valign=""botton"">&nbsp&nbsp&nbsp&nbsp Дебет &nbsp&nbsp&nbsp&nbsp</td>"
      "<td align=""center"" valign=""botton"">&nbsp&nbsp&nbsp&nbsp Кредит &nbsp&nbsp&nbsp&nbsp</td>"
      "<td align=""center"" valign=""botton"">&nbsp&nbsp&nbsp&nbsp Дебет &nbsp&nbsp&nbsp&nbsp</td>"
      "<td align=""center"" valign=""botton"">&nbsp&nbsp&nbsp&nbsp Кредит &nbsp&nbsp&nbsp&nbsp</td>"
      "</tr>" skip.
      put stream r-out unformatted "<tr>"
      "<td align=""center""> 1 </td>"
      "<td align=""center""> 2 </td>"
      "<td align=""center""> 3 </td>"
      "<td align=""center""> 4 </td>"
      "<td align=""center""> 5 </td>"
      "</tr>" skip.

      put stream r-out unformatted "<tr style=""font:bold""> <td> Сальдо на начало "   "</td>" .
      if begost <> 0 then put stream r-out unformatted "<td>" replace(trim(string(begost,'->>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>"  "</td>".
      put stream r-out unformatted "<td> </td>"
      "<td> </td>".
      if begost <> 0 then put stream r-out unformatted "<td>" replace(trim(string(begost,'->>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>"  "</td>".
      put stream r-out unformatted "</tr>" skip.

      for each wrk1  no-lock.
          put stream r-out unformatted
          "<tr>"
          "<td>" wrk1.rem "</td>"
          "<td>" replace(trim(string(wrk1.cam,'->>>>>>>>>>>9.99')),'.',',') "</td>"
          "<td>" replace(trim(string(wrk1.dam,'->>>>>>>>>>>9.99')),'.',',') "</td>"
          "<td>" replace(trim(string(wrk1.dam,'->>>>>>>>>>>9.99')),'.',',') "</td>"
          "<td>" replace(trim(string(wrk1.cam,'->>>>>>>>>>>9.99')),'.',',') "</td>"
          "</tr>" skip.
          grpcam = grpcam + wrk1.cam.
          grpdam = grpdam + wrk1.dam.
      end.
      put stream r-out unformatted "<tr style=""font:bold""> <td> Итого оборотов </td> " skip.
      if grpcam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpcam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpdam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpdam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpdam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpdam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpcam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpcam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      put stream r-out unformatted "</tr>" skip.

      put stream r-out unformatted "<tr style=""font:bold""> <td> Сальдо на конец "   "</td>".
      if grpcam - grpdam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpcam - grpdam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpcam - grpdam < 0 then put stream r-out unformatted "<td>" replace(trim(string(grpdam - grpcam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpcam - grpdam < 0 then put stream r-out unformatted "<td>" replace(trim(string(grpdam - grpcam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      if grpcam - grpdam > 0 then put stream r-out unformatted "<td>" replace(trim(string(grpcam - grpdam,'>>>>>>>>>>>9.99')),'.',',') "</td>".
      else put stream r-out unformatted "<td>" "</td>".
      put stream r-out unformatted "</tr>" skip.
    put stream r-out unformatted "</table>" skip.


    put stream r-out unformatted "<table border=""0"" cellpadding=""10"" cellspacing=""0"" style=""border-collapse: collapse""style=""font-size:14"">"
    "<tr>"
    "</tr>"
    "<tr>"
    "</tr>"
    "<tr>"
    '<td colspan=2> АО "ForteBank" </td>'
    '<td >  </td>'
    '<td colspan=2>' fname '</td>'
    "</tr>"
    "<tr>"
    "</tr>"
    "<tr>"
    '<td colspan=2> Гл.бухгалтер______________/Оспанова Г.А. </td>'
    '<td >  </td>'
    '<td colspan=3> Гл.бухгалтер_____________/_____________/ </td>'
    "</tr>"
    "<tr>"
    "</tr>"
    '<td colspan=2> Исполнитель _____________/_____________/ </td>'
    '<td >  </td>'
    '<td colspan=3> Исполнитель _____________/_____________/ </td>'
    "</tr>"
    "</table>" skip.



    output stream r-out close.

    unix silent cptwin fin.htm excel.
