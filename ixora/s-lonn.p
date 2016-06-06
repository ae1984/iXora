/* s-lonn.p
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
        17.03.2004 marinav - запретить удалять счет, если по нему есть уровни (были проводки)
        23.07.2004 tsoy    - если некто поменял документ изменяем Договор на неподписан.
        28.07.2004 tsoy    - убрал проверку на соответвие старых и новых данных в таблице loncon.
        11.08.2004 tsoy    - Статус не подписан устанавливается только при изменении опредленных параметров
        27/04/2005 madiar  - Изменение схемы ипотечных кредитов по ключевому слову
        11/05/2005 madiar  - Изменение схемы кредитов - добавил другие группы кредитов
        25/07/2005 madiar  - Изменение схемы кредитов - добавил группы кредитов юр.лиц
        13/12/2005 madiar  - Изменение схемы кредитов - добавил группы бизнес-кредитов
        30/01/2006 Natalya D. - добавлено поле Депозит
        15/02/2006 marinav  - компиляция
        04/05/06 marinav Увеличить размерность поля суммы
        09/12/2008 galina - убрала паузу перед редактированием нового кредита
        25/03/2009 galina - добавила поле Поручител
        23.04.2009 galina - убираем поле поручитель
        09/06/2010 galina- добавила ставку по штрафам до и после 7 дней просрочки
        23/08/2010 madiyar - ставка по комиссии prem_s
        25/08/2010 madiyar - premsdt
        03/12/2010 madiyar - отображение доступных остатков КЛ в форме
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        21/12/2011 kapar - ТЗ №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        18/06/2012 kapar - новое поле (Дата прекращения дополнительной % ставки)
        20/06/2012 kapar - новое поле (Дата начала дополнительной % ставки)
        11.01.2013 evseev - ТЗ-1530
        25/02/2013 sayat(id01143) - добавлены поля loncon.dtsub - ТЗ 1669 от 28/01/2013 (дата договора субсидирования),
                                                   loncon.obes-pier - ТЗ 1696 04/02/2013 (отвественный по обеспечению),
                                                   loncon.lcntdop и loncon.dtdop - ТЗ 1706 от 07/02/2013 (номер и дата доп.соглашения).
*/

/**/
{mainhead.i}
{lonlev.i}
def var vpy as char format "x(20)" label "DESC".
define shared variable v-cif   like cif.cif.
define shared variable v-vards like cif.name format "x(36)".
define shared variable v-lcnt  like loncon.lcnt.
def new shared var st as inte.

define shared variable s-prem as character.
define shared variable d-prem as character.
define shared variable s-apr as character.
define shared variable s-cat as character.
define shared variable grp-name   as character.
define shared variable cat-des    as character.
define shared variable crc-code   as character.
def shared var s-longrp like longrp.longrp.
def shared var vlcnt like loncon.lcnt.
def shared var xacc like jl.acc.
def shared var xjh like jh.jh.

def shared var v-crc like crc.crc.
def shared var v-rate like crc.rate[1].
def shared var v-komcl as deci.

def new shared var v-edit as logical init false.

define variable v-uno like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.

def var v-diff as logical.

def var v-oldwho as char.
def var v-oldwhn as date.

def temp-table b-loncon like loncon.
def buffer b-cif for cif.
def buffer b-lon for lon.

define shared frame cif.

{sub.i
&option = "LONSUB"
&head = "loncon"
&headkey = "lon"
&framename = "lon"
&formname = "s-lonrdl"
&where = "loncon.lon = s-lon and "
&updatecon = "true"
&deletecon = "true"
&predelete = "find first trxbal where trxbal.sub = 'lon' and trxbal.acc = s-lon no-lock no-error.
              if avail trxbal then undo,retry. run del-lon."
&display = " find lon where lon.lon = s-lon.
 if index(loncon.rez-char[10],'&') = 0 then paraksts = no.
 else if substring(loncon.rez-char[10],index(loncon.rez-char[10],'&') + 1,3) = 'yes' then paraksts = yes. else paraksts = no.
 dam1-cam1 = 0. for each trxbal where trxbal.subled = 'LON' and trxbal.acc = lon.lon no-lock : if lookup(string(trxbal.level),v-lonprnlev,"";"") > 0 then
 dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam). end.
 s-longrp = lon.grp. v-uno = lon.prnmos. s-prem = lon.base + string(lon.prem). d-prem = lon.base + string(lon.dprem). v-deposit = loncon.deposit. /*v-guarantor = trim(loncon.rez-char[8]).*/
 find first lons where lons.lon = lon.lon no-lock no-error. if avail lons then assign prem_s = lons.prem premsdt = lons.rdt. else assign prem_s = 0 premsdt = ?.
 run lonbalcrc('lon',lon.lon,g-today,'15',yes,lon.crc,output cl-voz). cl-voz = - cl-voz. run lonbalcrc('lon',lon.lon,g-today,'35',yes,lon.crc,output cl-nevoz). cl-nevoz = - cl-nevoz.
 assign clcif = '' clname = ''.
 find first b-lon where b-lon.lon = lon.clmain no-lock no-error.
 if avail b-lon then do:
  find first b-cif where b-cif.cif = b-lon.cif no-lock no-error.
  if avail b-cif then assign clcif = b-cif.cif clname = b-cif.name.
 end.
 display v-cif v-lcnt loncon.lon s-longrp v-uno lon.crc crc-code lon.trtype lon.gua loncon.lcntsub loncon.dtsub loncon.lcntdop loncon.dtdop lon.clmain clcif clname loncon.objekts lon.rdt lon.duedt lon.duedt15 lon.duedt35
 lon.opnamt dam1-cam1 cl-voz cl-nevoz s-prem d-prem lon.rdate lon.ddate lon.ddt[5] loncon.proc-no lon.cdt[5] loncon.sods1 lon.penprem lon.penprem7 prem_s premsdt
 lon.idt15 lon.idt35 paraksts loncon.vad-amats loncon.rez-char[9] loncon.vad-vards
 loncon.galv-gram /** loncon.kods loncon.konts loncon.talr **/ lon.basedy
 lon.aaa lon.aaad v-deposit lon.day lon.plan loncon.who loncon.pase-pier loncon.obes-pier v-crc v-rate v-komcl /*v-guarantor*/
 with frame lon. color
 display input dam1-cam1 with frame lon.
 display v-vards with frame cif."
&preupdate = "
                v-edit = false.
                hide all no-pause.
                run s-lonrd.
"
&postupdate = "
                 if index(loncon.rez-char[10],'&') > 0 and v-edit then do:
                      loncon.rez-char[10] = substring(loncon.rez-char[10],1,index(loncon.rez-char[10],'&')) + 'no'.
                      message 'Внимание документу установлен статус ""Не подписан""' skip  'Обратитесь в департамент авторизации' view-as alert-box.
                 end.
"
&prerun = "s-lon = loncon.lon."
&postrun = "view frame mainhead."
&end = "run put-shis('lnsch'). run put-shis('lnsci')."
&mykey = "f"
&myproc = "if length(v-keybuffer) >= 8 then
           if substring(v-keybuffer,length(v-keybuffer) - 7,8) = 'bpvc[tvf' then do:
              find lon where lon.lon = s-lon no-lock no-error.
              if (lookup(string(lon.grp),'16,20,25,26,27,56,60,65,66,67,10,15,50,55') > 0) and (lon.plan = 1 or lon.plan = 2) then do:
                def var old_sch as integer. def var new_sch as integer.
                old_sch = lon.plan.
                if old_sch = 1 then new_sch = 2.
                else new_sch = 1.
                message 'Изменить схему кредита с ' + string(old_sch) + ' на ' + string(new_sch) + '?'
                  view-as alert-box question buttons yes-no title '' update choice as logical.
                if choice then do:
                  find current lon exclusive-lock.
                  lon.plan = new_sch.
                  find current lon no-lock.
                  display lon.plan with frame lon.
                end.
                v-keybuffer = ''.
              end.
           end."
}
