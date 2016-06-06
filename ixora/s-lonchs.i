/* s-lonchs.i
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
        02/02/04 nataly добавлен признак валюты индекс v-crc, курс по контракту v-rate, признак индекс кредита lnindex
        25.02.2004 marinav - введено поле для комиссии за неиспольз кредитную линию v-komcl
        30/05/2005 madiar - убрал лишние exclusive-lock'и на loncon
        30/01/2006 Natalya D. - добавлено поле Депозит
        25/03/2009 galina - добавила поле Поручитель
        23.04.2009 galina - убираем поле поручитель
        09/06/2010 galina - добавила ставку по штрафам до и после 7 дней просрочки
        23/08/2010 madiyar - ставка по комиссии prem_s
        24/08/2010 madiyar - premsdt
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        08/11/2011 madiyar - доп. поля в списке кредитов, оптимизировал выборку
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        11.01.2013 evseev - тз-1530
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
*/

s-longrp = lon.grp.
grp-name = "".
crc-code = "".
cat-des = "".
s-prem = lon.base + string(lon.prem).
d-prem = lon.base + string(lon.dprem).
if lon.grp > 0
then do:
     find longrp where longrp.longrp = lon.grp no-lock.
     grp-name = " " + longrp.des.
end.
if lon.crc > 0
then do:
     find crc where crc.crc = lon.crc no-lock.
     crc-code = string(crc.code,"xxxx").
end.
if lon.loncat > 0
then do:
     find loncat where loncat.loncat = lon.loncat no-lock.
     cat-des = " " + loncat.des.
     find lonhar where lonhar.lon = lon.lon and lonhar.ln = 1 exclusive-lock no-error.
     if not available lonhar then do:
          create lonhar.
          assign
          lonhar.lon = lon.lon
          lonhar.cif = lon.cif
          lonhar.ln = 1
          lonhar.fdt = date(1,1,1)
          lonhar.who = userid("bank")
          lonhar.whn = g-today
          lonhar.lonstat = 1.
     end.
     if lonhar.rez-int[3] > 0 then s-cat = string(lonhar.rez-int[3]).
     else do:
          s-cat = string(100 * lon.loncat + 1).
          lonhar.rez-int[3] = 100 * lon.loncat + 1.
     end.

     if s-cat = "59101" then s-cat = "50101".
     else if s-cat = "59102" then s-cat = "50201".
     else if s-cat = "59103" then s-cat = "50401".
     else if s-cat >= "69101" and s-cat <= "69199" then s-cat = "6" + substring(s-cat,4,2) + "01".

     find loncat where loncat.loncat = lonhar.rez-int[3] no-lock no-error.
     if not available loncat
     then do:
          find first loncat where loncat.loncat > lonhar.rez-int[3] no-lock no-error.
          lonhar.rez-int[3] = loncat.loncat.
          s-cat = string(loncat.loncat).
     end.
     s-apr = loncat.des.
     crc-code = crc-code + s-apr.
     release lonhar.
end.

run lonbalcrc('lon',lon.lon,g-today,"1,7",yes,lon.crc,output dam1-cam1).

/*
if lon.idt15 = ? then lon.idt15 = lon.rdt + 3.
if lon.idt35 = ? then lon.idt35 = lon.rdt + 3.
*/

if index(loncon.rez-char[10],"&") > 0 or lon.opnamt > 0 and lon.opnamt - lon.dam[1] <= 0 then do:
     if index(loncon.rez-char[10],"&") > 0
     then do:
          if substring(loncon.rez-char[10], index(loncon.rez-char[10],"&") + 1,3) = "yes"
          then paraksts = yes.
          else paraksts = no.
     end.
     else do:
          paraksts = yes.
          find current loncon exclusive-lock.
          loncon.rez-char[10] = "&yes&".
          find current loncon no-lock.
     end.
end.
else paraksts = no.

v-uno = lon.prnmos.
v-deposit = loncon.deposit.

find first lons where lons.lon = lon.lon no-lock no-error.
if avail lons then assign prem_s = lons.prem premsdt = lons.rdt. else assign prem_s = 0 premsdt = ?.

assign clcif = '' clname = ''.
find first b-lon where b-lon.lon = lon.clmain no-lock no-error.
if avail b-lon then do:
 find first b-cif where b-cif.cif = b-lon.cif no-lock no-error.
 if avail b-cif then assign clcif = b-cif.cif clname = b-cif.name.
end.

run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz).
cl-voz = - cl-voz.
run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz).
cl-nevoz = - cl-nevoz.

display /* v-vards */
        v-cif
        v-lcnt
        loncon.lon
        s-longrp
        v-uno
        lon.crc
        crc-code
        lon.trtype
        lon.gua
        loncon.lcntsub
        loncon.dtsub
        loncon.lcntdop
        loncon.dtdop
        lon.clmain
        clcif
        clname
        loncon.objekts
        lon.rdt
        lon.duedt
        lon.duedt15
        lon.duedt35
        lon.opnamt
        dam1-cam1
        cl-voz
        cl-nevoz
        s-prem
        d-prem
/**        lon.lcr **/
        loncon.proc-no
        lon.penprem
        lon.penprem7
        prem_s
        premsdt
        loncon.sods1
        lon.idt15
        lon.idt35
        paraksts
        loncon.vad-amats
        loncon.vad-vards
        loncon.galv-gram
        loncon.rez-char[9]
/**        loncon.kods
        loncon.konts
        loncon.talr **/
        lon.basedy
       /* v-crc
        v-rate*/
        lon.plan lon.day lon.aaa lon.aaad v-deposit
        loncon.who
        loncon.pase-pier
        loncon.obes-pier
        /*v-guarantor*/
        with frame lon.
        color display input dam1-cam1 with frame lon.

       /*31/01/04 nataly*/
       find lonhar where lonhar.lon = s-lon and lonhar.ln = 1 no-lock no-error.
       if avail lonhar then do:
        v-crc = lonhar.rez-int[1].
        v-rate = lonhar.rez-dec[1].
        v-komcl = lonhar.rez-dec[2].
       end .
        else  do:
          v-crc = 0.
          v-rate = 0.
          v-komcl = 0.
        end.
       display v-komcl v-crc v-rate with frame lon.

        display v-vards with frame cif.
