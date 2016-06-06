/* 2ltrxa.p
 * MODULE
        Платежная система
 * DESCRIPTION
        противовес к 2ltrx.p (автоматическая проводка для vcon`a)
        !!! процедура - только для тенговых проводок на vcon`e !!!
        генерация 2-ой проводки для входящих переводов
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
        ....       sasco
 * CHANGES
        13.12.2001 sasco    - описание проводки берется из remtrz (вместо "... 2L ручная проводка ...")
                            - автоматическое зачисление на счет из remtrz.racc, если полочка = VCON
        28.09.2002 sasco    - отправка реестров для KMobile
        16.09.2003 nadejda  - создание проводки вынесено в 2ltrx.i
        07.03.2004 sasco поменял все WORKFILE и WORK-TABLE на TEMP-TABLE
        19.03.2004 isaev    - автом. пополнение карт.счетов с филиалов
        28.03.2013 evseev - tz1633
*/

{global.i}

{comm-txb.i}
def var v-dt as date format "99/99/99" no-undo.
def var seltown as char.
seltown = comm-txb().

def new shared var s-jh like jh.jh .
def shared var s-remtrz like remtrz.remtrz .
def var ourbank as cha .
def var vdel as cha initial "^" .
def var vparam as cha .
def var shcode as cha .
def var rcode   as int .
def var rdes   as cha .
def var v-text1 as character init '' .
def var v-arp as char.
def var v-cif as char.

def temp-table temp1
    field   crc  like crc.crc
    field   acc  like aaa.aaa.
{lgps.i}

find first remtrz where remtrz.remtrz = s-remtrz no-lock .
if remtrz.jh1 eq ? then do:
 message " 1 проводка еще не сделана ! " . pause .
 return .
end.

if remtrz.info[10] eq "" then do:
 message " Поле info[10] (счет ГК по Дт) в таблице remtrz не заполнено ! " .    pause .
 return .
end.

find sysc where sysc.sysc = "ourbnk" no-lock no-error .
if not avail sysc or sysc.chval = "" then do:
   display " Записи OURBNK нет в таблице sysc!".
   pause .
   undo .
   return .
end.
ourbank = sysc.chval.

if remtrz.rbank ne ourbank  then do:
 message "  Банк-получатель не " + ourbank + "! " .  pause .
 bell . bell .
 return .
end.

if remtrz.info[10] ne "" then do:
   find first jl where jl.jh = remtrz.jh1
                   and jl.gl = integer(remtrz.info[10])
                   no-lock no-error .
   if not avail jl then do:
      message " Значение поля info[10] в таблице remtrz "
      "не совпадает со счетом ГК в 1 проводке (таблица jl поле gl)! " .
      pause  .
      return .
   end .
end .

if remtrz.jh2 ne ? and remtrz.jh2 ne 0 then do:
   message " 2 проводка уже сделана !" . pause .
   return .
end.

do on error undo, retry :
  if remtrz.rsub = 'vcon' then do.
     find aaa where aaa.aaa  = remtrz.racc no-lock no-error .
     if not avail aaa or aaa.crc ne remtrz.tcrc then do :
        Message "Счет не найден "
                "или валюта счета и платежа не совпадают".
                 pause. undo, retry.
     end.
     else undo, retry.
   end.
end.


if keyfunction(lastkey) ne "end-error"
then do trans :
   find first remtrz where remtrz.remtrz = s-remtrz exclusive-lock no-error.
   find first que of remtrz exclusive-lock no-error.

   v-arp = remtrz.racc.
   v-cif = "cif".

   def var my-name as char init "2ltrxa.p".
   {2ltrx.i " remtrz.rsub = 'cif'. " "  " }

end .

