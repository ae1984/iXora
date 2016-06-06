/* lnguaran.p
 * MODULE
        Кредиты
 * DESCRIPTION
        Ввод и редактирование поручителя
 * RUN
        Способ вызова программы, описание параметров, примеры вызова
 * CALLER
        Список процедур, вызывающих этот файл
 * SCRIPT
        Список скриптов, вызывающих этот файл
 * INHERIT
        Список вызываемых процедур
 * MENU
        Пункт меню
 * AUTHOR
        25/03/2009 galina
 * BASES
        BANK
 * CHANGES
        06.05.2009 galina - добавила определение переменной v-guarantor
        31/08/2010 madiyar - перекомпиляция из-за изменения формы s-lonrdl.f
        26/01/2011 madiyar - lon.idtXX, lon.duedtXX
        30/12/2011 kapar - ТЗ  №1122
        17/05/2012 kapar - ТЗ ДАМУ
        11/06/2012 kapar - ТЗ ASTANA-BONUS
        18/06/2012 kapar - новое поле (Дата прекращения дополнительной % ставки)
        20/06/2012 kapar - новое поле (Дата начала дополнительной % ставки)
*/


{lonlev.i}

def shared var g-today as date.

def shared var s-lon like lon.lon.
define shared variable v-cif      like cif.cif init "".
define shared variable v-lcnt     like loncon.lcnt init "".
def shared var s-longrp like longrp.longrp.
define variable v-uno like uno.uno.
define variable clcif  like cif.cif.
define variable clname like cif.name.
define shared variable crc-code   as character init "".
define shared variable s-prem     as character.
define shared variable d-prem     as character.
def shared var v-crc like crc.crc.
def shared var v-rate like crc.rate[1].
def shared var v-komcl as deci.
define shared variable v-vards    like cif.name format "x(36)" init "".

/*galina времено чтобы перекомпилить*/
def var v-guarantor as char.
/**/
{s-lonrdl.f}
find first loncon where loncon.lon = s-lon no-lock.
v-guarantor = trim(loncon.rez-char[8]).
/*---------------*/
find lon where lon.lon = s-lon.
if index(loncon.rez-char[10],'&') = 0 then paraksts = no.
else do:
  if substring(loncon.rez-char[10],index(loncon.rez-char[10],'&') + 1,3) = 'yes' then paraksts = yes.
  else paraksts = no.
end.
dam1-cam1 = 0.
for each trxbal where trxbal.subled = 'LON' and trxbal.acc = lon.lon no-lock:
  if lookup(string(trxbal.level),v-lonprnlev,";") > 0 then dam1-cam1 = dam1-cam1 + (trxbal.dam - trxbal.cam).
end.
s-longrp = lon.grp.
v-uno = lon.prnmos.
s-prem = lon.base + string(lon.prem).
d-prem = lon.base + string(lon.dprem).
v-deposit = loncon.deposit.
display v-cif v-lcnt loncon.lon s-longrp v-uno lon.crc crc-code lon.gua loncon.objekts
lon.rdt lon.duedt lon.opnamt dam1-cam1 s-prem d-prem loncon.proc-no lon.rdate lon.ddate lon.ddt[5] lon.cdt[5] loncon.sods1
lon.idt15 paraksts loncon.vad-amats loncon.vad-vards loncon.galv-gram
lon.aaa lon.aaad v-deposit lon.day lon.plan lon.basedy loncon.who loncon.pase-pier
v-crc v-rate v-komcl v-guarantor with frame lon. display v-vards with frame cif.
/*------------------*/
update v-guarantor with frame lon.
find current loncon exclusive-lock.
loncon.rez-char[8] = v-guarantor.
find current loncon no-lock.
