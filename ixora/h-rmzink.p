/* h-rmzink.p
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
        03.08.2005 dpuchkov
 * CHANGES
        03.09.2013 evseev - tz-1817
*/


{global.i}
{lgps.i }

def shared var s-remtrzink like que.remtrz .


def var i_num as int .
def var h as int .
def var v-ofc like ofc.ofc.
def var choice as integer format '9' init 1.
def temp-table w-remtrz
    field  remtrz  like que.remtrz
    field  ref     like remtrz.ref
    field  payment like remtrz.payment
    field  name    like cif.name
    field  crc     like remtrz.tcrc
    field  source  like remtrz.source
    field  ptype   like remtrz.ptype
    field  rdt     like remtrz.rdt
    field  valdt1  like remtrz.valdt1
    field  valdt2  like remtrz.valdt2
    field  sbank   like remtrz.sbank
    field  rbank   like remtrz.rbank
    field  pid     like que.pid
    field  con     like que.con
    field  who     like g-ofc
    field  urgency as char
    field  vkc     as char
    field  vwho    as char
    field  vwhn    as date
    field  dkc     as char
    field  dwho    as char
    field  dwhn    as date.


h = 12 .
v-ofc = userid('bank').

message
  "1)ИР ПО МЕНЕДЖЕРУ     2)ВCЕ ПЛАТЕЖИ ИР "

    update choice.
       find first que where que.pid = 'INK'
                        and que.con <> 'F'
                        and  (can-find(remtrz
                        where remtrz.remtrz = que.remtrz /*and (remtrz.source  = 'IBH')*/ ))   use-index fprc  no-lock no-error.
       if avail que then do.
          for each que where que.pid = 'INK' and que.con <> 'F' use-index fprc no-lock.

              find remtrz where remtrz.remtrz = que.remtrz /* and remtrz.source  = 'IBH' */ no-lock no-error.
              if not avail remtrz then next.
              find aaa where aaa.aaa = remtrz.dracc no-lock no-error.
              if not avail aaa then do:
                 find first aaar where aaar.a1 = remtrz.remtrz no-lock no-error.
                 find aaa where aaa.aaa = aaar.a5 no-lock no-error.
              end.

              find cif where cif.cif = aaa.cif no-lock no-error.

              if (choice = 1 and remtrz.tcrc = 1 and (substr(cif.fname,1,8)) = v-ofc) or
                 (choice = 2 and remtrz.tcrc = 1) then do.
                  create w-remtrz.
                  w-remtrz.remtrz  =  que.remtrz.
                  w-remtrz.ref     =  remtrz.ref.
                  w-remtrz.name    =  trim (cif.prefix + " " + trim(cif.name)).
                  w-remtrz.payment =  remtrz.payment.
                  w-remtrz.crc     =  remtrz.tcrc.
                  w-remtrz.source  =  remtrz.source.
                  w-remtrz.ptype   =  remtrz.ptype.
                  w-remtrz.rdt     =  remtrz.rdt.
                  w-remtrz.valdt1  =  remtrz.valdt1.
                  w-remtrz.valdt2  =  remtrz.valdt2.
                  w-remtrz.sbank   =  remtrz.sbank.
                  w-remtrz.rbank   =  remtrz.rbank .
                  w-remtrz.who     =  cif.fname.
                  w-remtrz.pid     =  que.pid.
                  w-remtrz.con     =  que.con.

/*                find ib.doc where ib.doc.remtrz =  w-remtrz.remtrz no-lock no-error.
                  if avail ib.doc and ib.doc.urgency = "U"  then do:
                      w-remtrz.urgency = "*".
                  end. */

                  /* Проставление признаков контроля Валютного и Кредитного Админ. департаментов */
                  find vkdkcon where vkdkcon.remtrz = w-remtrz.remtrz no-lock no-error.
                  if avail vkdkcon then do:
                     if vkdkcon.vk = "vk" then w-remtrz.vkc = "*".
                                          else w-remtrz.vkc = "".
                     if vkdkcon.dk = "dk" then w-remtrz.dkc = "*".
                                          else w-remtrz.dkc = "".
                  end.
              end.
          end.
       end.

if i_num <> 0 then do:
   message "Ограничение на просмотр "  i_num  " платежей"  view-as alert-box buttons OK .
end.

/*v-mes = 'F1 - Признак Вал.контроля. F2 - Признак контроля Кред.Админ.'.*/

     {browpnp.i
      &h = "h"
      &where = "w-remtrz.source eq 'INK' "
      &frame-phrase = "row 1 centered scroll 1 h down title 'F1 - Признак Вал.контроля. F2 - Признак контроля Кред.Админ.'"
      &predisp =  " display
                    w-remtrz.source column-label ""Источник""
                    w-remtrz.ptype  column-label ""Тип""
                    w-remtrz.rdt    column-label ""Рег.дата""
                    w-remtrz.valdt1 column-label ""1Дата""
                    w-remtrz.valdt2 column-label ""2Дата""
                    w-remtrz.sbank  column-label ""БанкО""
                    w-remtrz.rbank  column-label ""БанкП""
                    with row 17.
                    pause 0.
                    display
                    w-remtrz.pid column-label ""Код""
                    w-remtrz.con column-label ""Сост.""
                    with centered row 17.
                    pause 0."
      &seldisp = " w-remtrz.remtrz "
      &file = " w-remtrz "
      &disp = "  w-remtrz.vkc column-label ""ВК"" format 'x(1)'
                 w-remtrz.dkc column-label ""ДК"" format 'x(1)'
                 w-remtrz.urgency column-label ""П"" format 'x(1)'
                 w-remtrz.remtrz  column-label ""Платеж""
                 w-remtrz.name column-label ""Клиент"" format 'x(25)'
                 w-remtrz.payment column-label ""СуммаК"" format 'zzz,zzz,zzz,zz9.99-'
                 w-remtrz.crc column-label ""Вал""
                 w-remtrz.who column-label ""Менеджер""              "

      &addupd = " w-remtrz.remtrz "
      &upd    = "  "
      &addcon = " false "
      &updcon = " false "
      &delcon = " false "
      &retcon = " true "
      &enderr = " hide all.  "
      &befret = " s-remtrzink = w-remtrz.remtrz .
                  frame-value = w-remtrz.remtrz .
                  hide all. "
      &action = " if keyfunction(lastkey) = 'GO' then do:
                     find sysc where sysc.sysc = 'vkcon' no-lock no-error.
                     if avail sysc then do:
                     if lookup(g-ofc,sysc.chval) > 0 then do:
                        run vk_pro(w-remtrz.remtrz).
                        if w-remtrz.vkc = '*' then w-remtrz.vkc = ''.
                        else w-remtrz.vkc = '*'.
                        displ w-remtrz.vkc with frame frm.
                     end.
                     else message 'У Вас нет прав Валютного контроля! ' view-as alert-box warning buttons ok.
                     end.
                     else message 'Нет возможности Валютного контроля! ' view-as alert-box warning buttons ok.
                  end.
                  else if keyfunction(lastkey) = 'HELP' then do:
                     find sysc where sysc.sysc = 'dkcon' no-lock no-error.
                     if avail sysc then do:
                     if lookup(g-ofc,sysc.chval) > 0 then do:
                        run dk_pro(w-remtrz.remtrz).
                        if w-remtrz.dkc = '*' then w-remtrz.dkc = ''.
                        else w-remtrz.dkc = '*'.
                        displ w-remtrz.dkc with frame frm.
                     end.
                     else message 'У Вас нет прав контроля Кредитного Администрирования! ' view-as alert-box warning buttons ok.
                     end.
                     else message 'Нет возможности контроля Кредитного Администрирования! 'view-as alert-box warning buttons ok.
                  end. "
     }

/* 30.09.2004 saltanat - Процедура проставления признака Валютного контроля */
procedure vk_pro.
def input parameter p-remtrz like remtrz.remtrz.

find vkdkcon where vkdkcon.remtrz = p-remtrz no-lock no-error.
if avail vkdkcon then do:
   find current vkdkcon exclusive-lock.
   if vkdkcon.vk = 'vk' then do:
   vkdkcon.vk     = ''.
   vkdkcon.vwho   = g-ofc.
   vkdkcon.vwhn   = g-today.
   end.
   else do:
   vkdkcon.vk     = 'vk'.
   vkdkcon.vwho   = g-ofc.
   vkdkcon.vwhn   = g-today.
   end.
   find current vkdkcon no-lock.
end.
else do:
    create vkdkcon.
    assign vkdkcon.remtrz = p-remtrz
           vkdkcon.vk     = 'vk'
           vkdkcon.vwho   = g-ofc
           vkdkcon.vwhn   = g-today.
end.

end procedure.

/* 30.09.2004 saltanat - Процедура проставления признака Кредитного Администрирования контроля */
procedure dk_pro.
def input parameter p-remtrz like remtrz.remtrz.

find vkdkcon where vkdkcon.remtrz = p-remtrz no-lock no-error.
if avail vkdkcon then do:
   find current vkdkcon exclusive-lock.
   if vkdkcon.dk = 'dk' then do:
   vkdkcon.dk     = ''.
   vkdkcon.dwho   = g-ofc.
   vkdkcon.dwhn   = g-today.
   end.
   else do:
   vkdkcon.dk     = 'dk'.
   vkdkcon.dwho   = g-ofc.
   vkdkcon.dwhn   = g-today.
   end.
   find current vkdkcon no-lock.
end.
else do:
    create vkdkcon.
    assign vkdkcon.remtrz = p-remtrz
           vkdkcon.dk     = 'dk'
           vkdkcon.dwho   = g-ofc
           vkdkcon.dwhn   = g-today.
end.

end procedure.


















